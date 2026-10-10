// ello can you see me? =)
// dang 2 days without proper sleep..... it was worth but uuugh you know :)

// sorry guys but this is all i can do today...we already made 2 incredible demos this weekend and i just had
// neither physical nor mental capacity. next time maybe :)

// artemka @ revision2o26 - 06.04.2o26

// also: the handle is pronounced as "artyomka", plz stop making mistakes :D

#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 230.0));}

float time = fGlobalTime;
float mt   = mod(time, 120);
float tt = mod(fGlobalTime + 0.07*hash(gl_FragCoord.xy/v2Resolution), 30.0);

const float PI = 3.14159265359;

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

// ordered dither matrix
int dither[] = int[](0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5);

float map(vec3 p) {
    p.xy *= rot2(tt*1.3);  
    p.xz *= rot2(tt*1.5);  
    p.xy  = abs(p.xy);  
    p.xy -= vec2(0.3+0.8*sin(tt*4.3));
    
    
  
    p.x *= (1.0+0.9*texture(texFFT,abs(mod(p.x+time,1)-1.5)*0.01).r+0.9*texture(texFFT,0.010).r);
    p.y *= (1.0+0.9*texture(texFFT,abs(mod(p.x+time,1)-1.5)*0.01).r+0.9*texture(texFFT,0.011).r);
  
    return length(p) - 2.0;
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

vec2 trace(vec3 o, vec3 d) {
  float t = 0.;
  float mct = 1000.0;
  for (int i = 0; i < 256; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((abs(ct) < 0.00001) || (t > 128.)) break;
    t += ct;
    mct = min(mct, abs(ct));
  }
  
  return vec2(t, mct);
}

vec3 light(vec3 o, vec3 l, vec3 n, vec3 r) {
  float a = 0.1*(sin(n.x*2.3+n.z*3.3)+cos(n.y*1.3+n.x*2.2+0.5)+cos(n.z*0.24+n.x*0.45+0.5))+0.4;
  a += 0.6*max(dot(n, normalize(o)), 0);
  a += 0.9*pow(max(dot(l, r), 0), 32);
  a  = a/(1.0+0.3*a);
  a  += 0.02*hash(n.xy);
  a  = min(a, 1.0);
  a  = pow(a, 2.4);
  return vec3(a);
}

void main(void)
{
  vec2 fuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = fuv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 color = vec3(1.0);
  vec3 rmcol = vec3(0.0);
  
  vec3 ray = normalize(vec3(uv, -0.7));
  vec3 o = vec3(0,0,4);
  //o.xy += 0.03*hash(uv*8.2+vec2(time*0.05));
  vec3 l = normalize(vec3(
    3*sin(mt*1.4),
    3*cos(mt*3.6),
    3*sin(mt*3.5)
  ));
  
  vec2 tm = trace(o, ray);
  float t = tm.x;
  //if (!((t == 0.0) || (t > 128.0))) {
    vec3 p = o+t*ray;
    vec3 n = norm(p);
    vec3 r = reflect(-l, n);
    //color = vec3(1.0);
    rmcol = light(o, l, n, r);
    //rmcol = rmcol / (1.0 + 0.3*rmcol);
    if (tm.y < 0.1) color *= 0.3;
    if (t < 128.0) color = rmcol;
   
  color = pow(color, vec3(0.45));
  // subpixels :grins:
  switch (int(gl_FragCoord.x/(int(3*sin(time*1.3)+4))) % 3) {
    case 2 : color *= vec3(0.6,0.6,1.0); break;
    case 1 : color *= vec3(0.6,1.0,0.6); break;
    case 0 : color *= vec3(1.0,0.6,0.6); break;
    default: break;
  }
	out_color = vec4(color, 1.0);
}