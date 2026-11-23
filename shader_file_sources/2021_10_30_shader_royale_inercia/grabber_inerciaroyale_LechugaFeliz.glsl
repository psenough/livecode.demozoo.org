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

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
#define pi acos(-1.)
float t= mod(fGlobalTime, 100.+(2*pi))*.195;

float cc(float t){
    return mix(floor(t), floor(t+1), pow(smoothstep(0.,1., fract(t)), 40.));
}
float smin(float a, float b, float k){
    float h = max(0., k-abs(a-b))/k;
    return min(a,b)-h*h*k*.25;
}
float sbt(vec3 p, vec2 s){
    return length(vec2(length(p.xy)-s.x, p.z))-s.y;
}
float sbb(vec3 p, vec3 s){
    p=abs(p)-s;
    return mix(max(max(p.x,p.y), p.z), length(p.xz), .26);
}
float fr1;
float d2;
float mainFractal( vec3 p){
    
    vec3 p1 = p;
    //
    //p.x = abs(p.x)-20.;
    
    //p1.yx = abs(p1.yx);
    p1.yz*=rot(2.34);
    float k, sc = 1.;
    for(float i = 0;i < 10; i++){
        p1.xz*=rot(p.y*.06251+i*i+cc(t*.31)+t*.25);
        p1=abs(p1)-.2246-i*.215;
        k = max(1., 1.877/dot(p1,p1));
        p1 *= k;
        sc *= k;
    }
    
    p1.z = (fract(p1.z/20.-.5)-.5)*20.;
    
    float d = sbb(p1, vec3(1.)) / sc;
    fr1 += .15/(.1+d*d);
    d2 = d;
    //d = max(d, -sbb(p, vec3(15.)));
    return d*.26;
}

float h(float a){
  return fract(sin(a*435.)*375.);
}
float g1,d1;
float fr2;
float center(vec3 p){
  float d = mainFractal(p);
  
  float tt = t;
  //tt += h(sin(p.x+t))*.001*.5;
  p.xz*=rot(p.y*.34+tt*10.);
  
  float a = length(p)-3.-sin(p.x*.34+t)*sin(sin(p.z*.45+t));
  a=mix(a, sbb(p, vec3(5.)), sin(cc(t))*.5+.5);
  
  d1 = a;
  g1+=1./(.1+a*a)*texture(texFFTSmoothed, 0.01).r*10.;
  d = smin(d, a, 1.);
  return d;
}

float centerLight(vec3 p){
  
  float d = center(p);
  
  // p.y=abs(p.y);
    //p.xz*=rot(p.y*.05);
  
  float a = length(p)-3.;
  fr2 += 1./(1.+a*a*a);
  d = smin(d,a,1.);
  
  
  
  return d;
}

float dr;
float noseQueCrestaEraEsto(vec3 p){
  float d = centerLight(p);
  //p.xz*=rot(t+p.z*.01);
  //p.yz*=rot(t+p.z*.025342);
  //p=abs(abs(p)-9.)-4.;
  //float drr = (length(p)-1.);
  //d = smin(d, drr, 1.);
  //dr=drr;
  return d;
}
float ff;
float m(vec3 p){
  float d = noseQueCrestaEraEsto(p);
  
  vec3 p1 = p;
  p.x=abs(p.x)-50.;
  p.yz*=rot(p.y*.0124+t*.1);
  p.xz*=rot(p.y*.04+cc(t*.546)+t*sin(cc(-t*.25)+p.z*.00029895)*.75);
  p.y += cc(t)+t;
  p.x += sin(p.y*.34+t*40.);
  for(int i = 0; i < 2; i++)
    p.xz = abs(p.xz)-15.-texture(texNoise, p.yz).r*.03153;
  float a = length(p.xz)-1.-texture(texFFTSmoothed, 0.01).r*20.;
  ff += .15/(3.5+a*a);
  d = min(d, a);
  p1.xz = abs(p.xz)-10.;
  p1.yz*=rot(p1.z);
  //float cucu = sbb(p1, vec3(1., 2., 9.));
  dr = a;
  //d=min(d, cucu);
  return d;
}

vec3 nm(vec3 p){
    const vec2 e = vec2(-.02424, 0.0345345);
  
  return normalize(m(p)-vec3(m(p-e.xyy), m(p-e.yxy),m(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


  vec3 s = vec3(0.01, 0.01,-15.-sin(t*.525)*20.-40.);
  s.x += sin(t);
  s.xy *= rot(cc(t));
  vec3 p = s;
  uv*=rot(sin(cc(t*2.)));
  vec3 tg = vec3(0.6);
  tg.yz*=rot(sin(cc(t)*.25));tg.xz*=rot(t);
  vec3 cz = normalize(tg-s);
  vec3 cx = normalize(cross(cz, vec3(0., -1., 0.)));
  vec3 cy = normalize(cross(cz,cx));
  vec3 r = mat3(cx,cy,cz)*normalize(vec3(-uv, 1.-length(uv)*.85+fract(length(uv)+cc(t*.25))));
  vec2 dh = vec2(0.0);
  vec3 co = vec3(0.)-length(uv)*.51;
  for(int i = 0; i < 200; i++){
      dh.y = m(p)*.65;
    if(abs(dh.y) < .001) {
      vec3 n = nm(p);
      vec3 l = normalize(vec3(-1.)-p);
      float dif = max(0., dot(l, n));
      float fr = pow(max(0., 1+dif), 3.);
      float sp = pow(max(0., dot(reflect(-l, n), r)),50.);
      co = vec3(dif+sp)*min(fr, .45);
      if(abs(d2) < .5 || abs(dr) < .5) r=reflect(r, n), p+=20.;
      else break;
    }
    if(dh.x > 200) break;
    dh.x += dh.y;
    p+=dh.y*r;
    co-=g1*vec3(0.45,0.3, 0.64)*.00024;
    co+=fr1*vec3(1., .45, 0.)*.000445;
    co += fr2*vec3(0.45,0.3, 0.64)*.131;
    co += ff *vec3(0.1)*.1;
    //co = smoothstep(0., 1., co);
    co = pow(co,vec3(1.083434));
    co += max(0., length(p-s)/300.)*vec3(0.034,0.034, 0.15)*.5;
  }
	out_color = vec4(co, 1.);
}