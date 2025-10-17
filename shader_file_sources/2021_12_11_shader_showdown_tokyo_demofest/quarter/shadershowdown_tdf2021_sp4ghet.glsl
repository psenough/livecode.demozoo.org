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

#define time fGlobalTime
#define saturate(x) clamp((x), 0,1)
const float PI = acos(-1);
const float TAU = 2 * PI;
const vec3 up = vec3(0,1,0);
const vec3 l = normalize(vec3(.2, 1, .2));

mat2 r2d(float t){
  float c = cos(t), s = sin(t);
  return mat2(c,s,-s,c);
}

mat3 ortho(vec3 z, vec3 up){
  vec3 cu = normalize(cross(z, up));
  vec3 cv = cross(cu, z);
  return mat3(cu,cv,z);
}

vec3 bg(vec3 n){
  float qq = dot(l,n) * .5 + .5;
  float q = qq + pow(qq,16)*2;
  vec3 p = ortho(l, up) * n;
  vec2 tp = vec2(atan(p.z, length(p.xy)), atan(p.y, p.x)) / TAU;
  q += texture(texNoise, tp * 5 + time  * .2).x;
  return vec3(q);
}

void chmin(inout vec4 a, in vec4 b){
  a = a.x < b.x ? a : b;
}

float box(vec3 p, vec3 b){
  p = abs(p) - b;
  return length(max(p, 0)) + min(0, max(p.x, max(p.y, p.z)));
}

vec4 to(vec3 p){
  float s = 2 / (1 + dot(p,p));
  return vec4(s*p, s-1);
}

vec3 from(vec4 p){
  float s = 1 / (1 + p.w);
  return s * p.xyz;
}

vec4 map(vec3 q){
  vec4 d = vec4(1000, 0,0,0);
  vec3 p = q;
  float f = length(p);
  vec4 p4 = to(p);
  float t = time * .2;
  p4.zw *= r2d(-t);
  p4.yw *= r2d(3*t);
  p = from(p4);
  float e = length(p);
  float cor = max(1,f) * min(1, 1/e);
  
  float bx = box(p, vec3(1.1));
  bx = max(bx, -box(p, vec3(1)));
  bx = max(bx, -box(p, vec3(2, .5, .5)));
  bx = max(bx, -box(p, vec3(.5, 2, .5)));
  bx = max(bx, -box(p, vec3(.5, .5, 2)));
  bx = max(bx, -box(vec3(abs(p.yz)-1, p.x).zxy, vec3(.5, .3, .3)));
  bx = max(bx, -box(vec3(abs(p.xz)-1, p.y).xzy, vec3(.3, .5, .3)));
  bx = max(bx, -box(vec3(abs(p.xy)-1, p.z), vec3(.3, .3, .5)));
  bx *= cor * .5;
  chmin(d, vec4(bx, 1,0,0));
  
  bx = box(p, vec3(2.1));
  bx = max(bx, -box(p, vec3(2)));
  bx = max(bx, -box(p, vec3(3, 1, 1)));
  bx = max(bx, -box(p, vec3(1, 3, 1)));
  bx = max(bx, -box(p, vec3(1, 1, 3)));
  bx = max(bx, -box(vec3(abs(p.yz)-2, p.x).zxy, vec3(1, .5, .5)));
  bx = max(bx, -box(vec3(abs(p.xz)-2, p.y).xzy, vec3(.5, 1, .5)));
  bx = max(bx, -box(vec3(abs(p.xy)-2, p.z), vec3(.5, .5, 1)));
  bx *= cor * .5;
  chmin(d, vec4(bx, 1,0,0));
  
  vec2 xy = vec2(length(p.xz) - .5,p.y);
  float thk = length(xy);
  float th = atan(p.x, p.z);
  float ph = atan(xy.y, xy.x);
  vec3 pp = vec3(mod(24 * th, TAU) - PI, thk - .2, mod(12 * ph, TAU) - PI);
  pp.xz /= TAU;
  float tr = box(pp, vec3(.3, .01, .45));
  tr *= cor * .5;
  chmin(d, vec4(tr, 2, 0,0));
  
  return d;
}
  
vec3 normal(vec3 p, vec2 e){
  return normalize(vec3(
    map(p + e.xyy).x - map(p - e.xyy).x,
    map(p + e.yxy).x - map(p - e.yxy).x,
    map(p + e.yyx).x - map(p - e.yyx).x
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt =uv - 0.5;
	pt /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 c = vec3(0);
	
  c.rg = uv;
  
  vec3 ro = vec3(0,1.7, 8);
  vec3 fo = vec3(0);
  
  vec3 rd = ortho(normalize(fo-ro), up) * normalize(vec3(pt, 1));
  vec3 p = ro;
  float t =0;
  vec4 d;
  for(int i=0; i<256; i++){
    p = ro + rd*t;
    d = map(p);
    t += d.x;
    if(abs(d.x) < .001 || t > 25){
      break;
    }
  }
  
  if(abs(d.x) < 0.001){
    vec3 n = normal(p, vec2(.01, 0));
    vec3 h = normalize(l-rd);
    vec3 re = reflect(rd, n);
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    vec3 al = d.y == 1 ? vec3(.99, .2, .1) : vec3(.2, .7, .8);
    float fre = pow(1 - saturate(dot(n, -rd)), 5);
    
    c += al * nl;
    c += al * (.1 + pow(nh, 20));
    c += fre * vec3(.1, .7, .3);
    c += al * bg(re);
    
    float ao = 0;
    for(int i=1; i<=20;i++){
      ao += saturate(map(p + n * i * .1).x / (i * .1));
    }
    c *= ao / 20;
  }else{
    c = bg(rd);
  }
  
  c = pow(c, vec3(.4545));
  c *= 1 - dot(pt,pt);
	out_color = vec4(c,0);
}