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
uniform sampler2D texInerciaBW;
uniform sampler2D texInercia;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time,f,fm;

float box(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
vec3 rnd(vec3 t) {return fract(sin(t*847.627+t.yzx*463.994+t.zxy*690.238)*492.094);}
mat2 R(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}

float S(vec3 p)
{
   vec3 fp=floor(p);
  p=mod(p,4)-2;
  return box(p,vec3(rnd(fp/16)))-.5;
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvOriginal = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  f = texture( texFFTIntegrated ,.1).r * 8;
	fm = clamp(texture( texFFTSmoothed , .3 ).r * 8 + 0.1,0,1);
  time = f+fGlobalTime;

  
  uv *= fract(pow(length(uv),.1)-(time/16));

  vec4 cLogo=texture(texInercia,vec2(uvOriginal.x,1-uvOriginal.y));
  
  float fov=smoothstep(.4,.8,cos(fGlobalTime/4));
  vec3 ro=vec3(0,0,-8);
  vec3 n,p,r=normalize(vec3(uv,fov+.5));  
  r.xz*=R(time/32+fov);
  r.xy*=R(time/28);
  r.yz*=R(time/27);
  
  float d,t=0,td=0;
  float c=0;
  for (int i=0;i<99;i++) {
      p=ro+r*t;
      d=S(p);
      t+=d/2;
      td+=d/2;
      if (abs(d)<.01 || d>99) {
           n=normalize(S(p)-vec3(S(p-vec2(.01,0).xyy),S(p-vec2(.01,0).yxy),S(p-vec2(.01,0).yyx))); 
           r=reflect(r,normalize(n+.01*rnd(vec3(uv,td+i))));
           c+=max(.1,pow(1+dot(r,n),7));
           t=.1;
      }
  }
    float pulse=smoothstep(0.49,0.5,length(fract(-p.y+p.z*0.1+time/2)-.5));

   vec3 mat=mix(vec3(.5,.4,.3),vec3(.3,.6,.8),clamp((uv.x*uv.y)*4,0,1)+uv.y);
   vec3 ll=mat*c/64*clamp(1-td/64,0,1);
  float ca=length(uv*uv)*.1;
  vec4 chroma=vec4(texture(texPreviousFrame,vec2(uvOriginal.x-ca,uvOriginal.y)).r,texture(texPreviousFrame,vec2(uvOriginal.x,uvOriginal.y)).g,texture(texPreviousFrame,vec2(uvOriginal.x+ca/2,uvOriginal.y)).b,1);


 float sc = sin(uvOriginal.x*2920)*.2+.8;
	out_color = mix(vec4(ll,1)*sc*(1-length(uv)/2),chroma,.3) + cLogo;// vec4(sin(f)*.3,0,sin(abs(uv.y)*32+time)/4+.3,1);
}