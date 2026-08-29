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

float E = 0.001;
float FAR = 100.;

vec3 glow = vec3(0.);

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.)) + min(max(d.x, max(d.y, d.z)), 0.);
}

float scene(vec3 p){
  vec3 pp = p;
  
  float safe = length(p)-2.0;
  
  for(int i = 0; i < 7; ++i){
    pp = abs(pp)-vec3(4.0, 2., 2.);
    rot(pp.xy, time*0.1 + fft);
    rot(pp.xz, time*0.5);
  }
  
  float cs = length(pp)-2.0;
  float bb = box(pp, vec3(0.1, FAR, 0.1));
  
  vec3 g = vec3(0.5, 0.2, 0.5) * 0.02 / (abs(cs)+0.1);
  g += vec3(0.2, 0.3, 0.2) * 0.05 / (abs(cs)+0.01);
  
  g *= 0.5;
  glow += g;
  
  cs = max(abs(cs), 0.5);
  
  return max(min(cs, bb), -safe);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = uv-0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(sin(time*0.5), sin(time), cos(time*0.5));
  vec3 rt = vec3(0., 0., -1.);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0., 1., 0.)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1./radians(60.)));
  
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < 100; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  vec3 col = vec3(0.);
  if(t < FAR){
    col = vec3(0.1, 0.2, 0.2);
  }
  
  col += glow;
  col = vec3(1.0, 0.75, 0.5)-col;
  
  vec3 prev = texture(texPreviousFrame, uv*0.75).rgb;
  prev = mix(prev, texture(texPreviousFrame, uv*0.25).rgb, 0.5);
  
  col = mix(col, prev, 0.9);
  
  col = smoothstep(-0.2, 1.2, col);
  

	out_color = vec4(col, 1.);
}