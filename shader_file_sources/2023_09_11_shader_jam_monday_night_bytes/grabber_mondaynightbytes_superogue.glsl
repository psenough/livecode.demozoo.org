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

float f,f2,t;

vec3 rnd(vec3 p) {return fract(sin(p*125.78+p.yzx*564.24+p.zyx*365.55));}
mat2 R(float a) {return mat2(-cos(a),sin(a),sin(a),cos(a));}
float box(vec3 p,vec3 d) {p=abs(p)-d;return max(p.x,max(p.y,p.z));}

float S(vec3 p)

{
  vec3 fp=floor(p);
  p=mod(p,2)-fract(f);
  
  float d2=dot(p,sign(p))-1;  
  return max(box(p,vec3(rnd(fp*floor(f)*.8))) , -d2);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uvOrg=uv;
  vec4 fc=texture(texPreviousFrame,uvOrg);

  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  f = texture( texFFTIntegrated , .1).r;
  f2 = texture( texFFTIntegrated , .2).r;
  t=fGlobalTime*4 + f*3.; 

  float fov=smoothstep(.3,.9,sin(t/8.))+smoothstep(.0,.4,cos(t/6.))/2;
  vec3 ro=vec3(0,0,-8);
  vec3 rd=normalize(vec3(uv,fov+1.));
  vec3 p;

  rd.x=abs(rd.x);
  // you spin me around
  rd.xy*=R(t/32);
  rd.yz*=R(t/31);
  rd.xz*=R(t/29);
  

  float d,dd,c,td=0;
  float a=1;
  for (int i=0;i<128;i++) {
       p=ro+rd*dd;
       d=S(p);dd+=d/2;
       if (abs(d)<.01 || td>64) {
         vec2 e=vec2(0,.01);
         vec3 n=normalize(d-vec3(S(p-e.xyy),S(p-e.yxy),S(p-e.yyx)));
         rd=reflect(rd,normalize(n-.01*rnd(vec3(uv*td+i,dd))));
         c+=max(0,pow(1+dot(rd,n),8.));
         a=a/3;dd=.1;         
       }
       td+=d/2;
  }
  
  vec3 mat=mix(vec3(.8,.5,.3),vec3(.3,.5,.8),clamp((uv.x*uv.y)*4,0,1));
  vec3 ll=mat*c/64*clamp(1-td/32,0,1);
  float scan=sin((uv.x+uv.y)*540)*sin((uv.x-uv.y)*270)+1;
	out_color = fc*.2+.5*scan*vec4(sqrt(ll),1)*(1-length(uv)/3);
}