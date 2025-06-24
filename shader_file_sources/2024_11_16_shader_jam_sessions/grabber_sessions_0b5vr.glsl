#version 410 core

#define saturate(x) clamp(x, 0.,1.)
#define linearstep(a,b,t) saturate( ((t)-(a)) / ((b)-(a)) )
#define repeat(i,n) for(int i=0;i<(n);i++)

const float PI = acos(-1.);
const float TAU = 2.0 * PI;

float time;

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

uvec3 seed;
uvec3 hash3u(uvec3 s){
  s=s*1145141919u+1919810u;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  s^=s>>8;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  return s;
}

vec3 hash3f(vec3 s){
  uvec3 r=floatBitsToUint(s);
  return vec3(hash3u(r))/float(-1u);
}

vec3 random3(){
  seed=hash3u(seed);
  return vec3(hash3u(seed))/float(-1u);
}

vec2 cis(float t){
  return vec2(cos(t),sin(t));
}

vec3 colorshit(float t) {
  return 3.0*(0.5 - 0.5 * cos(TAU * saturate(1.5*t - vec3(0.0, 0.25, 0.5))));
}

float ease(float t,float k){
  float tt=fract(1.-t);
  float y=(1.+k)*pow(tt,k)-k*pow(tt,k+1.);
  return (1.-y)+floor(t);
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)<.999?vec3(0,1,0):vec3(0,0,1);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 cyclic(vec3 p,float pers,float lacu){
  mat3 b=orthbas(vec3(3,2,-1));
  vec4 sum=vec4(0);
  repeat(i,5){
    p+=sin(p.yzx);
    sum+=vec4(
      cross(sin(p.zxy),cos(p)),
      1.0
    );
    sum/=pers;
    p*=lacu;
  }
  return sum.xyz/sum.w;
}

float sdbox2(vec2 p,vec2 s){
  vec2 d=abs(p)-s;
  return min(max(d.x,d.y),0.)+length(max(d,0.0));
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p = uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  float deltap=1.0/v2Resolution.y;
  
  time = fGlobalTime;
  seed=floatBitsToUint(vec3(uv,time));
  
  vec3 col=vec3(0.0);
  
  repeat(i, 32) {
    float delay=(float(i)+random3().x)/32.;
    float tt=time-0.5*delay;
    tt*=140.0/60.;
    float ta=mix(tt,ease(tt,6.),0.8);
    vec3 cmod=colorshit(delay);
    float d=sdbox2((p-.5+100.0*p.y),vec2(.2));
    float shape=linearstep(deltap,-deltap,d);
    float noise=cyclic(vec3(p,ta),0.9,1.5).x;
    noise=0.5+0.5*noise;
    //noise*=(1.-.4*length(p));
    float shit=shape+noise;
    col+=cmod*shit/32.;
  }

	out_color = vec4(col,1);
}