#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float T,H,H2,ST;

mat2 rot(float a){float c=cos(a);float s=sin(a);return mat2(c,s,-s,c); }

void g(){
  T=fGlobalTime;
  H=texture(texFFTIntegrated,0.0).x;
  H2=texture(texFFTIntegrated,0.05).x;
  ST=T-mod(T,4)-mod(T,6);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float df(vec3 p) {
  float ball=length(p)-1.0;
  float flr=1.0-p.y;
  p.xy*=rot(p.z/10+T);
  vec3 p2=p;
  p2=mod(p2,4.0)-2.0;
  vec3 p2id=p-p2;
  vec3 ap=abs(p2)-1.0;
  ball = length(p2)-(0.5+fract(p2id.x*42.3143+H+p2id.y*1.4134+p2id.z*4.314));
  return min(ball, max(ball-.2, ap.x+.2));
}

vec3 nf(vec3 p, float s) { vec2 e=vec2(0,s); return normalize(vec3(df(p+e.yxx)-df(p-e.yxx),df(p+e.xyx)-df(p-e.xyx),df(p+e.xxy)-df(p-e.xxy))); }


float trace(vec3 p, vec3 d, float st, float et){
  float t=st;
  for (int i=0; i<100; i+=1) {
    float dist=df(p+d*t);
    if (dist<1e-3||dist>et) break;
  }
  return t;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  g();

	vec2 m;m.x = atan(uv.x / uv.y) / 3.14;m.y = 1 / length(uv) * .2;float d = m.y;
  float f = texture( texFFTSmoothed, uv.x*.5-.5 ).r * 100;m.x += sin( fGlobalTime ) * 0.1;m.y += fGlobalTime * 0.25;vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  
  vec3 p0=vec3(0,0,-4+T*4+H2*5), d0=normalize(vec3(uv.xy,+1+length(uv)*.5));
  d0.xy*=rot(T/4);
  d0.xz*=rot(sin(ST/2)*.25);
  d0.yz*=rot(sin(ST/4)*.25);
  
  vec3 c=vec3(0);
  vec3 w=vec3(1);
  
  for (int i=0; i<1; i+=1){
    float dist=trace(p0,d0,1e-3,1e+4);
    vec3 p1=dist*d0+p0;
    c=fract(p1);
  }
  
  for (int i=0;i<100;i+=1){
    p0+=d0*df(p0);
  }
  c=p0;
  vec3 n=nf(p0,1e-3);
  float fr=1.0+dot(d0,n);
  c=(n*.5+.5)*.1+fr;
  
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  out_color.xyz=c+t.xyz/4+f*.1;
  
  c=out_color.xyz;
  c*=1-length(uv);
  vec3 C=mix(vec3(4,2,1), vec3(1,2,4), smoothstep(.1,.2,sin(T/3)));
  c*=C*1.9;
  c+=c.zyx*.1;
  c=1.4*c/(1+c);
  
  out_color.xyz=c;
  
  
}