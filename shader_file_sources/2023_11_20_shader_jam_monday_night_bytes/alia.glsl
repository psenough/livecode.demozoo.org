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

/*
  It's transgender day of remembrance!
  I'm feeling kinda shitty for not being at the local vigil, but also not up to going.
  So, going to do a thing for that.
  Trans rights! 
*/

#define Rot2D(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x);
#define eps 0.001
#define time fGlobalTime

vec3 pal[5] = vec3[5](
  vec3(.5,.5,1),
  vec3(1,.5,.5),
  vec3(1),
  vec3(1,.5,.5),
  vec3(.5,.5,1)
);

vec3 font[20] = vec3[20](
  //t
  vec3(1,1,1),
  vec3(0,1,0),
  vec3(0,1,0),
  vec3(0,1,0),
  vec3(0,1,0),
  //d
  vec3(1,1,0),
  vec3(1,0,1),
  vec3(1,0,1),
  vec3(1,0,1),
  vec3(1,1,0),
  //o
  vec3(0,1,0),
  vec3(1,0,1),
  vec3(1,0,1),
  vec3(1,0,1),
  vec3(0,1,0),
  //r
  vec3(1,1,0),
  vec3(1,0,1),
  vec3(1,1,0),
  vec3(1,0,1),
  vec3(1,0,1)
);

mat3 rgb2yuv = mat3(
  .299, -.173, .511,
  .587, -.339, -.428,
  .114, .512, -.083);
  
mat3 yuv2rgb = mat3(
  1,1,1,
  0, -.336, 1.732,
  1.371, -.698, 0);

vec3 tdor(vec2 p) {
  p.y=-p.y;
  int x = int(mod(p.x, 5));
  ivec2 uv = ivec2(fract(p) * vec2(4, 6));
  if (x>3 || uv.x>2 || uv.y>4) return vec3(0);
  return pal[x] * font[x*5 + uv.y][uv.x];
}

void intersectCube(inout vec3 p, vec3 dir, inout vec3 norm, inout vec2 uv) {
  vec3 a = (1-p)/dir, b = (-1-p)/dir;
  vec3 f = max(a, b), n = min(a, b);
  
  float x = min(f.x, min(f.y, f.z)),
  d = max(n.x, max(n.y, n.z)),
  o = d<0 ? x : d;
  
  norm = normalize(step(eps, abs(a-o)) - step(eps, abs(b-o)));
  
  p += dir * o;
  if (norm.x==0 && norm.y==0) {
    uv = p.xy;
  } else if (norm.y==0 && norm.z==0) {
    uv = p.yz;
  } else {
    uv = p.xz;
  }
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 p = vec3(0,0,-.7);
  vec3 dir = normalize(vec3(uv, 1));
  
  Rot2D(p.xy, time/2);
  Rot2D(dir.xy, time/2);
  Rot2D(p.xz, time/2);
  Rot2D(dir.xz, time/2);
  
  vec3 o = vec3(0);
  
  vec3 norm;
  vec2 coords;
  float scale = 1.0;
  float bass = texture(texFFTIntegrated, .01).x;
  for (int i=0; i<50; i++) {
    intersectCube(p, dir, norm, coords);
    
    coords = abs(coords)*10.25;
    coords = coords.x < coords.y ? coords.xy : coords.yx;
    coords.x -= time/2;
    
    if (max(coords.x, coords.y)>9 && max(coords.x, coords.y)<10) {
      vec3 col = tdor(coords);
      col = rgb2yuv * col;
      col *= scale;
      vec3 col2 = col;
      Rot2D(col2.yz, 1.5);
      float t= clamp(length(uv)/.5, 0,1);
      col = mix(col2, col, t);
      col.yz *= t;
      col = yuv2rgb * col;
      o += col;
    }
    if (o.x+o.y+o.z>0) break;
  
    norm += p * (sin(bass/2)*.2+.2)*(sin(time)*.5+.5);
    norm += sin(i+time)*.1;
    norm = normalize(norm);
    dir = reflect(dir, norm);
    p += norm * eps;
    scale *= .9;
  }
	out_color = vec4(o, 1);
}