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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;

float fft = texture(texFFTIntegrated, 0.5).r;

const float FAR = 40.0;
const int STEPS = 60;
const float E = 0.001;

const float PI = 3.14159265;

vec3 glow = vec3(0.0);

// Sign function that doesn't return 0
float sgn(float x) {
	return (x<0.0)?-1.0:1.0;
}

vec2 sgn(vec2 v) {
	return vec2((v.x<0.0)?-1.0:1.0, (v.y<0.0)?-1.0:1.0);
}


float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 r){
  vec3 d = abs(p)-r;
  
  return length(max(d, 0.0) + min(max(d.x, max(d.y, d.z)), 0.0));
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// Mirror at an axis-aligned plane which is at a specified distance <dist> from the origin.
//THANK YOU MERCURY!!!!
float pMirror (inout float p, float dist) {
	float s = sgn(p);
	p = abs(p)-dist;
	return s;
}

// Mirror in both dimensions and at the diagonal, yielding one eighth of the space.
// translate by dist before mirroring.
//THANK YOU MERCURY!!!!
vec2 pMirrorOctant (inout vec2 p, vec2 dist) {
	vec2 s = sgn(p);
	pMirror(p.x, dist.x);
	pMirror(p.y, dist.y);
	if (p.y > p.x)
		p.xy = p.yx;
	return s;
}

// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
//THANK YOU MERCURY!!!!
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.0*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.0;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.0;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.0)) c = abs(c);
	return c;
}

float scene(vec3 p){
  
  vec3 pp = p;
  
  vec3 dd = vec3(4.0, 2.0, 4.0);
  
  pp.xz = mod(pp.xz + vec2(10.0), vec2(20.0))-vec2(10.0);
  
  
  
  pModPolar(pp.xz, 12.0);
  rot(pp.xz, time*0.5 + fft);
  pMirrorOctant(pp.xz, dd.xz*0.5);
  
  pp.y = mod(pp.y + 10.0, 20.0)-10.0;
  
  float c = sphere(pp-vec3(10.0, 2.0, 0.0), 4.0);
  
  for(int i = 0; i < 8; ++i){
    pp = abs(pp)-vec3(5.0, 3.0, 2.0);
    rot(pp.xy, time*0.25 + fft*1.5);
    rot(pp.yz, fft);
    rot(pp.xz, fft*10.0);
  }
  
  float a = box(pp, vec3(0.5, 0.5, FAR*2.0));
  float b = box(pp, vec3(1.0, 2.0, FAR*2.0));
  
  
  vec3 g = vec3(0.5, 0.0, 0.0)*0.05 / (0.01+abs(a));
  g += vec3(0.2, 0.2, 0.8)*0.05 / (0.01+abs(b));
  g *= 0.5;
  glow += g;
  
  
  b = max(abs(b), 0.5);
  
  return min(c, min(a, b));
}


float march(vec3 ro, vec3 rd, out vec3 p){
  p = ro;
  float t = E;
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    
    if(d < E || t > FAR){
      break;
    }
    
    p += rd*d;
  }
  
  return t;
}

vec3 normals(vec3 p){
  vec3 eps = vec3(E, 0.0, 0.0);
  return normalize(vec3(
    scene(p+eps.xyy) - scene(p-eps.xyy),
    scene(p+eps.yxy) - scene(p-eps.yxy),
    scene(p+eps.yyx) - scene(p-eps.yyx)
  ));
}

vec3 shade(vec3 ro, vec3 rd, vec3 n, vec3 ld){
  float l = max(dot(n, ld), 0.0);
  vec3 a = reflect(n, ld);
  float s = pow(max(dot(rd, a), 0.0), 10.0);
  
  return l*vec3(0.8, 0.5, 0.5)*0.4 + s*vec3(0.8, 0.5, 0.8)*0.6;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = -1.0 + 2.0*uv;
  q.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 ro = vec3(1.2, time*2.0, 2.0);
  vec3 rt = vec3(0.0, 10.0+ro.y, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x, y, z)*vec3(q, radians(60.0)));
  
  vec3 p = ro;
  float t = march(ro, rd, p);
  
  vec3 col = vec3(0.1, 0.1, 0.3);
  vec3 ld = normalize(rt-ro);
  vec3 lp = vec3(0.0, 20.0*sin(time*0.5), 10.0*cos(time*0.5));
  vec3 lt = ro;
  vec3 ld2 = normalize(lt-lp);
  
  if(t < FAR){
    vec3 n = normals(p);
    col = shade(ro, rd, n, ld);// + vec3(0.2, 0.2, 0.25);
    col + shade(ro, rd, n, ld2);
    col *= 0.5;
    col += vec3(0.1, 0.0, 0.2);
    
    rd = reflect(rd, n);
    ro = p + n*2.0*E;
    t = march(ro, rd, p);
    if(t < FAR){
      col += shade(ro, rd, n, ld);
      col += shade(ro, rd, n, ld2);
      col *= 0.5;
      col += vec3(0.1, 0.0, 0.2);
    }
  }
  
  col += glow*0.5;
  
  vec3 pframe = texture(texPreviousFrame, uv*0.25+fft).rgb;
  col += pframe;
  col *= 0.2;
  
  vec2 uvv = uv;
  rot(uvv, time);
  
  vec3 logo = texture(texRevision, uv).rgb;
  
  col = smoothstep(0.0, 1.0, col);
  
  col += logo*vec3(0.5);
  
 
  col *= smoothstep(0.8, 0.4*0.799, distance(uv, vec2(0.5))*(0.6 + 0.4));
  
  
  
	out_color = vec4(col, 1.0);
}