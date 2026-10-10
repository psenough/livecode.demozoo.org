// ping pong beep boop
// nothing fancy this time sorry :p sick a bit (not a feet this time)

// backstory
// we planned a Pi Pico2 demo (a proper one, not the underutilized stuff like in lft's kaleidoscopico)
// made for the inercia 2o25, featuring lots of stuffz like cool 3d and particles and stuff and stuff
// but it ended up in quite of production hell, i made most of boilerplate code (incl. DVI/HSTX displau) 
// by september 2025 and i made a test of my YCoCg framebuffer + on-the-fly RGB conversion 
// to RGB, and it was a screenshot from Quake II (software render) with blob sprites blended on top :)

// this become a recurring joke in our group, and folks were making fun of me and that demo lmao

// unfortuantely i broke my foot, then another health troubles kicked in, the planned inercia trip was
// scrapped, and the demo postponed to revision as well :/

// anyway, enjoy this silly shader :p

// see you at SESSIONS!

// -- artemka o7.12.2o25


#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


// font
const int font[] =  int[](
    0,0,0,0,0,0,48,48,48,0,48,0,
    40,40,0,0,0,0,20,62,20,62,20,0,
    30,40,28,10,60,0,34,4,8,16,34,0,
    16,40,26,36,26,0,16,32,0,0,0,0,
    16,32,32,32,16,0,32,16,16,16,32,0,
    8,42,28,42,8,0,0,16,56,16,0,0,
    0,0,0,48,16,32,0,0,56,0,0,0,
    0,0,0,48,48,0,2,4,8,16,32,0,
    28,54,58,50,28,0,24,56,24,24,60,0,
    60,6,28,48,62,0,62,6,12,38,28,0,
    12,28,52,62,4,0,62,48,60,6,60,0,
    28,48,60,50,28,0,62,6,12,24,48,0,
    28,50,28,50,28,0,28,50,30,2,28,0,
    48,48,0,48,48,0,48,48,0,48,16,32,
    8,16,32,16,8,0,0,56,0,56,0,0,
    32,16,8,16,32,0,60,12,24,0,24,0,
    28,42,46,32,28,0,28,50,50,62,50,0,
    60,50,60,50,60,0,28,50,48,50,28,0,
    60,50,50,50,60,0,62,48,60,48,62,0,
    62,48,60,48,48,0,30,48,54,50,30,0,
    50,50,62,50,50,0,60,24,24,24,60,0,
    62,6,6,54,28,0,50,52,56,52,50,0,
    48,48,48,48,62,0,54,62,62,42,34,0,
    50,58,62,54,50,0,28,50,50,50,28,0,
    60,50,50,60,48,0,28,50,50,50,28,2,
    60,50,50,60,50,0,30,56,28,14,60,0,
    60,24,24,24,24,0,50,50,50,50,28,0,
    50,50,50,28,8,0,34,42,62,62,54,0,
    50,50,28,50,50,0,52,52,60,24,24,0,
    62,12,24,48,62,0,48,32,32,32,48,0,
    32,16,8,4,2,0,48,16,16,16,48,0,
    8,20,34,0,0,0,0,0,0,0,60,0,
    32,16,0,0,0,0,0,30,38,38,30,0,
    48,60,50,50,60,0,0,30,56,56,30,0,
    6,30,38,38,30,0,0,28,54,56,28,0,
    14,24,62,24,24,0,0,28,38,62,6,28,
    48,60,50,50,50,0,48,0,48,48,48,0,
    6,0,6,6,38,28,48,50,60,50,50,0,
    48,48,48,48,28,0,0,52,62,42,42,0,
    0,60,50,50,50,0,0,28,50,50,28,0,
    0,60,50,50,60,48,0,30,38,38,30,6,
    0,60,50,48,48,0,0,30,56,14,60,0,
    24,62,24,24,14,0,0,50,50,50,28,0,
    0,50,50,28,8,0,0,34,42,62,54,0,
    0,54,28,28,54,0,0,38,38,30,6,28,
    0,62,12,24,62,0,24,16,48,16,24,0,
    32,32,32,32,32,0,48,16,24,16,48,0,
    0,20,40,0,0,0,48,48,0,0,0,0
);

int text[] = int[](
    0,0,0,0,81,85,65,75,69,0,16,0,66,65,76,76,83,0,0,0,0,0,0,0,0
);

float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 230.0));}

float time = fGlobalTime;
float mt   = mod(time, 120);
float tt = mod(fGlobalTime + 0.01*hash(gl_FragCoord.xy/v2Resolution), 180.0);

const float PI = 3.14159265359;

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

// char grid
vec3 drawgrid(vec2 fuv, vec3 col) { 
  fuv.y = 1.0 - fuv.y;
  fuv.y -= 0.515;
  fuv.x += fGlobalTime*0.1;
  
  ivec2 cg = ivec2(floor(fuv*80));
  if (cg.y < 0 || cg.y > 5) return col;
    
  int bitpos = 0x20 >> (cg.x%6);
  int bit = font[((text[(cg.x/6) % text.length()]*6)+(int((cg.y)))) % font.length()] & bitpos;
  return bit==0 ? col : col - 0.5*vec3(1.0);
}

// -------------------
// 3d raymarching stuff

int total_balls = 1 + int(time*0.5) % 6;

float sphere(vec3 p, float r) {
  return length(p)-r;
}

float map(vec3 p) {
  float t = time;
  
  float disp = 1.5;
  float k = 3.0;
  float acc = 0.0;
  
  p.x *= (1.0+0.02*texture(texFFT,abs(mod(p.x+time,1)-1.5)*0.01).r+0.9*texture(texFFT,0.010).r);
  p.y *= (1.0+0.02*texture(texFFT,abs(mod(p.x+time,1)-1.5)*0.01).r+0.9*texture(texFFT,0.011).r);
  
  for (int i = 0; i < total_balls; i++) {
    acc += exp(-k*sphere(p+vec3(
      1.5*sin(t*(0.5+disp*(0.4+sin(i*0.46)))),
      1.5*cos(t*(0.5+disp*(0.4+cos(i*0.24)))),
      1.5*sin(t*(0.5+disp*(0.4+sin(i*0.65))))
    ), 1.0));
  }
  
  return -log(acc+0.001)/float(total_balls+(0.5/total_balls));
}

vec3 norm(vec3 p) {
  vec2 b = vec2(0., 0.0001);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}

vec2 trace(vec3 o, vec3 d) {
  float t = 0.;
  float mct = 1000.0;
  for (int i = 0; i < 256; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((abs(ct) < 0.00001) || (t > 128.)) break;
    t += ct;
    mct = min(mct, abs(ct));
  }
  
  return vec2(t, mct);
}

// cel shading palette
vec3 pal[] = vec3[](
  vec3(0.15,0.2,0.2),
  vec3(0.2,0.3,0.4),  
  vec3(0.4,0.4,0.6),
  vec3(0.5,0.5,0.7),
  vec3(0.7,0.6,0.8),
  vec3(0.7,0.6,0.8),
  vec3(0.8,0.8,0.9),
  vec3(0.98,0.98,0.97)
);

vec3 light(vec3 o, vec3 l, vec3 n, vec3 r) {
  float a = 0.1*(sin(n.x*2.3+n.z*3.3)+cos(n.y*1.3+n.x*2.2+0.5)+cos(n.z*0.24+n.x*0.45+0.5))+0.4;
  a += 0.6*max(dot(n, normalize(o)), 0);
  a += 0.9*pow(max(dot(l, r), 0), 32);
  a  = a/(1.0+0.3*a);
  a  += 0.02*hash(n.xy);
  a  = min(a, 1.0);
  a  = pow(a, 2.4);
  return mix(vec3(a), pal[int(floor(a * 7.7))], 0.7);
}

// backdrop palette
vec3 palette[] = vec3[](
  vec3(0.98, 0.96, 0.96),
  vec3(0.90, 0.99, 0.84),
  vec3(0.95, 0.89, 0.65),
  vec3(0.68, 0.76, 0.95),
  vec3(0.53, 0.86, 0.75),
  vec3(0.88, 0.76, 0.64),
  vec3(0.88, 0.66, 0.74),
  vec3(0.83, 0.76, 0.86)
);

vec3 backdrop(vec2 uv, vec3 color) {
  if (abs(uv.y) > 0.4) return color;
  uv *= rot2(mt*0.22);
  uv += 0.3*vec2(sin(mt*1.4),cos(mt*1.3));
  uv.x = abs(uv.x);
  uv += 0.1*vec2(sin(mt*1.2),cos(mt*0.8));
  uv.y = abs(uv.y);
  for (int i = 1; i < 9; i++) {
    uv *= rot2(mt*0.3+sin(i*4.9));
    uv += 0.6*vec2(sin(mt*0.3+i*1.2),cos(mt*0.1));
    uv = 1.02*abs(uv);
  }
  return palette[int(uv.x * palette.length()) % palette.length()];
}

vec3 glgrid(vec2 fuv) {
  const float zoom=10;
  ivec2 cg = ivec2(fuv*zoom);
  //sin(mt*1.2+cg.x*0.3)*cos(mt*0.8+cg.y*0.1)
  //return abs(hash(vec2(cg)+time)) > 1.0-0.8*texture(texFFT,0.02).r ? vec3(0.9) : vec3(0.0);
  float ift = float(int(mt*5))/5;
  return abs(hash(vec2(cg)+ift)) > 1.0-0.1*texture(texFFT,0.02+cg.x*0.02).r ? vec3(0.9) : vec3(0.0);
}

// ordered dither matrix
int dither[] = int[](0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5);

void main(void)
{
	vec2 fuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = fuv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 color = vec3(1.0);
  vec3 rmcol = vec3(0);
 
  text[10] = total_balls + 16;
  
  color = backdrop(uv, color);
  
  vec3 ray = normalize(vec3(uv, -0.7));
  vec3 o = vec3(0,0,4);
  //o.xy += 0.03*hash(uv*8.2+vec2(time*0.05));
  vec3 l = normalize(vec3(
    3*sin(mt*1.4),
    3*cos(mt*3.6),
    3*sin(mt*3.5)
  ));
  
  if (abs(uv.y)>.396 && abs(uv.y)<.4) color -= vec3(0.4);
  if (abs(uv.y)>.4) {
    color -= 0.9*(texture(texFFT, 0.1*abs(uv.x)).r);
  }
  if (uv.y < -.4) {
    color -= 0.3*texture(texInerciaBW, (uv - vec2(mt*0.5,.7))*vec2(1.6,-10)).rrr;
  }
  vec2 tm = trace(o, ray);
  float t = tm.x;
  //if (!((t == 0.0) || (t > 128.0))) {
    vec3 p = o+t*ray;
    vec3 n = norm(p);
    vec3 r = reflect(-l, n);
    //color = vec3(1.0);
    rmcol = light(o, l, n, r);
    //rmcol = rmcol / (1.0 + 0.3*rmcol);
    if (tm.y < 0.1) color *= 0.3;
    if (t < 128.0) color = rmcol;
   
    
    //color = mix(color,vec3(0.5,0.4,0.6),pow(max(dot(n,vec3(0,0,1)),0),2));
  //}
  
  color = drawgrid(uv, color);
  {
    int it = int(mt*9);
    ivec2 dfrag = ivec2(gl_FragCoord.xy / 4) % 4;
    int m = (((dfrag.x * 4) + dfrag.y) ^ (it & 15));
    //color = mix(color, color * (dither[m])/16, 0.09);
    
    color = vec3(ivec3((color + dither[m]/128.0)*10))/10.0;
  }
  //if (glgrid(uv).x>0.5) color = 1.0-color;
  out_color = vec4(color, 1.0);
}