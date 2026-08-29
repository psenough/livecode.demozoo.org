#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
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

float BPM=128;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float Gt=fGlobalTime/60*BPM;
  float fGt=fract(Gt);
  float iGt=floor(Gt);
  float pGt=iGt+fGt*fGt*fGt*fGt;
  float low=texture(texFFTSmoothed,0.02).r*900;
  float reso=(350+sqrt(fGt)*200);
  uv=floor(uv*reso)/reso;
  vec2 uv_=uv;
  vec2 uv2=uv;
  uv_-=.5;
	uv_ /= vec2(v2Resolution.y / v2Resolution.x, 1);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
 
  
//  uv+=vec2(0.25*pGt*(floor(uv.y)+.5),0);
  //uv=mod(uv+1,2)-1;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;


  vec2 uvID=uv_;
  float no=texture(texNoise, uv2).r;
  uv2-=.5;
  uv2*=1+no*.1-(fGt*fGt*fGt*fGt)*.2;
  uv2+=.5;
  float le=length(uv_);
  vec4 prev=texture(texPreviousFrame,uv2);
  
  //uvID+=vec2(.5*pGt*(floor(uvID.y*(8+mod(iGt,16)+1))+32-mod(iGt,16)/2),0);

  rot(uvID,0.25*le*(-3+mod(pGt*3,7)));

  for(int i=0;i<10;i++){
    uvID=abs(uvID)-vec2(.1,i*.02);
    uvID=mod(uvID,(1+mod(iGt,4))*.5);
    rot(uvID,pGt*.1-i*.1);
  }
  
  m=uvID;
	float d = abs(min(m.y,m.x));

	float f = texture( texFFT, d ).r * 30;
  f=f*f*f*f;
  f=.1+min(f,1);
  vec2 uv_C=uv_*vec2(1,-1)*(.8-pow(1-fGt,4)*.2)+vec2(.45,.6);
  uv_C=clamp(uv_C,0,1);
  vec4 ineC=texture(texInercia2025, uv_C);
  vec4 ineBW=texture(texInerciaBW, uv_);
  vec4 ineID=texture(texInercia2025, uvID*4);
  
	vec4 t = vec4(0); //plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  t=vec4(1*f,2*f,3*f,1);
  rot(t.xz,uvID.y);
  rot(t.yz,uvID.x);
  rot(prev.yz,.05);
	out_color = t+ineID*(1-fGt)*3*(1-le*.4)+prev*.7*(le*1.2);
 // rot(out_color.zy,fGt*le*.8);
 out_color-=(ineC.r+ineC.b+ineC.g);
 out_color+=ineC;
  out_color=vec4(vec3(out_color.rgb*out_color.rgb),out_color.a);
}