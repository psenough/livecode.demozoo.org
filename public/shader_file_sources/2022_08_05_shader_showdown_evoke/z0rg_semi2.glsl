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

#define sat(a) clamp(a, 0., 1.)
mat2 r2d(float a)
{float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

vec3 getCam(vec3 rd,vec2 uv){
  
  float fov = 3.;
   vec3 r = normalize(cross(rd,vec3(0.,1.,0.)));
   vec3 u = normalize(cross(rd,r));
   return normalize(rd+fov*(r*uv.x+u*uv.y));
}
vec2 _min(vec2 a,vec2 b){
    if(a.x < b.x) return a;
    return b;
}
float _cube(vec3 p,vec3 s){
  vec3 l = abs(p)-s;
  return max(l.x,max(l.y,l.z));
}
vec2 map(vec3 p){
  vec2 acc = vec2(100000.,-1.);
  
  vec3 p2 = p;
  p2.xy += sin(p.z+fGlobalTime)*.2;
  acc = _min(acc,vec2(-(length(p2.xy)-4.),1.));
  
  p += vec3(sin(fGlobalTime),cos(fGlobalTime*.33),sin(fGlobalTime*.5)-.5);
  
  for(int i=0;i<8;++i){
    float fi = float(i);
     vec3 p3 = p+vec3( sin(fi),cos(fi*5.+fGlobalTime),sin(fi))*(2.+texture(texFFT,fi*.1).x*10.);
    
      p3.xy *= r2d(fGlobalTime*.5+fi);
      p3.xz *= r2d(fGlobalTime*.5+fi);
     acc = _min(acc,vec2(_cube(p3,vec3(.5+texture(texFFT,.1).x)),0.));
    }

  return acc;
}

vec3 getNorm(vec3 p,float d){
   vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
  
}
vec3 accCol;
vec3 trace(vec3 ro,vec3 rd, int steps) {
   accCol = vec3(0.);
   vec3 p = ro;
   for(int i= 0; i< steps;++i)
   {
      vec2 res = map(p);
      if(res.x < 0.01)
         return vec3(res.x,distance(p,ro),res.y);
      accCol +=vec3(.4,.2,sat(sin(p.z*.5)))*(1.-sat(res.x/.5))*.1; 
      if(res.y == 1.)
         accCol *=1.1;
      p+=rd*res.x;
   }
   return vec3(-1.);
  }
  
 vec3 rdr(vec2 uv){
  vec3 col = vec3(.0);
  vec3 ro = vec3(sin(fGlobalTime),cos(fGlobalTime*.7),-2.);
  vec3 ta = vec3(0.);
 vec3 rd = normalize(ta-ro);
  rd = getCam(rd,uv);
  
  vec3 res = trace(ro,rd, 128);
  if(res.y > 0.) 
  {
        vec3 p = ro+rd*res.y;
        vec3 n = getNorm(p,res.x);
        col = vec3(1.)*n;
    
      if(res.z == 1.)
      {
          float a = atan(p.y,p.x);
          col = .2*texture(texTex4, vec2(a, p.z*.25+texture(texFFTIntegrated, .1).x*2.)).xyz;
          n += texture(texTex4, vec2(a, p.z*.25+texture(texFFTIntegrated, .1).x*5.)).xyz;
      }
      col += pow(sat(dot(n,normalize(vec3(1.,2.,3.)))),7.);
  }
  col +=accCol;
  return col;
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 col = rdr(uv);
  
	out_color = vec4(col,1.);
}