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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time,f,fl,fm,fh;

// Superogue back here
mat2 R(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}
float N(vec3 p){return fract(sin(p.x*17.9+p.y*79.3)*4337);}


vec2 S(vec3 p)

{
  p.xz*=R(time/2);
  p.yz*=R(sin(fh*5)*.3);
  vec3 op=p;
  float m=0.0;
  float os=length(p)-8-(sin(time)*2);
  float is=length(p)-1;
  float od=dot(p,sign(p))-3.5;
  p=abs(p-sin(time)*.2);
  p=mod(p,1)-.5;
  float d=dot(p,sign(p))-abs(sin(time-op.y));
  float nd=max(od,d);
  if (-os<nd) m=1.0;
  if (is<nd) m=2.0;  
  return vec2(min(min(nd,-os),is),m);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
        vec2 uvOriginal = vec2(uv.x,1-uv.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  // fft
  f = texture( texFFTIntegrated , .1).r * 4;
	fm = clamp(texture( texFFTSmoothed , .3 ).r * 32. + 0.1,0,1);
  float ff = texture( texFFTIntegrated , floor(uvOriginal.y*64)/64).r *0.1*(fm);
	fh = texture( texFFTIntegrated , .7 ).r * 1;
  time = f+fGlobalTime*.5;
   if (mod(time,8)<4) ff=0;


  vec4 ovColor=texture(texSessions,vec2(uvOriginal.x+sin(ff)*.5,uvOriginal.y));   

  // go march
  vec3 ro=vec3(0,0,-6+sin(time*3));
  ro=ro+N(vec3(uv,1))*.05;  
  vec3 rd=normalize(vec3(uv,1));
  ro=ro+N(vec3(uv,1))*(dot(uv,uv))*.4;

  float g=0,td=0;
  vec3 p;
  vec2 d;
  for (int i=0;i<99;i++) {
      p=ro+td*rd;
      d=S(p);
      if ((d.x<.001) || (td>99)) break;
      td+=d.x*.25;
      g+=.001/(d.x+.1); // some glow 
  }
  mat3 e=mat3(p,p,p)-mat3(.01);
  vec3 n=normalize(vec3(S(p).x) - vec3(S(e[0]).x,S(e[1]).x,S(e[2]).x) );
  vec3 l=vec3(4,1,-9),ld=normalize(l-p);
  float dif=dot(n,ld);
  float spec=pow(dif,99);
  vec3 color=vec3(.2,.3,.4);
  if (d.y==2.0) color=vec3(abs(cos(time))*.5+.1,.3,abs(sin(time))*.4+.2);
  if (d.y==1.0) color=vec3(.1,.1,.1);
  float lz=8./td;
  vec3 ll=color*dif*lz+spec+uv.y*.3+g;
  
  out_color = ovColor*fm+clamp(vec4(ll*(1.-dot(uv,uv)*.5),1),0,1);
}