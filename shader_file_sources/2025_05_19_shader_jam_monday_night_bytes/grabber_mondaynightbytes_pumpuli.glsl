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

int STEPS=100;
float E=0.0001;
float FAR=100;
vec3 glow=vec3(0);

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}


float sdRBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p)-b+r;
  return length(max(q,0.0)+min(max(q.x,max(q.y,q.z)),0.0));
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 rgb2hsv(vec3 rgb) {
 	float Cmax = max(rgb.r, max(rgb.g, rgb.b));
 	float Cmin = min(rgb.r, min(rgb.g, rgb.b));
 	float delta = Cmax - Cmin;

 	vec3 hsv = vec3(0., 0., Cmax);

 	if (Cmax > Cmin) {
 		hsv.y = delta / Cmax;

 		if (rgb.r == Cmax)
 			hsv.x = (rgb.g - rgb.b) / delta;
 		else {
 			if (rgb.g == Cmax)
 				hsv.x = 2. + (rgb.b - rgb.r) / delta;
 			else
 				hsv.x = 4. + (rgb.r - rgb.g) / delta;
 		}
 		hsv.x = fract(hsv.x / 6.);
 	}
 	return hsv;
 }

float scene(vec3 p, vec3 ro, vec3 rd){
  vec3 pp = p;
  float fq=abs(p.x)*abs(p.x);
  fq*=.08;
  float fft=texture(texFFTSmoothed,fq).r;
  fft=fft*(1+fq);
  float bb=texture(texFFTSmoothed,0.01).r;
  float ff=texture(texFFTSmoothed,0.1).r;
  //
  for(int i=0;i<10;i++){
    pp=abs(pp)-vec3(1.5);
    ff=texture(texFFTSmoothed,0.01*i).r;
  }
  //*/
  float d = distance(p,pp);
  float b = sdRBox(pp,vec3(1,1,1)*.7,0.1);
  vec3 g = vec3(.8)*.2/(abs(b)+100);
  glow+=g+fft*.1;
  //glow*=d*.03;
  return b;
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i=0; i < STEPS;++i){
    float d = scene(p,ro,rd);
    t+=d;
    p = ro+rd*t;
    if(d <=E || t >= FAR){
      break;
    }
  }
  return t;
}

float BPM=132;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv2=uv;
  
  float Gt=fGlobalTime/60*BPM;
  float iGt=floor(Gt);
  float fGt=fract(Gt);
  float pGt=(iGt+fGt*fGt*fGt*fGt)*.2;
  
  float bm=texture(texFFTSmoothed,0.002).r;
  
  vec2 ares=vec2(240,136)*20;
  
  float brd=ares.x/24;
  vec4 border=vec4(0);
  
  vec2 reso=ares+brd;
  vec2 uv_=uv;
  uv_=floor(uv_*reso);
  uv_-=brd;
  if (uv_.x < 0 || uv_.x > ares.x-brd || uv_.y < 0 || uv_.y > ares.y-brd) {
    out_color = vec4(palette[0],1);
    border=vec4(1);
  }
  uv_-=floor(ares/2)-brd/2;
  uv_/=ares.x;
  
  uv=floor(uv*reso);
  uv-=brd;
  uv-=floor(ares/2)-brd/2;
  uv/=ares.x;
  
  uv2-=.5;
  uv2*=1.06-fGt*.02;
  uv2+=.5;
  
  
  vec4 prev=texture(texPreviousFrame,uv2);
  
  vec2 q = uv*2;
  vec3 rg = vec3(0);
  vec3 ro = vec3(2,0,2);
  
  vec3 rt= vec3(0,0,0);
  vec3 up = vec3(0,1,0);
  
  rot(ro.xy,pGt*1.24);
  rot(ro.xz,pGt*1.73);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,up));
  vec3 y = normalize(cross(x,z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1/radians(90.0)));
  
  float mr = march(ro,rd);
  vec3 pos = ro+rd*mr;
  
  
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x*m.x*.3);

	float f = texture( texFFTSmoothed, d ).r * 100;
  
  float l=length(uv)*3;

  float cir=length(uv)*(2);
  cir=abs(mod(cir*4,2)-1);
  float cc=step(cir,0.3+f*.02);
  cc-=step(cir,0.2+f*.02);
  
  
	vec4 t = vec4(vec3(mod(-m.y+m.x+Gt*.02+pGt*(cc-.5)+m.y*cc+Gt*.2,.5)),0);
	t = clamp( t, 0.0, 1.0 );
  
  vec4 c = vec4(0);
  
  c = vec4(t);//mod(vec4(uv_.x+uv_.y+mod(Gt*.05,2)-fi),1);
  if (mr<FAR){
    c+=.0;
  }
  
	c = clamp( c, 0.0, 1.0 );
  int ci = int
 ((c)*16);
  
  c=vec4(palette[ci],0)*l*l;
  if (mr<FAR){
    c+=vec4(glow,1);
  }else{
    c*=l*l+cc*f*.2;
  }
	out_color = c;
  out_color-=border*vec4(1.8,1.4,1.1,1)*prev.a*2;
  //out_color+=prev.a*(.5-fGt)-prev.a*.02;
  
  out_color*=1+prev.a*2*glow.bbbb*glow.bbbb+(1-mr/FAR);
  out_color+=prev.a*-.6;
  out_color+=prev*(1-l*l);
  
  out_color=vec4(out_color.rgb,(out_color.r+out_color.g+out_color.b)/3);
}

























































// greets to everyone !! !!