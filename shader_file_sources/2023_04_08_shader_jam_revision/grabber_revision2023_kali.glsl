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

#define time fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float det=.001, it;
float cyl;
float so=0.;
float id=0.;

mat2 rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c,s,-s,c);
}

float hash(vec2 p)
{
  p*=1000.;
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


vec3 path(float t) {
  float s=sin(t*.1+cos(t*.05)*2.);
  float c=cos(t*.3);
  return vec3(s*s*s,c*c,t);
}

float de(vec3 p) {
  id=0.;
  p.xy-=path(p.z).xy;
  p.xy*=rot(p.z*1.+time*.7+so*50.);
  vec3 p2=p+sin(p.z)*.2;
  float m=1000., sc=1.;
  float s=sin(p.z*.7)*.7;
  float sph=length(p.xy)-1.3-s;
  //p2.xy*=rot(time);
  cyl=length(p2.xy+.5*s+.1)-.05-fract(-p.z+time*3.)*.05;
  cyl*=.7;
  for (int i=0; i<8; i++) {
    float s=2.;
    p.xy=sin(p.xy);
    p.xy*=rot(1.);
    p.xz*=rot(1.6);
    p=p*s;
    sc*=s;
    float l=length(p.xy)-.2;
    m=min(m,l);
    if (m==l) it=float(i);
  }
  float d=m/sc;
  d=max(d,-sph);
  d=min(d,cyl);
  if (d==cyl) id=1.;
  return d;
}

vec3 normal(vec3 p) {
    vec2 e=vec2(0.,det);
    return normalize(vec3(de(p+e.yxx),de(p+e.xyx),de(p+e.xxy))-de(p));
}

vec3 march(vec3 from, vec3 dir) {
    vec3 p, col=vec3(0.);
    float d, td=0., maxdist=8.;
    float g=0.;
    float r=hash(dir.xy);
    for (int i=0; i<200; i++) {
        p=from+dir*td;
        d=de(p)*(1.-r*.2);
        if (d<det || td>maxdist) break;
        td+=d;
        g+=.1/(.1+cyl*5.);
    }
    if (d<det) {
        vec3 n=normal(p);
        col=normalize(1.+dir)*.3*max(0.,-n.z);
        if(mod(floor(-time*4.+p.z*1.5),8.)==it) col+=1.; 
        if (id==1.) col=vec3(1.,.5,.2)*max(0.,n.x);
    } else td=maxdist;
    col.rb*=rot(dir.y*1.5);
    col=mix(col,vec3(1.,.7,.5)*exp((-1.5+so*150.)*length(p.xy-path(p.z).xy))*(1.5+so*70.),pow(td/maxdist,1.5));
    col+=g*.05*vec3(1.,0.5,.3);
    return col;
}

mat3 lookat(vec3 dir) {
    vec3 up=vec3(0.,1.,0.);
    vec3 rt=cross(up,dir);
    return mat3(rt,cross(dir,rt),dir);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=1.5+sin(length(uv)*10.+time)*.1;
  
  for (float x=0.; x<1.; x+=.2) so+=texture(texFFTSmoothed, x).x;
  so*=.1;
  
  float t=time*1.5;
  
  vec3 from = vec3(0.,0.,time*20.);
  from=path(t);
  from.x+=.5;
  vec3 adv=path(t+1.);
  vec3 rdir=normalize(adv-from);
  vec3 dir = normalize(vec3(uv,1.));
  dir=lookat(rdir)*dir;
  dir*=1.+tan(t*.25)*.05;
  //dir.xz*=rot(tan(t*.1));
  
  vec3 col = march(from, dir);
  vec3 fback=texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy).rgb;
  col=mix(col*col,fback,.5);
  
	out_color = vec4(col,1.);
}