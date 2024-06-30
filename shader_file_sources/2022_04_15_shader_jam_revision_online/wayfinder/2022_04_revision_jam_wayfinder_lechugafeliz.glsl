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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything




#define PI acos(-1)
#define t mod(fGlobalTime, 5.)
#define rot(a) mat2(cos(a), sin(a),-sin(a), cos(a))
#define esf(p, s) length(p)-s
#define line(p, L) min(L, max(0., p))
#define rep(p, S) (fract(p/S-.5)-.5)*S

vec3 s = vec3(0.01, -4.01, -10.);
vec3 tg = vec3(0.,floor(mod(t,3.)), 0.);

vec4 plas( vec2 v)
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( t + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(t)), c * 0.15, cos( c * 0.1 + t / .4 ) * .25, 1.0 );
}

float box(vec3 p, vec3 s){
  p=abs(p)-s;
  return max(max(p.x, p.y), p.z);
}
struct Data{
  float d, id;
};
struct Acf{
  float d, dd;
};
struct Ace{
  float d,dd,ddd,dddd;
};
Acf acf = Acf(0.,0.);
Ace ace = Ace(0.,0., 0.,0.);

float kiff(vec3 p){
  return box(p, vec3(4., 1., .4));
}

float smin(float a, float b, float k){
  float h = max(0., k-abs(a-b))/k;
  return min(a,b)-h*h*k*.25;
}

float ss(float tt){
  tt = tt/20.;
  return 1;
}
Data m(vec3 p){
  vec3[20] pp;
  p.xz *= rot(sin((t+p.x*p.x)*.0285-.615)*.5-.5);
  //p.xz *= rot(sin(floor(t)));
  p.yz*=rot(sin((t*.0125)*20.1415));
  p.xz*=rot(ss(t));
  p.z += t*1.;
  p*=.74;
  pp[0] = p;
  pp[1] = p;
  pp[2] = p;
  p.xz = rep(p.xz,1.);
  float d = esf(p.xy,.01);
  float dd = esf(p.zy, .01);
  
  acf.d += .01/(.1+d*d)*.1;
  acf.dd += .01/(.1+dd)*.7;
  
  vec2 gid = vec2(2.5);
  vec2 idp1 = floor(pp[1].xz/gid-.5);
  pp[1].y += sin(t*idp1.y)*.5-.5;
  pp[1].xz = rep(pp[1].xz, gid);
  
  
  float k1 = box(pp[1]-vec3(0.,.2,1.), vec3(1.));
  
  for(float i = 0.; i < 3.; i++){
    pp[2].xz *= rot(t);
    pp[2].yz*=rot(t);
    //pp[2].xyz -= i*.1;
  }
  float ss0,ss1,ss2,ss3,ss4;
  ss0 = ss1 = ss2 = ss3 = ss4 = sin(floor(t))*2-2.;
  float k2 = esf(pp[2]-vec3(0., ss0, 0.), .65-plas(p.yx).x*.01);
  float k3 = esf(pp[2]-vec3(ss1, 0., 0.), .45+plas(p.yz).x*.057);
  float k4 = esf(pp[2]-vec3(0., 0.,ss2), .56+plas(-p.zy).x*.2541);
  float k5 = esf(pp[2]-vec3(ss3, ss2, 0.), .84+plas(p.xy).x*.18561);
  float k6 = esf(pp[2]-vec3(ss2,ss3, ss4), 1.);
  
  ace.d += .0025/(.525+k2*k2*k2);
  ace.dd += .0825/(.525+k3*k3*k3);
  ace.ddd += .0725/(.525+k4);
  ace.dddd += .0725/(.525+k5);
  
  d=min(d,k1);
  d=min(d,dd);
  float dd1 = 1.;
  dd1=smin(dd1,k2, .85);
  dd1=smin(dd1,k3, .85);
  dd1=smin(dd1,k4, .85);
  dd1=smin(dd1,k5, .85);
  dd1=smin(dd1,k6, .85);
  ace.d += .015/(.025+dd1*dd1);
  d = smin(dd1, d, 1.);
  d *= .75;
  return Data(d, 0.);
}
vec3 nm(vec3 p){
  const vec2 e = vec2(0.01, 0.);
  return normalize(m(p).d- vec3(m(p-e.xyy).d,m(p-e.yxy).d,m(p-e.yyx).d));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 p = s;
  vec3 cz = normalize(tg-s);
  vec3 cx = normalize(cross(cz,vec3(0., -1.,0.)));
  vec3 cy = normalize(cross(cz,cx));
  vec3 r = mat3(cx,cy,cz)*normalize(vec3(-uv, .45));
	
  vec3 co = vec3(0.);
  float dd;
  Data dt;
  vec3 l = normalize(vec3(-1.));
  l.yz *= rot(sin(t)*.25-.25);
  vec3 n;
  for(float i = 0; i < 64; i++){
    dt = m(p);
    if(dt.d < 0.01){
      n = nm(p);
      float dif = max(0., dot(l, n));
      float esp = max(0., pow(dot(reflect(-l, n), -r), 20.));
      co = vec3(dif+esp);
    }
    if(dd > 300) co=vec3(0.);
    dd += dt.d;
    p += dt.d*r;
  }
  
  co += acf.d * vec3(0.34, 0.1, 0.45)*.18525;
  
  co += ace.d * vec3(0., .56, .56)*.01434;
  co += ace.dd * vec3(0.56, .856, .256)*.01434;
  co += ace.ddd * vec3(0.345, .56, .356)*.01434;
  co += ace.dddd * vec3(0.7, .256, .5656)*.01434;
  co += .001+length(uv)*sin(t*18.4)*.25-.25;
  
  co = pow(co, vec3(1.92424))*.22;
  
  
	out_color = vec4(co, 1.);
}