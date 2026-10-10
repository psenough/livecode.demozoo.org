#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texLynn;
layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = fGlobalTime*176/60;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 hash3d(vec3 p){
	uvec3 q= floatBitsToUint(p);
	q = ((q>>16u)^q.yzx)*1111111111u;
	q = ((q>>16u)^q.yzx)*1111111111u;
	q = ((q>>16u)^q.yzx)*1111111111u;return vec3(q)/float(-1U);
	}
 float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0),p))+min(0.,max(p.x,max(p.y,p.z)));}
struct GS {vec3 hash,cell,size;};
struct Grid{GS sub;float d;};
Grid grid;
#define gsub grid.sub
void dosub(vec3 p){
     gsub.size =vec3(.5);
     for(int i=0;i<5;i++){
        gsub.cell = (floor(p/gsub.size)+.5)*gsub.size;
        gsub.cell.y =0;
        gsub.hash = hash3d(gsub.cell);
        if(i==4||gsub.hash.x < .5) break;
        gsub.size *=.5;
     }
  }
void dogrid(vec3 ro,vec3 rd){
     dosub(ro+rd*.001);
     vec3 src= -(ro-gsub.cell)/rd;
     src+= abs(.5*gsub.size/rd);
     grid.d = min(src.x,min(src.z,src.z));
  }
vec2 sdf(vec3 p){
	vec3 hp=p-gsub.cell;

	vec2 h;
    float rev= texture(texRevisionBW,clamp(gsub.cell.xz/15,-.5,.5)-.5).r;
  float tt= sqrt(textureLod(texFFTSmoothed,gsub.hash.x,0).r)*(1-rev)*(1-rev)*2;
  hp.y-=tt*gsub.size.x;

	h.x = box(hp,vec3(.49*gsub.size.x,.49+tt,.49*gsub.size.x));
	h.y= rev;
	return h;
}
vec3 lynn(vec2 uv){
  
     uv = clamp(uv*vec2(1,-1),-.5,.5)-.5;
     vec4 t = texture(texLynn,uv);
     return mix(vec3(0),t.rgb,t.a);
  }
vec3 stepNoise(float x,float n){
    float u = smoothstep(.5-n,.5+n,fract(x));
    return mix(hash3d(vec3(floor(x),-1U,1)),hash3d(vec3(floor(x+1),-1U,1)),u);
  }
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 col = vec3(0.);
  
	vec3 ro=vec3(0,1,-6),rt=vec3(0.);
    rt = erot(ro,vec3(0,1,0),bpm*.25+.1);
	 ro = erot(ro,vec3(0,1,0),bpm*.25);

  	vec3 rob=mix(vec3(-5,2,-5),vec3(7),stepNoise(bpm/4,.3)),rtb=vec3(0.);
 
	 rob = erot(rob,vec3(0,1,0),bpm);
 
   ro=mix(ro,rob,.5+.5*tanh(sin(fGlobalTime*.25)*5));;
   rt=mix(rt,rtb,.5+.5*tanh(sin(fGlobalTime*.25)*5));
	vec3 z =normalize(rt-ro),x= vec3(z.z,0.,-z.x);
	vec3 rd = mat3(x,cross(z,x),z)*erot(normalize(vec3(uv,.45)),vec3(0,0,1),(stepNoise(-bpm*.125+length(uv)*.1,.5).x-.5)*2);
	vec3 rp=ro;
	vec3 light = vec3(1.,2.,-3),acc=vec3(0);
	vec2 d;
	float rl=0.,i=0.,glen=0.;;
  for(float st=0;st++<3.;){
	for(;i++<128;){
		if(glen<=rl){
        dogrid(rp,rd);
        glen +=grid.d;
      }
    d = sdf(rp);
    if(gsub.hash.z<.1 && d.y>0 || length(gsub.cell)<1){
        acc+=stepNoise(-fGlobalTime+gsub.hash.x,gsub.hash.y*.5)*exp(-.1*abs(d.x))/(150-149*exp(-fract(rp.y*.1+fGlobalTime+gsub.hash.x*.1+length(gsub.cell))));
        d.x = max(.001,d.x);
      }
		if(d.x<.001)break;
		rl=min(rl+d.x,glen);
		rp=ro+rd*rl;
	}		
  vec3 n= norm(rp,.001);
	if(d.x<.001){

		vec3 ld = normalize(light-rp);
		float dif = max(.05,dot(ld,n));
		float spc = pow(max(0,dot(reflect(ld,n),rd)),32);
		float fre = pow(1.+dot(rd,n),4);
		col += mix(vec3(hash3d(rp).x*.05+.5*d.y)*dif+spc,col,fre)/st;
	}
  if(d.y>=.5){ 
      rl=0.;
      rp=ro=rp+n*.01;
      rd = reflect(rd,n);
     
    }
  }
	col = mix(col,mix(vec3(.1),vec3(.1,.2,.3),clamp(sqrt(uv.y),0,1)),1-exp(-.0001*rl*rl*rl));
   ivec2 gl = ivec2(gl_FragCoord.xy);
  vec3 lol = mod(bpm,4)<2 ? uv.xxx:uv.yyy;
    ivec2 off = ivec2(5+(hash3d(floor(lol*5+floor(bpm)))-.5)*500);
  vec3 pcol =vec3(
      texelFetch(texPreviousFrame,gl+off,0).r,
      texelFetch(texPreviousFrame,gl-off,0).g,
      texelFetch(texPreviousFrame,gl-off,0).b
  );
  
  col = sqrt(col+acc);
  vec3 ll =  +lynn(uv+(stepNoise(bpm,.3).xy-.5)+(hash3d(floor(uv.xxx)+bpm).x-.5)*.01)*exp(-1*fract(bpm+hash3d(floor(lol*50)).x));
 
   col = mix((col+acc),pcol,ll+.5*fract(bpm));
   
    if(mod(bpm,8)<4) col = mix(col,1-col,20*exp(-5*fract(bpm*4)));
   float trev = texture(texRevisionBW,clamp(uv,-.5,.5)-.5).x;
  out_color = vec4(col +ll+dFdx(col)*vec3(-1,1,1),1.);
}