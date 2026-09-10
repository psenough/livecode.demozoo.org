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

float time = fGlobalTime*160/120;

float rand(vec2 p) {
  return fract(sin(dot(p,vec2(1,1.001)))*10000);
}

vec3 trace(float x, out vec3 t) {
  float u = floor(x);
  float f = fract(x);
  vec3 o0 = vec3(rand(vec2(u+0,0))-0.5, rand(vec2(u+0,1))-0.5, u+0) * vec3(40,20,60);
  vec3 t0 = vec3(rand(vec2(u+0,2))-0.5, rand(vec2(u+0,3))-0.5, 1) * vec3(40,40,15)* 8;
  vec3 o1 = vec3(rand(vec2(u+1,0))-0.5, rand(vec2(u+1,1))-0.5, u+1) * vec3(40,20,60);
  vec3 t1 = vec3(rand(vec2(u+1,2))-0.5, rand(vec2(u+1,3))-0.5, 1) * vec3(40,40,15) * 8;
  vec3 o = mix(o0,o1,6*pow(f,5) - 15*pow(f,4) + 10*pow(f,3));
  o += t0 * pow(1-f,3) * f;
  o -= t1 * pow(f,3) * (1-f);
  t = (o1-o0) * (30*pow(f,4) - 60*pow(f,3) + 30*pow(f,2));
  t += t0 * (-3*pow(1-f,2) * f + pow(1-f,3));
  t -= t1 * (3*pow(f,2)*(1-f) - pow(f,3));
  return o;
}

float capsule(vec3 p, vec3 a, vec3 b) {
  vec3 pa=p-a,ba=b-a;
  float h = clamp(dot(pa, ba)/dot(ba,ba),0,1);
  return length(pa-ba*h);
}

float map(vec3 o) {
  float x = floor(time*4)/4;
  vec3 T;
  vec3 p = trace(x,T);
  for(int i=-1;i<8;i++) {
    x += 1/4.;
    vec3 q = trace(x,T);
    if(capsule(o,p,q) < rand(vec2(x,0)) * 4 + 1.5) return 0;
    p = q;
  }
  if(rand(o.xz) < 0.1 || rand(o.xy) < 0.01 || rand(o.yz) < 0.01) return 1;
  return 0;
}


float vao(vec2 s, float c) {
  return (s.x+s.y+max(c,s.x*s.y))/3;
}

float ao(vec3 ii, vec3 ir, vec3 tw) {
  vec3 tu = tw.yzx;
  vec3 tv = tw.zxy;
  vec4 s = vec4(map(ii-tu),map(ii-tv),map(ii+tu),map(ii+tv));

  vec4 c = vec4(map(ii-tu-tv),map(ii-tu+tv),map(ii+tu-tv),map(ii+tu+tv));
  float v = mix(mix(vao(s.xy, c.x),vao(s.xw, c.y),dot(ir,tv)+0.5),
  mix(vao(s.zy, c.z),vao(s.zw, c.w),dot(ir,tv)+0.5),dot(ir,tu)+0.5);
  return 1-pow(v,2)*0.5;
  
}
bool cast(vec3 o, vec3 d, out vec3 ii, out vec3 ir, out vec3 tw) {
  vec3 u = floor(o);
  vec3 s = sign(d);
  d = abs(d);
  vec3 r = (o-u-0.5)*s+0.5;
  for(int i=0;i<100;i++) {
    if(map(u) > 0.5) {
      ii = u;
      ir = (r-0.5)*s;
      return true;
    }
    vec3 l = (1-r)/d;
    vec3 m = step(l,l.yzx) * step(l,l.zxy);
    tw = -s*m;
    r += d*length(l*m) - m;
    u += m*s;
  }
  return false;
  
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
time +=( rand(uv*1000+time)*0.01 + fract(gl_FragCoord.x/2) * 0.04 + fract(gl_FragCoord.y/2) * 0.02) *0.5;
  vec3 c = vec3(0);
  
  vec3 T;
  vec3 o = trace(time,T);
  vec3 d = vec3(uv,1+dot(uv,uv)*0.5);
  trace(time+0.1,T);
  T = normalize(T);
  vec3 B = normalize(cross(T,vec3(0,1,0)));
  vec3 N = cross(B,T);
  d = d.x*B + d.y*N + d.z*T;
  vec3 ii,ir,tw;
  if(cast(o,d,ii,ir,tw) || true) {
    vec3 pos = ii+ir+0.5;
    vec3 normal = sign(ir)*normalize(pow(abs(ir),vec3(10)));
    c = vec3(1);
    c *= ao(ii+tw,ir,tw);
    c  *= exp(-pow(distance(pos,o),2)*0.001);
    
    vec3 pl = trace(time+0.4, T);
    vec3 sd = normalize(pl-pos);
    float ra = max(0,dot(normal, sd)) / pow(distance(pl,pos), 0.5);
    cast(pos-d*0.01, sd, ii,ir,tw);
    if(distance(pos,ii+ir+0.5) < distance(pl,pos)) ra *= 0.0;
    
    if(distance(o,pl) < distance(o,pos)) ra += 0.1 / distance(pl, o+dot(pl-o,d)*d) * 9;
    
    pl = trace(time+0.15 + (cos(time*3.1415926535)*0.5+0.5)*0.2, T);
    sd = normalize(pl-pos);
    float ga = max(0,dot(normal, sd)) / pow(distance(pl,pos), 0.2);
    if(distance(pos,ii+ir+0.5) < distance(pl,pos)) ga *= 0.0;
    ga *= cos(ii.z+ir.z+0.5)*0.5+0.5;
    if(distance(o,pl) < distance(o,pos)) ga += 0.1 / distance(pl, o+dot(pl-o,d)*d) * 2;
    
    float rim = pow(1-max(0,dot(normal,normalize(o-pos))), 2);
   c *= (ga*vec3(1,0,0.5) + ra*vec3(0,0.5,1)+rim*vec3(0.5,0.25,0.75)*0.1) * 8;
  }
  
 // now I have completed all things I prepared beforreeeee
  
   // what should i do
  c *=cos(dot(uv,uv));
	out_color = vec4(c,1);
}