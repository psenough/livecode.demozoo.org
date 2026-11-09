#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDR;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float bpm = fGlobalTime*135/60;
mat3 orth(vec3 p){
    vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
vec3 rnd(vec3 p){
  uvec3 q = floatBitsToUint(p)*1234567890u+123456789;
    q.x*=q.y+q.z;q.y*=q.x+q.z;q.z*=q.y+q.x;
    q^=q>>16u;
     q.x*=q.y+q.z;q.y*=q.x+q.z;q.z*=q.y+q.x;
  return vec3(q)/float(-1U);
  }
  float sdCrystal(vec3 p) {
  float c = cos(3.1415/5.), s=sqrt(0.75-c*c); // magic numbers
  vec3 n = vec3(-0.5, -c, s); // magic direction

  // fold the space to add symmetry
  p = abs(p);
  // fold along the n direction
  p -= 2.*min(0., dot(p, n))*n;

  // fold the space again and along the n direction
  p.xy = abs(p.xy);
  p -= 2.*min(0., dot(p, n))*n;

  // repeat the process
  p.xy = abs(p.xy);
  p -= 2.*min(0., dot(p, n))*n;

  // distance to the surface
  float d = p.z -7.;
    
  d = min(length(p.xy),d);
  return d;
}
vec2 sdf(vec3 p){
      vec3 hp=p;
      vec2 h;
      hp = erot(hp,normalize(vec3(1.,1.,1.)),fGlobalTime);
      vec2 st = vec2(hp.x/(5.-hp.y),hp.y/(5.-hp.z));
      float a = texture(texFFTSmoothed,sqrt(texture(texNoise,st).r)*.1).r*.56;
      h.x = length(hp)-1.-a;
      h.y = 0.+a;
  
  vec3 hhp= p;
  vec3 rr = rnd(floor(vec3(bpm*.25)));
      hhp = erot(hhp,normalize(rr-.5),exp(-3*fract(bpm*.25)));
      h.x = min(-sdCrystal(hhp),h.x);
  
  vec3 tp=p;  
  tp+=cross(sin(tp*7),cos(tp.yzx*12))/12;
  tp=abs(tp)-.5;
  vec3 r = tanh(rnd(tp))*.5;
  float tt = floor(bpm+r.x)+smoothstep(.1,.9,fract(bpm+r.x));
      tp = erot(tp,normalize(sin(vec3(.3,.4,.5)+bpm)),tt);
      vec2 t;

      vec2 q = vec2(length(tp.xz)-2.,tp.y);
     t.x = length(q)+.1-step(.0,sin(atan(tp.x,tp.z)*5+bpm*5))*.2;
  t.y = 10.;
  h=t.x < h.x ? t:h;
       
      return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0.);
  col +=step(uv.y+.5,texture(texFFTSmoothed,uv.x).r);
  
  vec3 ro=vec3(1.,1.,-5.),rt=vec3(0.);
  ro=erot(ro,normalize(vec3(0.5,1.,.2)),tanh(sin(bpm)*5)+bpm*.125);
  rt=-5*ro+ro.yzx;
  vec3 rd= orth(rt-ro)*normalize(vec3(uv,1.-.2*exp(-3*fract(bpm))));
  
  vec3 rp=ro;
  vec3 light = vec3(1.,2.,-3.);
  vec2 d;
  float rl;
  vec3 acc=vec3(0.);
  for(float i=0.;i++<99;){
    
      d = sdf(rp);
      if(d.y==10.){
          acc+=vec3(.1,.2,.3)*exp(-fract(bpm))*exp(-abs(d.x))/exp(i*d.x*d.x);
         d.x = max(abs(d.x),.01);
        }
      if(d.x < .001) break;
      rl+=d.x;
      rp=ro+rd*rl;
  }
  if(d.x<.001 && d.y <10.){
      col+=vec3(.05);
       vec3 n=norm(rp,.001);
         rd=reflect(rd,n);
         rp+=n*.1;
        ro=rp;
       rl=0.;
        for(float i=0.;i++<99;){
    
      d = sdf(rp);
      if(d.y==10.){
          acc+=vec3(.1,.2,.3)*exp(-fract(bpm))*exp(-abs(d.x))/exp(i*d.x*d.x);
         d.x = max(abs(d.x),.01);
        }
      if(d.x < .001) break;
      rl+=d.x;
      rp=ro+rd*rl;
  }
    
    }
  if(d.x<.001){
      vec3 n = norm(rp,.001);
      vec3 ld = normalize(light);
      float dif = max(0.,dot(ld,n));
      float spc  = pow(max(0.,dot(reflect(ld,n),rd)),32.);
      float fre = pow(1+dot(rd,n),4.);
      col = mix(vec3(.1),vec3(.2),step(.1,d.y*40))*dif+spc;
      col+=fre;
  }
  vec3 r = rnd(floor(vec3(uv.xy*10,bpm*4)));
   col = col+acc;
  if(fract(bpm+.5)>.5) col = fwidth(col);
  
  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(10.*(r.xy-.5));
  vec3 pcol = vec3(
    texelFetch(texPreviousFrame,gl+off,0).r,
  
    texelFetch(texPreviousFrame,gl-off,0).g,
  
    texelFetch(texPreviousFrame,gl-off,0).b
  );
  col = mix(sqrt(col),pcol,(.3+r.z*.7)*exp(-fract(bpm)));
  
  /*
  
  Don't forget to come to SESSIONS
  
  */
	out_color = vec4(col,1.);
}