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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T (fGlobalTime)

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void R(inout vec2 p,float a)
{
  a*=2*3.141593;
  p=p*cos(a)+sin(a)*vec2(-p.y,p.x);
}

float Rep(float p,float r)
{
  return mod(p,r)-r/2;
}

void dmin(inout vec4 d,vec4 b)
{
  if(b.x<d.x) d=b;
}

vec4 F(vec3 p)
{
  R(p.xz,sin(T*.7)*.1);
  vec3 p0=p;
  
  float r=mod((T+123)*sin(T*234),1);
  R(p.xy,fGlobalTime/10);
  vec3 q=p;
  R(q.xz,.1);
  float r2=mod(sin(sin(T*4)*4+floor(q.z/.1)*.1*sin(T)*5),1);
//  vec4 d=vec4(length(p)-1-r2*.3,.4,length(p)<3?1:0,.3);
  vec4 d=vec4(max(length(q)-.3-r2*r2,abs(Rep(q.z,.1))-.04),.4,length(q)<3?1:0,.3);

  float e=length(p.xy);
  e=abs(Rep(e,2))-.5;
  dmin(d,vec4(p.z+1.5,sin(p.x*2)*sin(p.y*2)>0?.4:.2,0,0));
  dmin(d,vec4(max(-p.z+1.5,abs(e)),sin(p.x*2)*sin(p.y*2)>0?.4:.2,0,0));
 
  
  q=abs(p);
  q-=2;
  
  dmin(d,vec4(length(q.xy)-.01,.4,1+r*2,-.3));
  
  float b=abs(10+sin(T)*8-length(p.xy))-.1;
  R(p.xy,sin(T));
  p.z-=sin(T*6)*sin(T);
  p=abs(p);
  b=max(b,abs(p.z)-.1);
  b=max(b,min(p.x,p.y)-4);
  dmin(d,vec4(b,.4,1+r,.3));

  d.x=max(d.x,.5-length(p0.xz));
  
  if(d.z==0) d.w=0;
  return d;
}


void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 rd=normalize(vec3(uv.x,1,uv.y));
  vec3 ro=vec3(0,-8+sin(T)*4,0),p;
  vec4 s1=vec4(0), s2=vec4(0), v;
  vec2 e=vec2(.01,0);
  
  float N=200, q1=.3, q2=.1;
  
  for(int i=0;i<N;i++)
  {
    s1+=v=F(p=ro+rd*s1.x*q1);
    vec3 n=normalize(vec3(
      F(p+e.xyy).x, F(p+e.yxy).x, F(p+e.yyx).x
    )-v.x);
    float u=(i+.5)/N*2-1;
    vec3 h=vec3(sqrt(1-u*u),0,u);
    float r=uv.x*41+uv.y*101+fGlobalTime*100;
    r=(r+123)*sin(r*234);
    R(h.xy,r+i*.382);
    n=normalize(n+h*v.y);
    s2+=F(p+reflect(rd,n)*s2.x*q2);
  }
  s1+=s2;
  
 // out_color = vec4(1/(s1.x+1)*4);
  out_color = vec4(s1.z-s1.w,s1.z,s1.z+s1.w,0)/N;
  

/*	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  */
}