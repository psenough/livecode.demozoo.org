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
uniform float md1;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time mod(fGlobalTime,600)
#define pi 3.141592
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

float hcap(vec3 p, float l, float r){
  p.z -= clamp(p.z,0,l);
  vec3 d = abs(p)-vec3(r,r,0);
  float a = max(d.x,max(d.y,d.z));
  return a;
}
float h11(float a){
  return fract(sin((a+3.2323)*12.3234)*5454.89443); 
}
float h21(vec2 a){
  return fract(sin(dot(a+3.2323,vec2(434.545,095.434985))*12.3234)*5454.89443); 
}

float box(vec3 p, vec3 r){
   vec3 d = abs(p)-r;
  float a = max(d.x,max(d.y,d.z));
  return a;
}
vec2 map(vec3 p){
  p.z = -p.z;
  vec3 po = p;
  p.xy*=rot(p.z*0.02);
  vec2 a = vec2(0);
  float t = time;
    p.z -= t*7.5;
  
  p.y+=tanh(sin(t)*5)*3.9;

  
  vec3 m = vec3(0.2,0.2,3.2)*4;
  vec3 id = floor(p/m);
  //p.z += (t+40)*(h21(id.xy)*0.4+0.6);
    
  //if(length(id.xy) < (10))

  p = mod(p,m)-0.5*m;

  
  float r = 0.1;
 // t = mod(t,pi)-0.3;
  t*=h21(id.xy+id.z+0.5)*4;
  t+=h21(id.xy+id.z)*7;
  
  float sharp = 5;
  float e = tanh(sin(t-pi/2)*sharp)+sin(t-pi/2)*0.2;
  float s = tanh(sin(t-pi/4)*sharp)+sin(t-pi/4)*0.2;
  float st = 2.0;
  p.z -= s*st;
  a.x = hcap(p,e*st-s*st,r);
 // a.x = max(1.0,a.x);
  p = po;
  vec2 b = vec2(1);
  float m2 = 3.5;
    //p.xz*=rot(t*0.1);

  //p.z = mod(p.z,m2)-0.5*m2;
  //p.x = mod(p.x,6.0),-3;
  float m3 = 6;

  float id2 = floor(p.z/m3);
  p.z = mod(p.z,m3)-m3*0.5;
  p.xy*=rot(pi/4.+id2);

  p.xy*=rot(pi/4.);
  t = time;
  p.x -= tanh(sin(t)*7)*4.;
  p.x -= t*3.;

  p.y = mod(p.y,3)-1.5;
  p.y = abs(p.y);
  p.x = mod(p.x,6.0)-3;
  p.xy*=rot(-pi/4.);

  //p.xy*=rot(pi/4.);
  //p.y = abs(p.y)-1.;
  
  b.x = box(p-vec3(1,1,-0),vec3(999,1,1)*0.2);
  a = (a.x<b.x)?a:b;
 
  return a;
}
vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0);
  return normalize(map(p).x-vec3(
  map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x));
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0,0,-5);
  
  //ro.xz *=rot(time*0.1);
  float fov = 1.0+(tanh(sin(time)*7)/pi)*0.5+0.5;
  vec3 lk = vec3(0,0,0);
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = normalize(fov*f+uv.x*r+uv.y*cross(f,r));
  
  vec3 p = ro;
  float rl = 0;
  vec2 d = vec2(0);
  float shad = 0.;
  
  
  #define STEPS 80.0
  #define MDIST 35.0
  for(float i = 0.; i< STEPS; i++){
    p = ro+rd*rl;
    d = map(p);
    rl+=d.x*0.8;
    if(abs(d.x)<0.005){
      break;
      shad = i/STEPS;
    }
    if(rl>MDIST)
      break;
    
  }
  if(rl<MDIST){
      vec3 n = norm(p);
      col = n*0.5+0.5;  
    col = vec3(1);
    if(d.y>0.5){
      col = vec3(0.8,0.6,0.3+rl*0.1)*(1.0-shad);
      vec3 r = reflect(rd,n);
      vec3 ld = vec3(-1,0,-1);
      float spec = pow(max(0,dot(r,ld)),10);
      col+=spec*0.02;
    }
  }
  col = mix(col,vec3(0.1),min(rl,MDIST)/MDIST);


	out_color = vec4(col,1);
}