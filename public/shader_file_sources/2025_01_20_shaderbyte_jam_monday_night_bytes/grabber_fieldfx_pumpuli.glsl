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

vec3 orange[16] = vec3[](
vec3(26/255., 28/255., 44/255.),
vec3(47/255., 33/255., 60/255.),
vec3(70/255., 35/255., 80/255.),
vec3(93/255., 39/255., 93/255.),
vec3(120/255., 40/255., 89/255.),
vec3(150/255., 50/255., 86/255.),
vec3(177/255., 62/255., 83/255.),
vec3(199/255., 92/255., 84/255.),
vec3(215/255., 110/255., 86/255.),
vec3(239/255., 125/255., 87/255.),
vec3(243/255., 160/255., 97/255.),
vec3(250/255., 180/255., 105/255.),
vec3(255/255., 205/255., 117/255.),
vec3(255/255., 230/255., 180/255.),
vec3(255/255., 240/255., 200/255.),
vec3(255/255., 255/255., 255/255.)
);


void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 sharpen(in sampler2D tex, in vec2 coords, in vec2 renderSize) {
  float dx = 1.0 / renderSize.x;
  float dy = 1.0 / renderSize.y;
  vec4 sum = vec4(0.0);
  sum += -1. * texture(tex, coords + vec2( -1.0 * dx , 0.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 0.0 * dx , -1.0 * dy));
  sum += 5. * texture(tex, coords + vec2( 0.0 * dx , 0.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 0.0 * dx , 1.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 1.0 * dx , 0.0 * dy));
  return sum;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main(void)
{
  
  float BPM=162/(8-mod(floor(fGlobalTime*.1),4)*2);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 zom=uv;
  vec2 zom2=uv;
  
  float fGt=fGlobalTime/60*BPM;
  fGt=mod(fGt,1);
  
  float Gt=fGlobalTime/60*BPM;
  Gt=mod(Gt,3.1415*100);
  float bm=1-fract(Gt);
  float low=texture(texFFTSmoothed,0.02).r*10;
  float mid=texture(texFFTSmoothed,0.5).r*20;
  for(float i=0;i>1;i+=0.05){
    low+=texture(texFFTSmoothed,0.02+i*0.1).r*10;
    }
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    
  rot(uv,.3*sin(fGlobalTime*.05));
  uv+=vec2(.1*sin(fGlobalTime*.31),0.23*cos(fGlobalTime*.3));
    
  vec2 uv_=uv;
  
  vec2 reso=vec2(240,136);//*(.2+bm);
    
  int intt=int(fGt/60*BPM*.25);
  
  for(int i=0;i<10;i++){
    uv=abs(uv)-vec2(.1,0.2*(mod(i,2)-1));
    rot(uv,Gt*.4+(bm*.1));
    uv=abs(uv)-vec2(0,.2);
    rot(uv,intt-Gt*.01+fGt*.5);
  }
  
  
  uv=floor(uv*reso);
  uv-=floor(reso/136);
  uv/=reso;
  
  
  
  zom-=.5;
  zom*=.999;
  rot(zom,.005*sin(Gt*.125*uv.y*10));
  rot(zom,.03*length(uv)*uv_.y);
  zom+=.5;
  
  zom2-=.5;
  zom2*=.98;
  zom2+=.5;
  
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
  m.y*= 1+texture( texFFTSmoothed, abs(m.x*0.05)).r*2;
	float d = abs(m.y)+mod(Gt,1);

	float f = texture( texFFTSmoothed, d ).r * 100;
	float fx = texture( texFFTSmoothed, abs(m.y*3) ).r * 10;

  vec4 prev= texture(texPreviousFrame,zom);
  vec4 sprev= sharpen(texPreviousFrame,zom,vec2(300))*.2;
  vec4 sprev2= sharpen(texPreviousFrame,zom2,vec2(300));
  
  sprev=normalize(sprev);
  sprev2=normalize(sprev2);
  
  float vert=(1/abs(uv.x))*mid;
  float horiz=abs(uv.x/uv.y)*m.y*low;
  
  vert*=bm;
  horiz*=bm;
  
  vec4 c = vec4(horiz*sprev+vert*prev+fx*(1/m.y));
  
  c+=sprev*low*.1+sprev2*.1;
  c*=.5+bm+prev*(low+mid);
  
  
  int ci = int((c.r+c.g+c.b)/3*5-sprev2*2);
  
  vec4 ou=vec4(orange[min(15,max(0,ci))],0);
  
  if((mod(uv_.y*(reso.y*1.5),2))>1){ou=(c-.5)*prev*20;}
  
	out_color = ou;
}