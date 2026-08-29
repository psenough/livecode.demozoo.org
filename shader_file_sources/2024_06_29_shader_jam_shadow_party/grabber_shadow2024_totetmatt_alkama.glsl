#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCIX;
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texLcdz;
uniform sampler2D texNfp;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texSession2024;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

////////////////////////////////////////
// HUG THE ALKAMA //// HUG THE ALKAMA //
////////////////////////////////////////

////////////////////////////////////////
// HUG THE ALKAMA //// HUG THE ALKAMA //
////////////////////////////////////////
vec3 noise;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
mat3 ort(vec3 p){
    vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.1,.2)));}
vec3 cy(vec3 p,float pump){
  
    vec4 s = vec4(0.);
    mat3 o = ort(vec3(-1.,2.,-3.));
    for(float i=0.;i++<5.;){
         p*=o;
         p+=sin(p.xyz);
         s+=vec4(cross(sin(p),cos(p.yzx)),1.);
         s*=pump;
         p*=2.;
      }
      return s.xyz/s.w;
  }
struct GridResult {
  vec3 cell;
  float d;
  vec3 n;
};  GridResult grid;
GridResult gridTraversal( vec3 ro, vec3 rd ) {
  GridResult r;

  r.cell = floor( ro + rd * 1E-3 ) + 0.5;
  r.cell.y=0.;
  vec3 src = -( ro - r.cell ) / rd;
  vec3 dst = abs( 0.5 / rd );
  vec3 bv = src + dst;
  r.d = abs(min( min( bv.x, bv.z), bv.z ));
  
  r.n = -step( bv, vec3( r.d ) ) * sign( rd );
  
  return r;
}

vec3 pcg3d(vec3 p){
    uvec3 q= floatBitsToUint(p)*1234567u+1234567890u;
    q.x += q.y*q.z;  q.y += q.x*q.z;  q.z += q.y*q.x;
  q^=q>>16u;
       q.x+= q.y*q.z;  q.y += q.x*q.z;  q.z += q.y*q.x;
  return vec3(q)/float(-1u);
  }
float bpm= fGlobalTime *128/60.;

float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec2 sdf(vec3 p){
    vec2 h;
    vec3 hp=p-grid.cell;
  vec3 r = pcg3d(grid.cell);
  float tx = sqrt(texture(texFFTSmoothed,r.x).x)*.5;
    h.x = box(hp,vec3(.45,tx*50,.45));
    h.y= r.z;
  
  vec3 tp=p;
  vec2 t;
  //tp.xz=.5-abs(tp.xz);
  tp.y -=5.;
  tp=erot(tp,vec3(1.,0.,0.),floor(bpm+noise.z*.2+atan(tp.z,tp.x)*.1));
  float ag = atan(tp.x,tp.z)/3.1415;
  vec2 q = vec2(length(tp.xz)-20.1,tp.y);

  t.x = length(q)-cy(tp+bpm,2.).x;
  t.y = -fract(ag);
  tp = erot(tp,cy(tp+bpm,2.)*.5,.785);
  t.x = min(t.x,min(min(length(tp.yz),length(tp.xy)),length(tp.xz))-.1);
  h = t.x < h.x ? t:h;
 
  return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0);
  noise = pcg3d(vec3(uv.xy,bpm));
 
  float wheee=  tanh(sin(bpm*.25+noise.x*.1)*16.);
  vec3 ro=vec3(0.,16.,-40.+wheee*10),rt=vec3(0.+sin(bpm*.25)*5,cos(bpm*.5)*5,tan(bpm*.125))+noise*max(0.,length(uv)-.4)*2;;
  ro = erot(ro,vec3(0.,1.,0),bpm*.1+floor(bpm*.5)+smoothstep(.0,.1+noise.z*.1,fract(bpm*.5)));
  ro.y +=tanh(sin(bpm)*4);
  vec3 rd= ort(rt-ro)*normalize(vec3(uv,1.-.5*wheee*.1));
  vec3 rp=ro;
  float i=0.;
  float rl=0.;
  vec2 d;
  vec3 light= vec3(1.,22.,-3.);
    float gridlen = 0.0;
vec3 acc=vec3(0.);
  for(;i++<70.;){
       if ( gridlen <= rl ) {
        grid = gridTraversal( rp, rd );
        gridlen += grid.d;
      }
      d= sdf(rp);
      if(d.y <=-0.){
        vec3 c = cy(rp,2.);
          acc+=vec3(1.)*exp(-abs(d.x))/(100-95*exp(-9*fract(c*.12 +d.y+bpm)));
        d.x = max(.001,abs(d.x));
        }
      rl=min(rl+d.x,gridlen);
      rp=ro+rd*rl;
      if(d.x< .001) break;
    }
    if(d.x < .001) {
      
       vec3 n = norm(rp,.001);
       vec3 ld = normalize(light-rp);
       float dif = max(0.,dot(ld,n));
       float spc = pow(max(0.,dot(reflect(ld,n),rd)),32.);
       float fre= pow(1+dot(rd,n),4);
       float sss= clamp(sdf(rp+ld*.1).x/.1,0.,1.);
       col +=exp(-5*fract(vec3(d.y)+floor(bpm)*5.5))*(dif+sss*.5)+spc;
       col = mix(vec3(.1),col,1-fre);
      }
   col = mix(col,.5*pal(floor(bpm)*.1),1-exp(-.000005*rl*rl*rl));
     col  =sqrt(col*.3)+2*acc;
      
     col = mix(col,fwidth(col*2.),smoothstep(.3,.4,abs(uv.y)));
      //if(fract(bpm)>.9)col = fwidth(col*2);
	out_color = vec4(col,1.);
}