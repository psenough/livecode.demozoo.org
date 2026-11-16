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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define T fGlobalTime
#define O(X) sin(X*T*3.14159*171/60)
#define M(X,Y) (mod(X,Y+Y)-Y)

mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }

mat2 _R2;

float df(vec3 p) {
  p.xy*=rot(-p.z*0.1+O(0.1));
  vec3 rp=M(p,2);
  //float d=length(p)-1+O(1)*0.01;
  float d=1e9;
  d=min(d,p.y+2);
  d=min(d,2-p.y);
  d=min(d,p.x+2);
  d=min(d,2-p.x);
  d=min(d,length(rp)-0.5-O(1));
  float s=1;
  for (int i=0; i<10; i+=1) {
    p.xz*=_R2;
    p.yz*=_R2;
    vec3 rp2=M(p,s);
    s*=0.5;
    d=max(d-0.1*s,min(d,length(rp2.xz)-s));
    d=max(d-0.1*s,min(d,length(rp2.yz)-s));
  }
  return d;
}

vec3 nf(vec3 p) {
  vec2 e=vec2(0,1e-3);
  return normalize(vec3(
    df(p+e.yxx)-df(p-e.yxx),
    df(p+e.xyx)-df(p-e.xyx),
    df(p+e.xxy)-df(p-e.xxy)
  ));
}

void main(void)
{
  _R2=rot(0.1);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, uv.x*0.5-0.5 ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  vec3 col=vec3(0);
  
  float s=1.0;
  for (int i=0; i<10; i+=1){
    
    //uv.xy += sin(uv.yx*s);
    s*=0.5;
  }
  
  float t=1e-3;
  vec3 pos = vec3(0,0,-4);
  pos.z+=T*16+O(2);
  vec3 dir=normalize(vec3(uv.xy,1));
  int maxit=100,i;
  for (i=0; i<maxit; i+=1){
    float dist=df(pos+t*dir);
    t+=dist;
    if (dist<1e-3) break;
  }
  vec3 pos2=pos+t*dir;
  

  col=uv.xyx;
  col+=f*0.1;
  col=fract(pos2);
  vec3 n=nf(pos2);
  col=abs(n);
  col=vec3(1)*float(i)/float(maxit);
  col+=abs(n)*0.4;
  col+=smoothstep(.1,.2,sin(df(pos2+vec3(1,1,1))*50))*smoothstep(-.4,.2,sin(T*20+df(pos2+vec3(1,-1,+1))*20))*vec3(1,1,1)*0.2;
  
  
  
	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
  
  
	out_color = vec4(col,1);
  
}