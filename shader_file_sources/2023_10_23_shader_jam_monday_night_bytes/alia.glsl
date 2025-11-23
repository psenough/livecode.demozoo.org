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
#define iTime int(fGlobalTime*60)
#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x)

// =^^=
// greets to juni, jtruk + alien! And ofc aldroid and h0ff <3

float pDist(vec3 p, vec3 dir) {
  vec3 plane = normalize(vec3(sin(time/2),sin(time*.4225),2));
  float d=dot(-p,plane) / dot(dir,plane);
  return d;
}

float boxDist(vec2 p, vec2 s, float r) {
  p=abs(p)-s;
  return length(max(p,0.)) + min(0., max(p.x,p.y)) - r;
}

vec3 hash(vec3 p) {
  p=fract(p*vec3(253.3567,352.353,436.3535));
  p+=dot(p,p.yxz+19.19);
  return fract((p.xxy+p.yxx)*p.zyx);
}

vec3 map(vec2 p) {
  vec2 op = p;
  if (mod(iTime+p.y,200.) < 100.) {
    p=floor(p)/10;
    vec2 q=p;
    p.y += sin(p.x/2+time*8)*2;
  
    float mask=1-step(1.,mod(p.y,8.));
      int col = int(mod(p.y,3.));
    mask *= max(0.,fract(p.x/20 - time/3 + hash(vec3(floor(p.y))).x*8.)*2-1);
    p.y=fract(p.y/2)*2-.5;
    float d = 1-(abs(p.y)-.2);
    d = 1-smoothstep(0.,.1,p.y);
    d *= mask;
  
    vec3 c=vec3(d);
    c[col%3] = 0;
    return c;
  }
  //if (c.x+c.y+c.z==0) {
  //return c;
    ivec2 a=ivec2(op+iTime*0);
    int i=a.x^a.y;
    vec3 c=pow(fract(vec3(i+iTime)/256), vec3(3.));
 
  return c;
}

vec3 mask(vec2 p) {
  p.x *=3;
  int c=int(mod(p.x,3));
  p=fract(p)-.5;
  float b=1.-smoothstep(0., .1, boxDist(p, vec2(0.3), 0.));
  vec3 m=vec3(0);
  m[c] = b;
  return m*9;
}
#define samples 64

void main(void)
{
  vec3 o=vec3(0);
  for (int i=0;i<samples; i++) {
    vec2 uv = gl_FragCoord.xy;
    vec3 k=hash(vec3(uv / v2Resolution.xy, fract(time*1 + float(i/samples))));
    uv += k.xy*2.;
    uv = vec2(uv.x / v2Resolution.x, uv.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
    float z=sin(time/5.3244);
    z=pow(abs(z),3.) * sign(z);
    z=smoothstep(-1,1,z);
    vec3 p=vec3(sin(time/3),sin(time/4),-2+z*1);
    vec3 dir=normalize(vec3(uv,.25));
    //vec3 c=vec3(0);
  
    float dist=pDist(p,dir);
    if (dist>0) {
      p=p+dir*dist;
      p*=20;
      o+=map(p.xy) * mask(p.xy);
    }
  }
	out_color = vec4(o/samples,1);
}