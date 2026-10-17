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
#define nn texture(texNoise, p.xy).x * 0.55
#define mm texture(texFFTSmoothed, 0.01).x * 22.
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
float smin(float a, float b, float k){
  float h = max(0., k-abs(a-b))/k;
  return min(a,b) - h*h*h*k*.25;
}
float h(float a){
  return fract(sin(dot(a, 534.23))*732.);
}
float cc(float tt){
  tt *= .375;
  return mix(floor((tt)), floor((tt+1)), smoothstep(0., 1., pow(fract(tt), 15.)));
}
float bb(vec3 p, float s){
  p = abs(p)-s;
  return max(max(p.x, p.y), p.z);
}
float t = mod(fGlobalTime, 10.)*.72955;
float ac1 = 0., ac2 = 0., ac3 = 0.;
vec3 ac1color = vec3(0.225, 0.155, .525);
vec3 ac2color = vec3(0.123, .383, .43);
vec3 ac3color = vec3(.9, 0.34, 0.5);

float fr1(vec3 p, float sz, float rt){
  vec3 p0 = p;
  for(float i = 1.; i++ < 8.;){
    p.xy = abs(p.xy)-10.;
    //p.y += sin(i+t*15.+p.z*.135324)*.15-.15;
    p.xy *=rot(i*i+t*.55+rt*1.125+p.z*.00071);
    p.xy *= rot(p.z*.00161);
    
  }
  
  float d2 = length((p.xy))-sz-rt+2.;
  ac3 += 1.5/(.5+d2);
  float d3 = (length(p0-vec3(sin(t)*2., cos(t)*2., 0.))-.85);
  float d4 = (length(p0+vec3(0., sin(t)*3., cos(t)*3.))-.8);
  vec3 pc = p0;
  //pc.x = (fract(pc.x/5.-.5)-.5)*5.;
  for(float i = 0.; i++ < 8.;){
    pc = abs(pc)-2.9743;
    pc.xy *= rot(.121245+cc(t*.5436)+t*.08123);
    pc.zy *=rot(.1313+cc(t*.234)+t*.123);
    
  }
  float d5 = bb(pc, 1.225);
  ac1 += 1.5/(.65+d3*d3);
  ac2 += 2.5/(.55+d4*d4);
  return smin(smin(smin(d2, d5*.6, 2.), d3, 2.), d4, 2.);
}
float m(vec3 p){
  float d1 = fr1(p, .95, 1.65);
  float d2 = fr1(p, 1.05, 1.25);
  return min(d1, d2);
  
}
vec3 nm(vec3 p){
  vec2 e = vec2(-0.01, 0.0);
  return normalize(m(p)-vec3(m(p-e.xyy), m(p-e.yxy), m(p-e.yyx)));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= rot(t*.4125);
  //t += h(uv.x+t)*.014256;
	vec3 co = vec3(0.01);
  vec3 s = vec3(0.01, 0.01, -10.);
  vec3 p = s;
  vec3 pt = vec3(0.1, sin(t)*1.5, cos(t)*1.5);
  vec3 cz = normalize(pt-s);
  vec3 cx = normalize(cross(cz, vec3(0., -1. ,0.)));
  vec3 cy = normalize(cross(cz, cx));
  vec3 r = mat3(cx, cy, cz) * vec3(uv, 1+(length(uv)/50.));
  for(float i = 0.; i++ < 150.; ){
    float d = m(p);
    if(abs(d) < 0.00001) {
      //if(abs(d) > 0.0000001){
        r = reflect(r, nm(p)) * .816;
        p+=.125;
      //}
      //else break;
    };
    p+=d*r;
  }
  vec3 n = nm(p);
  vec3 l = normalize(vec3(1.95, -7.5, -1.));
  vec3 dif = clamp(vec3(dot(n,l)), 0., 1.);
  
  co = dif;
  
  co *= length(uv)/20.;
  co += ac3* ac3color * .00656;
  co += ac1* ac1color*.0136;
  co += ac2* ac2color * .0122;
  
  //co *= 6.-length(p-s)/150.;
  
  co *= pow(co, vec3(.214234));
  
	out_color = vec4(co, 1.);
}