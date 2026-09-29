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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t;

mat2 R(float a) {return mat2(-cos(a),sin(a),sin(a),cos(a));}
float rnd(vec2 p){return fract(6666*p.x*fract(6667*p.y));}
float box(vec3 p,float r) {p=abs(p)-r;return max(p.z,max(p.x,p.y));}

float S(vec3 p)

{
   p.x=abs(p.x);
  float pz=clamp(sin(t/9)*8,0,1)+1;
   p.xz*=R(t/18);
   float obd=box(-p,10);
   p.xy*=R(t/6);
   p.yz*=R(t/18);
   float bd=box(p,pz);
   p.yz*=R(t/7.3);
   vec3 rp=mod(p*3,2)-1;
   float md=(pz-1)*box(rp,.5);
 
    float od=dot(p,sign(p))-2;
    return min(max(min(od,bd),md),-obd);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uvOrg=uv;
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec4 fc=texture(texPreviousFrame,uvOrg);

  
  float f = texture( texFFTIntegrated , .1).r;
  t=fGlobalTime + f*8; 

  vec3 dof,o,ro,p,r; 
  float a,d,c,td=0;
  
  float dr=length(uv);
  dr*=dr;
  c=0;
  for (int s=0;s<4;s++) {    
    vec3 dof=vec3(rnd(vec2(uv+s)),rnd(vec2(fract(t)+s*.2,fGlobalTime+s)),0);
   float pz=clamp(sin(t/7)*4,0,1)*3;
    ro=vec3(0,0,pz-9)+(dof*dr);
    r=vec3(uv,1)-(dof*dr*.1);
    p=ro;
    td=0;a=1.0;d=0;
    for (int i=0;i<32;i++) {
        p=ro+r*td;
        d=S(p);
        if (d<.001) {
           vec2 e=vec2(.001,0);
           vec3 n=normalize(p-vec3(S(p-e.xyy),S(p-e.xyx),S(p-e.yyx)));
           vec3 rn=normalize(n+0.01*dof);
           r=reflect(r,rn);
           c+=a; 
           d=0.1;
           float fr=1-abs(dot(n,r));
           a*=0.3+0.5*pow(fr,2);
        }
        
        td+=d*.8;
        if (td>49) break;
    }    
  } // s
  
  c*=a;
  if (td>49) c=uv.y;
  float pulse = smoothstep(.49,.5,length(fract((uv.y)*.01-t/32)-.5));
  
  float scan=sin((uv.x+uv.y)*540)*0.25+0.75;
  c*=scan;
  c+=pulse+uvOrg.y*.1;
  vec3 mc=mix(vec3(.4,.5,.8),vec3(.8,.5,.4),clamp(1-uvOrg.y,0,1));
	out_color = (fc *.7 + vec4(vec3(sqrt(smoothstep(0,1,c*mc))),1) * .3);
}