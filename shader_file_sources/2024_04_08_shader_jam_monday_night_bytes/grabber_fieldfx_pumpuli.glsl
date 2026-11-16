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

float gtt=texture(texFFTIntegrated,0.002).r*.002;
float gttf=texture(texFFT,0.002).r*4;

vec3 glow=vec3(0.0);
const float E = 0.001;
const int STEPS = 100;
const float FAR = 800;

float cir(vec2 uv, float r) {
  
  return length(uv)-r;
}

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
float scene(vec3 p, vec3 ro, vec3 rd){
  vec3 pp = p;
  pp+=vec3(5);
  for(int i=0;i<4;++i){
    pp=abs(pp)+vec3(-10,-10,-10);
    rot(pp.zy,.01+gtt*10);
  }
  pp-=vec3(5);
  float d = distance(p,pp);
  float bx = sdRBox(pp,vec3(1,1,1)*(1+gttf*2),.4);
  vec3 g = vec3(.2)*.01 / (abs(bx)+0.5);
  glow += g;
  glow *= d*.03;
  
  return bx;
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


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 zom=uv;
  vec2 zom2=uv;
  vec2 rat=vec2(v2Resolution.y / v2Resolution.x, 1);
	uv -= 0.5;
	uv /= rat;
  float gft=texture(texFFTIntegrated,0.005).r;
  float gt=fGlobalTime*.6;//+gft*.3;
  
  vec2 q = uv;
  
  vec3 ro = vec3(10,0,0);
  vec3 rt = vec3(0,0,0);
  vec3 up=vec3(0.0,1.0,0.0);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,up));
  vec3 y = normalize(cross(x,z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1/radians(90.0)));
  
  float mr = march(ro,rd);
  vec3 pos = ro+rd*mr;
  
  //uv*=mod(gft*.05,10);
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = exp(abs(m.x/2)*.2);

	float f = texture(texFFT, d ).r*1;
  float b = texture(texFFTSmoothed,0.002).r*10;
  
  
  zom2-=.5;
  zom2*=.8;
  zom2+=.5;
  
  for(int i=0;i<10;++i) {
    zom=abs(zom)-vec2(.001,0)*(1-mod(i,2)*2);
    zom-=.5;
    zom*=.999-b*.05;
    zom+=.5;
  }
  
  vec3 pr=texture(texPreviousFrame,zom).rgb;
  vec3 spr=texture(texPreviousFrame,zom2).rbg;
  
	vec3 t = vec3(cir(mod(zom,.8),.2));
	t = clamp( t, 0.0, 1.0 );
  
  float tt=(.4-mod(sin(gt*.2)*.4+.4,.8))*5;
  
  float c1=cir(uv,.2);
  float c = mod(abs(c1),.2+b*.3)*c1;
  vec2 off=vec2(.2,.1)*tt;
  rot(off,gt*.02);
	float f2 = texture(texFFT, d+off.x ).r*1;
  float c2= cir(uv*vec2(1.001)+off,.2+abs(f2*.1));
  
  
  float c3=step(c,f*.1*(length(off)*3))-(max(step(c2,0),0)*1000)-mod(spr.r,.25);
  
  vec3 col=vec3(1);
  col+=step(t.r,.0);
  
  col*=c3;
  col+=vec3(.05,.02,0);
  //rot(spr.rb,.5);
  //rot(pr.br,.1);
  col+=pr*.5+spr*.4;
  
  col*=vec3(1*max(min(col.r+.2,1),0),.4*max(min(col.g+.2,1),0)+.6,1.2);
  
  if (col.r+col.b+col.g<.1) {
    col=col*mr*.2+pr*.2;
  } 
  
  
	out_color = vec4(col,0);
}