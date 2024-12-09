#version 420 core

// Greetings from the graduation party of Papumaja & Tastula !! The guestlist for this party had about 140 people...


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
uniform sampler2D texRevisionBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float E = 0.001;
const int STEPS = 100;
const int FAR = 100;

float time=fGlobalTime;
float fft=texture(texFFTIntegrated,0.02).r*100;
float fft2=texture(texFFTSmoothed,0.02).r*100;
vec3 glow=vec3(0);

float sdCirc( vec2 uv, float r ) {
  return length(uv)-r;
}
float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0))+min(max(d.x, max(d.y, d.z)), 0.0);
}
void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y, p.x);
}

float scene(vec3 p, vec3 ro, vec3 rd){
  vec3 pp = p;
  float fpp= texture(texFFTSmoothed,pow(abs(p.z*.03),1.5)).r;
  float keski = sphere(pp,.2+fpp*10);
  float pallo = box((pp-ro)*rd,vec3(1));
  //rot(pp.xy, time*0.01);
  //rot(pp.yz, time*0.005);
  for(int i = 0; i < 8; ++i){
    pp = abs(pp)-vec3(1,0.1,2);
    
    rot(pp.xy, time*0.005+fft*0.01);
    rot(pp.yz, time*0.007+fft*0.003);
  }
  
  
  float d = distance(p, pp);
  float sp = box(pp, vec3(d*0.05, d*0.04, d*0.02));
  
  vec3 g = vec3(.1)*0.01 / (abs(sp)+0.05);
  glow += g;
  
  sp = abs(sp*0.5);
  
  return max(min(sp,keski),-pallo);
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p,ro,rd);
    t += d;
    p = ro + rd * t;
    if(d <= E || t >= FAR){
      break;
    }
  }
  return t;
}

vec3 HueShift (in vec3 Color, in float Shift)
{
  vec3 P = vec3(0.55735)*dot(vec3(0.55735),Color);
  vec3 U = Color-P;
  vec3 V = cross(vec3(0.55735),U);    
  Color = U*cos(Shift*6.2832) + V*sin(Shift*6.2832) + P;
  return vec3(Color);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

const int BPM = 134;


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  
  
  float tim=time*60/BPM;
  //uv=mod(uv*sin(time*.2)*10,2)-1;
  
  
	vec2 uv_=uv;
  vec2 zom=uv;
  vec2 zom2=uv;
  
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 rUv=uv;

  
  float px=-texture(texFFTSmoothed,abs(uv.x/uv.y)/3.14).r*1000+100;
  //uv=floor(uv*px)/px;
  
  
  float f3=texture(texFFT,abs(zom.x-.5)).r;
  
  vec3 viz=vec3(0);
  
  zom-=.5;
  zom*=1;
  if (f3>abs(zom.y)) {
    viz=vec3(1);
  }
  zom+=.5;
  
  float ff=texture(texFFTSmoothed,0.2).r*10;
  
  vec2 q = uv_ -.5;
  
  q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(18,0,0); 
  vec3 rt = vec3(0, 0, 0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0, 1, 0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, 1/radians(90.0)));
 
  float t = march(ro, rd);
  vec3 p = ro+rd*t;
  float dis = distance(ro,p);
  
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
  
	float f = texture(texFFT,d).r * 100;
  float f2=texture(texFFTSmoothed,abs(m.x/6)).r*1;
  vec2 revUv=uv;//(uv*(1-ff*40)-.5*f2*1);  
  
  
  zom2-=.5;
  rot(zom2,.005-f*.01);
  zom2*=0.99;
  zom2+=.5;
  
  revUv+=.5;
  revUv-=.5;
  rot(revUv,fft*.03);
  revUv*=1-f2*.3;
  revUv+=.5;
  vec4 rev=texture(texRevisionBW,revUv);
  rot(rUv,fft*.02);
  rUv-=.5;
  vec4 rev2=vec4(.5)+texture(texRevisionBW,rUv*t*.1);
  
  vec2 zm = zom;
  zm-=.5;
  for(int i =0; i<30; ++i) {
    zm = abs(zm)-vec2(.0002*fft2*.2,0);
  }  
  zm+=.5;
  zom=zm;
  vec4 prev=texture(texPreviousFrame,zom);
  vec4 prev2=texture(texPreviousFrame,zom2);

  float s = sdCirc(uv,.1+f2*5);
  vec3 col = vec3(0);

  if(t<FAR) {
    col=vec3(t-.8);//*rev.rgb*.9;
  }
  
  //rot(prev.xy,.05);
  out_color = vec4(col,1);
  out_color*=prev*5;//*vec4(.9,-.5,1,0);
  //out_color=normalize(out_color)+vec4(.09,0.2,.08,1);
  
  //out_color=clamp(out_color,-.4,1.4);
  
  
  
  if (out_color.r<.01) {
    out_color=vec4(1);
  }
  if (out_color.r>.99) {
    out_color=vec4(prev*.99);
  }//
  out_color*=vec4(-1.2,1.5,1.9,0);
  
  out_color*=rev2;
  
  prev2=vec4(HueShift(prev2.rgb,.001+f2*.02),1);
  prev2=mix(prev2,vec4(glow*vec3(1.2,3.8,4.9),1),.05);
  
  if(t>FAR-1) {
    out_color=prev2;
  }
  out_color+=vec4(viz,1);
  if(mod(tim,1)<0.1) {
    out_color*=rev*vec4(1,.1,1,0);
  }
  out_color*=.5+step(s,0)*vec4(1,0,0,0);

  out_color=step(prev.r,.01)*.4+out_color;
  
}