// we're back

// NOOOOO PANIC MODE :D

// sorry we planned a PC-98 demo for SESSIONS but as usual lack of time and laziness 
// maybe for the next party :)                                         (oh hai natt)

// --artemka 16.11.2o24 @ sessions24 shader jam

#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq`
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 230.0));}

float time = fGlobalTime;
float mt   = mod(time, 60);
float tt = mod(fGlobalTime + 0.01*hash(gl_FragCoord.xy/v2Resolution), 180.0);

const float PI = 3.14159265359;

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

float star(vec2 uv, float t) {
    float r = length(uv)*32.;
    float a = atan(uv.y, uv.x) - PI;
    float v = (1.+sin(r*(1.-.4*sin(5.*a + PI/3.))+0.8*t)) *(1.0+0.8*sin(t*3.5));
    return v; 
}

float box(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

// raymarching stuff just to show anything on screen
vec3 mod3(vec3 p, vec3 s, vec3 l) {
  vec3 q = p - s*clamp(round(p/s),-1,1);
  return q;
}

float map(vec3 p) {
  p.zx *= rot2(time*0.1);
  p.xy *= rot2(time*0.1);
  p = mod3(p,vec3(3),vec3(1));
  p.zx *= rot2(time*1.4);
  p.yz = abs(p.yz);
  p.xy = abs(p.xy);
  p.yz *= rot2(time*1.2);
  p += vec3(0.8*sin(time*0.2),0.8*cos(time*0.8),0); 
  p.yz *= rot2(time*0.2);
  p.xy = abs(p.xy);
  p.xy *= rot2(time*1.1);
  p += vec3(0.2*sin(time*2.2),0,0.5*sin(time*0.2)); 
  p.xy = abs(p.xy);
  return box(p, vec3(1.0+0.8*texture(texFFT, 0.01)));
}

vec3 norm(vec3 p) {
  vec2 b = vec2(0., 0.0001);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}

float trace(vec3 o, vec3 d) {
  float t = 0.;
  for (int i = 0; i < 256; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((abs(ct) < 0.001) || (t > 128.)) break;
    t += ct;
  }
  
  return t;
}

void main(void)
{
  vec2 fuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = fuv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 color = vec3(0.0);
  
  // backdrop
  color = mix(vec3(0.4,0.2,0.6), vec3(0.6,0.2,0.7), smoothstep(0.3,0.6,star(uv*rot2(time*0.2), time)));
  
  // raymarch something
  vec3 ray = normalize(vec3(uv, -0.7));
  vec3 o = vec3(0,0,10);
  float t = trace(o, ray);
  if (!((t == 0.0) || (t > 128.0))) {
    vec3 p = o+t*ray;
    vec3 n = norm(p);
    color = mix(vec3(0.1,0.2,0.1),vec3(0.9,0.8,0.9),pow(max(dot(n,vec3(0,0,1)),0),2));
  }
  
  if (fuv.x>0.05 && fuv.x<0.2) {
    vec2 auv = (mod(fuv-vec2(0.05,0),0.2));
    color += texture(texFFT,auv.x).r;
  }
  
  if (fuv.x>0.84 && fuv.x<0.96) {
    vec2 auv = fuv-vec2(0.85,0);
    auv -= 0.05*0.5;
    auv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    auv.y += mt*0.08;
    vec2 mauv = mod(auv,0.05);
    ivec2 iauv = ivec2(auv*20);
    mauv -= vec2(0.02);
    float o = 1.0-smoothstep(0.014,0.018,length(mauv));
    color += 0.8*o*hash(vec2(iauv)-vec2(float(int(mt*3))));//*texelFetch(texFFT,iauv.x+iauv.y,0).r;
  }
  
  // top/bot indents
  if (abs(uv.y)>.396 && abs(uv.y)<.4) color += vec3(0.4);
  if (abs(uv.y)>.4) color *= 0.5;
    
  // vingette
  color *= 1.0-0.4*length(fuv-vec2(0.5));
  
	out_color = vec4(color,1.0);
}