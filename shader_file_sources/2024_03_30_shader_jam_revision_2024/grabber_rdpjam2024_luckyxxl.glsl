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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = 3.14159265;
const float TWO_PI = 2.0 * PI;

vec3 rainbow(float t)
{
  t = fract(t);
  const float s = 2 * TWO_PI;
  return max(vec3(max(cos(t*s), cos(1-t*s)), cos((t-1/3.)*s), cos((t-2/3.)*s)), vec3(0.0));
}

float t = fGlobalTime;
float b = fGlobalTime * 125.0 / 60.0;

vec3 f1(vec2 u)
{
  float tt = t * 3;
  u += vec2(sin(tt), cos(tt)) * 0.5;
  vec2 p = vec2(atan(u.y, u.x), length(u));
  p.x += sin(p.y * 10.0) * sin(b / 4 * TWO_PI) * 0.2;
  p.x += (texture(texFFT, 0.1).r * 2.0 - 1.0) + sin(t*20)*0.01;
  float k = (1.0 - smoothstep(0.0, 0.5, abs(fract((p.x / TWO_PI * 25.0) + t * 0.2) - 0.5))) * min(p.y * 3.0, 1.0);
  vec3 c = rainbow(t);
  c += vec3(1.0) * pow(k, 32.0);
  c *= 1.0 - fract(b*2)*2;
  return k * c;
}

vec3 f2(vec2 u)
{
  vec2 uu = u;
  u.x += (texture(texFFT, abs(u.y)).r * (1.0 + abs(u.y) * 10) * 2.0 - 1.0) * 0.3;
  u.x += sin(uu.y * 10 - t) * 0.1 + t * 0.1 + fract(b) * 0.1 * (fract(2*b) < 0.5 ? 1:-1);
  vec3 c = vec3(0.0);
  c += pow((1.0 - abs(fract(u.x * 5) - 0.5)), 16) * vec3(0.0, 1.0, 1.0);
  return c;
}

vec3 f3(vec2 u)
{
  vec2 cc = fract(u * 10);
  ivec2 ii = ivec2(u * 10);
  int i = (ii.x * 123 + ii.y * 1234124) % 1024;
  float d = distance(cc, vec2(0.5));
  float tt = b + u.y * 0.1 + i/52.0;
  vec3 c = max(0.0, fract(tt) * 0.5 - d) * vec3(0.0, 1.0, 0.0);
  return c;
}

vec3 f4(vec2 u)
{
  float y = u.y * 16;
  float o = fract(y);
  int i = int(y) + (int(b) * 12345) % 16;
  float s = max(0.0, 1.0 - fract(b));
  if((i% 4) != 0) s = 0;
  return vec3(o * s);
}

vec3 f5(vec2 u)
{
  vec2 p = vec2(atan(u.y, u.x), length(u));
  u *= 1.0 + texture(texFFT, 0.01).r;
  float a = -t;
  vec2 cs = vec2(sin(a), cos(a));
  mat2 r = mat2(cs.x, -cs.y, cs.y, cs.x);
  u = r * u;
  u.x += int(u.y * 4) * 0.3;
  u.y += int(u.x * 4) * 0.3;
  float d = 1.0 - length(u) + sin(p.x * 20 + t * 5 + sin(t * 4) * 10 + p.y * 20) * 0.04;
  float k = fract(d * 5 - t * 2 + sin(t * 2) * 2);
  vec3 c2;
  c2.x = fract(k);
  c2.y = fract(k + 1/3.);
  c2.z = fract(k + 2/3.);
  int i = int(k*8);
  vec3 c;
  c.x = (i&1)==0?1:0;
  c.y = (i&2)==0?1:0;
  c.z = (i&4)==0?1:0;
  return c2;
}

float f6(vec2 u)
{
  u.y += (sin(u.x + t) + sin(u.x + t * 1.1234) * 0.5) * 0.2;
  u.y += t * -0.2;
  float k = fract(u.y * 16 + t * 5) < 0.9 ? 1:0;
  return k;
}

vec3 f7(vec2 u)
{
  u.y += texture(texFFT, 0.0).r * 0.0;
  u.y += u.x * sin(t);
  vec2 c = fract((u+12456) * 8);
  ivec2 ii = ivec2((u+123456) * 8);
  ii.y += ii.x;
  int i = ii.x + ii.y;
  float d = 1.0-distance(c, vec2(0.5))*2.0;
  i<<=1;
  vec3 cc = vec3((i&1)==0?1:0, (i&2)==0?1:0, (i&4)==0?1:0);
  ii.y += ii.x + int(b);
  float h = (ii.y&1)==0?0.0:1.0;
  float hh = clamp(sin((u.x + u.y * 0.5) + t * 2) + sin(u.y + t * 4.1235), 0.0, 1.0);
  cc *= h;
  vec3 ccc = cc * vec3((i&1)==0?1:0) * d * hh;
  ccc += (1.0 - smoothstep(0.0, 0.1, abs(d - (1.0 - fract(b))))) * h * hh;
  return ccc;
}

void main(void)
{
	vec2 u = gl_FragCoord.xy / v2Resolution * 2.0 - 1.0;
  u.x *= v2Resolution.x / v2Resolution.y;
  
  vec3 c = vec3(0.0);
  //c += f2(u) * 0.5;
  //c += f3(u) * 0.8;
  //c += f4(u) * 0.3;
  c += f5(u);
  c = mix(f5(u), f1(u), f1(u) * 10);
  
  //c = mix(c*0.8, f7(u), f6(u));
  c = f5(u)*0.6;
  vec3 o = clamp(f7(u), 0.0, 1.0);
  c = mix(c, o, o*2);
  c *= 0.8;
  if(fract(t * 20) < 0.5) c *= 0.0;
  c += clamp(f1(u), 0.0, 1.0);
  //c += clamp(f1(u), 0.0, 1.0);
  
  //c += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution).rgb * 0.5;
  //c *= 0.0;
  
  vec2 uu = u;
  if(fract(b/4)<0.25) uu = uu.yx;
  c += (1.0 - smoothstep(0.0, 0.3, abs(uu.y - sin(b * TWO_PI) * (fract(uu.x * 4)< 0.5?-1:1)))) * vec3(fract(uu.y*32)<0.2?1:1);
  
  vec2 uuu = gl_FragCoord.xy/v2Resolution*2-1;
  float ps = 0.0, pd = 0.005;
  c.r += ps*texture(texPreviousFrame, (uuu * (1-pd))*.5+.5).r;
  c.g += ps*texture(texPreviousFrame, (uuu * 1)*.5+.5).g;
  c.b += ps*texture(texPreviousFrame, (uuu * (1+pd))*.5+.5).b;
 

	out_color = vec4(c, 1.0);
}