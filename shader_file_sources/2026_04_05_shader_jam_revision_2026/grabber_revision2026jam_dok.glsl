#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define time fGlobalTime
const float pi = acos(-1);
#define r2(a)mat2(cos(a),-sin(a),sin(a),cos(a))
const float bpm=160/60.;
vec4 s=time*bpm/vec4(1,4,8,16),t=fract(s);

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
float sd_box(vec3 p, vec3 e)
{
        p= abs(p) - e;
        return length(max(p,0))+ min(0,max(p.x,max(p.y,p.z)));
}
float sd_tri( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}
vec3 erot(vec3 p, vec3 x, float a){
        return mix(dot(p,x)*x,p,cos(a))+cross(p,x)*sin(a);
}

float M;
float map(vec3 p) {
        float m, d=1e9;
        M=0;
        {
                vec3 q = p;
		float sn = sign(q.x);
                q.x=abs(q.x)-1.5;
                q = erot(q, normalize(vec3(0,1,0)), sn*time);
                q.xy *= r2(-pi/3);

                m = max(sd_tri(q, vec2(1,.01)),-sd_tri(q+vec3(0,.4,0), vec2(.6,.11)));
                m = min(m,sd_tri(q+vec3(0,.35,0), vec2(.3,.01)));
                if (m <d) {
                        M=1;
                        d=m;
                }
        }
        {
                vec3 q = p;

                q.z+=.1*sin(time+q.x*4+sin(q.x*10+time*0.1)*0.1)*smoothstep(4,-4,q.y);

                q.x=abs(q.x)-5;
                q.z+=6;
		q.xz*=r2(.125*pi+.1*sin(.1*q.y-time));
                m = sd_box(q, vec3(3,6,.01));
                if (m <d) {
                        M=2;
                        d=m;
                }
        }

        return d;
}


vec3 nrm(vec3 p) {
        vec2 e = vec2(-1,1);
        float h= 5e-3;
        return normalize(
        e.xyy*map(p+e.xyy*h)+
        e.yxy*map(p+e.yxy*h)+
        e.yyx*map(p+e.yyx*h)+
        e.xxx*map(p+e.xxx*h));
}

uint hashi(uint x){
        const uint c = int(-1u*(1-sqrt(5)/2))|1;
        x ^=x>>16; x*=c;
        x ^=x>>15; x*=c;
        x ^=x>>16;
        return x;
}

float hashf(vec3 p) {
        uint x = hashi(floatBitsToInt(p.z));
        x = hashi(floatBitsToInt(p.y)+x);
        x = hashi(floatBitsToInt(p.x)+x);
        return x / float(-1u);
}

vec4 tex(sampler2D tex, vec2 uv)
{
	vec2 sz = textureSize(tex,0);
	float r = sz.x/sz.y;
	uv*=vec2(1,r);
	uv.y=1-uv.y;
	return texture(tex, uv);
}


void main(void)
{
        vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
        vec2 UV = uv;
        uv -= 0.5;
        uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
        vec3 col = vec3(0);
        vec3 ro = vec3(0,0,3);
        float fv =.8;

	float glx = pow(1-t.y,1.5)*.1*(hashf(vec3(floor(gl_FragCoord.yy/5),time)));

        vec3 cz = normalize(-ro),
        cx=normalize(cross(cz,vec3(0,1,0))),
        cy=normalize(cross(cx,cz)),
        rd=mat3(cx,cy,cz)*normalize(vec3(uv+vec2(glx,0),fv));
        vec3 p;
        float i,r,d,h;
        h=10;
        r=d=0;
        float o=1;
        float gl =0;
//        col=.1*pow(vec3(.9,.01,.01),(2).xxx);

	{
		vec2 uv = uv*5;
		float id;
		uv.y-=(id=floor(uv.y/1.5))*1.5;
		float sn = ((int(id)%2==0)?-1:1);
		uv.x-=(floor(s.x)+pow(t.x,.5)) * sn;
		uv.x-=floor(uv.x/1.5)*1.5;
		uv-=.5;
		uv*=r2(sn*.5*pi*(id+floor(s.x)+pow(t.x,.2)));
		uv+=.5;
		vec4 o = tex(texEwerk,clamp(uv,0,1));
		col = mix(col,o.rgb,o.a);
	}		
	
        for (i=0;i<100;i++) {
                vec3 p = ro+r*rd;
                d = map(p);
                d *=1+.2*t.x*(hashf(vec3(gl_FragCoord.yy,time)));
                r+=d*.9;
                if(d<1e-3) {
                        vec3 n = nrm(p);
                        if (M==1&&h-->0) {
                                col=vec3(1,.85,0);
				p=ro+r*rd;
                                rd = reflect(rd,n);
                                ro = p + .5*n;
                                r=0;
                                o*=.5;
                                continue;

                                break;
                        }
                        if (M==2){
                                float fr = abs(dot(rd,n));
                                col=fr*vec3(.88,.0001,.0001);
                                break;
                        }
                        if (M==2) {
                                o*=1-pow(abs(dot(rd,n)),.135);
                                col+=.8*o;
                                break;
                        }
                        break;
                }
                if(r>1e4)
                        break;
        }
        gl = i/100;
        gl=pow(gl,2.2);
	
	col*=0.8+gl;
	col=pow(col,vec3(0.25+2.*pow(1-t.x,.5)));
	{
		vec2 uv = uv;
		uv*=r2(.235*pi*pow(.5+.5*sin(-time*0.1),2));
		uv+=vec2(.1,-.2);
		uv.y+=.1*cos(time);
		uv.x+=.1*sin(time);
		vec4 o = tex(texC64,clamp(uv*mix(4.,2.6,pow(.5+.5*sin(time*1.2),4)),0,1));
		col = mix(col,o.rgb,o.a);
	}
	{
		vec2 uv = uv;
		uv*=r2(.2*pi*pow(.5+.5*sin(time),2));
		uv+=vec2(.2,.5);
		uv.y+=.2*cos(-time*0.5);
		uv.x+=.2*sin(-time*0.4);
		
		vec4 o = tex(texAmiga,clamp(uv*mix(2.,1.6,pow(.5+.5*sin(time),5)),0,1));
		col = mix(col,o.rgb,o.a);
	}

	{
		vec3 pre = texture(texPreviousFrame, (UV-.5)*.98+.5).rgb;
		vec3 ccc=mix(pre,col,mix(1,pow(4-col.r,3),pow(t.x,2.1)));
		col = mix(col,ccc,pow(t.x,4)*pow(.5+.5*sin(pi*t.z*1.2),3));
	}
        out_color = vec4(clamp(col,0,1),1);
}
