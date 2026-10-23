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
float fft = texture(texFFTIntegrated, 0.3).r;

const float E = 0.001;
const float FAR = 100.;
const int STEPS = 60;

vec3 glow = vec3(0.0);

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float cluster(vec3 p){
  vec3 pp = p;
  for(int i = 0; i < 5; ++i){
    pp.xy = abs(pp.xy)-0.5;
    rot(pp.xy, 0.5);
  }
  return box(pp, vec3(0.2, 0.5, 0.2));
}

float scene(vec3 p){
  vec3 pp = p;
  
  float safe = sphere(p, 1.0);
  
  pp.z -= time;
  
  float off = 6.0;
  pp.z = mod(pp.z+off*0.5, off)-off*0.5;
  rot(pp.xy, time);
  
  float c = cluster(pp);
  
  glow += vec3(0.3, 0.1, 0.0) * 0.015 / (abs(c) + 0.05);
  
  pp = p;
  
  for(int i = 0; i < 5; ++i){
    pp = abs(pp)-0.2;
    rot(pp.xy, 0.4);
    rot(pp.xz, time);
  }
  
  float b = box(pp, vec3(FAR, 0.1, FAR));
  
  glow += vec3(0., 0.1, 0.3) * 0.01 / (abs(b) + 0.2);
  
  return max(-safe,max(c, -b));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = uv-0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0.0, 0.0, 0.0);
  vec3 rt = vec3(0.0, -.1, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0., 1., 0.)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1./radians(60.0)));
  
  float t = E;
  vec3 p = ro;
  
  vec3 col = vec3(0.03, 0., 0.05);
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  if(t < FAR){
    col = vec3(0.4, 0.1, 0.0);
  }
  col += glow;
  
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  col = mix(col, prev, 0.7);

	out_color = vec4(col, 1.0);
}