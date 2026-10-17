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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float gtt=fGlobalTime;
float gt=texture(texFFTIntegrated,0.002).r*.12+gtt*.2;
float gttf=texture(texFFT,0.002).r*4;
float sttf=texture(texFFTSmoothed,0.002).r*4;

float cir(vec2 uv, float r) {
  return length(uv)-r;
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float po=4000;
  float bm=texture(texFFTSmoothed,0.002).r*po;
  
  vec2 zom=uv;
	uv -= 0.5;
  uv=floor(uv*bm)/bm;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 zm=uv;
  
  
  zom-=.5;
  zom*=1.01-(bm/po)*.15;
  zom+=.5;
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x);

	float f = texture( texFFTSmoothed, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  for(int i=0;i<9;i++){
    zm=abs(zm)+vec2(0,.0);
    zm-=.5;
    rot(zm,.1-gt*.2);
    zm+=.5;
    zm=abs(zm)-vec2(0.5,0);
    zm-=.5;
    rot(zm,-.1+gt*.11);
    zm+=.5;
  }
  
  float ftx=texture(texFFT,abs(zm.x*10)).r*20;
  vec3 prv=texture(texPreviousFrame,mod(zm,.8)).rgb;
  vec3 prev=texture(texPreviousFrame,zom).rgb;
  //rot(prv.xy,.5);
  rot(prv.xz,.3);
  rot(prev.xy,-.5);
  //rot(prev.xz,-.3);

  vec3 col = vec3(1-prv.g*100);
  float cr = cir(uv,.2);
  float cr2 = cir(uv*vec2(2.8,.9),.2);
  float cr3 = cir(uv*vec2(8,1.1),.2);
  
  col*=step(cr,f/10);
  col+=abs(prv)*.8;
  
  col+=ftx*gttf*10;
  
  if(prv.r+prv.g+prv.b<0.01){
    col=vec3(1);
  }
  col=prv*col+step(cr-0.05,f/10)*vec3(10,12,8);
  //col*=clamp(prev,0.5,.8)*step(cr-.2,1-sttf*.5);
  
  col*=1-step(cr2,0);
  
  if(col.r+col.g+col.b<0.01){
    col=vec3(prev);
  }
  float uv2=zom.y*40+abs(zom.x-.5*pow(length(zom-vec2(.5,.8))*5,4))+gt*10;
  
  if(mod(uv2,4)<2){
    col*=prev;
  }
  col+=step(cr3,0)*vec3(1,1,0);
  
	out_color = vec4(col,1);
}