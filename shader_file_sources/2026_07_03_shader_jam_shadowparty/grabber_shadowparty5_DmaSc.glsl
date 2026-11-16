#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define fft(f) texture(texFFTSmoothed, f).x
const float PI = acos(-1.);
float time = fGlobalTime;
float counter = 0;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdSphere( vec3 p, float r )
{
    return length(p) - r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdScene(vec3 p, float sSize) {
  float sphere = sdSphere(p, .5+(sSize/5));
  float box = sdBox(p/2, p*3);
  float torus = sdTorus(p, vec2(1, .1+(sSize/10)));
  //return max(torus, -box);
  return torus;
}

mat2 rotation(float angle) {
  float s = sin(angle), c = cos(angle);
  return mat2(c, -s, s, c);
}

vec3 normal(vec3 p, float weird, float sSize) {
  vec2 e = .01 * vec2(weird,-.5);
#define q(s) s * sdScene(s + p, sSize)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

// Rotation matrix around the X axis.
mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

// Rotation matrix around the Y axis.
mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

// Rotation matrix around the Z axis.
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

// Identity matrix.
mat3 identity() {
    return mat3(
        vec3(1, 0, 0),
        vec3(0, 1, 0),
        vec3(0, 0, 1)
    );
}

void main(void)
{
  counter +=1;
  if (counter > 10) {
    counter = 0;    
  }
  float sinT = sin(time);
  float cosT = cos(time);
  float cossinT = cos(sin(time));
  
  vec2 uv;
  
  uv = (gl_FragCoord.xy / v2Resolution.xy) - .5;
  uv.x *= v2Resolution.x/v2Resolution.y;
  vec2 uvC = uv;
  //uv *= rotation(time * 2);
  //uv -= vec2(0., .5);
  
  vec3 color = vec3(0.);
  
  vec3 ro = vec3(.0, .0, -2.);
  vec3 rd = normalize(vec3(uv, .5));
  vec3 p = ro;
  float td = 0.;
  bool hit = false;
  
  for (int i = 0; i < 128; i++) {
    float d = sdScene((p * rotateX(cosT+time) * rotateY(sinT+time) * rotateZ(time)), 3+sinT);
    if (d < .01) {
      hit = true;
      break;
    }
    p += rd * d;
    td += d;
    if (td > 30) break;
  }
  
  if (hit) {
    vec3 lo = vec3(1., 1., 1.);
    vec3 ld = normalize(lo - p);
    float diffuse = max(dot(ld,normal(p, sinT/10, sinT)), .3);
    color = diffuse * vec3(.8/sinT/2, .5, .8/sinT/2);
  }
  else {
    color = vec3(sinT/5, sinT/5, counter);
  }
  
  /*
  float scaleFact = 2. + sinT;
  float circle = sdCircle(uvC, .5);
  float hexaL = sdHexagon(uv/scaleFact, .25)*scaleFact;
  float hexa = sdHexagon(uv, .1);
  float scene = min(hexaL, -circle);
  
  vec3 color = vec3(.8, 0, .8) * (1. - step(0., scene));
  */
	out_color = vec4(color, 0);
}