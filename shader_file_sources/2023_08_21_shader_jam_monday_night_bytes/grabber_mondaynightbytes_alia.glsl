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
#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x)
#define pi 3.142 // accuracty is important lol

float pln(vec3 p, vec3 d, vec3 n, float o) {
  float dist=dot(n * o - p, n) / dot(d,n);
  return dist<0. ? 10000. : dist;
}

vec3 hash(vec3 p) {
  p=fract(p*vec3(224.357,351.537,474.357));
  p += dot(p, p+19.19);
  return fract((p.xxy + p.yxx) * p.zyx);
}

vec3 col(vec2 p, float t) {
  vec2 op = p;
  p=fract(p)*2.-1.;
  float d = length(p);
  if (fract(t/4.) > .5) {
    p=abs(p);
    d=max(p.x,p.y);
  }
  d=fract(abs(d-fract(time)));
  d=(1-smoothstep(0.,.005,d))*20.;
  
  p=op;
  p=fract(p)*2.-1.;
  float r=1-step(0.03, abs(p.x+sin(time)));
  float g = 1-step(0.02, abs(max(p.x,p.y)+fract(time)));
  
  return vec3(r, g*4., 0) + d;
}


vec3 pos(vec2 p) {
  p = vec2(pi*2.*p.x, 2. * p.y - 1.);
  return vec3(sqrt(1.001-p.y*p.y) * vec2(cos(p.x), sin(p.x)), p.y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec4 o=vec4(0,0,0,1);
  float ft = texture(texFFTIntegrated, 0.01).x/8.;
  float cd=sin(ft*.67349);
  cd = pow(abs(cd), 5.) * sign(cd);
  vec3 p = vec3(sin(time)*.5,sin(time*.7937),-5+cd*3.);
  
  vec3 d = normalize(vec3(uv, 1));
  
  r2d(d.xz, sin(ft*1.246527)/2.);
  r2d(d.yz, sin(ft)/2.);
  
  vec3 k=hash(vec3(uv,.1));
  float fd = 5.;
  
  const int samps=64;
  float l=sqrt(length(uv));
  
  for (int i=0;i<samps;i++) {
    vec3 q=pos(k.xy) * pow(k.z,.25);
    r2d(q.xy,k.x*pi*2.);
    q *=1.5;
    vec3 t=p+d*fd;
    vec3 t2=p*d*fd*2.;
    t2+=q;
    vec3 d2 = normalize(t - t2);
    q = t2 - (d2 * fd * 2.);
    
    
    q += d2 * pln(q,d2,vec3(0,0,-1),0);
    vec3 c = col(q.xy, ft)/float(samps);
    c = mix(c,c.yzx,l);
    o.xyz += c;
    k=hash(k);
  }
  
  //o.xyz = col(p.xy);
  //o.rgb += k*.3;
	out_color = o;
}