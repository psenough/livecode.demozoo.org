#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texAkm;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float MAXX=2;
const float pi = acos(-1);

float aaa = floor(fGlobalTime*.33);
float t = 40+aaa+(mod(.05*fGlobalTime, .1*pi));

#define rep(p, r) mod(p, r) - r*.5
#define sat(a) clamp(a, 0., 1.)

float sphere(vec3 p, float r) { return length(p)-r; }
float cube(vec3 p, vec3 s) { vec3 b=abs(p)-s; return max(max(b.x, b.y), b.z); }

float t1=abs(sin(t*2));
float t2=abs(cos(t*2));
float t3=cos(t*10);
float t4=1;

float scene(vec3 p) {
	vec3 pp=p;
  float scale=1.;
  for(int i=0;i<7;i++) {
		float a=.6+.3*t1;
		float b=.7+.1*t2;
    p = 2.*clamp(p, -vec3(a*b), vec3(a*b))-p;
    float k = max((.5+.2*t1)/dot(p,p), 1.);
    p *= k;
    scale *= k;
  }
  return max(cube(p, vec3(.5+.1*t3))/scale, sphere(pp, .3+.0325*t4));
}

vec3 cameraDir(vec2 uv, vec3 o, vec3 t, float z) {
  vec3 forward = normalize(t-o);
  vec3 side = normalize(cross(vec3(-0.4,1,0), forward));
  vec3 up = normalize(cross(forward, side));
  
  return normalize(forward*z + side*uv.x + up*uv.y);
}

vec3 normal(vec3 p) {
  vec2 e = vec2(0.001, 0);
  return normalize(scene(p)-vec3(scene(p-e.xyy), scene(p-e.yxy), scene(p-e.yyx)));
}

vec3 march(vec3 og, vec3 dir, int it, float tresh, float maxd) {
  float d=0;
  int i=0;
  for(i=0; i<it; i++) {
    float h = scene(og+dir*d);
    if(abs(h) < tresh*d) { return vec3(1,d,i); }
    if(d>maxd) { return vec3(0,d,i); }
    d += h;
  }
  vec3(0,d,i);
}

#define ao(a) (scene(p+n*a)/a)

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv2 = uv;
  
  vec3 col = vec3(0);
  
  vec3 eye = 1.*vec3(.0,.21,.0);
  eye.xz += .3 *vec2(sin(t), cos(t));
  vec3 target = vec3(0);
  target.xy += .05 *vec2(cos(t*3), sin(t*2));
	
	float dist=0;
	
	for(float xx=0; xx<MAXX; xx++) {
		for(float yy=0; yy<MAXX; yy++) {
			uv2 = uv+vec2(xx,yy)/(.5*MAXX*v2Resolution);
			
			vec3 lcol = vec3(0);
			vec3 dir = cameraDir(uv2, eye, target, .5);
			
			vec3 lp = 3.*vec3(1,2,-2);
			lp.xyz += 3.*vec3(sin(t*2), cos(t), cos(t));
			
			vec3 m = march(eye, dir, 200, .001, 2.);
			dist = m.y;
			float i = m.z;
			
			if(m.x==1) {
				vec3 p = eye+dir*dist;
				vec3 n = normal(p);
				vec3 ld = normalize(lp-p);
				float diff = sat(abs(dot(n, ld)));
				float spec = sat(pow(abs(dot(dir, reflect(ld, n))), 10.));
				float fres = sat(pow(abs(1.-dot(n, -dir)), 2.));
				
				float a = ao(.005)*ao(.01)*ao(.02)*ao(.04)*ao(.08)*ao(.16);
				a = 6*mix(1., sat(a), .85);
				
				lcol = a*vec3(diff+spec)*fres*acos(-dir*.25+.5)*vec3(.5, 1., 1.);
				
				vec3 ml = march(p+ld*.01, ld, 100, .001, 1.);
				lcol *= .5*lcol+.5*sat(ml.y);
			}
			
			col += sat(lcol);
		}
	}
  
	col /= MAXX*MAXX;
	
  col = mix(col, 0.1 * vec3(0.5, 0.8, 1.), 1.0 - exp2(-3. * dist));
  col *= sat(1.15-pow(length(uv), 5.));
  col = pow(col, vec3(1./1.8));
  
  out_color = vec4(col, 1);
}