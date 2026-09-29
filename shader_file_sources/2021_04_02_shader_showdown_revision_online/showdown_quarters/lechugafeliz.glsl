#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float time = mod(fGlobalTime, 50.);
float smin(float a, float b, float k){ float h = max(k-abs(a-b), 0.)/k; return min(a, b)-pow(h, 3.)*k*(1.0/6.0);}
#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))

float sb(vec3 p , vec3 s){ p= abs(p)-s; return max(max(p.x, p.z), p.y);}
float c1(vec3 p){
  vec3 p1 = p;
  for(int i = 0; i < 5; i++){
    p1.xy *= rot(1.);
  p1 = abs(p1)-3.-sin(time);
  
  }
  float sb1 = sb(p1, vec3(0.1, vec2(1.25)));
  
  return sb1;
}

float c2(vec3 p){
  vec3 p1 = p;
  for(int i =0 ; i < 4; i++){
    p1.xy *= rot(9.);
    p1 = abs(p1)-10.*cos(time)+i;
    
  }
  float sb1 = sb(p1, vec3(0.1, vec2(3.25)));
  
  return min(sb1, c1(p));
}
float rand(float x){return fract(sin(x*32234.234234)*2342.34234);}
float glow;
float c(float t, float s){t/=s; return mix(rand(floor(t)), rand(floor(t+1)), smoothstep(0., 1., fract(t)));}
float map(vec3 p){float d = c2(p);
  float tt = c(time, 40.)*10.+time*.1;
  for(float i = 0; i < 3;i++){ p.xz *= rot(tt*.34534+i); p.yx *= rot(tt*.34534); p=abs(p)-.4;}
  float ball = length(p)-9.*sin(tt+p.y*.234234)*sin(tt+p.z)*sin(tt+p.x*.434234);
  glow += .1/(.1+ball*ball);
  d = smin(d, ball, 10.+cos(tt*10.)*20.);  return d;
}
float t1 = c(time, 20.);
void cam(inout vec3 p){p.xz *= rot(time+t1); p.yx *= rot(time+t1);}
void main(void)
{
  #define pi = 3.14153596
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  //uv = mod(uv, 20.);
  //uv = mod(-uv, 1)*.2;
  uv = (fract(uv/40.+.5)-.5)*40.*cos(time*t1);
  uv *= rot(time);
  uv.xy += sin(t1)*.4-.5;
  
  time += rand(dot(uv.x, uv.y))*.03;
  //float t1 = c(time, 20.);
  float fov = 1.+sin(time+t1)*.1;
  vec3 s = vec3(0.00001, .0000001, -60.), r = normalize(vec3(-uv, fov));
  cam(s); cam(r);
  vec3 p = s, col = vec3(0.);
  const float MAX = 100.; float d = 0., i = 0.;
  for(; i < MAX; i++) if(d = map(p), p+=d*r, abs(d) < 0.0001) break;
  const vec2 e = vec2(0.01, 0.435345);
  col += dot(map(p)-vec3(normalize(vec3(map(p-e.xyy), map(p-e.yxy),map( p-e.yyx)))), -vec3(.3));
  //asd
  float tt = c(time, 20.);
  //col += length(p-s)/300. * vec3(0.1, .34, .3)+vec3(sin(tt), 0.045345, -sin(tt));
  col += glow * vec3(.213, .3453, .7454)*.966;
  col *= 1-max(length(p-s)/sin(time)*2., 0.)*vec3(1., .3123, 1.);
	out_color = vec4(col, 1.);
}