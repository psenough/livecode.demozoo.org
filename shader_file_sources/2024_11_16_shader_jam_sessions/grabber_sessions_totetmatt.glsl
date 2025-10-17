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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = 140*fGlobalTime/60;
float box2(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));}
float box3(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.z,p.y)));}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 getTexture(sampler2D tex, vec2 uv){
    vec2 size = textureSize(tex,0);
    float ratio = size.x/size.y;
    return texture(tex,uv*vec2(1,ratio)-.5).rgb;
}
mat3 orth(vec3 p){
    vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
struct GridResult { // Ask 0b5vr for this
  vec3 cell;
  float d;
  vec3 n;
};  GridResult grid;
GridResult gridTraversal( vec3 ro, vec3 rd ) { // Ask 0b5vr for this
  GridResult r;

  r.cell = floor( ro + rd * 1E-3 ) + 0.5;
  r.cell.y=0.;
  vec3 src = -( ro - r.cell ) / rd;
  vec3 dst = abs( 0.5 / rd );
  vec3 bv = src + dst;
  r.d = abs(min( min( bv.x, bv.z), bv.z ));
  
  r.n = -step( bv, vec3( r.d ) ) * sign( rd );
  
  return r;
}vec3 pcg3d(vec3 p){
    uvec3 q= floatBitsToUint(p)*1234567u+1234567890u;
    q.x += q.y*q.z;  q.y += q.x*q.z;  q.z += q.y*q.x;
  q^=q>>16u;
       q.x+= q.y*q.z;  q.y += q.x*q.z;  q.z += q.y*q.x;
  return vec3(q)/float(-1u);
  }
  vec3 hp;
  vec3 tp;
  
float diam(vec3 p,float s){p=abs(p); return (p.x+p.y+p.z-s)*inversesqrt(3.);}
vec2 sdf(vec3 p){
    hp=p;
  hp.y-=bpm;
    vec2 h;  
    hp-=grid.cell; // Ask 0b5vr for this
  vec3 rnd = pcg3d(grid.cell);
  float offset = sqrt(texture(texFFTSmoothed,rnd.x+rnd.z).r)*5;
       hp =erot(hp,vec3(0.,1.,0.),bpm*rnd.y);
     hp.y += tan(fGlobalTime+rnd.z*5)-offset;

  // NANI ? 
    h.x = rnd.y< .5 ? diam(hp,.5-offset): box3(hp,vec3(.45,offset,.45));
    h.y= 1.+grid.cell.x+rnd.z;
  
  vec2 t;
   tp=p;
  tp = erot(tp,vec3(0.,1.,0),tp.y*.01);
  t.x = -box2(tp.xz,vec2(15.));
  t.y = 0;;
  h= t.x<h.x ? t:h;
  
  vec3 ttp= p;
  ttp.y-=bpm;
  
   vec3 tprnd= (pcg3d(vec3(floor(bpm)))-.5);
   ttp+=tprnd;
  ttp+=cross(sin(ttp*4),cos(ttp.yzx+bpm));
  t.x = length(ttp)-1.-4*exp(-3*fract(bpm*.25));
  t.x = abs(t.x);
  t.y =-1.;
    h= t.x<h.x ? t:h;
  return h;
}

vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.1,.2,.3)));}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));}
vec3 intro(vec2 uv){
  uv*=2.;
 
// GOod luck gam to explain
  vec3 rnd =pcg3d(floor(uv.xyx*50));
  vec3 col = vec3(1.);
  vec2 uuv = uv;
   // uuv.y -= tan(bpm+rnd.x*.1);
  
  float d = length(uuv)-.5;
  d= smoothstep(.002,.001,d); 
  col= mix(vec3(1.),vec3(.737, 0, .176),d);;
  col = col.g ==0 ? col+(getTexture(texSessions,uv*(1-exp(-3*fract(bpm*.5))))):col;
  float fft =sqrt(texture(texFFTSmoothed,floor(uv.y*25)/25).r)*2;
  
  col = step(-uv.x+.8,fft) >0 ? vec3(.929, .161, .224): col;
  col = step(-uv.x-.8,-fft) <=0 ? vec3(0, .149, .329): col;
  rnd.x = smoothstep(.3,.7,rnd.x);
  col *= mix(getTexture(texSessions,uv),vec3(1.),exp(-5*fract(rnd.x+bpm*.5)));
  return col;  
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

 vec3 col = vec3(0.);
    vec3 trnd=pcg3d(vec3(floor(bpm)));
  float sq =(mod(bpm,4.));
  vec3 subscreenRnd=pcg3d(trnd);
  float screenRatio = v2Resolution.y/v2Resolution.x;
  vec2 subscreenSize = vec2(1.,screenRatio);
 // uv -=(max(vec2(.1),subscreenRnd.xy)-.5)*1.5;
 // uv /=max(.1,subscreenRnd.z);
  vec3 rrnd = pcg3d(vec3(uv.xyx));
  
  col += step(uv.y+.4,texture(texFFTSmoothed,uv.x).r);
  col = intro(uv);
	
  vec3 ro= vec3(0.,3+bpm,-7.),rt=vec3(0.,0.+bpm,0.);
  rt.y += (cos(bpm*.2))*2;
  //ro.x += atan(sin(texture(texFFTIntegrated,.3).r*5))*5;
  //ro.z += cos(bpm*.1)*4;
  ro =erot(ro,vec3(0.,1.,0),bpm*.1);
  
  float tbpm = floor(bpm*.5+rrnd.x*.01)+smoothstep(.0,1.,pow(fract(bpm*.5+rrnd.x*.01),.5));
  ro =erot(ro,vec3(0.,1.,0),tbpm*.25);
  vec3 rd = orth(rt-ro)*erot(normalize(vec3(uv,1.-(.8*exp(-3*fract(bpm))))),normalize(vec3(0.0,0.,1.0)),bpm*.1);
  vec3 rp=ro;
  vec3 light = vec3(1.,2.+bpm,-3.);
  float rl=0.;
  vec2 d;
      float gridlen = 0.0;
      vec3 acc=vec3(0.);
  for(float i=0.;i++<99.;){
     
      if ( gridlen <= rl ) {
        grid = gridTraversal( rp, rd );
        gridlen += grid.d;
      }
       d = sdf(rp);
       if(d.y==-1){
          acc+=vec3(.2,.5,1.)*exp(-abs(d.x))/(50-49*exp(-fract(bpm*.25)));
          d.x = max(.001,abs(d.x));
         }
      rl=min(rl+d.x,gridlen);
      rp=ro+rd*rl;  
      if(d.x<.001) break;
  }
  if(d.x<.001){
      vec3 n = norm(rp,.001);
      vec3 ld = normalize(light-rp);
      float dif = max(0.,dot(ld,n));
       float spc = max(0.,pow(dot(reflect(ld,n),rd),32));
      float fre = pow(1+dot(rd,n),4.);
      col = spc+vec3(.1)*dif*exp(-5*fract(-bpm+d.y));
       
      if(d.y==0){
          col *= (texture(texSessionsShort,tp.zy*vec2(-.1,.1)).xxx)+texture(texSessions,tp.xy*vec2(-.1,.1)).xxx;
        }
   // col = mix(col,pal(fre),exp(-5*fract(length(-bpm+length(rp)*.1))));
  }
  col = mix(vec3(0.),col,step(abs(uv.y),subscreenSize.y)*step(abs(uv.x),subscreenSize.x));
  
  ivec2 gl =  ivec2(gl_FragCoord.xy);
    vec3 rnd = (pcg3d(floor(vec3(uv.xy*10,bpm)))-.5)*2;
  
  
  ivec2 off = ivec2(5.*rnd.xz);
  

  vec3 pcol = vec3(texelFetch(texPreviousFrame,gl+off,0).r
  ,texelFetch(texPreviousFrame,gl-off,0).g
  ,texelFetch(texPreviousFrame,gl-off,0).b);
  col = acc+sqrt(col)+fwidth(col*100)*vec3(1.,.5,.2);
  //col = mix(col,pcol,.9*getTexture(texSessionsShort,uv));
  if(sq<2.) col = mix(col,1-col,2*exp(-5*fract(bpm*4)));
  col = mix(col,pcol,exp(-fract(bpm)));
  out_color = vec4(col,1.);
}