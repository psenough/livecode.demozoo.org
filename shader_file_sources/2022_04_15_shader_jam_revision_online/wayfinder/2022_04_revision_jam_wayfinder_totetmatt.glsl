#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDfox;
uniform sampler2D texDojoe;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
//
// ** La jeunesse emmerde le Front National ** 
//
  float bpm = texture(texFFTIntegrated,.3).r*2.+fGlobalTime*.1;
float smin(float a,float b,float r){
  
  float k = max(0.,r-abs(a-b));
  return min(a,b) - k*k*.25/r;
  }
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
vec3 pal(float a){return .5+.5*cos(6.28*(1*a+vec3(0.,.3,.6)));}
float ease_out(float a){return 1.-pow(a-1.,2);}
#define PI 3.1415
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}

vec2 sdf(vec3 p){
  vec2 h;
  vec3 op = p;
  vec2 q = vec2(length(p.xz)-5.,p.y);
  h.x = -(length(q)-4.
  -dot(asin(sin(p*2)),asin(cos(p.yzx*9)))*.1
  //-min(20.,texture(texFFTSmoothed,.3+op.y*.01).r*20)
  )
  ;
  h.x *=.7;
  h.y = 1;
  
  vec3 tp = op;
  tp.y +=dot(sin(tp*7),cos(tp.zxy*7))*.1;
  vec2 r = vec2(length(tp.xz)-3.,tp.y);
     r.x = abs(r.x)-.2;
    r*=rot(atan(op.x,op.z)+bpm);
  r.y = abs(r.y)-.2+(sin(atan(op.x,op.z)*4+bpm*4)*.2+.2);

  vec2 t ;
  t.x =  length(r)-.1;
  t.y = 2.;
  

  h = t.x< h.x ? t:h;
    tp = op;
  
  tp.xz*=rot(asin(sin(-fGlobalTime)));
  float id = pModPolar(tp.xz,4);
     tp.yz *= rot(sin(id+bpm)*.5);
   tp.x -=3;;
    t.x = length(tp.xz)-.1;
  
  t.y =3.;
  
  h.x = smin(t.x,.8*h.x,.5);
  return h;
  
}

#define q(s) s*sdf(p+s).x

vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=1.1;;
  uv *=rot(fGlobalTime*.5);
  bpm = floor(bpm)+ease_out(fract(bpm));
  float id = floor(uv.x+-bpm+length(uv)+dot(sin(uv*20),cos(uv.yx*36))*.1);
  //uv*= fract(-bpm+length(uv)+dot(sin(uv*4),cos(uv.yx*4))*.1);
  vec3 col = vec3(.1);
  vec3 ro = vec3(1.,1.,-3.);
   ro.xz *=rot(-bpm);
  vec3 rt = vec3(1.,0,0.);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1,0.)));
  vec3 y = normalize(cross(z,x));
  
  vec3 rp = ro;
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.-.8*sqrt(length(uv))));
  vec3 light = vec3(1.,2.,-3.);
  float dd =0.;
  vec3 acc = vec3(0.);
  for(float i=0;i<128;i++){
    
    vec2 d = sdf(rp);
       if(d.y == 2. ) {
        float tt = texture(texFFT,.3).r*200;
         
         vec3 yellow = vec3(.7,.7,.0);
         
       acc +=mix(vec3(.7,.7,.0), vec3(.2,.2,.5),sin(atan(rp.x,rp.z)*4)*.5+.5)*exp(-abs(d.x))/(60.-min(59,tt*10));
         
       d.x = max(.001,abs(d.x));
      }
    rp+=rd*d.x;
  
    dd+=d.x;
    if(dd >50) break;
   
    if(d.x< .0001){
        vec3 n = norm(rp,.001);
      vec3 n2 = norm(rp,.002);
        float dif = max(0.,dot(normalize(light-rp),n));
         float spc = pow(max(0.,dot(rd,reflect(normalize(light),n))),2.);
      if(d.y == 1) {
         col = vec3(1.-fract(fGlobalTime)) * dif *
        mod(floor(fGlobalTime*.5+rp.x*.01),2)==0 ? texture(texRevision,rp.xy*vec2(1.,-1)*.25+fGlobalTime*.1).rgb : texture(texDojoe,rp.xy*vec2(1.,-1)*.25+fGlobalTime*.1).rgb
        
        ;
      } else if(d.y == 3) {
      
        col = vec3(1.)*dif;
        }
        
        col +=smoothstep(.1,.11,length(n-n2))*dif+spc*.5*pal(spc);
         break;
      
      
      }
    }

/*	out_color = vec4(mod(id,2)==0? col+acc :
    
    pal(floor( 10*length(col+acc+uv.x)+fGlobalTime+length(uv))*.0125+.4),1.);
    */
     out_color = vec4(col+acc,1.);
}