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
float gt=fGlobalTime;
float gtt=texture(texFFTIntegrated,0.002).r*.12;
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
  float pft=texture(texFFTSmoothed,length(p)*.01).r*.02;
  
  float bft=gttf*300;
  for(int i=0;i<8;++i){
    pp=abs(pp)-vec3(0,1,2);
    rot(pp.zy,.3+pft*40);
    pp=abs(pp)-vec3(2,0,0);
    rot(pp.xy,.3+gtt*.5);
  }
  pp=floor(pp*bft)/bft;
  float d = distance(p,pp);
  float b = sdRBox(pp,vec3(1,1,1)+vec3(8)*pft*10,.2);
  vec3 g = vec3(.2)*.1/(abs(b)+100);
  glow+=g;
  glow*=d*.03;
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

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 zom=uv;
  vec2 zom2=uv;
  vec2 rat=vec2(v2Resolution.y / v2Resolution.x, 1);
  uv -= 0.5;
  uv /= rat;
  float gft=texture(texFFTIntegrated,0.005).r;
  float ft=texture(texFFT,0.002).r;
  float res=8800-ft*16000;
  res=max(res,50);
  uv=floor(uv*res)/res;
  
  
  zom-=.5;
  zom*=1.-ft*.05;
  zom+=.5;
  
  vec2 q = uv;
  vec3 rg = vec3(0);
  vec3 ro = vec3(10,0,0)*2;
  //ro=rg;
  
  vec3 rt = vec3(0,0,0);
  vec3 up=vec3(0.0,1.0,0.0);
  //rot(ro.xy,gft*.15);
  //rot(ro.zx,gft*gft*.0001);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,up));
  vec3 y = normalize(cross(x,z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(q, 1/radians(90.0)));
  float mr = march(ro,rd);
  vec3 pos = ro+rd*mr;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFTSmoothed, abs(pos.x)*.01 ).r * 10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  vec3 prev=texture(texPreviousFrame,zom).rgb;
  zom2=zom;
  zom2-=.5;
  zom2*=.8-ft*.2;
  rot(zom2,3.14/2);
  zom2*=rat;
  zom2/=rat.yx;
  zom2+=.5;
  vec3 prev2=texture(texPreviousFrame,zom2).rgb;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  vec3 pink=vec3(1,1,1);
  
  vec3 c=vec3(.1);
  if(mr<FAR-1){
    c=vec3(10)*pink*f*(1+prev)+prev;
    
  }else {
    pos*=0;
  }
  c*=(.1+glow*0.1*pink*(.1+prev));
  
  c=clamp(c,0,1);
  if(c.r+c.g+c.b>2.9){
    c=1-prev*pink*4;
  }
  //rot(prev.xy,.2);
  c+=prev*.5;
  
  if(c.r+c.g+c.b<0.3){
    c=prev*2;
  }
  rot(pos.xz,gt*.1);
	out_color = vec4(c-prev/pink+vec3(normalize(abs(pos))),0);
  if(distance(clamp(out_color.rgb,0,1),vec3(0))<.1){
    out_color=vec4(prev2*.5,0);
  }
}