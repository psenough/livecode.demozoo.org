#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float PI=3.14;
float BPM=137;

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
  vec2 zom=uv;
  vec2 zom2=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float bm2=texture(texFFT,0.01).r;
  float reso=2000;
  uv=floor(uv*bm2*reso+.5)/(bm2*reso);
  zom2=floor(zom2*bm2*reso*5+.5)/(bm2*reso*5);

  
  float Gt=mod(fGlobalTime,10000);
  float snc=Gt/60*BPM*4;
  
  float bm=texture(texFFTIntegrated,0.02).r;
  bm=mod(bm,PI*2);
  float sn=0;
  for(float fi=0.25;fi<1;fi+=.01){
    sn+=texture(texFFTSmoothed,fi).r;
  }
  
  zom-=vec2(.5);
  zom*=1.0+0.1*bm2;
  rot(zom,bm2*.1*zom.x);
  zom+=vec2(.5);
  
  vec4 prev=texture(texPreviousFrame,zom);
  
  rot(prev.gb,5);
  vec2 uv_=uv;
  
  for(int i=0;i<40;i++){
    uv_=abs(uv_)-vec2(.0,0+sin(bm*.002)*.1);
    uv_-=vec2(.2,.001*i);
    rot(uv_,bm*.01*.1*length(uv_)+PI*.2+Gt*.2-bm*.01+sn*.1);
    uv_+=vec2(.2,.001*i);
    uv_=abs(uv_)+vec2(mod(Gt*.0001,1),0);
  }
  vec2 uv2=uv_*vec2(.7,-1)-vec2(.5);
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  float ax= abs(uv_.x*.2);
  float ux=abs(m.x*.08);

	float f = texture( texFFT, ux ).r * 10*(.4/d);
  float f2= texture( texFFTSmoothed, ax).r*10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  vec4 c = vec4(0);
  //c=f+t;
  uv_=mod(uv_,.75);
  vec4 inc=texture(texInerciaLogo2024,uv_*vec2(.7,-1)-vec2(.5)).bbba;
  vec4 incf=texture(texInerciaLogo2024,uv_*vec2(.7,-1)-vec2(.5,.5-f2*.1)).rrrr;
  vec4 inc3=texture(texInerciaLogo2024,zom2*vec2(1,-1)).gggg;
  uv2-=vec2(.2);
  uv2=mod(uv2+vec2(.1,.1),vec2(.25,.4));
  uv2+=vec2(.37,-.02);
  vec4 inc2=texture(texInerciaLogo2024,uv2);
  if((inc.r+inc.g+inc.b)>f2){c=inc+incf*.2;}
  else{c=prev*.95;}
	out_color = c*inc+inc2*(1+f)+prev*.9*f;
  if(snc-floor(snc)>.5){out_color=prev*.9;}
  if(snc/8-floor(snc/8)<.5){}else{out_color+=inc3*10;}
}