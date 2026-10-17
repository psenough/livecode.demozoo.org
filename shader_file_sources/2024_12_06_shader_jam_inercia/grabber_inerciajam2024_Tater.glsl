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

#define STEPS 128.0
#define MDIST 128.0
#define pi 3.1415926535
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pmod(p,x) (mod(p,x)-0.5*(x))

float tbox(vec3 p, vec3 b, float s)
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) + max(0.0,(p.y+b.y)*s);
}

float ebox(vec3 p, vec3 b)
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 glow1 = vec3(0);
vec3 glow2 = vec3(0);
vec3 lc = vec3(1,0.75,0.2);

vec2 map(vec3 p){
  vec2 a = vec2(0);
  vec2 b = vec2(1);
  
  float h = 25;
  a.x = ebox(p, vec3(1,h,1));
  a.x = min(a.x, ebox(p - vec3(4,h,0), vec3(5,1,3)));
  a.x -= 0.3;
  
  
  b.x = tbox(p - vec3(4,4,0), vec3(10,h,7),0.1);
  b.x = max(b.x,-p.x+2);
  b.x = max(b.x,p.y - h+1.25);
  float light = b.x - 10;
  
  //a = (a.x<b.x)?a:b;
  b.y = 2.0;
  b.x = ebox(p - vec3(5,h-1.4,0),vec3(3.5,0.1,2));
  glow1+=0.1/(0.1+b.x*b.x)*lc;
  a = (a.x<b.x)?a:b;
  
  b = vec2(3);
  float s1 = 9999;
  float fft = texture(texFFTIntegrated,0.3).x*2. + fGlobalTime*0.5;
  float fft2 = texture(texFFTSmoothed,0.1).x*2.;

  float time = fft;
  for(float i = 0; i<5; i++)
  {
    float t = time + i*23 + time*0.2*i;
    vec3 p2 = p;
    p2.xz*=rot(time*0.2);
    p2+=vec3(-i*4.23423,i*2.2434234,i);

    p2.x +=sin(p2.z*(0.09+i*0.025)+t+i)*9;
    p2.y +=sin(p2.z*(0.10+i*0.02)+t+i)*3.;
   // p2.y+=t*5;
    p2.z+=p2.y;
    p2.z+=p2.x;
    p2.z += t*40;
    p2.yz+=sin(t*0.2)*4;
    float l = 0.3 + fft2 *20.;
    float size = 0.01+abs(sin(p2.z*0.01)*0.04);
    p2.xy = pmod(p2.xy,10.0+i+sin(fft2*100)*3);
    p2.z = pmod(p2.z,10.0);
    p2.z = p2.z - clamp(p2.z, -l, l);
    
    s1 = min(s1,length(p2)-size);
    
  }
  b.x = max(s1*0.6,light);
  b.x = max(b.x,p.y-h+2.);
  b.x = max(b.x,-p.x+1.);
  b.x*=0.7;
  a = (a.x<b.x)?a:b;

  //a.x = length(p)-1.0;
  a.x *= 0.8;
  return a;
}
vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0.0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0.05);
  vec3 ro = vec3(0,0,-10)*7.5;
  float fft = texture(texFFTIntegrated,0.1).x*2. + fGlobalTime*0.5;

  ro.xz *= rot(sin(fft*0.1)*0.2+10.2);
  vec3 lk = vec3(0,15,0);
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = normalize(f*1.5 + uv.x*r + uv.y*cross(f,r));
  vec3 p = ro;
  
  bool hit = false;
  vec2 d = vec2(0);
  float rl = 0;
  for(float i = 0; i < STEPS; i++){
    p = ro+rd*rl;
    d = map(p);
    rl+=d.x;
    if(d.x<0.01){
      hit = true;
      break;
    }
  }
  
  vec3 col2 = col;
  if(hit){
    vec3 n = norm(p);
    col = n*0.5+0.5;
    col = vec3(n.y*0.5+0.5)*0.05;
    col2 = col;
    //if(d.y==3.0);
     // col2 = vec3(0.05);

    vec3 lp = vec3(5, 12.5, 0);
    vec3 ld = normalize(lp - p);
    float diff = max(0.,0.5+dot(n,ld));
    vec3 light = lc;
    light*=diff;
    float spec = max(0.0,pow(max(0.4+dot(reflect(ld,n),rd),0),3));
    float falloff = smoothstep(1,0,pow(distance(p,lp)*0.05,2.0));
    col += light*falloff;
    col += spec*diff*(1+n.y)*lc;
    if(d.y==3.0)
      col = vec3(1)*5.0 * (glow1*20.) * clamp(falloff+0.5,0,1);

  }
    
  col+=glow1*0.5;

  float time = fft * 2;
  float s = sin(time*12.1222)*sin(time*3.345)*cos(time*6.2342) + sin(time) - 0.5;
  if(s > 0 )
    col = col2;
	out_color = vec4(col,1.0);
}