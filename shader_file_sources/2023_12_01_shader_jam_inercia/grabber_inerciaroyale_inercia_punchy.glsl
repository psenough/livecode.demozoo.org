#version 410 core

/****
Radio bonzo

Credit: 
 grabber_inerciaroyale_cosamentale_2021.glsl 
****/

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
float time=  fGlobalTime*1.5;
mat2 rot(float t){ float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}
float zl;
float box(vec3 p ,vec3 b){ vec3 q = abs(p)-b;
  return length(max(q,vec3(0.)))-min(0.,max(q.x,max(q.y,q.z)));}
float map(vec3 p,vec4 ta){
  
  float t1 = ta.z;
  float d4 = length(p*vec3(0.1,5.,0.1)+vec3(0.,-10.-step(0.1,fract(time))*100.,0.))-2.;
  float d1 = 100.;
  vec3 rr = vec3(3.,0.,0.);
  vec3 pv = p;
  vec3 rv = vec3(5.,0.,5.);
  vec3 pl = mod(p,rr)-0.5*rr;
  if(step(0.5,fract(time*0.25))>0.){
   d1 = max(length(p+vec3(0.,2.,0.)+vec3(ta.x,0.,ta.y))-t1*5.,-(length(p.y+sin(time*5.)*5.)-2.));
  }
  else{ d1 = length(pl.xz+ta.xy)-0.5;}
  float d2 = p.y+1.5+texture(texNoise,p.xz*0.1).x*3.+sin(length((p.xz+ta.xy)*2.)-time*10.)*t1*0.25;
  vec3 pr = p;
  pr.xz *=  rot(p.y);
  float d3 = distance(p.y,0.2)-texture(texNoise,pr.xz*0.2).x+0.225;
  zl = min(d4,d1);
  return min(min(d1,min(d3,d2)),d4);}
  float rm(vec3 p,vec3 r,vec4 ta){
    float dd = 0.;
    for(int  i =0 ; i <64 ; i++){
      float d = map(p,ta);
      if(dd>20.){dd=20.; break;}
      if(d<0.01){break;}
      p += r*d;
      dd += d;
    }
    return dd;
  }
  vec3 nor(vec3 p,vec4 ta){vec2 e = vec2(0.01,0.); return normalize(map(p,ta)-vec3(map(p-e.xyy,ta),map(p-e.yxy,ta),map(p-e.yyx,ta)));}
  float rd(float t){ return fract(sin(dot(floor(t),45.))*7845.26);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *= 2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float tm = smoothstep(0.1,0.,fract(time));
    vec2 pm  = (vec2(texture(texNoise,vec2(0.5,time*5.)).x,texture(texNoise,vec2(0.25,time*5.)).x)-0.5)*0.1;
  float l2  =step(0.75,fract(time*0.5));
  float l1 = mix(0.,step(0.5,uc.y),l2);
  float mmv= pow(texture(texNoise,vec2(time,0.3)).x,0.5);
  vec3 p = vec3(0.,0.,-2.*mmv-4.);
  
  //float t2 = texture(texNoise,vec2(0.5,floor(time))).x*2.;
  vec3 r = normalize(vec3(uv+vec2(0.,-mix(0.5,mix(-0.2,0.5,l1),l2))+tm*pm,rd(time)*2.));
  float tt = mix(time,-time,l1);
  r.xz *= rot(tt);
  p.xz *= rot(tt);
  
  float tx = fract(floor(time)*0.1)*10.;
  vec2 px  = (vec2(texture(texNoise,vec2(0.5,tx)).x,texture(texNoise,vec2(0.25,tx)).x)-0.5)*5.;
  vec4 ta = vec4(px,pow(fract(time*0.7),3.),0.);
  
  //float r1 = smoothstep(10.,0.,rm(p,r));
	float r2 = 0.;
  float se = fract(sin(uv.x*v2Resolution.y+uv.y)*7845.236);
  float se2 = se*6.28;
  float a = sqrt(1.-se*se);
  vec3 rn = vec3(a*cos(se2),a*sin(se2),(se-0.5)*2.);
  rn *= sqrt(se);
  for(int  i = 0 ; i < 2 ; i++){
    float d = rm(p,r,ta);
    if(step(0.1,zl)>0.2){
      vec3 pp = p+ r*d;
      vec3 n = nor(pp,ta);
      r = n*rn;
      p = pp+r*0.1;
    }
    else{r2=1.;break;}
  }
  float b = sqrt(32.);
  float c = 0.;
  float d = pow(length(uv.y),1.5)*texture(texNoise, vec2(0.75,time)).x*0.02;
  for(float i = -0.5*b;  i<= 0.5*b ; i +=1.)
  for(float j = -0.5*b ; j<=0.5*b ; j +=1.){
    c += texture(texPreviousFrame,uc+vec2(i,j)*d).a;
  }
   c /= 5.;
  float  c2 = c+r2;
  vec3 c3 = mix(vec3(1.),3.*abs(1.-2.*fract(c2*0.3+0.5+vec3(0.,-1./3.,1./3.)))-1.,0.2)*c2;
	out_color = vec4(c3,r2);
}