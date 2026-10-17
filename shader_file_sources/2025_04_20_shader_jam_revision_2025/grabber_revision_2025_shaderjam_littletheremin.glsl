#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texRevisionBW;

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

int BPM=177;
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom=uv;
  
  float PI=3.1415;
  
  float Gt=fGlobalTime/60*BPM*.5;
  float Gti=floor(Gt);//texture(texFFTIntegrated,0.02).r*10;
  float Gtf=fract(Gt);
  
  float low=texture(texFFTIntegrated,0.01).r;
  float lw=texture(texFFT,0.01).r;
  for(float fl=0.001;fl<0.01;fl+=0.001){
    low+=texture(texFFTIntegrated,fl).r;
    lw+=texture(texFFT,fl).r;
  }
  low*=0.0005;
  lw*=0.2;
  low=mod(low,PI*2);
  
  vec2 ares=vec2(240,136);
  vec2 reso=ares+10;
  vec2 uv_=uv;
  uv_=floor(uv_*reso);
  uv_-=10;
  vec4 border=vec4(0);
  if (uv_.x < 0 || uv_.x > ares.x-10 || uv_.y < 0 || uv_.y > ares.y-10) {
    border = vec4(palette[int(floor(Gt*.25)*2+2+Gtf*2)%16],1);
  }
  uv_-=floor(ares/2)-5;
  uv_/=240;
  
  uv=floor(uv*reso);
  uv-=10;
  uv-=floor(ares/2)-5;
  uv/=240;
  
  
  vec2 uv2=uv;
  
  for(int i=0; i<80; i++){
    uv=abs(uv)-vec2(0.04,0.03+abs(uv2*.1));
    uv+=vec2(.002,.005-i*.0005);
    rot(uv,-0.01+low+Gtf*Gtf*.01+uv2.y*.003-uv2.x*.01);
  }
  
  
	vec2 m;
	m.x = atan(uv_.x / uv_.y) / 3.14;
	m.y = 1 / length(uv_) * .2;
	float d = abs(uv.x);
  
  
  float fx=texture(texFFT,.9-abs(uv.x*20.8)).r*100;
  
  zom-=.5;
  zom*=.99+fx*.02+lw*.1;
  zom+=.5;
  
  vec2 logo=mix(zom,uv+vec2(.5),lw*.2*lw);;
  
  logo-=.5;
  logo*=2-lw*.4;
  logo*=vec2(1,.6);
  rot(logo,(low*0.0002*(1+lw*.02)*low*low)*(Gti+Gtf*Gtf)*(mod(floor(length(logo)*10.9),5)-2));
  logo/=vec2(1,.6);
  logo+=.5;
  
  logo=logo*vec2(1,.6)+vec2(0,.2);
  
	float f = texture( texFFT, d*d ).r * 10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  vec4 prev=texture(texPreviousFrame,zom);
  
  vec4 lynn=texture(texLynn,zom*vec2(1,-1))*(1+prev*fx);
  vec4 rev=texture(texRevisionBW,logo);
  if(abs(logo.x)>1){rev*=0;}
  if(abs(logo.y)>1){rev*=0;}
  vec4 rev2=texture(texRevisionBW,logo+vec2(.02));
  vec4 c=vec4(1);
  
	c = clamp( c, 0.0, 1.0 );
  int ci = int(mod(c*16,16));
  
  ci=int(mod((c)*16,4));
  
  ci=int(min(max(0,ci),15));
  
  c=vec4(palette[int(mod(ci+f,5)+1)],0);
  rot(prev.rg,.3);
  c+=prev*.2+fx*.3*f*f*uv.x*prev+fx*.2*lw*2;
  
  if(int(mod(ci+f,16))==0){c=c-prev*(1-rev);}
  
	out_color = c+prev*.07;
  if(border.a>0){
    out_color*=prev+lw*.2;
  }else{
    out_color+=rev*(1-fx*.4)-rev2*lw;
    out_color*=1+rev;
  }
  out_color+=border*.5-(prev*fx*.3)*(1-border.a);
  
}