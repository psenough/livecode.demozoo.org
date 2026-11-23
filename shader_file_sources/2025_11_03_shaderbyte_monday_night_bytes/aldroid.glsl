#version 420 core

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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*432.23,uv.y*124.43,(uv.x+uv.y)*324.23);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float smin(float a, float b, float k) {
  float h = max(0,k-abs(a-b));
  return min(a,b)-h*h*0.25/k;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float map(vec3 p, out vec2 uv, out int mat) {
  mat=1;
  float mt = texture(texFFTIntegrated,0.2).x;
  vec3 q = p;
  float b1 = length(q-vec3(cos(mt*0.9),cos(mt*0.86),cos(mt*9.1))) - 1.5;
  float b2 = length(q+vec3(sin(mt*.73),sin(mt*9.2),sin(mt*8.65))) - 1.5;
  float res = smin(b1,b2,.94);
  uv = vec2(atan(p.z,p.x),p.y/3);
  
  return res;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  vec2 ig1;
  int ig2;
  return normalize(map(p,ig1, ig2) - vec3(map(p-e.xyy,ig1, ig2), map(p-e.yxy,ig1,ig2), map(p-e.yyx,ig1,ig2)));
}

vec3 blobmat(vec2 uv) {
 
  float bt1 = texture(texFFTIntegrated,0.1).x-texture(texFFT,0.1).x*4;
  float bt2 = texture(texFFTIntegrated,0.4).x-texture(texFFT,0.4).x*2;
  bt1 /= 3; 
vec3 col1 = plas(uv,bt1).xyz;
  col1 *= smoothstep(0.7,0.71,dot(col1,col1));
vec3 col2 = plas(uv*0.9,bt2).xyz;
  col2 *= smoothstep(0.7,0.71,dot(col2,col2));
  vec3 col = col1+col2;
  return col;
}

void main(void)
{
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10), rd= normalize(vec3(uv,3));
  float t=0,d;
  
  int mat;
  vec2 texuv;
  for (int i=0;i<100;++i) {
    d=map(ro+rd*t, texuv, mat);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  float uvn = n2(uv).x;
  vec3 col=vec3(uvn*(10.4*texture(texFFT,0.1)));
  
  vec3 ld = normalize(vec3(1,2,-3));
  
  if (d<0.01) {
    vec2 nte = n2(texuv);
    col = blobmat(texuv+nte*0.01);
    col *=0.5+0.5*length(nte);
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col *= dot(ld, n);
    col += pow(max(dot(reflect(-rd,n),-ld),0),4)*0.4;
  }
  
  out_color.rgb = col;
}