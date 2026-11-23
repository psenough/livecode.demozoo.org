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

void main(void) {
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;

  vec3 pos = vec3(sin(time / 10) * 1000 + 2000, 2, cos(time / 10) * 1000 + 2000);
  
  vec3 dir = normalize(vec3(uv, 1.));
  r2d(dir.yz, sin(time/1.57)*.25+1);
  r2d(dir.xz, -time / 10.);
  
  vec3 cell = floor(pos);
  vec3 sDir = sign(dir);
  vec3 stepper = abs(1./dir);
  vec3 tMax = (step(0., dir) - fract(pos)) / dir;
  vec3 mask = vec3(0);
  vec4 col = vec4(0, 0, 0, 50000);
  float dist = 0;
  
  for (int i=0; i<512; ++i) {
    float ld = dot(mask, tMax - stepper);
    ivec3 iCell = ivec3(cell);
    if (
      (
        (((iCell.x + int(time * 0)) & iCell.z) % 64) ^ ((iCell.x / 3 & iCell.z / 3) % 64) - 64
      ) > iCell.y
    ) {
      vec3 k = hash(floor(cell / vec3(4,1,4)) + floor(texture(texFFTIntegrated, 0.01).x / 4.)*0.);
      k = step(0.9, k.y) * mix(vec3(1,0,0), vec3(0,0,1), k.x);
      col.rgb = k;
      k = hash(floor(cell / vec3(4,1,4)) + floor(texture(texFFTIntegrated, 0.01).x / 4.)*0.);
      k = step(0.95, k.y) * mix(vec3(1,0,0), vec3(0,0,1), k.x);
      col.rgb += k;
      col.gb += (
        iCell.y - 
        int(texture(texFFTIntegrated, fract(float(iCell.x / 8) / 100.)).x) - 
        int(texture(texFFTIntegrated, fract(float(iCell.z / 8) / 100.)).x * 10.)) % 16 == 0 ? 1. : 0.;
      //((iCell.y + ((iCell.z / 2) % 16) + ((iCell.x / 2) % 14) - int(time*15)) - (((iCell.x + iCell.z) % 13)  < 7 ? 1 : 0)) % 32 == 0 ? 1. : 0.;
      col.rgb *= 200. / ld;
col.rgb /= abs(float(iCell.y)) / 8.;      
      //col.w = ld;
      break;
    }
    
    mask = step(tMax, tMax.yzx) * step(tMax, tMax.zxy);
    tMax += mask * stepper;
    cell += mask * sDir;
  }
  
	vec3 catC = vec3(0);
	for (float i=0.;i<21.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		catC[int(i)/7] += cat(uv + o / 4.) / 3.;
		uv *= .99;
	}
	out_color = col;
}