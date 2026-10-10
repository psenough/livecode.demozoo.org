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


vec3 quad(vec3 o, vec3 d, float a1, float a2) {
  o.xz *= mat2(cos(a1),-sin(a1),sin(a1),cos(a1));
  d.xz *= mat2(cos(a1),-sin(a1),sin(a1),cos(a1));
  o.yz *= mat2(cos(a2),-sin(a2),sin(a2),cos(a2));
  d.yz *= mat2(cos(a2),-sin(a2),sin(a2),cos(a2));
  float t = -o.z / d.z;
  vec3 c = o+t*d;
  return vec3(c.xy, t);
}

float rand(vec2 p) {
  return fract(sin(dot(p,vec2(1,1.001)))*10000);
}

float ti = fGlobalTime;

float box(vec3 p, vec3 s) {
  vec3 q = abs(p) - s;
  return length(max(q,vec3(0))) + min(max(q.x,max(q.y,q.z)), 0.);
} 

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 c = vec3(0);
  float a = 0;
  
  vec3 o = vec3(0,0,-5);
  vec3 d = vec3(uv,1);
  a = ti*0.1;
  o.xz *= mat2(cos(a),-sin(a),sin(a),cos(a));
  d.xz *= mat2(cos(a),-sin(a),sin(a),cos(a));
  
  for(int j=0;j<20;j++) {
    float lo = tanh(sin(ti*2.5)*10.)+1.;
    lo += tanh(cos(ti*2.5)*10.)+1.;
    float dex = uv.x * 1000.0  * (1+rand(vec2(j,1)));
    float dey  =uv.y * 1000.*(1+rand(vec2(j,0)));
    if(fract(ti) < 0.5) dex = dey = 0;
    vec3 p = quad(o-vec3(0,0,(j-10)*0.3),d,j*lo*0.1+dex,j*lo*0.4+dey);
    vec3 pp = o+p.z*d;
    float d4 = 10000;
    for(int i=0;i<8;i++) {
      vec3 ce = vec3(rand(vec2(i,0)), rand(vec2(i,1)), rand(vec2(i,2))) - 0.5;
      ce *= 1.;
      float s = 1.;
      vec3 p2 = pp + ce;
      p2 = mod(pp + ce + s/2.,vec3(s)) - s/2.;
      p2.xz *= mat2(cos(a),-sin(a),sin(a),cos(a));
      p2.yz *= mat2(cos(a),-sin(a),sin(a),cos(a));
      float dd = box(p2, vec3(0.2+rand(vec2(floor(ti),0))*0.1));
      d4 = min(max(dd,-d4), max(-dd,d4));
    }
    float f = box(pp, vec3(1.));
    d4 = max(d4, -f);
    vec3 pr = pp;
    pr = mod(pr + 0.5 + ti, 1.) - 0.5;
    float f2 = box(pr, vec3(0.2));
    d4 = max(d4, -f2);
    vec3 cc = cos(vec3(0,2,4)+j*0.2+ti)*0.5+0.5;
    cc += exp(-max(f,0)*20.)*2.;
    cc += exp(-max(f2,0)*20.)*1.;
    cc /= pow(length(pp),2.);
    c += smoothstep(0.1, -0.1, d4) * 0.1 * cc;
    c += smoothstep(0.01, -0.01, abs(d4)-0.03) * 0.4 * cc;
  }
  
  vec3 u = vec3(0);
  for(int k=0;k<12;k++) {
    float a = rand(vec2(k,0) + uv*1000.+ti) * 6.;
    float r = rand(vec2(k,1) + uv*1000.+ti)*(1-cos(length(uv)*2.))*0.2;
    vec2 d = vec2(cos(a),sin(a)) * r;
    u += texture(texPreviousFrame, ouv + d).rgb;
  }
  u /= 12;
  c = mix(c,u,0.7);
    
  out_color = vec4(c,1);
}