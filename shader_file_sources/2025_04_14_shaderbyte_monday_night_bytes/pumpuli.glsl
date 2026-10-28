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

vec3 palette[16] = vec3[](
vec3(0x1a/255., 0x1c/255., 0x2c/255.),
vec3(0x5d/255., 0x27/255., 0x5d/255.),
vec3(0xb1/255., 0x3e/255., 0x53/255.),
vec3(0xef/255., 0x7d/255., 0x57/255.),
vec3(0xff/255., 0xcd/255., 0x75/255.),
vec3(0xa7/255., 0xf0/255., 0x70/255.),
vec3(0x38/255., 0xb7/255., 0x64/255.),
vec3(0x25/255., 0x71/255., 0x79/255.),
vec3(0x29/255., 0x36/255., 0x6f/255.),
vec3(0x3b/255., 0x5d/255., 0xc9/255.),
vec3(0x41/255., 0xa6/255., 0xf6/255.),
vec3(0x73/255., 0xef/255., 0xf7/255.),
vec3(0xf4/255., 0xf4/255., 0xf4/255.),
vec3(0x94/255., 0xb0/255., 0xc2/255.),
vec3(0x56/255., 0x6c/255., 0x86/255.),
vec3(0x33/255., 0x3c/255., 0x57/255.)
);

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}
float sdRBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p)-b+r;
  return length(max(q,0.0)+min(max(q.x,max(q.y,q.z)),0.0));
}

float BPM = 124;
float PI=3.1415;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom=uv;
  
  float Gt=fGlobalTime/60*BPM;
  float Gti=floor(Gt);
  float Gtf=1-fract(Gt);
  Gt=Gtf*Gtf*-.8+Gti;
  
  Gt=mod(Gt,64);
  
  vec2 ares=vec2(240,136);
  vec2 reso=ares+10;
  vec2 uv_=uv;
  uv_=floor(uv_*reso);
  uv_-=10;
  vec4 border = vec4(0);
  if (uv_.x < 0 || uv_.x > ares.x-10 || uv_.y < 0 || uv_.y > ares.y-10) {
    border = vec4(palette[int(floor(Gt*.25)*2+2+Gtf*2)%16],1);
  }
  uv_-=floor(ares/2)-5;
  uv_/=240;
  
  uv=floor(uv*reso);
  uv-=10;
  uv-=floor(ares/2)-5;
  uv/=240;
  
  zom-=.5;
  zom*=.99;
  zom+=.5;
  
  rot(uv,Gt*.1);
  uv+=vec2(sin(Gt*.021),cos(Gt*0.022))*uv.x;

	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x*.04);

	float f = texture( texFFTSmoothed, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float cir=length(uv)*(2);
  float cir2=length(uv)*2;
  
  cir=step(cir,0.25+f*.01);
  cir2=step(cir2,0.2+f*.009);
  
  float ln=length(uv);
  
  vec2 uv2=uv;
  
  for(int i=0; i<80; i++){
    uv=abs(uv)-vec2(0.4,0.3+abs(uv2*.01));
    uv+=vec2(.002,.005-i*.005);
    rot(uv,-0.01+Gt*PI*0.0125+uv2.y*.003-uv2.x*.01);
  }
  ln=length(uv);
  float sz=20;
  float fx=texture(texFFTSmoothed,floor(ln*sz)/sz).r*10;
  
	vec4 t = vec4(vec3(mod(uv.x-uv.y+Gt*.05-min(cir,1)/16+fx-ln*10,1)),0);
	t = clamp( t, 0.0, 1.0 );
  t-=(cir-cir2);
  
  vec4 c = vec4(0);
  
  
  c = vec4(t);//mod(vec4(uv_.x+uv_.y+mod(Gt*.05,2)-fi),1);
  
	c = clamp( c, 0.0, 1.0 );
  if(abs(uv.x*20)>0.3){c=1-c;}
  vec4 prev=texture(texPreviousFrame,zom);
  float cf=float(c);
  int ci = int((c+prev.a*.2)*16);
  
  
  
  c=vec4(palette[int(ci%5/2+2*floor(Gt*.25))%16],0);
  
  if(ci%5<2){c=prev*(.8+fx);}
  
	out_color = vec4(c.rgb,cf);
  if(border.a==1){out_color=border+(prev*f*.05);}
}
