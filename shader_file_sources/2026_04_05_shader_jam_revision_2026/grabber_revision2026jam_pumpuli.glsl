#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texZX;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void rot(inout vec2 p, float a) {p=cos(a)*p+sin(a)*vec2(-p.y,p.x);}

float BPM=135;
float PI=3.1415;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv2=uv;
  vec2 uv3=uv2;
  vec2 uv4=uv3;
  vec2 zom=uv;
  float gt=fGlobalTime/60*(BPM);
  float gti=floor(gt);
  float gtf=pow(gt-gti,4);
  float gtc=gti+gtf;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float low=texture(texFFT,.002).r*10;
	uv2 -= 0.5;
	uv2 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv2*=1-low*low*.008;
  float l=length(uv2);
  float sl=step(mod(l,.25),.13);
  rot(uv2,gt*(.5-sl)*(1+floor(l*4)));
  uv2+=vec2(.5);
  
	uv3 -= 0.5;
	uv3 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv3*=4-low*low*.008;
  uv3 += .5;
  
	uv4 -= 0.5;
	uv4 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv4*=2-low*low*.02;
  uv4-=vec2(mod(gt/2,8)-4,0)*.5;
  rot(uv4,gtc*PI/2+.2);
	uv4 += 0.5;
  
  zom-=.5;
  zom*=.9+low*.03;
  rot(zom,abs(zom.x)*.1);
  zom+=.5;
  
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
  vec4 prev=texture(texPreviousFrame,zom);

	float f = texture( texFFT, d ).r * 100;
  
  uv3*=vec2(1,-1);
  uv4*=vec2(1,-1);
  
  vec4 revi=texture(texRevisionBW,vec2(min(1,max(0,uv2.x)),min(1,max(0,uv2.y))));
  vec4 dritt=texture(texDritterLogo,uv3);
  vec4 dritt2=texture(texDritterLogo,vec2(min(1,max(0,uv4.x)),min(0,max(-1,uv4.y))));
  
  for(int i=0;i<4;i++){
    uv4=abs(uv4)-vec2(0,.5);
    rot(uv4,gtc);}
  
  dritt2=texture(texDritterLogo,vec2(uv4.x-gtc*(.5-step(uv4.y,-.5)),min(0,max(-1,uv4.y))));
	vec4 t = vec4(.2);
	t = clamp( t, 0.0, 1.0 );
  float drs=step(dritt.x,.2);
  rot(prev.xy,0.0+(0.5-drs)*(low*.1));
	out_color = revi*(1-prev*2)+prev*.9+vec4(step(dritt2.x,0));
}