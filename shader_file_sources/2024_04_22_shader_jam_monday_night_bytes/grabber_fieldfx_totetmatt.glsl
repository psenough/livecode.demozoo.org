#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = 160*fGlobalTime/60;
vec3 mul3( in mat3 m, in vec3 v ){return vec3(dot(v,m[0]),dot(v,m[1]),dot(v,m[2]));}

vec3 oklch_to_srgb( in vec3 c ) {
    c = vec3(c.x, c.y*cos(c.z), c.y*sin(c.z));
    mat3 m1 = mat3(
        1,0.4,0.2,
        1,-0.1,-0.06,
        1,-0.1,-1.3
    );

    vec3 lms = mul3(m1,c);

    lms = pow(lms,vec3(3.0));

    
    mat3 m2 = mat3(
        4, -3.3,0.2,
        -1.3,2.6,-0.34,
        0.0,-0.7, 1.7
    );
    return mul3(m2,lms);
}
vec3 pcg3d(vec3 p){
  uvec3 q=floatBitsToUint(p)*1234567+1234567890u;
  q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  q^=q>>16u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1u);
  }
float frw = bpm*.125;
mat3 orth(vec3 p){
    vec3 z = normalize(p),x=vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec2 sdf(vec3 p){
    vec3 hp=p;
    vec2 h;
  vec3 rnd = pcg3d(floor(p));
  hp= erot(hp,vec3(0.,0.,1),hp.z*.1);
    hp=abs(hp)-5.5;
   float sc= 1.;
    for(float i=0.;i++<4.;){
       hp=abs(hp)-5.5; 
      sc*=1.5;
       hp= erot(hp,vec3(0.,0.,1),hp.z*.1+dot(sin(hp),cos(hp.yzx))*.1+.5*tanh(sin(floor(bpm*2)+hp.z*.1)));
       hp*=1.5;
      }
      float lol = sqrt(texture(texFFTSmoothed,length(rnd)).r)*2;
    h.x = length(hp.xy)-1.-lol;;;
      h.x/=sc;
    h.y = 1.+lol;
    return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.0,.3,.7)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
  float ratio = v2Resolution.y / v2Resolution.x;
	uv /= vec2(ratio, 1);  
  
  uv *= 1+1.5+1.5*sin(bpm)*step(.35,abs(uv.y));
  uv = erot(uv.xyy,vec3(0.,0.,1.),tanh(cos(bpm)*5)).xy;
  

  
  vec3 frnd = pcg3d(floor(vec3(uv*5,bpm*.25)));
vec3 rnd = pcg3d(vec3(uv,bpm));
  frw += texture(texFFTIntegrated,.3).r*8+rnd.x*.01;
  frw = floor(frw)+pow(fract(frw),.25);
  vec3 col = vec3(0.);
  vec3 ro = vec3(0.,0.,-5+frw),rt=vec3(0.,0.,0.+frw);
  float aaa;
  ro.x +=(aaa=tanh(sin(bpm*0.5+rnd.y*.1)*5))*.1;
    ro.y +=tanh(cos(bpm*1.5)*5);
  vec3 rd = orth(rt-ro)*normalize(vec3(uv,1.-.5*exp(-fract(bpm+.5))));
  
  vec3 rp=ro;
  float rl = 0.,i=0.;
  vec2 d;
  vec3 light = vec3(1.,2,-3.+frw);
  vec3 acc=vec3(0.);
  
  
  
  for(;i++<128;){
      d=sdf(rp);
      acc+=pal(rp.z*.1)*exp(5*-fract((rp.z*.001+bpm)))*exp(-abs(d.x))/(10-5*exp(-fract(d.y*3.33+bpm)));
      //d.x = max(0.001,abs(d.x));
      rl+=d.x;
      rp=ro+rl*rd;
      if(d.x< .001){break;}
  }
  /*if(d.x<.001){
      vec3 n = norm(rp,.001);
      vec3 ld = normalize(light-rp);
      float dif = max(0.,dot(ld,n));
      col =vec3(1.)*dif;
      
  }*/
  
  acc = mix(acc,10*pal(rp.z*.1),step(.9,fract(rp.z)));
  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off= ivec2(erot(vec2(1.,0).xyy,vec3(0.,0.,1),bpm).xy*10);
   vec3 pcol =vec3(
   texelFetch(texPreviousFrame,gl+off,0).x,
   texelFetch(texPreviousFrame,gl-off,0).y,
   texelFetch(texPreviousFrame,gl-off,0).z
  );
 
  col  = mix(acc,sin(pcol-bpm*4+rp.z),.5+aaa*.1);
  col = mix(col,vec3(1.-exp(5*-fract(bpm+.5))),1-exp(-.001*rl*rl*rl));
  if(fract(bpm+frnd.x)>.9) {col = .1/(.1+col);}
  col = mod(bpm+frnd.z+uv.y,10) <5 ? oklch_to_srgb(col) : col;
	out_color = vec4(col*col,(acc,0.,1.));
}