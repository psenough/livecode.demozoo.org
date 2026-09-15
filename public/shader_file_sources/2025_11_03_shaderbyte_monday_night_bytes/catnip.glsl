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

vec4 plas( vec2 v, float time ) {
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float torus(vec3 p, vec2 t) {
  p.xy = vec2(length(p.xy) - t.x, p.z);
  return length(p.xy) - t.y;
}

float df(vec3 p) {
  float dp = dot(p, p);
  float s = 10.;
  
  p = p / dp * s;
  r2d(p.xy, p.z / pi + sin(p.z + texture(texFFTIntegrated, 0.03).x) / 4.);
//  r2d(p.xy, p.z / pi + sin(p.z + time) / 4.);
  p = sin(p + vec3(time, time, -time * 2.));
  
  float d = torus(p, vec2(1, .1));
  d = min(d, torus(p.yzx, vec2(1, .1)));
  d = min(d, torus(p.zxy, vec2(1, .1)));
  
  float r = texture(texFFTSmoothed, fract(p.z / 5. + time) / 20.).x * 1280. + 12.;
  d += abs(fract(p.z * 8.) - .5) / r;
  d += abs(fract(p.x * 8.) - .5) / r;
  d += abs(fract(p.y * 8.) - .5) / r;
  
  return d * dp / s;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(1e-3, 0);
  return normalize(vec3(
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec4 rm(vec3 p, vec3 dir) {
  float td = 0.;
  for (int i=0; i<50; i++) {
    vec3 pos = p + dir * td;
    float d = df(pos);
    if (d<1e-3) {
      vec3 n = norm(pos);
      vec3 ld = normalize(vec3(1,1,1));
      return vec4(
        abs(sin(pos) * dot(n, ld)) + pow(1. - abs(dot(n, dir)), 4.) * vec3(abs(n.x),abs(n.y),abs(n.z)),
        pow(max(0., dot(ld, reflect(dir, n))), 400.)
      ) / (pow(td + .001, 2.05) + 3) * 4.; 
    }
    td += d;
//    p += dir * d;
  }
  return vec4(0.);
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  vec3 p = vec3(0, 0, -1);
  vec3 dir = normalize(vec3(uv, 1.));
  
  vec4 col = rm(p, dir);
  /*
  float h = 0, s = 2.;
  uv = gl_FragCoord.xy / v2Resolution.xy;
  float xstep = 2. / v2Resolution.x;
  for (int i=0; i<100; i++) {
    h += texture(texPreviousFrame, uv).a * s;
    uv.x -= xstep;
    s *= .97;
  }
  col.rgb += vec3(1,2,1) * h * h * 1.;
  */
	out_color = col;
}

// Greets to aldroidia, iv, canmom, boris, buelfest and you!
