#version 410 core
// what a blast doing both a shader and bytejam :S

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

float sdCir(vec2 p, float r) {
  return length(p)-r;
}

vec4 plas( vec2 v, float time )
{
	return vec4( v.x,v.y,v.x-v.y, 1.0 );
}

void rot(inout vec2 p,float a) {
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  float bm=texture(texFFTSmoothed,0.002).r*2000;
  
  uv=floor(uv*bm)/bm;
  
  vec2 uv_=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  bm-=length(uv-vec2(.5,0))*(bm*2);
  
  uv=floor(uv*bm)/bm;
  
  float gt = fGlobalTime;
  float ft = texture(texFFTIntegrated,0.002).r;
  float n = texture(texNoise,uv_*5+vec2(ft,gt)*.1).r;
  
  uv_-=.5;
  uv_*=.9;
  uv_+=.5;

	vec2 m;
  uv-=vec2(.5,0);
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x);

  uv+=vec2(.5,0);
	float f = texture( texFFT, d ).r * (.3+d*10)*10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float c = (mod(sdCir(uv-vec2(.5,0),.2+n*(.1+f*.1))-ft*.02,.5));
  uv_-=.5;
  for(int i=0;i<50;i++) {
    uv_=abs(uv_)+vec2(0.03,0);
    rot(uv_,gt*.004+ft*.01+n*.1);
    uv_=abs(uv_)+vec2(0,0.01);
    rot(uv_,n*.001);
  }
  uv_+=.5;
  float c2= mod(sdCir(uv_,.2)-ft*.002,.1);
  vec4 p = texture(texPreviousFrame, uv_);
	vec4 t = vec4(5);
  t *= .5-c*2;
  t += vec4(step(c2*10,0.05+f));
  vec4 a = vec4(0.8,0.4,0.3,1);
  vec4 b = vec4(0.8,.8,1,1);
  t=t+p*-2;
  t = mix(a*(1*n*2),b*2,floor(t)/1.5);
	out_color = t;
}