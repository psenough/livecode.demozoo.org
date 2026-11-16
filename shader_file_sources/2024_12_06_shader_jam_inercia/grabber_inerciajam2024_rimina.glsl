#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.5).r;

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

vec3 glow = vec3(0.0);

vec4 getTexture(sampler2D sampler, vec2 uv){
     vec2 q = uv + vec2((fft*2.0 + time*0.1), (time*0.1 + fft));
     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return 1.0 - texture(sampler, q*vec2(1.,-1.*ratio)-.5);
}

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void rotate(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float scene(vec3 p) {
  vec3 pp = p-vec3(0.5, 3.0, 0.0);
  
  for(int i = 0; i < 7; ++i){
    pp = abs(pp) - vec3(5.0, 10.0, 12.0);
    rotate(pp.xy, fft*10.0);
    rotate(pp.xz, time*0.5);
    rotate(pp.yz, fft*10+time*0.1);
  }
  
  float juttu = box(pp, vec3(0.1, 0.1, FAR));
  
  glow += vec3(0.5) * 0.01 / (abs(juttu) + 0.01);
  
  return juttu;
}


float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < FAR; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd*t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  return t;
  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 q = uv + vec2(sin(fft*2.0 + time*0.1), (time*0.1 + fft));
  
  vec3 ro = vec3(0.0, 0.0, 10.0);
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(uv, 1.0/radians(60.0)));
  
  float t = march(ro, rd);
  vec3 p = ro + rd*t;
  
  vec4 col = vec4(0.);
  col = getTexture(texInerciaLogo2024, uv);
  col += vec4(0., 0.2, 0.1, 0.0);
  col = mix(col, texture(texPreviousFrame, uv-0.01*fft), 0.75);
  col *= 0.5;

  col = 1.0-col;
  col += vec4(glow, 1.0);
  
	
  out_color = sqrt(1.0-col);
}