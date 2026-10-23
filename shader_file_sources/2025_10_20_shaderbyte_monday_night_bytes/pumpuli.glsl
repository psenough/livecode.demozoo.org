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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}
int BPM=160;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv_=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float Gt=fGlobalTime/60*BPM;
  Gt=mod(Gt,32);
  float low=texture(texFFT,.02).r*2;
  float lowS=texture(texFFTSmoothed,.1).r;
  float lowI=texture(texFFTIntegrated,.01).r;
  lowI=20+mod(lowI,100);
  uv_-=.5;
  rot(uv_,uv_.y*.08*(mod(floor(Gt/2),3)-1));
  uv_*=2-lowS*8;
  uv_+=.5;
  vec4 prev=texture(texPreviousFrame,uv_);
  
  for(int i=0;i<20;i++){
    uv=abs(uv)-vec2(.4-sin(lowI*.2*sin(uv_.y*.01+lowI*.0011))*.1*cos(uv_.x*.4+floor(Gt*.01)*.0125)*2,.05*mod(floor(Gt*.01),7));
    rot(uv,lowI*.01*(10-i)*.8);
  }
  uv=mod(uv,1.25-.25*mod(floor(Gt*(mod(floor(Gt/8),4)))*8,5));
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = exp(abs(uv.x/2));
  
  float n=texture(texNoise,uv+vec2(Gt*.21,Gt*.22)*.1).r;
  
	float f = texture( texFFTSmoothed, d*20 ).r *40*d*d*d;
  f*=(1-m.y)*(1-n*1.5);
  f=pow(f+.2,4);
  
  vec4 c=vec4(1,0.3,1,1);
  
  rot(prev.rb,.72*sin(lowI*.31));
  
  c=f*c+prev*.7;
  
	out_color = c;
}