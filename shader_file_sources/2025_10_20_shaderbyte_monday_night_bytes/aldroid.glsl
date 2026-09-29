#version 420 core
// there's an aaaaaaaldroid
// waiting for the jam
// they think they're going to shader
// but they haven't any ham
// uuhhh
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
  vec3 p=vec3(uv.x*324.23,uv.y*543.2,(uv.x+uv.y)*213.23);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float gft(float bp) {
  float btst= texture(texFFTSmoothed,0.3).x;
  return floor((texture(texFFTIntegrated,0.1).x-bp)*(40-40*btst))/(40-40*btst);
}

vec3 blps(float bp=0) {
  float ft = gft(bp);
  return vec3(cos(ft)*10,0,ft*10+sin(ft)*10+10);
}

float vn(vec2 uv) {
  vec2 p=floor(uv);
  vec2 f = fract(uv);
  vec2 u = f*f*(3-2*f);
  float a= n2(p+vec2(0,0)).x;
  float b= n2(p+vec2(1,0)).x;
  float c= n2(p+vec2(0,1)).x;
  float d= n2(p+vec2(1,1)).x;
  return a + (b-a)*u.x + (c-a)*u.y +(a-b-c+d)*u.x*u.y;
}
float fbm(vec2 uv) {
  float a=0.5;
  float res = 0;
  for (int i=0;i<4;++i) {
    res += vn(uv) * a;
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float gl;

float map(vec3 p) {
  vec3 bp = p - blps();
  float bld = length(bp)-1;
  gl += 1/(50+bld*sin(p.x+p.z)*fbm(p.xy)*0.01);
  return p.y+1+fbm(p.xz)+cos(length(bp)/10)*2;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)));
}

void main(void)
{
  float bt = floor(fGlobalTime - texture(texFFT,0.1).x*10);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ruv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 ro=vec3(0,3,1+gft(4)*10);
  vec3 la = blps(texture(texFFTSmoothed,0.1).x*5.1);
  vec3 f=normalize(la-ro);
  vec3 r=cross(f,vec3(0,1,0));
  vec3 u = cross(r,f);
  vec3 rd = normalize (6*f+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
    
  }
  
  vec3 p = ro+rd*t;
  vec3 ld = normalize(p-blps());
  //float nf=vn(uv);
  vec3 bgcol=vec3(0.2+plas(uv,bt*0.2)*0.1);
  //vec3 bgcol=vec3(1,1,1)*fbm(uv*20);
  vec3 col = vec3(0.4,0.,0.01);
  if (d<0.01) {
    vec3 n = gn(p);
    col = plas(vec2(0,3),bt/10).rgb*clamp(dot(-ld,n),0.1,1.)*1;
    col += vec3(1,1,0.5)*pow(max(dot(reflect(-ld,n),-rd),0),4)*0.3;
  }
  
  col = mix(bgcol+gl*texture(texFFT,0.1).x*10,col,exp(-0.0000005*t*t*t));
  
  col = floor(col*10)/10*0.7+col*0.3;
  col = pow(col,vec3(0.4545));
  
  out_color.rgb=col+texture(texPreviousFrame,ruv+vec2(0.01,0)).rgb*0.44;
}