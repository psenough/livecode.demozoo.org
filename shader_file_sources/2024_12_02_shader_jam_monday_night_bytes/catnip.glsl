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

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
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

float map(vec2 uv) {
  ivec2 c = ivec2(uv * 64);
  int q = c.x & c.y;// + 
 // (c.x ^ c.y) + c.x;
  float h = texture(texNoise, uv).x + texture(texNoise, uv * 2.).y / 2. + texture(texNoise, uv * 3.).z / 3.;
  h += texture(texFFTSmoothed, ((q+int(time*5)%60)%64)/640.).x * 2.;
  return h / 3.;
}

float samp(vec2 p) {
  return texture(texPreviousFrame, p * .2).w;
}

vec3 trace(vec2 uv, vec2 res, float stepSize) {
  vec3 p = vec3(sin(time / 30.) * 20.,sin(time / 4.)*.3 + 1.,time);
//  r2d(uv, cos(time / 30.));
  vec3 dir = normalize(vec3(uv - vec2(0, .7), 1));

  r2d(dir.xz, sin(time / 30.));
  
  vec3 col = vec3(0);
  bool hit = false;
  
  for (int i=0; i<400; i++) {
    float h = samp(p.xz);
    if (p.y < h) {
      col = vec3(h * (vec3(400-i) / 200.));
      hit = true;
      break;
    }
    p += dir * stepSize;
  }
  
  if (hit) {
    vec2 e = vec2(stepSize,0);
    vec3 n = normalize(vec3(
      samp(p.xz + e.xy) -samp(p.xz - e.xy),
      .1,
      samp(p.xz + e.yx) - samp(p.xz - e.yx)
    ));
    vec3 lDir = normalize(vec3(sin(time / 3.), .70, cos(time / 2.0)));
    
    col *= max(0., dot(n, lDir));
    
    for (int i=0; i<100; i++) {
      p += lDir * stepSize;
      float h = texture(texPreviousFrame, p.xz * 0.2).w;
      if (p.y < h) {
        col *= .5;
        break;
      }
    }
    return col;
  }
  return mix(vec3(1), vec3(0,0,1), pow(dir.y+.12, .25));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	
  float m = map(uv);
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
  float stepSize = 1. / v2Resolution.y;
	stepSize = 0.02;
  vec3 catC = vec3(0);
	/*for (float i=0.;i<9.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		catC[int(i)/3] += cat(uv + o / 4.) / 3.;
	}*/
  
  catC = trace(uv, v2Resolution.xy, stepSize);
	out_color = vec4(pow(catC, vec3(.45)), m);
}
