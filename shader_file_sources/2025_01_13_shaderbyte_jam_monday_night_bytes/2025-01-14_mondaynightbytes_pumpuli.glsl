
// this one has a bunch of commented out things near the end, feel free to mix those around
// to fit the feel of the backing track!

// greetings to everyone !!

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


float logspace(float start, float stop, float n, float N)
{
    return start * pow(stop/start, n/(N-1));
}

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

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

int BPM=174/16;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom=uv;
  
  float PI=3.1415;
  
  float Gt=fGlobalTime/60*BPM;
  float fGt=floor(Gt);
  float Gti=texture(texFFTIntegrated,0.02).r*10;
  
  
  float bfl=1-fract(Gt);
  float ffl=1-fract(Gt*8);
  
  vec2 ares=vec2(240,136);
  vec2 reso=ares+10;
  vec2 uv_=uv;
  uv_=floor(uv_*reso);
  uv_-=10;
  if (uv_.x < 0 || uv_.x > ares.x-10 || uv_.y < 0 || uv_.y > ares.y-10) {
    out_color = vec4(palette[0],1);
    return;
  }
  uv_-=floor(ares/2)-5;
  uv_/=240;
  
  uv=floor(uv*reso);
  uv-=10;
  uv-=floor(ares/2)-5;
  uv/=240;
  
  float bm = texture(texFFTSmoothed,0.02).r*20;
  float bms= texture(texFFTSmoothed,0.003).r*2;
  
  //zom=floor((zom*(700*bm))+.5)/(700*bm);
  //zom=floor((zom*700)+.5)/700;
  
  
  zom-=0.5;
  //zom*=0.8+.3*bms-.3*bfl;
  zom*=1.3-bms*.1;
  rot(zom,(0.02*sin(Gt*PI*.25+(uv.x+uv.y)*10)+pow(bms*.02,4)-pow(bm*.02,8))*bfl*4);
  zom+=0.5;
  
  
  vec4 sharp = sharpen(texPreviousFrame,zom,vec2(400));
  vec4 prev = texture(texPreviousFrame,zom);
  
  prev=vec4(vec3(prev.r+prev.g+prev.b)/3,prev.a);
  sharp=vec4(vec3(sharp.r+sharp.g+sharp.b)/3,sharp.a);

	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x*.07);
  
  float fx=texture(texFFTSmoothed,.4-abs(uv.x*.8)).r*10;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float cir=mod(length(uv),2)*(2);
  float cir2=length(uv)*(2);
  
  cir=step(cir,0.25+pow(bms*.8,4)+f*.005);
  
    
  if (uv.y<=0) {fx*=-1; }
  
  float tf=.5;
  
  //tf=mod(fx-uv.y-Gt*.18+floor(Gt*8)*.2-min(cir,1)*.1,1);
  
  
	vec4 t = vec4(vec3(tf),0);
	t = clamp( t, 0.0, 1.0 );
  
  vec4 c = vec4(0);
  
  c = vec4(t);//mod(vec4(uv_.x+uv_.y+mod(Gt*.05,2)-fi),1);
  
  float zl=length((zom-.5)*vec2(1,v2Resolution.y/v2Resolution.x));
  
  if(cir<1){c=prev*2;}else{}
  c-=(prev+(prev*zl))*.8*step(cir2,c*2);
  
  //c*=mod(vec4(tf+uv_.x-uv_.y+mod(fGt*.05,2)),1);
  
	c = clamp( c, 0.0, 1.0 );
  int ci = int(mod(c*15,15));
  
  ci=int(mod((c)*15,4))+8;
  
  //ci+=int(cir*mod(zl*30-tf*20,2));
  
  
  ci=int(mod(ci,16)-abs((cir)*3));
  
  ci=int(min(max(0,ci),15));
  
  c=vec4(palette[int(mod(ci+(fGt+.5),16))],0);
  //c=vec4(palette[ci],0);//*(1+sharp*.7*zl*.5);
  
  //c+=prev*.7*(c*2)*bfl*.6;//+(cir)*.5;
  
  
  //if (uv.y<=0) {c*=.5+prev*.6*(1+zl); }
  
  //if(int(mod(floor(uv.x*reso.x),2))>0){c*=.9;}
  
  c = prev+sharp-cir*4+fx;
  
  ci=int(min(max(0,c.r*8),15));
  
  c=vec4(palette[ci],0);
  
	out_color = c;
  
}