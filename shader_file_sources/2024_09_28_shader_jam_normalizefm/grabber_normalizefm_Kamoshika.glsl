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
#define hash(x) fract(sin(x) * 43758.5453123)
const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float BPM = 145.;
const float quadScale = 1.;
const int numSamples = 8;
float Time;
float reTime;

const uvec4 ch_W = uvec4(0x00C6C6,0xC6C6D6,0xD66C6C,0x6C0000);
const uvec4 ch_e = uvec4(0x000000,0x0078CC,0xFCC0CC,0x780000);
const uvec4 ch_b = uvec4(0x00E060,0x607C66,0x666666,0xDC0000);
const uvec4 ch_G = uvec4(0x003C66,0xC6C0C0,0xCEC666,0x3E0000);
const uvec4 ch_L = uvec4(0x00F060,0x606060,0x626666,0xFE0000);
const uvec4 ch_lov = uvec4(0x0044EE,0xFEFEFE,0x7C3838,0x100000);
const uvec4 ch_1 = uvec4(0x001030,0xF03030,0x303030,0xFC0000);
const uvec4 ch_0 = uvec4(0x007CC6,0xD6D6D6,0xD6D6C6,0x7C0000);
const uvec4 ch_crs = uvec4(0x000000,0x18187E,0x181800,0x000000);
const uvec4 ch_3 = uvec4(0x0078CC,0x0C0C38,0x0C0CCC,0x780000);

bool extract_bit(uint n, int b) {
  return bool(1U & (n >> b));
}

bool sprite(uvec4 spr, vec2 uv) {
  ivec2 I = ivec2(floor(uv));
  bool bounds = 0 <= I.x && I.x < 8 && 0 <= I.y && I.y < 12;
  int h = I.y / 3;
  if(h < 2) {
    spr.xy = spr.zw;
  }
  if(h % 2 == 0) {
    spr.x = spr.y;
  }
  int bit = 7 - I.x + (I.y % 3) * 8;
  return bounds && extract_bit(spr.x, bit);
}

vec3 hud(vec2 uv, vec3 col, float scale) {
  bool webgl = mod(Time, 2.) < 1.;
  uvec4[] str = webgl ? uvec4[](ch_W, ch_e, ch_b, ch_G, ch_L) :
                        uvec4[](ch_1, ch_0, ch_crs, ch_3, ch_crs);
  int len = webgl ? 5 : 4;
  
  uv *= 12. / scale;
  uv += vec2(8 * len, 12) * 0.5;
  int ix = int(floor(uv.x / 8.));
  ix = clamp(ix, 0, len - 1);
  uv.x -= float(ix * 8);
  
  if(sprite(str[ix], uv)) {
    col = min(col + 0.7, 1.);
  } else if(-5. < uv.x && uv.x < 11. && 0. < uv.y && uv.y < 13.) {
    col *= 0.3;
  }
  return col;
}

vec3 rayDir(vec2 uv, vec3 dir, float fov) {
  dir = normalize(dir);
  vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 side = normalize(cross(dir, u));
  vec3 up = cross(side, dir);
  return normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
}

void dof(inout vec3 ro, inout vec3 rd, inout float seed, float L, float factor) {
  float r = sqrt(hash(seed++));
  float a = hash(seed++) * PI2;
  vec3 v = vec3(r * vec2(cos(a), sin(a)) * factor, 0);
  ro += v;
  rd = normalize(rd * L - v);
}

float plaIntersect(vec3 oc, vec3 rd, vec3 normal) {
  return -dot(oc, normal) / dot(rd, normal);
}

bool sphIntersect(vec3 oc, vec3 rd, float ra2) {
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra2;
  return b * b > c;
}

float hash13(vec3 p) {
  return hash(dot(p, vec3(127.1, 311.7, 74.7)));
}

vec3 hsv(float h, float s, float v) {
  vec3 res = fract(h + vec3(0, 2, 1) / 3.);
  res = clamp(abs(res * 6. - 3.) - 1., 0., 1.);
  res = (res - 1.) * s + 1.;
  return res * v;
}

float smoothSqWave(float x, float factor) {
  x -= 0.5;
  float odd = mod(floor(x), 2.);
  factor *= odd * 2. - 1.;
  float res = smoothstep(0.5 - factor, 0.5 + factor, fract(x));
  return res * 2. - 1.;
}

float luma(vec3 col) {
  return dot(col, vec3(0.299, 0.587, 0.114));
}

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

float triWave(float x) {
  x -= 0.5;
  x *= 0.5;
  float res = abs(fract(x) - 0.5) - 0.25;
  return res * 4.;
}

float confettiIntersect(vec3 ro, vec3 rd, out vec3 normal, out float hue) {
  float t = -1.;
  
  for(int i = -1; i < 10; i++) {
    float pZ = floor(ro.z) - float(i);
    float tp = plaIntersect(ro - vec3(0, 0, pZ), rd, vec3(0, 0, 1));
    vec2 p = ro.xy + tp * rd.xy;
    
    float zID = mod(pZ, 500.);
    vec2 dis = vec2(sin(zID * 2.2), 0);
    p.x += dis.x;
    dis.y = hash(floor(p.x) + zID * 50.3218) * 500.;
    p.y += dis.y;
    
    vec3 ID = vec3(floor(p), zID);
    vec3 ce = vec3(ID.xy + 0.5 - dis, pZ);
    vec3 oc = ro - ce;
    
    vec2 maxQuadSize = normalize(vec2(8, 12)) * 0.5;
    vec2 quadSize = maxQuadSize * quadScale;
    float ra2 = dot(quadSize, quadSize);
    if(!sphIntersect(oc, rd, ra2)) {
      continue;
    }
    
    ID.xy = mod(ID.xy, 500.);
    float h = hash13(ID);
    hue = h;
    float a = (fract(reTime * 0.4) + h * 1e1) * PI2;
    mat2 rotA = rotate2D(a);
    normal = vec3(0, rotA[0].yx);
    
    float phi = fract(h * 1e2) * PI2;
    mat2 rotPhi = rotate2D(phi);
    float theta = acos(fract(h * 1e3) * 2. - 1.);
    theta += sign(fract(h * 1e4) - 0.5) * reTime * 0.1517;
    mat2 rotTheta = rotate2D(theta);
    normal.yx *= rotPhi;
    normal.xz *= rotTheta;
    
    float tc = plaIntersect(oc, rd, normal);
    if(tc < 0.) {
      continue;
    }
    
    vec3 P = oc + tc * rd;
    P.zx *= rotTheta;
    P.xy *= rotPhi;
    P.y = dot(P.zy, rotA[1]);
    P.xy *= rotate2D(h * 1e5);
    
    vec2 q = P.xy;
    q *= 12. / quadSize.y * 0.5;
    q += vec2(8, 12) * 0.5;
    
    //p -= 0.25;
    //p = fract(p) * 15.;
    
    uvec4[] str = uvec4[](ch_W, ch_e, ch_b, ch_G, ch_L, ch_lov);
    //uvec4[] str = uvec4[](ch_1, ch_0, ch_crs, ch_3);
    int len = str.length();
    int ix = int(floor(fract(h * 1e6) * float(len)));
    if(sprite(str[ix], q)) {
    //if(sprite(uvec4(-1), q)) {
      t = tc;
      break;
    }
  }
  
  if(dot(rd, normal) > 0.) {
    normal = -normal;
  }
  
  return t;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  
  Time = time * BPM / 60. * 0.5;
  reTime = Time + triWave(Time - 0.5) * 0.47;
  //reTime = Time + triWave(Time) * 0.47;
  //reTime = sin(Time * PI);
  
  vec3 ro = vec3(1, 1, -1) * reTime;
  float fov = 60.;
  fov += smoothSqWave(Time, 0.15) * 20.;
  vec3 dir = vec3(0, 0, -1);
  vec3 rd = rayDir(uv, dir, fov);
  
  float seed = hash13(vec3(uv, fract(time * 0.1)));
  float L = 3. + sin(time) * 2.;
  for(int i = 0; i < numSamples; i++) {
    vec3 ros = ro;
    vec3 rds = rd;
    dof(ros, rds, seed, L, 0.1);
    
    vec3 normal;
    float hue;
    float t = confettiIntersect(ros, rds, normal, hue);
    if(t > 0.) {
      vec3 albedo = hsv(hue, 0.7, 1.);
      vec3 ld = normalize(vec3(1, 5, 2));
      float diff = max(dot(normal, ld), 0.);
      float spec = pow(max(dot(reflect(ld, normal), rd), 0.), 30.);
      col += albedo * (mix(diff, spec, 0.5) * 7. + 0.3) * exp(-t * t * 0.02);
    }
  }
  col /= float(numSamples);
  col = clamp(col, 0., 1.);
  
  col = pow(col, vec3(1. / 2.2));
  
  //col += float(sprite(ch_W, uv * 15.));
  //col += fract(atan(uv.y, uv.x) / 6. + 0.5 - Time);
  
  float lu = luma(1. - col);
  if(mod(Time - 1., 2.) < 1.) {
    vec2 pos = gl_FragCoord.xy / v2Resolution;
    vec2 dis = (pos - 0.5) * 0.07;
    col.r = texture(texPreviousFrame, pos - dis).a;
    col.g = texture(texPreviousFrame, pos).a;
    col.b = texture(texPreviousFrame, pos + dis).a;
  }
  
  float s = 0.25 + pow(sin(Time * PI2 * 2.) * 0.5 + 0.5, 5.) * 0.3;
  col = hud(uv, col, s);
  
	out_color = vec4(col, lu);
}