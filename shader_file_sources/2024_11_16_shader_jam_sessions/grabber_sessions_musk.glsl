#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T (fGlobalTime)
#define PI (3.14159)
#define PT (T*PI)

mat2 rot(float a){ float c=cos(a),s=sin(a);return mat2(c,s,-s,c); }

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
mat2 R0=rot(.1);
float box(vec3 p) { vec3 ap=abs(p); return max(ap.x,max(ap.y,ap.z)); }
float tun(vec3 p, float s=2.0, float z=0.5) { p=mod(p,s+s)-s; return box(p)-z;}
float df(vec3 p) {
  vec3 p3=p;p3.xy*=rot(p3.z*.1);
  float d=min(tun(p3,2.0), tun(p3,4.0,2.0));
  d=min(d,3.0-abs(p3.x));
  float s = 2.0;
  vec3 p2=p;
  for (int i=0; i<18; i+=1) {
    p2+=vec3(.94,.12,.41);
    p2.xy*=R0;p2.yz*=R0;
    float d2=tun(p2,s*2.0,s);
    d=min(d,max(d-s/8,d2));
    s*=0.85;
  }
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d*d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 layer1 = plas( m * 3.14, fGlobalTime ) / d;
  float l0z = sin(PT*0.1)+1.0; mat2 l0r=rot((sin(T)+T)*.01);
	vec4 layer0 = clamp( (layer1+f*.1)*(texture(texSessions,uv*l0r*vec2(1,2)*l0z+T*vec2(.1,-.1)).x), 0.0, 1.0 );
  if (fract(T/8.0*PI/2.0)<.5)
    layer0 = clamp( (layer1+f*.1)*(texture(texSessionsShort,uv*l0r*vec2(1,1)*l0z*8.0+T*vec2(.1,-.1)).x), 0.0, 1.0 );
  
  vec3 pos=vec3(sin((T*.05-fract(T*.05))),sin((T*.1-fract(T*.1))),-4+T),
  dir=normalize(vec3(uv,1-length(uv)));dir.xy*=rot(PT*.1-fract(T*.1));
  dir.xz*=rot(sin(PT/8-fract(PT/8))*sin(PT/4-fract(PT/4)));
  
  float dist,t=1e-3;
  int i,maxit=200;
  for (i=0;i<maxit;i+=1) {
    dist=df(pos+dir*t);
    t+=dist;
    if (dist<1e-3||dist>1e+3) break;
  }
  float ig=float(i)/900.0;
  vec3 p2=pos+dir*t;
  
  for (int i=0;i<10;i+=1){
    float w=sin(i)+0.01;
    ig+=df(p2+vec3(vec2(w)*rot(T+i),0))/w*.1;
  }
  ig+=smoothstep(.99,1.0,sin(40.*df(p2+vec3(0,0,1))))*sin(T*4.0+p2.z);
  ig+=smoothstep(.9,1.0,sin(10.*df(p2+vec3(0,0,1))))*sin(T*4.0+p2.z);
  ig=max(0,ig);
  ig*=1-length(uv);
  
  float f0=fract(T/16)-T/16;
  vec3 c=max(vec3(0.),1.5+sin(vec3(f0+1,f0+2,f0+3)));
  if (fract(T/8)<.5) c=vec3(1.0,2.0,3.0);

  vec4 fin = layer0*.0+pow(vec4(ig),vec4(c,1))*(1.0+sin(T)*.5)*9.0;
  
  layer0=pow(vec4(1.2)*fin/(1.0+fin),vec4(0.5));
  vec4 prev = texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy+sin(vec2(T,T+PI/2)*4.1)*.01);
  for (int i=0;i<20;i+=1){ 
   prev += texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy+sin(float(i)+vec2(T,T+PI/2)*1.1)*.011);
  }
  prev*=.05;
  
  out_color = mix(fin,prev,0.7);
}