#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define TAU 6.2831853071795864769
#define PI  3.1415926535897932384
float t = fGlobalTime;
#define sat(a) clamp(a, 0., 1.)

vec4 getTextureBW(vec2 uv){
     vec2 size = textureSize(texInerciaBW,0);
     float ratio = size.x/size.y;
  if (uv.y>-0.061 && uv.y < 0.065 && uv.x > -0.498 && uv.x < 0.48)
     return texture(texInerciaBW,uv*vec2(1.,-1.*ratio)-.5);
  return vec4(0);
}
void main2(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 col = vec4(0.);
	col = getTextureBW(uv);
  out_color = sqrt(col);
}
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}




float wtf(float x) { return -1.+2.*fract(atan(atanh(fract(x*.5))/tan(x*.5))); }
vec3 pal(float a) { return .5+.5*cos(a+vec3(0,2+1.9*wtf(t),4+1.9*wtf(t+PI*.5))); }
vec4 polar(vec2 v) { return vec4(length(v), 0., 0., atan(v.y, v.x)); } // r=radius, a=angle
mat2 rot(float a) { float c=cos(a), s=sin(a); return mat2(c, s, -s, c); }


float map(vec3 p) {
  p.xy *= rot(t* .5);
  p.xz *= rot(t* .4);
  p.zy *= rot(t* .3);
  p -= .5*(sin(t*.4), cos(t*.4));
  p.xy -= vec2(.6);
  p = abs(p);
  p -= .5*(sin(t*.4), cos(t*.4));
  p.xy -= vec2(.6);
  p = abs(p);
  float r = 1.5;
  float d = length(p)-r;
  p -= vec3((.51+.03*sin(t*2.))*r);
  d = max(d, -(length(p)-.7*r));
  return d;
}

vec3 normal(vec3 p) { vec2 e=vec2(.001,0.); return normalize(
        vec3(map(p+e.xyy),map(p+e.yxy),map(p+e.yyx)) -
        vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)) ); }


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float iner = getTextureBW(uv*.55-vec2(0.,0.) ).r * .2;
  t += iner*(50.+10*sin(t));


  
  uv -= 0.03*vec2(sin(t*1.1), cos(t*1.1));
  vec2 uv2 = uv*1500.;
  uv2 *= rot(t*.05);
  ivec2 fff = ivec2(uv2 - v2Resolution.xy * 0.5);
  int n = (fff.x+fff.y)^(fff.x-fff.y);
  bool b = abs(n*n*n) % 997 < 62 + int(-cos(t*.3)*61.);
  

  
  float ff = 0.*getTextureBW(uv*.7-vec2(0.,0.28) ).r * .2;
	//m.x += ff*22.3;

	vec4 tt = plas( m * 3.14, fGlobalTime ) / d;
	tt = clamp( tt, 0.0, 1.0 );
	vec3 col = ((f + tt)*(8.*ff)+uv.xyxx).xyz;
  col.r = length(-uv.xyx)*.5;
  col/=2.;
  col += .5*vec3(int(b));
  
  uv /= 1.9;
  vec4 pol = polar(uv);
  uv=abs(uv);
  
    vec3 ro=vec3(0,0,-5);
    vec3 rd=normalize(vec3(uv,1.));
    vec3 p=ro;
    for (int i=0;i<50;i++){
        float d=map(p);
        if (d>20.) break;
        if (d<.001) {
            vec3 n = normal(p);
            vec3 ldir = vec3(sin(9.*t)*cos(7.*t), cos(9.*t)*cos(7.*t), 1.);
            ldir=normalize(ldir);
            float diff = sat(dot(n, -ldir +0.*.2*sin(10.*p)));
            vec3 h = -normalize(rd + ldir);
            float blinnPhong = pow(sat(dot(h, n)), 200.);
            col = vec3(diff)+blinnPhong;
            break;
        }
        p+=rd*d;
        col += .007*pal(pol.a)/(.0001+d);
    }

  
  
  out_color = vec4(col, 1.);
}



