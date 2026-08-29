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


#define time 0 //mod(fGlobalTime, 10.)
#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
#define adv time*150.
#define pi acos(-1.)
#define m texture(texFFTSmoothed, 0.01).x * 100.
float sb(vec3 p, vec3 s){
  vec3 q = abs(p)-s;
  return max(max(q.z, q.y), q.x);
}
struct obj{
  float d;
  vec3 l,s;
};

bool glass;
bool glass2;

float glow;
obj m1(vec3 p){
  
  vec3 p0 = p;
  p0.z -= adv;
  p0.zy *= rot(1.5);
  p0.xz *= rot(sin(time)*5.); // pirueta1
   vec3 p1 = p0;
  
  vec3 p2 = p0;
  vec3 p3 = p0;
  p2.x = abs(p2.x)-1.;
  p2.xy *= rot(10.);
  p2.y += .5;
  p3.y -= 1.;
  p3.x = abs(p3.x)-.5;
  p3.xz *= rot(-13.);
  float body = sb(p2, vec3(5., 1., .1));
  float body2 = sb(p3, vec3(1., 2., .01));
  float d = 0.;
  float cabin = length(p1)-1.;
  
  
  //d = min(body, d);
  //d = min(body2, d);
  glass2 = d < 0.01;
  
  // bg
  vec3 p4 = p;
  float ground = -p4.y+300.;
  d = min(ground, d);
  
  // structures
  const float rep = 20.;
  vec3 p5 = p;
  
  p5 = (fract(p/rep-.5)-.5)*rep;
  p5.yx = abs(p5.yx)-10.;
  
  float sts = sb(p5, vec3(vec2(.01), 5.));
  glow += .1/(.1+sts*sts);
  d = max(sts, d);
  d = min(min(min(body, cabin), body2), d);
  //d = min(sts, d);
  
  return obj(d,vec3(0.123123123, .546456456, 0.567567567), vec3(0.2343423,.23423432, .567567));
}

float glow2;
obj map(vec3 p){
  obj o = m1(p);
  const float rep = 40.;
  vec3 p1 = p;
  p1 = (fract(p/rep))*rep;
  
  p1.x = abs(p1.x)-5.;
  float d = sb(p1, vec3(5, 1., 1.));
  //glow2 += 10./(.1+d*d);
  o.d = min(o.d, d);
  
  // test
  o.d = d;
  return o;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float fov = 1.;
  vec3 s = vec3(0.0001, 0.0001, -15.);
  s.x += sin(time)*50.;
  vec3 t = vec3(0.);
  s.z += adv;
  t.z += adv;
  vec3 rz = normalize(t-s);
  vec3 rx = normalize(cross(rz, vec3(0., 1., 0.)));
  vec3 ry = normalize(cross(rz, rx));
  vec3 r = normalize(rx*uv.x+ry*uv.y+rz*fov);
  
  // loop

  
  vec3 col = vec3(0.);
  vec3 p = s;
  const float MAX = 100.;
  float i = 0.;
  const vec2 e = vec2(0.01, 0.);
  obj o;
  for(; i < MAX; i++){
    o = map(p);
    float d = o.d;
    if(abs(d) < 0.0001){
      if(glass2){
        vec3 n = normalize(d-vec3(map(p-e.xyy).d, map(p-e.yxy).d, map(p-e.yyx).d));
        r = reflect(r, n);
        d += 4.;
      }else
        break;
    }
    p+=d*r;
  }
  col += 1.-i/MAX;
  col += glow*vec3(0.3*m, .4, .4-sin(time*.1)*3.5-.5*pi)*(.1+m);
  //col += glow2*vec3(1.)*.01;
	out_color = vec4(col, 1.);
}