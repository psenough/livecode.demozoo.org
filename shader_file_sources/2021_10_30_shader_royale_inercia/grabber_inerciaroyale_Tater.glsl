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
uniform float md1;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define STEPS 128.0
#define MDIST 128.0
#define pi 3.1415926535
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define sat(a) clamp(a,0.,1.)
#define pmod(p,x) (mod(p,x)-0.5*(x))
float psin(float x, float b){
  float xx = floor(b*x)/b;
  return sin(xx)+(sin(floor(b*x+1.0)/b)-sin(xx))*mod(b*x,1.0);
}
vec2 vor(vec2 m, vec3 p, vec3 s){
  float scl = 0.2;
  vec3 c = round(scl*p+s);
  c+=sin(fract(72985*sin(dot(c,c.yzx+33.3)))*6.+fGlobalTime*3)*0.3;
  c*=(1./scl);
  float v = length(c - p);
  return v<m.x?vec2(v,m.x):v<m.y?vec2(m.x,v):m;
}

vec3 spiral(vec3 p, float R){
  p.xz*=rot(p.y/R);
  vec2 s = sign(p.xz);
  p.xz = abs(p.xz)-R*0.5;
  p.xz*=rot(fGlobalTime);
  float poy = p.y;
  p.y = 0.;
  p.yz*=rot(mix(0.,pi/4.,1./(R*0.5+1.5)))*-sign(s.x*s.y);
  p.y = poy;
  return p;
}
float wavey = 0.;
vec2 map(vec3 p){
    float fft = texture(texFFTSmoothed,0.).x*200;

  float t = mod(fGlobalTime,150.);
  vec3 po2 = p;
  p.z+=t*30.;
  p.xz*=rot(0.4);
  vec3 po = p;
  vec2 a = vec2(1);
  vec2 b = vec2(2);
  vec2 c = vec2(3);
  
  //TRIANGLE PLANE
  p.xz*=0.9;
  p.y+=psin(p.x*0.1,2.)*4.*sin(t+p.x*0.01);
  p.xz*=rot((2.*pi)/3.);
  p.y+=psin(p.x,0.2)*3.*sin(t*2+p.x*0.05);
  p.xz*=rot((2.*pi)/3.);
  p.y+=psin(p.x,0.2)*3.*sin(t*2+p.x*0.04);
  p.xz*=rot((2.*pi)/3.);
  
  //HEX LATTICE
  vec3 p2 = p;
  p2.y+=fft*0.1;
  float m = 5.;
  p.x = pmod(p.x-m*0.5,m);
  b.x = length(p.xy)-0.2;
  p = p2;
  p.xz*=rot((2.*pi)/3.);
  p.x = pmod(p.x-m*0.5,m);
  b.x = min(b.x,length(p.xy)-0.2);
  p = p2;
  p.xz*=rot((2.*pi)/3.);
  p.xz*=rot((2.*pi)/3.);
  p.x = pmod(p.x-m*0.5,m);
  b.x = min(b.x,length(p.xy)-0.2);
 
  a.x = p.y+1.;
  
  a = (a.x<b.x)?a:b;
  
  //BIAS THE LATTICE
  p = po;
  a.x*=0.7;
  c.x = p.y;
  a.x = mix(c.x,a.x+0.1,1.15);
  
  //VORONOI
  vec3 r = po2;
  
  r.y-=t*0.5;
  r.xy*=rot(pi/4.);
  vec2 s = vec2(0.5,-0.5);
  vec2 vd =
  vor(vor(vor(vor(vor(vor(vor(vor(vec2(5),
  r,s.xxx) ,r,s.xxy) ,r,s.xyx) ,r,s.xyy),
  r,s.yxx) ,r,s.yxy) ,r,s.yyx) ,r,s.yyy);
  float h = vd.y-vd.x;
  
  //WAVES
  p = po2;
  float wav = 0.;
  p.xz*=0.5;
  wav+=sin(p.z*0.8+t)*0.1+sin(p.x*0.8+t)*0.2;
  wav+=sin(p.z*0.3-t*2.)*0.2+sin(p.x*0.3-t*2.)*0.2;
  wav+=sin(length(p.xz)*0.3+t*3.0);
  p.y+=wav*5.0;
  b.x = p.y;
  
  float v = mix(b.x,0.01,sat(1.-h));
  b.x = max(b.x,v+0.1);
  
  //TWIST
  p = po2;
  p = spiral(p,27+fft);
  p = spiral(p,10+fft*0.3);
  p = spiral(p,4);
  p = spiral(p,1.5);
  
  c.x = length(p.xz)-0.5;
  c.x*=0.8;
  b = (b.x<c.x)?b:c;
  
  
  a.x = mix(a.x,b.x*0.8,wavey);
  a.y = mix(a.y,b.y,wavey);
  
  return a;
}

vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0);
  return normalize(map(p).x-vec3(
  map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x));
}

void main(void)
{
  vec3 col = vec3(0.2);
  float t= fGlobalTime;
  wavey = smoothstep(-0.25,0.3,sin(t*0.4));
  //wavey = 1.;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv-=0.2*(1.0-wavey);
  
  uv.xy*=rot((1.0-wavey)*sin(t*1.5+pi/2.)*0.05);

  vec3 ro = vec3(0,3,-5)*5.5;
  ro.zy+=(sin(t*1.5)*8.+3.);
  
  vec3 ro2 = vec3(0,5,7)*10;
  ro2.xz*=rot(t*0.3);
  ro = mix(ro,ro2,wavey);
  
  vec3 lk = vec3(0,0,30*(1.0-wavey));
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = normalize(f*0.3+uv.x*r+uv.y*cross(f,r));
  
  vec3 p = ro;
  vec2 d= vec2(0);
  float dO = 0.;
  float shad = 0.;
  bool hit = false;
  for(float i = 0.; i<STEPS; i++){
    p = ro+rd*dO;
    d = map(p);
    dO+=d.x;
    if(abs(d.x)<0.005||i==STEPS-1.){
      shad = i/STEPS;
      hit = true;
      break;
    }
    if(dO>MDIST){
      dO = MDIST;
      break;
    }
  }
  vec3 bg = mix(vec3(0.5,0.4,0.85),vec3(0.45,0.45,0.9),clamp(rd.y*5,-1,1));
  if(hit){
    vec3 n = norm(p);
    vec3 ld = normalize(vec3(20,45,0)-p);
    vec3 rr = reflect(rd,n);
    float diff = max(0,dot(n,ld));
    float amb = dot(n,ld)*0.5+0.5;
    float spec = pow(max(0.,dot(rr,ld)),40);
    float fres = pow(max(0.7+dot(rd,n),0),2.0);
    vec3 al = vec3(0.2,0.25,0.75);
    #define AO(a,n,p) smoothstep(-a,a,map(p+n*a).x)
    float ao = AO(0.3,n,p)*AO(0.5,n,p)*AO(0.9,n,p);
    float sss = 0.;
    for(float i = 0.; i<20.; i++){
      float dist = i*0.09;
      sss+=smoothstep(0.,1.,map(p+ld*dist).x/dist)*0.033; 
    }
    
    
    if(d.y==2.0) al*=2;
    col = vec3(1.0-shad);
    col = al*mix(vec3(0.3,0,0.3),vec3(1),mix(diff,amb,0.25));
    col+=spec*0.3*bg;
    col+=sss*0.3;
    col*=mix(ao,1.0,0.3);
    col = pow(col,vec3(0.7));
    
    //WAVEY COLOR
    sss = 0.;
    float ssmag = 1.;
    ld = normalize(vec3(0,100,0)-p);
    if(d.y==3.0){ld = normalize(vec3(p.x,0,p.z));
    ssmag = 1.5;
    
    }
    spec = pow(max(.0,dot(rr,ld)),20.0);
    vec3 wcol = vec3(0);
    al = vec3(0.2,0.6,1);
    for(float i = 0.; i<20.; i++){
      float dist = i*0.3;
      sss+=smoothstep(0.,1.,map(p+ld*dist).x/dist)*0.06*ssmag; 
    }
    wcol = mix((1.0-shad),1.,0.5)*vec3(sss)*al;
    wcol+=spec*0.3;
    col = mix(col,wcol,wavey);
  }
  col = mix(col,bg,pow(dO/MDIST,2.5));
	out_color = vec4(col,1);
}






