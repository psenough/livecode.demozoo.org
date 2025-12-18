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

// Hello Revision 2023!

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, .5).r;
float ffts = texture(texFFTSmoothed,60.).r;

vec3 glow = vec3(0.0);

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, float b){
  vec3 d = abs(p)-b;
  return length(max(d,.0)) + min(max(d.x,max(d.y,d.z)),0.0);
}

float scene(vec3 p){
  vec3 pp = p;
  
  for(int i = 0; i < 4; ++i){
    pp = abs(pp) - vec3(0.75, 2.0, 1.5);
    rot(pp.xz, time*0.3+sin(4.*fft));
    rot(pp.zy, fft*2.5);
    rot(pp.xy, fft*0.5+time*0.1+cos(8.*ffts));
  }
  
  float spheres = sphere(pp,1.0+ffts*50.);
  float spheres2 = sphere(pp,3.+ffts*5.);
  float spheres3 = sphere(pp,3.25+ffts*5.);
  float spheres4 = sphere(pp,3.5+ffts*5.);
  float spheres5 = sphere(pp,3.75+ffts*5.);
  float spheres6 = sphere(pp,4.+ffts*5.);
  
  pp = p;
  for (int i = 0; i < 3; ++i){
    pp = abs(pp) - vec3(2.5,2.5,3.5);
    rot(pp.xz, time*.5+cos(10.*ffts));
    rot(pp.xy, fft*5.2);
  }
  float boxes = box(pp,1.0);
  
  pp = p;
  
  for (int i = 0; i < 5; ++i)
  {
    pp = abs(pp) - vec3(.5,3.0,5.5);
    rot(pp.xy, time*.2+sin(6.*fft));
    rot(pp.yz, time*.6+cos(12.*ffts));
  }
  
  float boxes2 = box(pp,1.0*ffts*5.);
  glow += vec3(0.9,0.04,0.5) * 0.05 / abs(boxes2)+0.01;    
  glow += vec3(0.5,0.04,0.9) * 0.01 / abs(boxes)+0.001;
  glow += vec3(0.08,0.45,0.85) * 0.02 / abs(spheres) +0.01;
  glow += vec3(0.85,0.08,0.45) * 0.012 / abs(spheres3)+0.001;
  glow += vec3(0.85,0.8,0.85) * 0.012 / abs(spheres4)+0.001;
  glow += vec3(0.08,0.45,0.85) * 0.02 / abs(spheres2) +0.01;
  glow += vec3(0.85,0.08,0.45) * 0.012 / abs(spheres5)+0.001;
  glow += vec3(0.08,0.45,0.85) * 0.02 / abs(spheres6) +0.01;
  return sphere(p,1.+ffts*12.);
}

float march (vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i)
  {
    float d = scene(p);
    t += d;
    p = ro+rd * t;
    if (d < E || t > FAR) {
      break;
    }
  }
  return t;
}

vec3 normals(vec3 p){
  vec3 e = vec3(E, 0.0, 0.0);
  return normalize(vec3(
    scene(p + e.xyy) - scene(p - e.xyy),
    scene(p + e.yxy) - scene(p - e.yxy),
    scene(p + e.yyx) - scene(p - e.yyx)
  ));
}

vec3 shade(vec3 rd, vec3 p, vec3 ld){
  vec3 n = normals(p);
  
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(rd, ld), n), 0.0);
  float s = pow(a, .1);
  
  return vec3(1.)*l + vec3(.9)*s;
}

void main(void)
{
  vec3 col = vec3(0.0);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 q = -1.0 + 2.0*uv;
  q.x *= v2Resolution.x/v2Resolution.y;

  vec3 ro = vec3(4.0-sin(2*time)+sin(4*time)*3., -4.0+sin(time+ffts)*3., 15.0+cos(time)*5.);
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0,1.0,0.0)));
  vec3 y = normalize(cross(x,z));
  vec3 rd = normalize(mat3(x,y,z)*vec3(q,1.0/radians(94.0)));
  
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  vec3 ld = normalize(vec3(0.0,0.0,-10.0)-p);
  
  rot(q, time*.5);
  
  if (t < FAR){
    col = shade(rd, p, ld)*.05;
  }
  
  col += glow;
  
  col = mix(col, texture2D(texPreviousFrame, uv).rgb,.5);
  
  col = smoothstep(-.1,1.,col);
  
	out_color = vec4(col,1.);
}