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

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;

vec3 hash(vec3 p) {
  p = fract(p * vec3(443.537, 537.247, 247.428));
  p += dot(p, p.yxz + 19.19);
  return fract((p.xxy + p.yxx) * p.zyx);
}

float pDist(vec3 p, vec3 d, vec4 plane) {
  return dot(plane.xyz * plane.w - p, plane.xyz) / dot(d, plane.xyz);
}

vec4 boxDist(vec3 rp, vec3 rd, vec3 aa, vec3 bb) {
  vec3 a = (aa - rp) / rd,
  b = (bb - rp) / rd,
  f = max(a, b);
  float x = min(f.x, min(f.y, f.z));
  return vec4(
    normalize(step(.001, abs(a-x)) - step(.001, abs(b-x))) * sign(x),
    x
  );
}

vec4 sphereDist(vec3 p, vec3 d, vec4 s) {
  p -= s.xyz;
  float t = dot(d, p) * 2.,
  a = dot(p, p) - s.w * s.w;
  a = t * t - 4. * a;
  if (a < 0.) return vec4(10000.);
  a = (-sqrt(a) - t) / 2.;
  return vec4((d * a + p) / s.w, a);
}

vec3 sCol(vec3 d) {
  return vec3(.7,.7,1) * (d.y * .5 + .5) + pow(max(0., dot(d, normalize(vec3(1,1,-1)))), 20.) * 2.;
}

void main(void) {
	vec3 col = vec3(0);
  
  for (int j=0; j<int(samples); j++) {
    vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.x;
    vec3 k = hash(vec3(uv + float(j) / samples, fract(time)));
    uv = uv * 1.5 + (k.xy - .5) * 16. / v2Resolution.x;
    float t = time - 0. + k.z * (3./60.);
    //t = 0.;
    vec3 p = vec3(500. + sin(t / 4.) * 2000., t * 2500., sin(t / 8.) * 250. - 300);
    vec3 d = normalize(vec3(uv, 1));
    p = vec3(sin(t / 3.) * 10000., cos(t/3.) * 10000., sin(t / 8.) * 250. - 300);
    //r2d(d.xz, cos(t / 5.5) / 2.);
    r2d(d.yz, sin(t / 3.4) / 2. - 1.);
    r2d(d.xy, -t / 3. - 1.4);
    // r2d(d.xy, t * 3.142);
    
    float dist = pDist(p, d, vec4(0,0,-1,0));
    if (dist < 0.) {
      col += sCol(d);
    } else {
      p += d * dist;
    
      float scale = maxScale;
      for (int i=0; i<steps; i++) {
        scale /= 2.;
        k = hash(vec3(floor(p.xy / scale), .1));
        if (fract(k.x) > .75) break;
      }
    
      vec3 pos = p / scale;
      
      vec3 iCol = vec3(1), aCol = k * k * .5 + .5, bCol = (1. - k) * .5 + .5;
      if (k.y > 0.7) aCol *= texture(texFFTSmoothed, k.x).x*500.;
      vec3 aa= vec3(floor(pos.xy), 0.) * scale,
      bb = vec3(ceil(pos.xy), 1.) * scale;
      vec4 sp = vec4(
        floor(pos.xy) + k.xy,
        k.z, k.z) * scale;
      
      for (int b=0; b<3; b++) {
        vec4 bDist = boxDist(p, d, aa, bb);
      
        vec4 sDist = sphereDist(p, d, sp);
        bDist = bDist.w < sDist.w ? bDist : sDist;
        iCol *= bDist.w == sDist.w ? aCol : bCol;
        p += d * bDist.w;
        p += bDist.xyz * 0.001;
        d = reflect(d, bDist.xyz);
      }
      col += sCol(d) * iCol;
    }
  }
	out_color = vec4(col / samples, 1);
}