#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.5).r;

const float E = 0.01;
const float FAR = 100.0;
const int STEPS = 60;

vec3 glow = vec3(0.0);
float M = 0.0;

vec3 COL1 = vec3(0.5, 0.3, 0.1);
vec3 COL2 = vec3(0.8, 0.1, 0.8);

float box(vec3 p, vec3 b){
  vec3 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float sphere(vec3 p, float r){
  return length(p)-r;
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float scene(vec3 p){
  vec3 pp = p;
  
  float safe = sphere(p, 10.0);
  
  
  float orb = sphere(pp-vec3(0.0, 0.0, -8.0), 6.0+fract(fft*10.0)*2.5);
  
  rot(pp.xy, time);
  rot(pp.xz, time*0.5);
  rot(pp.yz, time*0.25);
  
  for(int i = 0; i < 5; ++i){
    pp = abs(pp)-vec3(0.5, 1.2, 1.0);
    rot(pp.xz, time*0.5 + fft*5.0);
    rot(pp.xy, time*0.5);
    rot(pp.yz, time+fft*5.0);
  }
  
  float a = box(pp, vec3(1.0));
  //a = max(a, -safe);
  
  vec3 g = vec3(1.0, 0.2, 0.1) * 0.08 / (abs(a)+0.01);
  g += COL2 *0.05 / (abs(orb)+0.01);
  g *= 0.5;
  
  glow += g;
  
  orb = max(abs(orb), 0.1);
  a = max(abs(a), 0.2);
  
  return min(a, orb);
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  return t;
}

vec3 normals(vec3 p){
  vec3 e = vec3(E, 0.0, 0.0);
  return normalize(vec3(
    scene(p+e.xyy) - scene(p-e.xyy),
    scene(p+e.yxy) - scene(p-e.yxy),
    scene(p+e.yyx) - scene(p-e.yyx)
  ));
}

vec3 shade(vec3 p, vec3 rd, vec3 ld){
  vec3 n = normals(p);
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(n, ld), rd), 0.0);
  float s = pow(a, 20.0);
  
  return COL1 * l * 0.25 + COL2 * s * 0.75;
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 q = -1.0 + uv*2.0;
  q.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 ro = vec3(0.0, 0.0, 10.0+fract(time+fft));
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, 1.0/radians(50.0)));
  vec3 col = vec3(0.01, 0.02, 0.03);
  
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  
  if(t < FAR){
    col += shade(p, rd, -z) + (1.0/t);
  }
  
  col *= glow;
  
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  
  col = mix(col, prev, 0.8);
  

	out_color = vec4(col, 1.0);
}