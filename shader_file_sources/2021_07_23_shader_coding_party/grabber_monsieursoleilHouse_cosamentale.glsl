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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float hs(vec2 uv){return fract(sin(dot(uv,vec2(45.,95.)))*7845.236);}
float rd(float t){return fract(sin(dot(floor(t),45.3))*7845.236);}
float no(float t){return mix(rd(t), rd(t+1.),smoothstep(0.,1.,fract(t)));}
float box(vec3 p, vec3 b){vec3 q = abs(p)-b;
  return length(max(q,vec3(0.)))+min(0.,max(q.x,max(q.y,q.z)));}
float no(vec2 p){vec2 f = floor(p); p = smoothstep(0.,1.,fract(p));
  vec2 se = vec2(45.,98.);vec2 v1 = dot(f,se)+vec2(0.,se.y);
  vec2 v2 = mix(fract(sin(v1)*7845.236),fract(sin(v1+se.x)*7845.236),p.x);
  return mix(v2.x,v2.y,p.y);}
  float it(vec2 t){float r = 0.; float a = 0.5;for(int  i = 0 ; i<5 ; i++){
    r += no(t/a)*a;a*=0.5;}return r;}
     float it(float t){float r = 0.; float a = 0.5;for(int  i = 0 ; i<5 ; i++){
    r += no(t/a)*a;a*=0.5;}return r;}
float li(vec2 uv,vec2 a, vec2 b){vec2 ua  = uv-a; vec2 ba = b-a;
  float h = clamp(dot(ua,ba)/dot(ba,ba),0.,1.);
  return length(ua-ba*h);}
mat2 rot(float t){float c = cos(t); float s = sin(t);return mat2(c,-s,s,c);}
float ev(vec3 r,float t){ 
  //float t1 = texture(texFFTSmoothed,0.2).x*5000.;
  r= normalize(r*vec3(1.,0.1,1.));
  float d1 = distance(0.5,fract(r.x*5.));
  float v1 = smoothstep(0.05,0.,d1);
  float d2 = distance(0.5,fract(r.z*5.));
  float v2 = smoothstep(0.05+t,0.,d2);
  float v4 = smoothstep(0.5+t,0.,d1);
  float v5 = smoothstep(0.5+t,0.,d2);

  float v3 = mix(v1,v2,smoothstep(0.4,0.6,abs(r.x)))*fract(time*3.);
  v3 +=  mix(v4,v5,smoothstep(0.4,0.6,abs(r.x)))*fract(time*3.)*0.3;
  float tb = 5.*fract(time*3.);
  float c1 = li(fract(r.xy*vec2(7.,14.)),vec2(0.5),vec2(0.5+r.xy*vec2(0.7,1.4)*tb));
  float c2 = li(fract(r.zy*vec2(7.,14.)),vec2(0.5),vec2(0.5+r.zy*vec2(0.7,1.4)*tb));
  float l1 = smoothstep(0.025+t,0.,c1);
  float l2 = smoothstep(0.025+t,0.,c2);
  float l4 = smoothstep(0.05+t,0.,c1);
  float l5 = smoothstep(0.05+t,0.,c2);
  float l3 = mix(l1,l2,smoothstep(0.4,0.6,abs(r.x)));
  l3 += mix(l4,l5,smoothstep(0.4,0.6,abs(r.x)))*0.3;
  v3 += l3;
  v3 *= smoothstep(0.9,0.5,length(r.y));
  float vf = mix(v3 ,1.-v3,step(.5,fract(time*1.5)));
  return vf;}
  float ev2(vec3 r,float t){
    float b = sqrt(24.);float r1 = 0.;float t1 = fract(time*4.)+t;
    for(float  i = -0.5*b ; i <= 0.5*b ;  i+= 1.)
    for(float  j = -0.5*b ; j <= 0.5*b ;  j+= 1.){
      r1 += ev(r+vec3(i,0.,j)*0.02*t1,t1*0.1);
    }
    //float r1 = ev(r);
    return r1/24.;
  }
  float smin(float a, float b, float t){float h = clamp(0.5+0.5*(b-a)/t,0.,1.);
    return mix(b,a,h)-t*h*(1.-h);}
      float smax(float a, float b, float t){float h = clamp(0.5-0.5*(b-a)/t,0.,1.);
    return mix(b,a,h)+t*h*(1.-h);}
    float z1;
  float map(vec3 p){
    vec3 pb = p;
    for( int i = 0 ; i < 5 ; i ++){
      p -=0.7;
      p.xz *= rot(time); 
      p.yz *= rot(time*0.5); 
      p  = abs(p);
    }
    float d1 = box(p,vec3(1.+fract(time*3.5))*0.4);
   
    z1 = d1;
    float d2 = length(pb+vec3(sin(time*2.))*5.)-6.-sin(time);
    float d3 = smax(d2,-d1,3.);
     d1 -= (texture(texNoise,p.xz*0.1).x+texture(texNoise,p.yz*0.1).x+texture(texNoise,p.xy*0.1).x-fract(time*0.7))*0.8;
    float d4 = min(d3,d1);
    return d4;}
    vec3 nor(vec3 p){vec2 e = vec2(0.01,0.);return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *= 2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 r = normalize(vec3(uv+vec2((hs(uv)-0.5)*pow(length(uv.y),1.5)*pow(it(time*7.),1.8),0.),0.3+fract(time)));
  vec3 p = vec3(0.,0.,-7.);
  float t1 = it(time)*6.5*step(0.5,rd(time));
  r.xz *= rot(t1);
  r.yz *= rot(sin(time*1.2));
   p.xz *= rot(t1);
  p.yz *= rot(sin(time*1.2));
  float dd = 0.;
  for(int  i = 0 ; i < 64 ; i++){
    float d = map(p);
    if(dd>25.){dd=25.;break;}
    if(d<0.01){break;}
   p += r*d;
    dd += d;
  }
  float s = smoothstep(25.,5.,dd);
  float m = smoothstep(0.1,0.,z1);
  float s1 = ev2(r,0.);
  vec3 n = nor(p);
  float s3 = ev2(reflect(n,r),8.*m)*max(0.2,(1.-m)*0.6);
   float ld = dot(n,-r);
  float fr = pow(1.-ld,1.)*0.1;
  s3 += fr;
  float dao = 0.7;
  float ao = mix(0.2,1.,pow(clamp(map(p+n*dao)/dao,0.,1.),0.8));
  s3 *= ao;
  float s2 = mix(s1,s3,s);
  float tr = step(0.5,rd(time*4.));
  vec3 c1 = mix(vec3(1.),3.*abs(1.-2.*fract(s2*0.5+0.3+tr*0.2+vec3(0.,-1./3.,1./3.)))-1.,0.15+tr*0.2)*s2;
  //vec2 mv = vec2(no(uv*5.+vec2(time,-time)),no(uv*5.+59.236+vec2(-time,time)))-0.5;
 // vec3 t2 = mix(texture(texPreviousFrame,uc+mv*0.1).xyz,c1,max(smoothstep(0.4,0.5,it(uv*0.7+time)),smoothstep(0.3,1.,fract(time))));
	out_color = vec4(c1,0.);
}