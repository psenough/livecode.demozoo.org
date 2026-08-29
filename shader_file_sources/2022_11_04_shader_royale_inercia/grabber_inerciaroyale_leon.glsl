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

#define time fGlobalTime
float fft, material, rnd;

mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }

float gyroid (vec3 p) { return dot(sin(p), cos(p.yzx)); }

float fbm (vec3 p) {
  float result = 0., a = .5;
  for (float i = 0.; i < 3.; ++i) {
    result += abs(gyroid(p/a)*a);
    a /= 2.;
  }
  return result;
}

float box (vec3 p, vec3 s)
{
  vec3 b = abs(p)-s;
  return max(b.x,max(b.y,b.z));
}

float random (vec2 p) { return fract(sin(dot(p,vec2(10.1324,5.654)))*46501.654); } 

float map(vec3 p)
{
  float dist = 100.;
  vec3 q = p;
  
  float t = time*1.+p.z*.5;
  t = pow(fract(t), 10.) + floor(t);
  t += rnd;
  float a = 1.;
  float tt = time + p.z;
  tt = pow(fract(tt), 10.1) + floor(tt);
  float r = .0*fft+.2+.1*sin(length(p)*3.-tt+p.z*5.);
  const float count = 12.;
  for (float i = 0.; i < count; ++i) {
    p.xz *= rot(t/a);
    p.yz *= rot(sin(t)/a);
    p.x = abs(p.x)-r*a;
    float shape = length(p)-.1*a;
    if (mod(i, 2.) < .5) shape = box(p,vec3(1,1,.01)*.15*a);
    material = shape < dist ? i : material;
    dist = min(dist, shape);
    a /= 1.2;
  }
  
  float noise = fbm(p*60.);
  dist -= noise*.002;
  return dist*.3;
}
#define ss(a,b,t) smoothstep(a,b,t)
void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution)/v2Resolution.y;
  float rng = random(uv);
  vec2 jitter = vec2(random(uv+.196),random(uv+4.1));
  fft = texture(texFFTSmoothed, 0.).r;
  fft = pow(fft, .8);
  float aa = abs(atan(uv.y, uv.x))/10.+fft*10.;
  float lod = 100.;
  aa = floor(aa*lod)/lod;
  float fft2 = texture(texFFT, aa).r;
  vec3 pos = vec3(0,0,2);
  float t = time*2.;
  float index = floor(t);
  float anim = fract(t);
  rnd = mix(random(vec2(index)), random(vec2(index+1.)), anim);
  vec3 ray = normalize(vec3(uv, -3));
  float luv = length(uv);
  ray.xy += jitter * smoothstep(.5, 2., luv)*.1;
  vec2 llod = 10.*vec2(random(vec2(floor(time*4.+.5))), random(vec2(floor(time*2.))));
  float blur = random(floor(uv*llod)+floor(time*4.));
  ray.xy += jitter*step(.95, blur)*.1;
  const float count = 100.;
  float shade = 0.;
  float total = 0.;
  for (float index = count; index > 0.; --index) {
    float dist = map(pos);
    if (dist < .0001 * total || total > 10.) {
      shade = index/count;
      break;
    }
    ray.xy += jitter*total*.0005;
    dist *= .9+.1*rng;
    total += dist;
    pos += ray * dist;
  }
  vec3 color = vec3(0);
  color += ss(4.,.5, luv)*.5;
  //uv.x = abs(uv.x)-fft*3.;
  luv = length(uv);
  color += ss(.01,.0,abs(abs(luv-8.5*fft))-fft2*4.);
  if (total < 10. && shade > .0) {
    color = vec3(0.2);
    vec2 unit = vec2(.001,0);
    vec3 normal = normalize(vec3(map(pos+unit.xyy)-map(pos-unit.xyy), map(pos+unit.yxy)-map(pos-unit.yxy), map(pos+unit.yyx)-map(pos-unit.yyx)));
    //color = normal*.5+.5;
    vec3 rf = reflect(ray, normal);
    color += .5+.5*cos(vec3(1,2,3)*5.+pos.z+blur);
    color *= mod(material, 2.);
    color += pow(dot(ray, normal)*.5+.5, 1.) * 2.;
    color += pow(dot(rf, vec3(0,1,0))*.5+.5, 10.);
    color *= shade;
  }
	out_color = vec4(color, 1);
}









