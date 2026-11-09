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

#define PI 3.14159265
#define TAU 2*PI
#define time fGlobalTime
#define saturate(x) clamp(x, 0, 1)

mat3 getOrtho(vec3 z, vec3 up){
  z = normalize(z);
  vec3 cu = normalize(cross(z,up));
  vec3 cv = cross(cu,z);
  return mat3(cu,cv,z);
}

const vec3 up = vec3(0,1,0);
float noise(vec3 p, float t){
  float ns=0, amp=1, trk=1.5 + t;
  const vec3 seed = vec3(-4,-2,.5);
  mat3 rot = getOrtho(seed, up);
  for(int i=0; i<4; i++){
    p += sin(p.zxy + trk)*1.6;
    ns += sin(dot(cos(p), sin(p.zxy)))*amp;
    p *= rot;
    p *= 2.3;
    trk *= 1.5;
    amp *= .5;
  }
  return ns*.5;
}

float fs(vec2 p){
  return fract(sin(dot(p, vec2(12.41245, 78.233))) * 421251.543123);
}

float random(float x){
  return fs(vec2(x));
}

vec2 seed;
float rnd(){
  return fs(seed);
}

vec3 rndSphere(){
  float t = PI*rnd();
  float p = TAU*rnd();
  return vec3(cos(t)*cos(p), sin(t), cos(t)*sin(p));
}

vec3 rndHemi(vec3 n){
  vec3 v = rndSphere();
  return dot(n,v) > 0 ? v : -v;
}

void chmin(inout vec4 a, vec4 b){
  a = a.x < b.x ? a : b;  
}

float box(vec3 p, vec3 b){
  p = abs(p) - b;
  return min(0, max(p.x, max(p.y, p.z))) + length(max(p,0));
}

mat2 r2d(float t){
  float c=cos(t), s=sin(t);
  return mat2(c,s,-s,c);
}


float long, shrt;

vec4 map(vec3 q){
  vec3 p = q;
  vec4 d = vec4(100000, 0,0,0);  
  
  
  float bx = box(p, vec3(5, 3.25, 7));
  float bx2 = box(p, vec3(4, 3, 6));
  bx = max(bx, -bx2);
  bx2 = box(p - vec3(0,5,-1), vec3(1,2,1)) - .5;
  bx = max(bx, -bx2);
  bx -= .05*noise(p, shrt);
  chmin(d, vec4(bx, 0,0,0));
  
  p=q - vec3(-1, 0, -2);
  p.y -= shrt*2 - 1;
  p.xy *= r2d(PI*.2);
  for(int i=0; i<10; i++){
    p.zy *= r2d(-PI*.35*(.3 + shrt));
    p.xy *= r2d(-PI*.4*(1.3 - shrt*shrt));
    p.y -= .15;
    p = abs(p);
  }
  
  bx = box(p, vec3(.01, .2, .01));
  chmin(d, vec4(bx, 1,0,0));
  
  return d;
}

vec3 normal(vec3 p){
  vec2 e = vec2(0, 0.07678);
  return normalize(vec3(
    map(p + e.yxx).x - map(p - e.yxx).x,
    map(p + e.xyx).x - map(p - e.xyx).x,
    map(p + e.xxy).x - map(p - e.xxy).x
  ));
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt = uv - 0.5;
	pt /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  seed = vec2(noise(vec3(pt*37, time), 15.3), noise(vec3(pt*25, time), 1.2));
  
  float bps = 120/60;
  
  float tm = 0*bps*.5;
  float pre = random(floor(tm) - 1);
  float now = random(floor(tm));
  long = fract(tm);
  long = 0.5 + 0.5*cos(PI*exp(-8.*long));
  long = mix(pre, now, long);
  
  tm = time*bps*2;
  pre = random(floor(tm) - 1);
  now = random(floor(tm));
  shrt = fract(tm);
  shrt = 0.5 + 0.5*cos(PI*exp(-3.*shrt));
  shrt = mix(pre, now, shrt);
  
  vec3 c = vec3(0);
  
  float longAngle = .4 * TAU * (long - .5) + PI*.5;
  vec3 ro = vec3(0,0,3);
  
  vec3 fo = vec3(-1, 2*shrt - 1,-2);
 
  vec3 rov = normalize(fo - ro);
  vec2 pt2 = pt*r2d((long - .5)*PI*.3);
  vec3 rd = getOrtho(rov, up) * normalize(vec3(pt2, 1));
  
  float t=0;
  vec3 p=ro;
  vec4 d;
  for(int i=0; i<64; i++){
    p = ro + rd*t;
    d = map(p);
    if(abs(d.x) < 0.01){
      break;
    }
    t += d.x;
  }
  
  vec3 l = normalize(vec3(1,4,1));
  if(abs(d.x) < 0.01){
    vec3 n = normal(p);
    c += max(0, dot(n,l));
    float fre = pow(1 - abs(dot(n,rd)) , 5);
    c += fre;
    
    float ao=0,ss=0;
    vec3 h = normalize(l-rd);
    for(int i=1;i<=10;i++){
      float aot = 0.1*i + .05*rnd();
      float sst = 0.3*i + .5*rnd();
      vec3 nd = mix(n,rndHemi(n),.2);
      ao += map(p+nd*aot).x/aot;
      ss += map(p+h*sst).x/sst;      
    }
    c += ss*.1;
    c *= ao*.1;
    
    if(d.y == 1){
      c *= vec3(25, 1, 1.5);
    }
    
    vec3 hitp = p;
    float sh=1, tt=.1;
    for(int i=0; i<24; i++){
      hitp = p + l*tt;
      float d = map(hitp).x;
      tt += d + .2*rnd();
      if(d < 0.001){
        sh = 0;
        break;
      }
      if(tt > 30){
        break;
      }
      sh = min(sh, 88*d/tt);
    }
    
    c *= saturate(.2+sh);
  }
  
  
  float od=0;
  vec3 acc=vec3(0), fogC = vec3(1, .8, .8);
  int n=16;
  float st=min(2, t/n), tt=0;
  for(int i=0; i<n; i++){
    p = ro + rd*tt;
    tt += st*(.95+.1*rnd());
    od += .2*(1 + abs(noise(p*3, time))) * st;
    
    vec3 pp=p; float t=0.1;
    float sh=2;
    for(int j=0; j<24; j++){
      pp = p + l*t;
      float d = map(pp).x;
      t += d;
      if(d < 0.01){
        sh=0;
        break;
      }
    }
    acc += exp(-od*fogC)*sh*st;
  }
  c *= exp(-.3*od);
  c += acc;
  
  c = c/(1 + c);
  
  c = pow(c, vec3(.4545));
  c = smoothstep(.05, 1.4, c);
  float lum = dot(c, vec3(.2126, .7152, .0722));
  float shad = smoothstep(.4, .01, lum);
  float high = smoothstep(.3, 1., lum);
  c = c*shad*vec3(.4, 1.2, 1.2) + c*(1-shad*high) + c*high*vec3(.9, .8,.8);
  
  c *= 1. - length(pt);
  
	out_color = vec4(c,0);
}