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

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

vec4 plas( vec2 v, float time ){	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );}

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

float bd(vec3 p, vec3 s, float r) {
  p = abs(p) - s - r;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float df(vec3 p) {
  vec3 op = p;
  //p.xz = fract(p.xz / 32.) * 32. + p.x / 2.;
  p.xz = fract(p.xz / 4.) * 4. - 2.;
  p.y = 0;
  float r = -op.y / 4.;
  float d = bd(p, vec3(r, .25, r), .1);
  
  p = op;
  d -= abs(fract(p.y / 2.) * 2. - .5) / 4.;
  d *= .5;
  p.xz = fract(p.xz/4.)*4. - 2.;
  p.y -= 2.;
  r2d(p.xz, time);
  r2d(p.xy, time);
  
  d = min(d, bd(p, vec3(.2), .05));
  return d * .5; //+ floor(op.y) / 8;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(.001, 0);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec3 rm(vec3 p, vec3 dir) {
  vec3 c = vec3(1);
  bool hit = false;
  
  for (int i=0; i<100; i++) {
    float d = df(p);
    if (d < 0.001) {
      vec3 n = norm(p);
      //vec3 c = sin(p);
      //c *= pow(abs(c), vec3(.1)) * sign(c) / c;
      hit = true;
      dir = reflect(dir, n);
      p += n * 0.002;
      if (p.y > 1.) {
        c *= vec3(1,0,1) * abs(sin(p)) * dot(n, normalize(vec3(1)));
        break;
      } else {
      
        c *= sin(p + sin(p.yzx * .3)) * .4 + .6;
        c *= abs(dot(n, normalize(vec3(1))));
        c.rb += 4. * smoothstep(0.9, 1., fract(p.y / 8. - (time * 130. / 120.)));
        c += step(0.95, fract(p.y / 8. + (texture(texFFTIntegrated, 0.05).x * .2)));
      }
    }
    p += dir * d * .7;
  }
  if (!hit) c *= 0;
  return c;
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  float h = sin(time / 4.);
  vec3 p = vec3(0,sin(texture(texFFTIntegrated, 0.02).x / 8.)*2+3,time * 4);
  float a = length(uv);
  vec2 u = uv / a * (cos(texture(texFFTIntegrated, 0.02).x / 8.) + 1.2);
  //a *= 1.2;
  vec3 dir = vec3(u*sin(a), cos(a));
  //normalize(vec3(uv, 1));
  r2d(dir.yz, (h*.5+.5) * pi/2.);
  //r2d(p.xz, time / 4);
  r2d(dir.xz, time / 4);

	vec3 catC = vec3(0);
  
  catC = rm(p, dir);
  catC = pow(catC, vec3(.45));
	out_color = vec4(catC, 0.);
}






































