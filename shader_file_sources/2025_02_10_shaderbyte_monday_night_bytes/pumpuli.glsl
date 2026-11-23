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

float sdHex( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
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

float pen( in vec2 p, in float r){
  const vec3 k = vec3(0.8,0.58,0.72);
  p.x = abs(p.x);
  p.y*=-1;
  p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
  p -= 2.0*min(dot(vec2( k.x,k.y),p),0.0)*vec2( k.x,k.y);
  p -= vec2(clamp(p.x,-r*k.z,4*k.z),r);
  return length(p)*sign(p.y);
}



int BPM=136*2;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom=uv;
  
  float PI=3.1415;
  
  float BDR=20;
  
  float Gt=fGlobalTime/60*BPM;
  Gt=mod(Gt,64);
  float fGt=floor(Gt);
  float Gti=texture(texFFTIntegrated,0.02).r*10;
  
  Gti=mod(Gti,64);
  
  vec4 border=vec4(1);
  
  float bfl=1-fract(Gt/2);
  float ffl=1-fract(Gt*4);
  
  float div=texture(texFFTSmoothed,0.03).r*20;
  
  float iGt=fGt+fract(Gt)*.5;
  
  div=-1+ffl*10;
  
  div*=0;
  div=1;
  
  BDR*=1-bfl*.2;
  
  vec2 ares=vec2(240,136)*div;
  vec2 reso=ares+BDR;
  vec2 uv_=uv;
  uv_=floor(uv_*reso);
  uv_-=BDR;
  if (uv_.x < 0 || uv_.x > ares.x-BDR || uv_.y < 0 || uv_.y > ares.y-BDR) {
    border = vec4(palette[0],1);
    //return;
  }
  uv_-=floor(ares/2)-(BDR/2);
  uv_/=240;
  
  uv=floor(uv*reso);
  uv-=BDR;
  uv-=floor(ares/2)-(BDR/2);
  uv/=240;
  
  uv/=div;
  uv_/=div;
  
  float bm = texture(texFFTSmoothed,0.02).r*20;
  float bms= texture(texFFTSmoothed,0.003).r*1;
  
  zom-=0.5;
  zom*=.998;//-cos(Gt*.019)*0.0015;  
  //zom+=vec2(sin(Gt*.11),cos(Gt*.13))*.0003;
  //rot(zom,sin(Gt*.017)*.002);
  zom+=0.5;
  
  
  vec4 sharp = sharpen(texPreviousFrame,zom,vec2(100));
  vec4 prev = texture(texPreviousFrame,zom);
  
  //prev=vec4(vec3(prev.r+prev.g+prev.b)/3,prev.a);
  sharp=vec4(vec3(sharp.r+sharp.g+sharp.b)/3,sharp.a);
  sharp*=prev;

  vec2 c_uv= uv;
  
	vec2 m;
	m.x = atan(c_uv.y / c_uv.x) / 3.14;
	m.y = 1 / length(c_uv) * .2;
	float d = abs(uv.x*.03);
  
  float fx=texture(texFFTSmoothed,.4-abs(c_uv.x*.7)).r*10;

	float f = texture( texFFT, d ).r * (300+d*bfl*10);
  
  for(int i=0;i<80;i++){
    c_uv=abs(c_uv)-vec2(.08-sin(i*.02*(0.5+bfl))*.07);//vec2(.2-.002*bfl,.2-.015*bfl);
    rot(c_uv,Gt*.0125);
  }
  
  c_uv+=(1-length(c_uv))*.3;
  
  
  float cir=mod(length(c_uv),2)*(2);
  
  cir=mod(sdHex(c_uv,1),2);
  float cir2=length(c_uv)*(2);
  cir=step(mod(cir-Gt*.1,.2)*3,0.1*cir2+pow(bms*.8,3)+f*.005);
  sharp*=cir+cir2;
  
  vec4 c = vec4(0);
  
  c = vec4(cir*(1-cir2))*vec4(1.2,.4,.9,1)*(.3+bfl);
  
  if(mod(uv.y*8,.2)>.1){
    c=c*(border);
  }else{
    c=c*(border)+fx;
  }
  //c=clamp(c,0.0,1.0);
  
  int ci=0;
  
  ci=int(mod(int(c*16),16));
  
  c=vec4(palette[ci],1);
  
	out_color =c+sharp*(bfl*.7)*(prev*1-fx);//+sharp*(1-bfl*3);
  
}