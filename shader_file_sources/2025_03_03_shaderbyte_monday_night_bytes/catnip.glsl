#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);
#define pi acos(-1)

// Greets to pumpuli, totetmatt, weatherman, havoc and dj furthr <3

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;
const mat3 y2r = mat3(1,1,1, 0,-.335,1.73, 1.37,-.6, 0);

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

float pdist(vec3 p, vec3 d) {
 // if (d.z > 0) return distance(-p.y, 4.) /  -d.y;
  return abs(distance(p.y, -4) / d.y);
}

vec4 sdist(vec3 p, vec3 d, vec3 o) {
 // p -= o;
  float t = dot(d, p) *2,
  a = dot(p, p) - 1;
  a = t*t - 4*a;
  
  if (a<0) return vec4(-1);
  a = sqrt(a);
  vec2 g = (vec2(-a, a) - t) / 2.;
  a = g.x < 0 ? g.y : g.x;
  if (a<0) return vec4(-1);
  
  return vec4((p+d*a), a);
}

vec4 cdist(vec3 p, vec3 dir) {
  vec3 s = vec3(
    texture(texFFTSmoothed, .002).x,
  texture(texFFTSmoothed, .005).x,
  texture(texFFTSmoothed, .007).x
  ) * 3. + .2;
  vec3 a = (-s - p) / dir,
  b = (s - p) / dir,
  f = max(a,b),
  n = min(a,b);
  
  float x = min(f.x, min(f.y, f.z)),
  d = max(n.x, max(n.y, n.z)),
  o = d < 0? x : d;
  
  if (d>x || o<0) return vec4(-1);
  return vec4(
      normalize(step(0.001, abs(a-o)) - step(0.001, abs(b-o))) * sign(d),
  o
  );
}

void main(void) {
  vec2 u = gl_FragCoord.xy / v2Resolution.xy,
  uv = (gl_FragCoord.xy * 2 - v2Resolution) / v2Resolution.y;
  
  float r = length(fract(vec2(sin(time / 3.247), cos(time / 2.174)) - u) - .5) - (.02 + texture(texFFTSmoothed, 0.01).r);
  vec2 off = vec2(sin(u.x * pi * 2 + time / 4.53278 + cos(u.y * pi * 4 + time / 3.7645)), cos(u.y * pi * 2 + time / 5.2472 + cos(u.x * pi * 4 + time / 4.347))) / v2Resolution.y;
  float l = texture(texPreviousFrame, fract(u + off)).a;
  
  if (r<0) l = fract(l+.05);
  out_color.a = l;
  
  float a = length(uv);
  u = uv / a;
  a = a * 1.5;// + 1.;
  vec3 pos = vec3(sin(time/2.583),sin(time/3.583),-2.1+sin(time/4.583)),
  //dir = normalize(vec3 (uv, 1));
  dir = -vec3(u * -sin(a), -cos(a));

  r2d(dir.xz, time/2.537);
  r2d(pos.xz, time/2.537);
  r2d(dir.xy, time/3.246);
  r2d(pos.xy, time/3.246);
  
  float li = 1.;
  bool h = false;
  vec4 sd = sdist(pos, dir, pos + vec3(0,0,3));
  sd = cdist(pos, dir);
  if (sd.w > 0) {
    pos += sd.w * dir;
    dir = reflect(dir, sd.xyz);
    li = .5;
    h = true;
  }
  
  r2d(dir.xz, time/2.537);
  r2d(pos.xz, time/2.537);
  r2d(dir.xy, time/3.246);
  r2d(pos.xy, time/3.246);
  
  
  pos.z += time * 20 - 1;
  
  float d = pdist(pos, dir);
  li /= pow(d, .5);
  pos += dir * d;
  uv = fract(pos.xz / 60.);
  l = texture(texPreviousFrame, uv).a;
  vec3 col = vec3(l * li,0,li);
  
  uv = fract(pos.xz / 43.);
  l = texture(texPreviousFrame, uv).a;
  if (h) {
     l=-l;
    //col.x = 1 - col.x;
    //col.yz *= 0;   
  } else {
  r2d(col.yz, l * pi * -1);
  }
  col = y2r * col;
  out_color.rgb = col;
  
 }
