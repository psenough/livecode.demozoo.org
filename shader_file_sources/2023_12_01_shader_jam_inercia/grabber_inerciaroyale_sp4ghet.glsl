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

float PI = acos(-1);
float TAU = PI*2;
float time = fGlobalTime;
vec3 up = vec3(0,1,0);
mat2 r2d(float t){
  float s = sin(t), c = cos(t);
  return mat2(c,s,-s,c);
}

float sdb(vec3 p, float radius, float roundness, float height){
  vec2 d = vec2(length(p.xz) - 2*radius + roundness, abs(p.y) - height);
  return min(max(d.x,d.y), 0.0) + length(max(d,0.0)) - roundness;
}

vec4 mapp(vec3 q){
  vec3 p = q;
  float d = 100000;
  vec3 mat = vec3(1);
  
  float sp = sdb(p, 0.05, 0.02, 1.);
  mat2 rot = r2d(PI * .15);
  p.xy *= rot;
  vec3 upslant = up;
  upslant.xy *= rot;
  float sub = sdb(p-upslant*.7, 0.1, 0.01, 0.15);
  sp = max(sp, -sub);
  d = min(sp, d);
  
  p = q;
  float bl = sdb(p-up*.7, 0.04, 0.02, 0.25);
  vec3 blk = vec3(0.01);
  if(abs(dot(normalize(p.xz), vec2(0,1))) > 0.9 && abs(p.y - .7) < .14){
    blk = vec3(.8, .8, .01);
  }
  mat = bl < d ? blk : mat;
  d = min(d,bl);
  
  return vec4(d, mat);
}

vec4 mapt(vec3 p){
  float x = length(p.xz) - .25;
  float y = p.y;
  float th = atan(y,x);
  float ph = atan(p.z, p.x);
  float r = length(vec2(x,y)) - 1.5;
  p = vec3(r, th, ph);
  p = p.yzx;
  p.y = mod(p.y, 2.) - 1;
  p.x = mod(p.x, .25) - .125;
  
  return mapp(p);
}

vec4 map(vec3 q){
  vec3 p = q;
  float t = fract(time * .03);
  p -= vec3(-.1, 0., -.2);
  p.xy *= r2d(TAU * .1);
  
  for(int i=0; i<10; i++){
    p.zy *= r2d(TAU * t + .01);
    p.xz *= r2d(-TAU * .5 * t);
    p.z -= .1;
    p = abs(p);
  }
  float bpm = 135.;
  float beat = time * bpm / 60.;
  
  if(mod(floor(beat * .5),3) < 1){
    return mapt(q);
  }
  if(mod(floor(beat * .5),3) < 2){
    return mapp(q);
  }
  
  return mapp(p);
}

vec3 normal(vec3 p){
  vec2 d = vec2(0.001, 0);
  return normalize(vec3(
    map(p + d.xyy).x - map(p-d.xyy).x,
    map(p + d.yxy).x - map(p-d.yxy).x,
    map(p + d.yyx).x - map(p-d.yyx).x
  ));
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt = uv - 0.5;
	pt /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 f = vec3(0);
  f = uv.y < 1./3. ? vec3(1) : f;
  f = uv.y > 2./3. ? vec3(0,114./255., 206./255.) : f;
  
  vec3 c = vec3(uv,0);
  
  vec3 ro = vec3(0,1,-4);
  ro.xz *= r2d(time);
  vec3 fo = vec3(0);
  vec3 rov = normalize(fo-ro);
  vec3 cu = normalize(cross(rov,up));
  vec3 cv = cross(cu,rov);
  vec3 rd = mat3(cu,cv,rov) * normalize(vec3(pt,1));
  vec3 p = ro;
  vec4 d = vec4(0);
  float t = 0;
  float th = 0.001;
  for(int i=0; i<128; i++){
    p = ro + rd*t;
    d = map(p);
    t += d.x * .7;
    if(abs(d.x) < th){break;}
  }
  
  vec3 l = normalize(vec3(1,1,1));
  vec3 l2 = normalize(vec3(1,1,-1));
  if(abs(d.x) < th) {
    vec3 n = normal(p);
    c = d.gba * max(dot(n,l),0.01);
    c += d.gba * max(dot(n,l2),0.01);
    c = pow(c, vec3(.4545));
  }else{
    c = f;
  }
  
  
  out_color = vec4(c,1);
}