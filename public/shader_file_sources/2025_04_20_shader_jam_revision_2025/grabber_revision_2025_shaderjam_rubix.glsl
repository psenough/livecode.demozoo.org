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
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texRevisionBW;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float t = fGlobalTime;
vec2 co;
float rnd() {
  co.x++;co.y--;
  return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float full = 0;

float segment(vec3 p, float s) // exact
{
    p = abs(p);
    p.x -= clamp(p.x, 0.0, s/2.);
    return length(p);
}

mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }

float map(vec3 p) {
  co = vec2(0);
  p.xy *= rot(t*1.7);
  p.xz *= rot(t*1.4);
  p.zy *= rot(t*1.5);

  //p += .1*sin(p.zxy);

  float r = 1.2;
  float d = length(p)-r;
//  d = abs(dot(cos(p), sin(p.zxy)));

  vec3 rv = vec3(1);
  for (int i = 0; i < (full==0?5:0); i++) {
    //vec3 rv = normalize(vec3(rnd()-.5, rnd()-.5, rnd()-.5));
    rv.xz *= rot(floor(t*2.4)/7.1);
    rv = normalize(rv);
    float d2;
    d2 = segment(p - r*rv, r*1)-.8;
    d = max(d, -d2);
    d2 = segment(p + r*rv, r*1.3)-.8;
    d = max(d, -d2);
  }

  return d;
}

vec3 norm(vec3 p){
  vec2 e = vec2(0,.001);
  return normalize(vec3(
    map(p+e.yxx) - map(p-e.yxx),
    map(p+e.xyx) - map(p-e.xyx),
    map(p+e.xxy) - map(p-e.xxy)));
}

float bg(vec2 uv, vec2 m){
  float sm = pow(length(uv),2)*10;
  float spi = t + m.y*3*sin(t*.71) + m.x*6.28 + sm;
  return spi;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = vec3(0);
  float k = 0;
  vec2 kuv = uv;
  kuv*= rot(t*1.6);
  k+= 15*kuv.x*sin(kuv.y*150);
  k+= 15*kuv.y*sin(kuv.x*150);
  k += 5*sin(t)*sin(t)*sin(t);
  col = 1.1*pow(length(uv),3)*vec3(.6,.2,.8) / (.8 + abs(k));
  
	vec2 m;
	m.x = (atan(uv.x / uv.y) / 3.14159) + t*0.04*(3 + sin(t) * 0.00);
	m.y = 1 / length(uv) * .2;
  m.y *= 1-pow(abs(sin(t*.3)),10);
  float spi = bg(uv,m);
	
 // m*=rot(t);
//  m-=vec2(.5);
  float f = 0.8*texture( texRevisionBW, m ).r * 1;
	col += f * cos(spi+vec3(2,3,4));
//  col*=.7;

//  if (mod(t, 3.4)<.3) uv.x=abs(uv.x);  
  full = fract(t/5)<.19?1:0;
  full=0;
  vec3 ld = vec3(0,0,1);
  vec3 ro = vec3(0,0,-5);
  vec3 rd = normalize(vec3(uv,2));
  vec3 p = ro;
  for (int i = 0; i < 50; i++) {
    float d = map(p);
    if (d > 50) break;
    if (d < 0.001) {
      vec3 n = norm(p);
      float diff = dot(-n,ld);
      diff = clamp(diff, 0,1);
      col = (diff*cos(vec3(1,3,5)+t*.3));
      if (full != 0) {
        vec2 tuv = vec2(0.5,0.45) + (-uv)*1;
        tuv *= rot(t);
        col = diff * texture( texLynn, tuv).rgb;
   //     col *= .8;
      }
      break;
    }
    p += d * rd;
  }

  vec2 tuv = vec2(0.5,0.45) + (-uv)*1;
  col += 0.99 * texture( texLynn, clamp(tuv, 0, 1)).rgb;
  vec2 eye1 = (tuv-vec2(.5))*8.;
  eye1+=vec2(1.5,.99);
  vec2 eye2 = (tuv-vec2(.5))*8.+vec2(-.3,.99);
  col += 0.99 * texture( texRevisionBW, clamp(eye1, 0, 1)).rgb;
  col += 0.99 * texture( texRevisionBW, clamp(eye2, 0, 1)).rgb;
col *= .7*(2-length(uv)*2);
  out_color = vec4(col,1);
}