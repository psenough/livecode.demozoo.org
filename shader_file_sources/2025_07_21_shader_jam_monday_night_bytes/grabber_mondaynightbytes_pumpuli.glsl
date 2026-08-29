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


float BPM=180/2;
int STEPS=100;
float E=0.0001;
float FAR=100;
vec3 glow=vec3(0);


vec3 palette[16] = vec3[](
vec3(0x1a/255., 0x1c/255., 0x2c/255.),
vec3(0x5d/255., 0x27/255., 0x5d/255.),
vec3(0xb1/255., 0x3e/255., 0x53/255.),
vec3(0xef/255., 0x7d/255., 0x57/255.),
vec3(0x1a/255., 0x1c/255., 0x2c/255.),
vec3(0x5d/255., 0x27/255., 0x5d/255.),
vec3(0xb1/255., 0x3e/255., 0x53/255.),
vec3(0xef/255., 0x7d/255., 0x57/255.),
vec3(0x1a/255., 0x1c/255., 0x2c/255.),
vec3(0x5d/255., 0x27/255., 0x5d/255.),
vec3(0xb1/255., 0x3e/255., 0x53/255.),
vec3(0xef/255., 0x7d/255., 0x57/255.),
vec3(0x1a/255., 0x1c/255., 0x2c/255.),
vec3(0x5d/255., 0x27/255., 0x5d/255.),
vec3(0xb1/255., 0x3e/255., 0x53/255.),
vec3(0xef/255., 0x7d/255., 0x57/255.)
);

vec3 palette2[16] = vec3[](
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

float scene(vec3 p, vec3 ro, vec3 rd,float bmi,float tot){
  vec3 pp = p;
  float fq=abs(p.x)*abs(p.x);
  float fq2=abs(p.y)*abs(p.y);
  fq2*=.8;
  fq2=floor(fq2)*.125+20;
  fq*=.8;
  fq=floor(fq)*.125+20;
  float fft=texture(texFFT,fq).r;
  float fft2=texture(texFFT,fq2).r;
  fft=fft*(10);
  float bb=texture(texFFT,0.01).r;
  float ff=texture(texFFT,0.1).r;
  //
  bmi=bmi;
  for(int i=0;i<6;i++){
    pp=abs(pp)-vec3(.5,fft2*2,0);
    pp-=fft*.8;
    rot(pp.xy,bmi*.1+fft*.02);
    rot(pp.xz,bmi*.11-bb*.1*bb);
    rot(pp.yz,bmi*.09+bb*.2*bb);
    //pp+=vec3(.2);
    //ff=texture(texFFTSmoothed,0.01*i).r;
  }
  //*/
  float d = distance(p,pp);
  float b = sdRBox(pp,vec3(1,1,1)*tot,0.1);
  vec3 g = vec3(.8)*.2/(abs(b)+100);
  glow+=g+fft*.1;
  //glow*=d*.03;
  return b;
}

float march(vec3 ro, vec3 rd,float bmi,float tot){
  float t = E;
  vec3 p = ro;
  for(int i=0; i < STEPS;++i){
    float d = scene(p,ro,rd,bmi,tot);
    t+=d;
    p = ro+rd*t;
    if(d <=E || t >= FAR){
      break;
    }
  }
  return t;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv2=uv;
  
  float Gt=fGlobalTime/60*BPM;
  Gt=texture(texFFTIntegrated,0.001).r*.1;
  float iGt=floor(Gt);
  float fGt=fract(Gt);
  float pGt=(iGt+fGt*fGt*fGt*fGt)*.2;
  
  float bm=texture(texFFT,0.002).r;
  float bmi=texture(texFFTIntegrated,0.002).r;
  float low=0;
  float mid=0;
  float hih=0;
  float tot=0;
  for(float fi=0;fi<.2;fi+=0.01){
    low+=texture(texFFT,fi).r;
    mid+=texture(texFFT,fi+.2).r;
    hih+=texture(texFFTSmoothed,fi*2+.6).r;
    bmi+=texture(texFFTIntegrated,fi*.1).r*.01;
    tot+=texture(texFFTSmoothed,fi*5).r;
  }
  
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
  uv2*=1.02-bm*.042;
  uv2+=.5;
  
  
  //rot(uv,sin(Gt)*4+sin(uv2.x*uv2.y+low-mid)*uv.y*2);
  
  
  vec4 prev=texture(texPreviousFrame,uv2);
  float bmo=prev.a;
  
  vec2 q = uv*2;
  vec3 rg = vec3(0);
  vec3 ro = vec3(2,0,2);
  
  vec3 rt= vec3(0,0,0);
  vec3 up = vec3(0,1,0);
  
  rot(ro.xy,Gt*3.44);
  rot(ro.xz,Gt*8.73);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,up));
  vec3 y = normalize(cross(x,z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1/radians(90.0)));
  
  float mr = march(ro,rd,pGt*.2+bmi*.2,(low/tot+hih+prev.r)*.15);
  vec3 pos = ro+rd*mr;
  
  float gfar=1;
  if(mr<FAR){}else{gfar=0;}
  glow*=gfar;
  
  
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = abs(m.x*m.x*.2+.001);
  m*=.2+tot;
  //m=uv;

	float f = texture( texFFT, d ).r * 100*(1+d*d);
  
  
  float l=length(uv)*3;

  float cir=length(uv)*(2);
  cir=abs(mod(cir*4-Gt*6,2)-1);
  float cc=step(cir,0.3+f*.02);
  cc-=step(cir,0.2+f*.02);
  m-=.5;
  rot(m,pGt*2*(mod(floor((m.y+pGt)*4),2)*2-1)*.3+(1-l)*.01);
  m+=.5;
  float sq=2;//+f*8.5;
  float sqb=1;
  
	vec4 t = vec4(vec3(mod(-m.y/2-mod(m.x/4+pGt*2,sqb),sqb)),0);
	t = clamp( t, 0.0, 1.0 );
  
  vec4 c = vec4(0);
  
  c = vec4(t);//mod(vec4(uv_.x+uv_.y+mod(Gt*.05,2)-fi),1);
  
	c = clamp( c, 0.0, 1.0 );
  int ci = int((c)*16);
  
  c=vec4(palette[int(mod(mod(ci/2,2)+iGt,16))],0);
  c*=((l*l*(1+cc)));
  //c*=((sq-l)*(bm*100));
  if (mr<FAR){
    c=vec4(palette[int(mod(mod(iGt+mr,2)*2+iGt,16))],0);//vec4(palette[0],0)+vec4(glow*palette[2]*4,0);
    c=mix(c,vec4(abs(-cross(pos,rd*mat3(x,y,z)*(.2+cir*bm*bm*bm))),0),bm);
  }else{
  c*=0;
  }
  
  c*=(1+prev);
  
  vec4 bwprev=vec4(vec3((prev.r+prev.g+prev.b)/3),prev.a);
  vec4 c2=vec4(palette[int(mod(mod(ci/2,2)+3,16))],0);
  c2/=l*(2-bm);
  
  out_color=c2*(1-c)+c;//
  out_color=c2;
  out_color+=prev*bm*bm+low*low*low*low+f*(1-l)*.1*-prev*(mr/FAR)*100;//*prev*(.3+glow.r*gfar+bm)+(1/l)*bm*prev*.025;
  
  float a=(out_color.r+out_color.g+out_color.b)/3;
  
  vec3 hsv=rgb2hsv(out_color.rgb);
  hsv.y*=.7;//-bm*bm+f*(bwprev.r*bwprev.r*.2);
  hsv.x=mod(hsv.x*(.5+bm-l*.8)+mod(Gt*.5,1)+.4+(Gt)*(1.0/256),1);
  hsv.y*=.2;
  hsv.z=abs(mix(.5,hsv.z,.7)-l*bwprev.r);
  out_color=vec4(hsv2rgb(hsv),out_color.a);
  
  out_color*=out_color+f*hsv.x*l;
  
  out_color=clamp(out_color,-.2,1.2+l);
  if((out_color.r+out_color.g+out_color.b)/3>1) {
    out_color=out_color*vec4(1,.8,1.2,0)*prev-l*l*l+f*.2/abs(uv.x)*.01;
  }
  out_color*=1-prev*bm;
  if(mr>FAR/2){pos*=prev.rgb*.2;}
  out_color=mix(out_color,vec4(pos,1),0.01+l*.01*-prev-f*0.01+low+mr/FAR);
  out_color=mix(out_color,vec4(vec3(out_color.r+out_color.g+out_color.b)/3,1),.8+f*.05+cc);
  out_color=out_color*(step(cir/2,bm)+.2)+prev*.8-out_color;
  out_color=vec4(out_color.rgb,a);
}




































































//greets to everyone o/