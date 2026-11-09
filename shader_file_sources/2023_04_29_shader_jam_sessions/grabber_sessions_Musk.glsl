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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

float PI=3.14159;
float T,DT;

void g() {
  T=fGlobalTime;
  DT=texture(texFFTIntegrated, 0.01).x/4;
}

mat2 rot(float a){ float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v )
{
	float c = 0.5 + sin( v.x * 190.0 ) + cos( sin( DT + v.y ) * 20.0 )*cos(v.y/2);
	float f = texture( texFFT, fract(sin(v.x*PI)) ).r;
  c=abs(c); vec3 c2=vec3(sin(c * 0.2 + cos(DT*2.0+v.y*0.5)), c * 0.15, cos( c * 0.1 + DT / .4 ) * .25); c2=vec3(length(c2));
  c2+=f;
	return vec4(c2 , 1.0 );
  
}

vec3 pat1(vec2 p, float s) {
  float e=0.4;float a=0,h=0;vec2 id;
  for(int i=0;i<5;i+=1){
    e=e/2;
    vec2 fp=mod(p,e);
    id=p-fp;
    h=fract(pow(id.x*83.3+id.y*3.42,2.0)+DT/16); float q=texture(texFFTIntegrated,id.x*42.42+id.y*4.42).x;
    a=min(min(e-fp.x,e-fp.y),min(fp.x,fp.y))-clamp(s,-cos(q)*e/1,1);
    if (h<.2) break;
  }
  float f=smoothstep(-s,s,a);
  float ssbg = texture(texSessions, p*vec2(1,-2)+T/10).x; f+=ssbg;
  return f*mix(vec3(0.2,0.4,0.3), vec3(0.9,0.13,0.1),smoothstep(0,1,fract(h*h*4+id.x))*(sin(id.x+id.y*44+DT)*.5+.5))*4.0;
}

float df(vec3 p){
  return length(p)-1.0;
}

vec3 scene(vec2 uv) {
  vec3 p=vec3(0,0,-4);
  vec3 dir=normalize(vec3(uv, +1));
  float t=0.01,dist=0; int it;
  for (it=0; it<100;it+=1){
    dist=df(p+dir*t);
    t+=dist; if (dist<1e-3||dist>1e+3) break;
  }
  vec3 c=vec3(it)/64;
  return c;
}

void main(void)
{
  g();
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);float pscale=1/v2Resolution.y;
	uv -= 0.5; uv /= vec2(v2Resolution.y / v2Resolution.x, 1); uv+=uv*pow(length(uv),4.0)*.2;

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
  vec3 ssbg;
  ssbg += pat1(uv+sin(vec2(DT,T)*4)/420+vec2(0,T/10),pscale);
  // typed by cat, I'll keep this here: llllllllllllllllllllllllllllllle324t5rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr5

	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14 ) / d;
  vec3 c=t.xyz*0;
  
  c+=ssbg+scene(uv);
  
  c*=sqrt(max(vec3(0),(1.0-abs(uv.xxx*vec3(1.01,1.02,1.03)*1)))*max(vec3(0),(0.5-abs(uv.yyy*vec3(1.03,1.02,1.01)*1))));
  float w=dot(c,vec3(.3,.5,.2)); c=mix(c,vec3(w),-0.5);
  c=1.4*c/(c+1.0);
	t = clamp( vec4(sqrt(c),1), 0.0, 1.0 );
	out_color = t;
}