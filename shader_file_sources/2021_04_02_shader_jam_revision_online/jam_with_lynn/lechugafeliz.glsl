#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
float time = mod(fGlobalTime*.015, 50.);
float sb(vec3 p, vec3 s){p=abs(p)-s; return max(max(p.y, p.x), p.z);}
bool isCub;
float rand(float x){return fract(sin(x*345345.44345345))*1.2;}
float rand2(vec2 x){return fract(sin(dot(x, x.yx+.44345345)));}
float smin(float a, float b, float k){return 0.;}
float c(float t, float s){t/=s; return mix(rand(floor(t)), rand(floor(t+1)), smoothstep(0.,1., fract(t)));}
#define m texture(texFFTSmoothed, 0.00001)
#define pi 3.14153459356546 // aaaaaaa
float glow;
float fractal(vec3 p){float d;
  
  float cut = sb(p, vec3(20.));
  //reflective cub
  float pm = sb(p, vec3(1.));
  isCub = pm < 0.5;
  
  vec3 p2 = p;
  float tt = c(time*2., 200.)*1.5+time;
  
  for(float i = 0.; i < 3; i++){
      p2.xz *= rot(tt*.123);
    p2.yz *= rot(tt*.523);
    p2.xy *= rot(time*34.213);
    p2 = abs(p2)-3.-i*.1+sin(time)*1.5+.5;
    //p2+=mod(time+tt, 1.45*pi);
  }
  float ccuv=sb(p2, vec3(0.234234 , 0.5467676, 4.5+m.r));
  
  glow += .1/(.1+ccuv*ccuv);
  d = 30-abs(p.y)-1.*sin(time+p.y)*cos(time+p.z)*sin(time+p.x)*.5;
  d =min(d,ccuv);
  d = max(-cut,d);
  return d *.84;
}

float glow2;
float map1(vec3 p){float d;

  const float re = 30.;
  vec3 p1 = p;
  float id = rand2(floor(p1.xz/re+.5)-.5)*re;
  p1.xz = (fract(p1.xz/re+.5)-.5)*re;
  d = fractal(p1*id*.1);
  
  vec3 p2 = p;
  p2 = abs(p2)-50.;
  float sf =fractal(p2);
  glow2 += 2./(.1+sf*sf);
  d = max(sf, d);
  
    return d;
}

bool isTube;
float glowTube;
float map(vec3 p){float d = map1(p);
  
  vec3 p1 = p;
  p1.xy = abs(p1.xy)-30.;
  p1.z += time*200.;
  float dd = p1.z*.12312;
  p1.x += sin(smoothstep(0., 1.,floor(dd+1)))*10.;
  p1.y += sin(dd*2.)*1.5;
  float tube = length(p1.xy)-2.;
  d = min(tube,d);
  isTube = tube<.05;
  glowTube +=1./(1.+sqrt(tube*tube*tube));
  return d;
}
const vec2 e = vec2(0.01, 0.);
vec3 nm (vec3 p){return map(p)-normalize(vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}

float getao(vec3 p, vec3 n, float d){
  return clamp(map(p+n*d)/d, 0., 1.);
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float tt = c(time, 20.)*2.;
  vec2 uv2 = abs(uv)-20.;
  time += cos(tt)+rand(dot(uv2, uv2.yx*54325.123123));
  
  float t1 = time*1000.;
  float scene = mod(time, .4);
  //if(scene <= 1)
    //uv = cos(abs(uv*20.)+2.+time)*2.;
  vec3 s = vec3(0.000001, .000001+(sin(t1*.005)*50.), -90.);
  vec3 t = vec3(0.001+sin(t1*.032)*40.5+.5, 0.0001-sin(atan(t1*.234))*10., .0001);
  vec3 cz = normalize(t-s);
  vec3 cx = normalize(cross(cz, vec3(0.,1., 0.)));
  vec3 cy = normalize(cross(cz, cx));
  vec3 r = normalize(cx*uv.x+cy*uv.y+cz*.3555);
  s.z += t1;
  //s.x += sin(time+s.y);
  vec3 col = vec3(0.), p = s;
  float i = 0.; const float MAX= 128.; float d;
  for(; i < MAX; i ++) if(d = map(p), p+=d*r, abs(d) < 0.001) {
    if(isTube){
      vec3 n = nm(p);r = reflect(r, n-texture(texFFTSmoothed, 0.01).rgb*10.);
      d -= 150.;
    }
    else break;
    }
  vec3 n = nm(p);
  col += clamp(dot(n, normalize(vec3(-uv, 1.))), 0.2, .4);
  col += glow*m.gbr*vec3(0.345345, -sin(tt*2.)*.5+0.5684568*tt, 1.-cos(time)*.25+.5);
  col += glow2 * vec3(0.334234, .135345, .0)*m.rgb;
  col += glowTube*(1.-vec3(0.2, 0.1,sin(tt)));
  col += dot(col, n.yxz)*vec3(1., 0.,0.)*cos(time)*.85;
  for(int i  = 0; i < 4; i++){
    col *= getao(p,n,i+.1)*.4;
  }
  col *= 3-max(length(p-s)/200., 0.);
  col.r = smoothstep(0.2, 0.4,col.r);
	out_color = sqrt(vec4(col, 1.946745));
}