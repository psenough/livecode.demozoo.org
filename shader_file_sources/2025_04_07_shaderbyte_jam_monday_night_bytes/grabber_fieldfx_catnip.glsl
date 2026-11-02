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
#define yuv2rgb mat3(1,1,1, 0,-.335,1.73, 1.37, -.6, 0);

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

float cat(vec2 p) {
	p.x = abs(p.x);
	vec2 q=p;
	q.x = abs(q.x-.2);
	q.y += q.x - .2;
	float r = abs(q.y)<.05 && q.x<.15 ? 1. : 0.;
	p.x -= .6;
	p.y = abs(p.y) - .08;
	r += abs(p.y)<0.03 && abs(p.x)<.15 ? 1. : 0.;
	return r;
}

float ld(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p-a, ba = b-a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
  return length(pa - ba * h) - r;
}

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

float df(vec3 p) {
  vec3 base = vec3(0);
  vec3 tg = base + vec3(0,1,0);
  float d = ld(p, base, tg, 0.5 + p.y / 10.), e;
  e = length(p - (tg + vec3(0,.85,-.2))) - .5;
  d = smin(d,e, .2);
  //return e;
  
  vec3 ls = tg + vec3(-.5 , .1, 0);
  vec3 rs = tg + vec3(.5 , .1, 0);
  e = ld(p, tg, ls, 0.4);
  d = smin(d, e, 0.2);
  e = ld(p, tg, rs, 0.4);
  d = smin(d, e, 0.2);
  
  tg = vec3(-1, 0, 0);
  r2d(tg.xy, sin(texture(texFFTIntegrated, 0.02).x));
  r2d(tg.xz, sin(texture(texFFTIntegrated, 0.03).x) * .5 + .7);
  vec3 le = ls + tg;  
  e = ld(p, ls, le, 0.2);
  d = smin(d, e, 0.2);

  tg = vec3(-.8, 0,0);
  r2d(tg.xy, sin(texture(texFFTIntegrated, 0.04).x));
  r2d(tg.xz, sin(texture(texFFTIntegrated, 0.05).x) + 1.5);
  vec3 lw = le + tg;
  e = ld(p, le, lw, 0.2);
  d = smin(d, e, 0.15);

// right
  tg = vec3(1, 0, 0);
  r2d(tg.xy, sin(texture(texFFTIntegrated, 0.03).x));
  r2d(tg.xz, sin(texture(texFFTIntegrated, 0.02).x) * .5 - .7);
  le = rs + tg;  
  e = ld(p, rs, le, 0.2);
  d = smin(d, e, 0.2);

  tg = vec3(.8, 0,0);
  r2d(tg.xy, sin(texture(texFFTIntegrated, 0.05).x));
  r2d(tg.xz, sin(texture(texFFTIntegrated, 0.04).x) - 1.5);
  lw = le + tg;
  e = ld(p, le, lw, 0.2);
  d = smin(d, e, 0.15);
  
  // leggen
  tg = vec3(-.4,-.4, 0);
  e = ld(p, base, base + tg, 0.3);
  d = smin(d, e, 0.15);
  
  le = vec3(-.2, -1.2, 0);
  float lrot=sin(texture(texFFTIntegrated, 0.06).x * 2.) * .7 + .5;
  r2d(le.yz, lrot);
  le += tg;
  e = ld(p, base+tg, le, 0.3);
  d = smin(d, e, 0.15);
  
  lw = vec3(-0.1, -1.,0);
  lrot += lrot + sin(texture(texFFTIntegrated, 0.07).x * 2.) * .5 - 1.5;
  r2d(lw.yz, lrot);
  lw += le;
  e = ld(p, lw, le, 0.2);
  d = smin(d, e, 0.15);
  le = vec3(0,0,-.6);
  r2d(le.yz, lrot);
  le += lw;
  e = ld(p, lw, le, 0.2);
  d = smin(d,e,.15);
 
// rithgt
  tg = vec3(.4,-.4, 0);
  e = ld(p, base, base + tg, 0.3);
  d = smin(d, e, 0.15);
  
  le = vec3(-.2, -1.2, 0);
  lrot=sin(texture(texFFTIntegrated, 0.07).x * 2.) * .7 + .5;
  r2d(le.yz, lrot);
  le += tg;
  e = ld(p, base+tg, le, 0.3);
  d = smin(d, e, 0.15);
  
  lw = vec3(-0.1, -1.,0);
  lrot += lrot + sin(texture(texFFTIntegrated, 0.08).x * 2.) * .5 - 1.5;
  r2d(lw.yz, lrot);
  lw += le;
  e = ld(p, lw, le, 0.2);
  d = smin(d, e, 0.15);
  le = vec3(0,0,-.6);
  r2d(le.yz, lrot);
  le += lw;
  e = ld(p, lw, le, 0.2);
  d = smin(d,e,.15);
  
  // tl
  tg = vec3(0,0,.5);
  base += tg + vec3(0, -.2, 0);
  lrot = .2;
  for (int i=0; i<4; i++) {
    r2d(tg.yz, sin(time) * .25 - .2 - texture(texFFTSmoothed, 0.04).x * 4.);
    r2d(tg.xz, sin(time * .5478) * .25);
    e = ld(p, base, base + tg, lrot);
    d = smin(d, e, 0.1);
    base +=tg;
    lrot *= 1.2;
  }
  return d;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(0.001, 0);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec3 rm(vec3 pos, inout vec3 dir) {
  float td = 0.1;
  for (int i=0; i<50; i++) {
    float d = df(pos + dir * td);
    if (d<0.001) {
      vec3 n = norm(pos + dir * td);
      dir = reflect(dir,n);
      return vec3(0.5);
    }
    
    td += d;
  }
  return vec3(1);
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  vec3 pos = vec3(sin(time / 4.437),sin(time / 4.7356),-3);
  vec3 dir = normalize(vec3(uv, 1.));
  r2d(dir.xz, time / 3.4257);
  r2d(pos.xz, time / 3.4257);
  //r2d(dir.xy, time / 2.5378);
  
  vec3 fkg = rm(pos, dir);
  
  float td = 5. / length(dir.xy);
  
  float tp = dir.z * td - time * 8.;
  
  vec3 bkg = vec3(.1,0,.5);
  r2d(bkg.yz, tp);
  bkg = bkg * yuv2rgb;
	bkg = 1.-bkg;
  bkg *= step(0.5, fract(tp / 8.));
  bkg *= pow(1./(1. + td), .5) * 3.;
  fkg *= bkg;
	vec3 catC = vec3(0);
	for (float i=0.;i<9.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		catC[int(i)/3] += cat(uv / 2. + o / 4.) / 3.;
	}
	out_color.rgb = pow(fkg, vec3(1.2));
}






































