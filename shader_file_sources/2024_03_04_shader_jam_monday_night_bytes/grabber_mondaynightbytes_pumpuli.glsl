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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time ) {
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}
float sum( in vec2 a) {
  return a.x+a.y;
}
float sum( in vec3 a) {
  return a.x+a.y+a.z;
}
float sum( in vec4 a) {
  return a.x+a.y+a.z+a.w;
}
float sdEqTri( in vec2 p, in float r )
{
  const float k = sqrt(3.0);
  p.x = abs(p.x) - r;
  p.y = p.y + r/k;
  if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
  p.x -= clamp( p.x, -2.0*r, 0.0 );
  return -length(p)*sign(p.y);
}

float sdHex( in vec2 p, in float r )
{
	const vec3 k = vec3(-0.866025404,0.5,0.577350269);
	p = abs(p);
	p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
	p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
	return length(p)*sign(p.y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float t = fGlobalTime;
  float ft=texture(texFFTIntegrated,.002).r*.002;
  float ft2=texture(texFFTIntegrated,.6).r*.20;
  float bm=texture(texFFTSmoothed,.02).r*10;
  
  vec2 uv_=uv;
  uv=round(uv*(5000*bm))/(5000*bm);
  
  rot(uv,ft*.5-ft2*.5+t*.1);
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv*8) * .2;
	float d = m.y;
  
  uv_-=.5;
  uv_*=.99;
  uv_+=.5;
  
  vec4 prev=texture(texPreviousFrame,uv_);
  
	float fft = texture( texFFT, pow(abs(m.x)+.05,2) ).r * 10000;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  float zom=ft*50+abs(m.y*4);
  
  zom=mod(zom,2);
  
  float hex=sdHex(uv,.1*zom);
  float hexft=sdHex(uv,.8*zom+fft*.0002);
  float inhex=1-(step(hexft,0)*2);

  vec2 p = uv;
  
  for(int i=0; i < 50; ++i){
    uv=abs(uv)-vec2(.4+abs(sin(ft))*.4,.2+abs(cos(ft*.8))*.4);
    rot(uv,ft*(.5-step(hex,0)));
    uv=mod(abs(uv)-vec2(0,ft*10),10);
    rot(uv,bm*.02);
  }
  
  float bhex=sdHex(uv,.2);
  
  uv+=mod(ft*.1+t*.03,10);
  
  float fx = texture(texFFTSmoothed,pow(abs(uv.x)+.02,2)).r*10;

	vec4 col = vec4(0)+fx;
  col*=abs(bhex);
  col= col/(1+abs(hex)*fft)+col;
  col-=vec4(.2,.4,.2,1)*inhex;

	col = clamp( col, 0.0, 1.0 );
  
  if(sum(col)>2){
    col=prev*vec4(4,2,1,1);
  }
  if(sum(col)<0.2){
    col=vec4(sum(prev))*vec4(1,4,2,1);
  }
  
	col = clamp( col, 0.0, 1.0 );
  
	out_color = col;
}