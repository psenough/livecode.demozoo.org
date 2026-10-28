// =^^=
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
#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x)

float bass = texture(texFFTSmoothed, 0.01).x;
float bass2 = texture(texFFTSmoothed, 0.03).x;
float btime = texture(texFFTIntegrated, 0.03).x;

vec3 hash(vec3 p) {
  p = fract(p*vec3(345.678, 456.789, 234.567));
  p += dot(p, p + 19.19);
  return fract((p.xxy+p.yyx) * p.zyx);
}

float pdist(vec3 p, vec3 d, vec4 pln) {
  float dist = dot(pln.xyz * pln.w - p, pln.xyz) / dot(d, pln.xyz);
  return dist < 0. ? 1000. : dist;
}

vec4 cdist(vec3 p, vec3 dir) {
  vec3 a = (-.5 - p)/dir, b = (.5 - p) / dir;
  vec3 n = min(a,b), f = max(a,b);
  float x = min(f.x, min(f.y, f.z)),
  d= max(n.x, max(n.y, n.z));
  float o = d<0 ? x : d;
  if (o<0 || d>=x) return vec4(0,0,0,-1);
  
  vec3 norm = normalize(step(0.001, abs(a-o)) - step(0.001, abs(b-o))) * sign(d);
  return vec4(norm, o);
}

float check(vec2 p, float scale, vec2 offset) {
  ivec2 t = ivec2(p*scale+offset + 100.);
  return float((t.x%2+t.y%2)%2);
}
  
float fb(vec2 p, vec2 a, bool inv) {
  p = fract(btime) < 0.5 ? abs(p) : p;  
  float fb = //fract(btime / 4) < 0.25 >
 //  texture(texInerciaBW, fract(p * a * (16./9.) * .5 + .5)).a;// : 
  texture(texPreviousFrame, fract(p * a * (16./9.) * .5 + .5)).a;
  //fb += check(p, 1.03, vec2(0))*.2;
  fb += hash(p.xyy).x * .2-.1;
  fb = inv ? 1-fb : fb;
  fb = (fb - .5) * 1.03 + .5;
  return fract(fb);
}

float df(vec2 p) {
  p = fract(btime)<.25 ? abs(p)-.25 : p;
  r2d(p,time);
  p = fract(btime*3)<.25 ? abs(p*2)-.5 : p;
  r2d(p,-time);
  p = fract(btime*5)<.25 ? abs(p)-.25 : p;
  
  float d = length(p) - bass2*8.;
  p = abs(p)-.25;
  d = min(d, length(p) - bass*8.);
  
  p = abs(p)-bass2*12.;
  d = mod(btime, 1.) < 0.5 ? d : max(p.x, p.y);
  //return d;
  d = abs(d) - 0.005;
  d = smoothstep(0., .01, d);
  return d;//abs(d)-.01;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	vec2 aspect = vec2(v2Resolution.y / v2Resolution.x, 1);
  uv /= aspect;
  
  float tmp = sin(btime*4.);
 // tmp = pow(abs(tmp), 5.) * sign(tmp);
  float zoom = 1.1 + tmp*.04;
  vec3 p = vec3(sin(time*.524)*0.01,sin(time*.4743)*0.01,-zoom);
  vec3 d = normalize(vec3(uv, 1));
  
  r2d(d.xy, sin(btime)*0.02);
  float dist = pdist(p, d, vec4(0,0,-1,0));
  p += d * dist;
  //out_color = vec4(fract(p), 1);
  //return;
  dist = df(p.xy);
	float fb = fb(p.xy, aspect, dist<0.5);
  //if (fract(btime)<0.2) fb = texture(texInercia, uv*.5+.5).a;
  p = vec3(0,0,-2);
  tmp = sin(btime)*1. + 2.;
  d = normalize(vec3(fract(uv*tmp)*2.-1, sin(btime*3.)*.5 + 1.));
 
  tmp = time;//sin(time/3)/8.;
  out_color = vec4(0);
  r2d(p.xz,tmp);
  r2d(p.xy,tmp);
  r2d(d.xz,tmp);
  r2d(d.xy,tmp);
  vec4 cube = cdist(p,d);
  
  if (cube.w > 0.) {
    //r2d(cube.xz,-tmp);
    //r2d(cube.xy, -tmp);
    //r2d(p.xy,-tmp);
    p += d * cube.w;
    float l = max(0., -dot(cube.xyz, d));
    d = reflect(d,cube.xyz);
    
    //out_color.rgb += pow(l * (1-texture(texInercia, d.xy * .5 + .5).rgb), vec3(1.8));
    //out_color.a = fb;
   // return;
//    dist = fract(p.x);
  }
//out_color = vec4(vec3(dist+fb), fb + dist);
  out_color += vec4(pow(vec3(mix(vec3(fb), vec3(1-dist,dist,dist), vec3(fb))), vec3(1.8)), fb);
}