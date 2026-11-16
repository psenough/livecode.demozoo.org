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

float time,f,fm;

mat2 R(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}
float N(float h) {return fract(sin(h*13373.24)*35436.73);}
float m=0;
float S(vec3 p)
{
//  p.x=abs(p.x);
  p.xy*=R(sin(time/4)*.5);
  p.xz*=R(time/3);
  vec3 op=p;
  m=0;
  float disp=sin(p.x*7-time) * sin(p.y*5+time) * sin (p.z * 3 - time*2) ;
  float sd=length(p)-6.5;
  float od=length(p)-3.5;
  p=p-sin(time+p.x);
  p=mod(p,1)-.5;
  float d=dot(p,sign(p))-sin(-op.y);
  op.xz*=R(time);
  float id=length(op-vec3(0,sin(time)/2,0))-.5+disp*.5;
  float d2=min(max(d,-od),-sd);
  if (id<d2) m=1.0;
  return min(d2,id);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvOriginal = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  f = texture( texFFTIntegrated , .1).r * 1;
	fm = clamp(texture( texFFTSmoothed , .3 ).r * 32. + 0.1,0,1);
 // float ff = texture( texFFTIntegrated , floor(uvOriginal.y*64)/64).r *0.1*(fm);
	//fh = texture( texFFTIntegrated , .7 ).r * 1;
  time = f+fGlobalTime;
 
  float v=length(uv);
  float dof=0;//v*N(time+uv.x*3.+uv.y*32.)*.01;
  vec3 ro=vec3(0,0,-2.5)+dof;
  vec3 rd=normalize(vec3(uv,1))-dof*.75;
  vec3 p=ro;
  float d=1,td=0;
  float g=0;
  for (int i=0;i<50;i++) {
      d=S(p);
      p+=rd*d/2;
      if (d<.001) break;
      if (d>99) break;
      td+=d;
      g+=.001/(d*d+.1);
  }
  mat3 e=mat3(p,p,p)-mat3(.1);
  vec3 n=normalize(vec3(S(p))-vec3(S(e[0]),S(e[1]),S(e[2]))); 
  
  vec3 col=(m==1.0) ? vec3(.9,.5,.2) : vec3(.3,.4,.5);
  float dif=max(0,dot(n,normalize(vec3(1,2,-3))));
float spec=pow(dif,64); 
  float dz=7./td;
 float dao =  .1;
   float ao = clamp(S(p+n*dao)/dao,0.,1.);

  float pulse=smoothstep(0.49,0.5,length(fract(-p.y+p.z*0.1+time/2)-.5));
  vec3 fcol= vec3(uv.y+dif*col+spec)*ao*dz;
  float ca=v*.05;
    vec4 chroma=vec4(texture(texPreviousFrame,uvOriginal-ca).r,texture(texPreviousFrame,uvOriginal-ca/2).g,texture(texPreviousFrame,uvOriginal+ca).b,1);
  float scan=sin((uv.x+uv.y)*540)*.5+.5;
	out_color = vec4(((clamp(fcol+pulse,0.,1.))*scan*(1.2-v*.25)),1)+chroma*.2;//vec4(1/td);//vec4(fract(uv.x*uv.y+time)*.25);
}