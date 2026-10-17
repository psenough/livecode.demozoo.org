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

// aldroid here!

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a), sin(a), cos(a));
}

float smin(float a, float b, float k) {
  float h = max(k-abs(a-b),0.0);
  return min(a,b) - h*h*0.25/k;
  
}

vec2 n2(vec2 uv) {
  vec3 p=vec3(uv.x*345.23,uv.y*453.23,(uv.x+uv.y)*231.43);
  p = mod(p,vec3(3,5,7));
  p *= dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 f = fract(uv);
  vec2 l = floor(uv);
  vec2 u = f*f*(3-2*f);
  float a = n2(l+vec2(0,0)).x;
  float b = n2(l+vec2(1,0)).x;
  float c = n2(l+vec2(0,1)).x;
  float d = n2(l+vec2(1,1)).x;
  return a + (b-a)*u.x +(c-a)*u.y+(a-b-c+d)*u.x*u.y;
}

float fbm(vec2 uv) {
  uv *= 10;
  float val=0;
  float a= 0.5;
  
  for (int i=0;i<4;++i) {
    val += a*vn(uv);
    a *= 0.4;
    uv *= 2;
  }
  return val;
}


float map(vec3 p,out float mat, out vec3 uvw) {
  
  float t = texture(texFFTIntegrated,0.1).x*10;
  float t2= texture(texFFTIntegrated,0.5).x*100;
  vec3 headpos = vec3(0,1.5,0)+0.1*vec3(sin(t/4),sin(t/5),sin(t/7));
  vec3 bodpos = vec3(0,-1,0)+.5*vec3(sin(t/9),sin(t/11),sin(t/13));
  vec3 gobpos =vec3(0,1,-2)-.1*vec3(sin(t/7),sin(t/7.1),sin(t/7.3));
  float b1 = length(p-headpos)-2;
  float b2 = length(p-bodpos)-3;
  float b3 = length(p-gobpos)-.6;
  float b33 = length(p-gobpos-vec3(0,3,0))-3;
  b3 = max(b3,-b33);
  float b4 = length(p-vec3(3,1.5+sin(t2)*0.1,-1)-bodpos)-.45;
  float b5 = length(p-vec3(-3,1.5,-1)-bodpos)-.45;
  
  float mn = smin(b1,b2,0.8);
  mn=smin(b4,mn,0.8);
  mn=smin(b5,mn,0.8);
  mn = abs(mn)-0.01;
  float res = max(mn,-b3)-0.05;
  
  mat = 1;
  uvw = p;
  
  vec3 q = p-headpos-vec3(-.6,0.3,-2.3);
  q.xz*=rot(0.4*sin(fGlobalTime));
  float ey=length(q)-.3;
  if (ey < res) {
    res=ey;
    mat = 2;
    uvw.xy = vec2(q.z/.3,atan(q.y,q.x));
  }
  q = p-headpos-vec3(.6,0.3,-2.3);
  q.xz*=rot(0.4*sin(fGlobalTime));
  float ey2=length(q)-.3;
  if (ey2 < res) {
    res=ey2;
    mat = 2;
    uvw.xy = vec2(q.z/.3,atan(q.y,q.x));
  }
  return res;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  float ig1;
  vec3 ig2;
  return normalize(map(p,ig1,ig2)-vec3(map(p-e.xyy,ig1,ig2),map(p-e.yxy,ig1,ig2),map(p-e.yyx,ig1,ig2)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  float mat;
  vec3 uvw;
  
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t,mat,uvw);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 col=mix(vec3(0.6,0.6,0.9),vec3(1),fbm(rd.xy/2+vec2(fGlobalTime/5,0))*0.4);
  col = mix(col,vec3(0.9),clamp(.7-4*uv.y,0,1));
  
  vec3 ld=normalize(vec3(3,4,-5));
  if (d<0.01) {
    if (mat==1 ) {
      col = vec3(0.9,0.4,0.5);
      vec3 n = gn(ro+rd*t);
      col *= vec3(0.01,0.045,0.1)+0.5*dot(n,ld);
    } else if (mat ==2 ) {
      col=mix(vec3(0.9),vec3(0.1),smoothstep(0.7,.71,abs(uvw.x)));
    }
  }
  col += clamp(-uv.y,0,1)*3*fbm(uv+vec2(-fGlobalTime/14,0));
  out_color.rgb=col;
}