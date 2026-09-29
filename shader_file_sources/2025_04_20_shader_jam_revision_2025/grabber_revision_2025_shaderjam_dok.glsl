#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is hi\
gher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh \
transients
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

#define time fGlobalTime
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}
vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}
const float bpm=145/60.0;
const float pi = acos(-1);
vec4 s=time*bpm/vec4(1,4,8,16),t=fract(s);
vec4 txt(vec2 p){
    float t= mod(floor(fGlobalTime),5);
    if(t<1){
      return texture(texAcorn1,clamp(p*vec2(1,-1),-.5,.5)-.5);
    }
     if(t<2){
      return texture(texAcorn2,clamp(p*vec2(1,-1),-.5,.5)-.5);
    }
    if(t<3){
      return texture(texLeafs,clamp(p*vec2(1,-1),-.5,.5)-.5);
    }
    if(t<4){
      return texture(texRevisionBW,clamp(p*vec2(1,-1),-.5,.5)-.5);
    }
    if(t<5){
      return texture(texLynn,clamp(p*vec2(1,-1),-.5,.5)-.5);
    }
}
vec2 m2(vec2 dm, float m, float d) { if (d<dm.x) dm=vec2(d,m); return dm;}
float sfc(float x) { return x/(1+x); }
float sdb(vec3 p, vec3 e)
{
	p = abs(p) - e;
	return length(max(p,0));
}
float gyr(vec3 p) { return dot(sin(p),cos(p));}

float fbm(vec3 p, float f)
{
	float a=5;
	float i;
	float r = 0;
	for (i=0;i<5;i++){
		r+=gyr(f*p/a)*a;
//		p+=r*.5;
		a/=2;
	}
	return r;
}

vec2 sd(vec3 p)
{
	vec2 dm = vec2(1e9,0);

	{
		vec3 q = p;
		float x= texture(texFFTSmoothed, 0.1).r*15;
		float s = mix(.1,.4,clamp(x,0,1));
		q.xz-= clamp(round(q.xz/4),-1,1)*4;
		dm = m2(dm, 2, length(q)-s);
	}
	
	{
		vec3 q = p;
		q.xz = abs(q.xz);
		q.xz -= 4;
		dm= m2(dm, 1, sdb(q, vec3(.5,10,.5)));
	}

	return dm;
}
vec3 nr(vec3 p)
{
	float h = 1e-3;
	vec2 e=vec2(-1,1);
	return normalize(
	e.xyy*sd(p+e.xyy*h).x+
	e.yxy*sd(p+e.yxy*h).x+
	e.yyx*sd(p+e.yyx*h).x+
	e.xxx*sd(p+e.xxx*h).x);
}

vec2 rm(vec3 ro, vec3 rd)
{
        vec2 r;
        float t,i,d;
	float h=10;
	vec3 p,n;
        for(t = 0,i = 100; i-->0;) {
                r = sd(ro + rd * t);
                t += d = r.x;
		p = ro + rd * t;
		n = nr(p);
		if (h>0) {
		if (d<1e-3&&r.y==2) {
			rd=reflect(n,rd);
			ro=p+n*1e-2;
			h--;
			continue;
		}
		}
		if(d<1e-3||t>1e3)break;
        }
        if (i == 0 || t>1e3) return vec2(0);
        return vec2(t,r.y);
}

void main(void)
{
        vec2 uv = (gl_FragCoord.xy - 0.5 * v2Resolution.xy) / v2Resolution.y;
	vec3 col = vec3(0);
	float fv = .1;

	
	fv = mix(.25,.5,t.x*min(sfc(texture(texFFTSmoothed,.1).r),1));
	
	
	vec3 ro = vec3(0,0,4);
	
	ro.y = sin(time);
	ro.xz*=r2(time);
	vec3 cf = normalize(-ro),
	cs=normalize(cross(cf,vec3(0,1,0))),
	cu=normalize(cross(cs,cf)),
	rd=mat3(cs,cu,cf)*normalize(vec3(uv,fv));
//	col =mix(col,sqrt(t.rgb),uv.x< 0 ? t.a:1);
	col.rg = rm(ro,rd);
	
	float ff;
	{
		vec2 vv= uv*r2(pi*.25);
		ff = max(abs(vv).x,abs(vv).y);
	}
	if (step(fract(ff-t.w),.5)>.5)col=1-col;

	{
		vec3 pre=texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy).rgb;
		float f = mix(.05,.1,min(texture(texFFTSmoothed,0.1).r/10,0));
		col=mix(pre,col,f);
	}

	col.rgb = col.rrr;

	//	col.r = texture(texFFTSmoothed,uv.x).r;
        out_color = vec4(col,1.);
}
