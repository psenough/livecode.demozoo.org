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
#define STEPS 250.0
#define MDIST 550.0
#define pi 3.1415926

#define pmod(p,x) (mod(p,x) - (x)*0.5)

#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

float smin(float a, float b, float k){
  float h = max(0.0,k-abs(a-b));
  return min(a,b)-h*h*0.25/k;
}
float anim(){
  return sin(fGlobalTime); 
}
float rand(vec2 a){
  return fract(sin(dot(a,vec2(43.234,21.4343)))*94544.3434343)-0.5;
}
float ssRemap(float t, float s1, float s2, float c){
  return 0.5*(s2-s1)*(t-asin(cos(t*pi)/sqrt(c*c+1.0))/pi)*s1*t;
}
float wave(vec3 p, float t){
  float dist = length(p.xz)-fract(t+0.5)*50;
  dist = min(dist,0);
  float wave = sin(dist)*exp(-abs(length(dist*0.2)));
  wave*=max(0,1.0-fract(t-0.5)*2.0);
  return wave;
}
float ball(vec3 p, float t){
  float mag = 80.0;
  p.y += (fract(t)-0.5)*mag;
  float a = length(p)-3.0;
  return a;
}

vec2 map(vec3 p){
  vec3 po = p;
  
  float t= mod(fGlobalTime,300.0)*0.6;
  vec2 a = vec2(1);
  vec2 b = vec2(2);
  
  //Bending
  p.y = pmod(p.y,60);
  
  float th = atan(p.x,p.z)/(2*pi)+0.5;
  th*=300.0;
  float r = length(p.xz)-60.0-texture(texFFTSmoothed,0.1).r*4000.0;
  p.x = r;
  //p.z = th;
  p.xy*=rot(sin(t));
  //p.xy*=rot(p.z*0.01*sin(t));
  p.xy = abs(p.xy)-5.0;
  p.xy*=rot(-pi/4.0);
  p.y=mix(p.y,ssRemap(p.y,0.01,0.4,0.3),0.5+0.5*anim());
  
  vec3 po2 = p;
  float count = 6.0;
  float wav =0;
  for(float i =0.0; i < count; i++){
    p = po2;
    t+=1/count;
    float mag = 10.0;
    p.x+=rand(vec2(floor(t),i))*mag;
    p.z+=(rand(vec2(floor(t),i*1.5)))*mag*30.0;
    a.x = smin(a.x,ball(p,t),0.5);
    wav +=wave(p,t)*1.5;
  }
  p = po2;
  t = mod(fGlobalTime,300.0)*4.0;
  wav+=sin(p.z+t)*0.1+sin(p.x+t)*0.1;
  wav+=sin(p.z*0.5-t)*0.2+sin(p.x*0.5-t)*0.2;
  
  //a.x = ball(p,t);
  b.x = p.y-wav;
  
  
  a=(a.x<b.x)?a:b;
  
  return a;
}

vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0);
  return normalize(map(p).x-vec3(
  map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float t= mod(fGlobalTime,300.0);
  vec3 col = vec3(0.1);
  vec3 ro = vec3(0,70,-150);
  
  float drop = texture(texFFTIntegrated,0.1).r*300.0;
  drop = 0.0;
  ro.y-=drop;
  
  //ro.z*=sin(t);
  //ro.y += sin(t)*20.0;
  ro.xz*=rot(t*0.3);
  vec3 lk = vec3(0,0,0);
  
  lk.y-=drop;
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = f*1.0+uv.x*r+uv.y*cross(f,r);
  
  vec3 p = ro;
  float dO, shad;
  vec2 d;
  
  for(float i = 0.0; i<STEPS; i++){
    p = ro+rd*dO;
    d = map(p);
    dO+=d.x*0.9;
    
    if(abs(d).x<0.01){
      shad = i/STEPS;
      break;
    }
    if(dO>MDIST){
      dO = MDIST;
      p = ro+rd*dO;
      d.y=0;
      break;
    }
  }
  shad = 1.0-shad;
  vec3 n = norm(p);
  vec3 ld = normalize(vec3(1,1,0));
  vec3 h = normalize(ld - rd);
  float spec = pow(max(dot(n,h),0.0),20.0);
  
  vec3 al = vec3(0);
  if(d.y==1.0) al = vec3(0,0.8,0.2);
  if(d.y==2.0) al = vec3(0,0,0.9)*1.5;
  p.y-=5.0;
  vec3 back = mix(vec3(0.1,0.1,0.5),vec3(0.0,0.4,0.6),clamp(p.y*0.05,0.0,1.0))*0.9;
  //back = vec3(0);
  
  col = shad*al;
  col+=spec*0.5;
  
  col = mix(col,back*2.0,(dO/MDIST));
  
  
	out_color = vec4(col,0);
}