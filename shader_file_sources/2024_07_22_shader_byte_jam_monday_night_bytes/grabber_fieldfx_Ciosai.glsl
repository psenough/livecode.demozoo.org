#version 410 core

const float pi=acos(-1.);
const float tau=pi*2.;

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

///  3 out, 3 in...
vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

float ease(float n){return smoothstep(0.,1.,smoothstep(0.,1.,n));}

float level(vec2 p, float t)
{
  float val = step(.1,abs(length(p)-.4));
  float a=t*.6+atan(p.y,p.x)/tau+.5;
  val+=step(.8,fract(a));
  
  return smoothstep(0.,1.,1.-val);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float t=fGlobalTime*1.3-hash33(vec3(gl_FragCoord.xy,0.)).x*.05;
  
  vec3 bg=vec3(.9,.9,.8);
  vec3 pal[]=vec3[](
  vec3(.1,.02,.4),
  vec3(.01,.4,.02),
  vec3(.9,.001,.4)
  );
  
  uv+=vec2(t,t*.34)*.2;
  
  vec2 i_uv=floor(uv*2.);
  vec2 f_uv=fract(uv*2.);
  f_uv.y+=mod(i_uv.x,2.)*.5;
  f_uv=fract(f_uv);
  uv=f_uv*2.-1.;
  
  uv*=1.5;
  
  uv*=mat2(cos(-t),-sin(-t),sin(-t),cos(-t));
  
  float f_t=fract(t);
  float i_t=floor(t);
  
  
  vec4 paint=vec4(
  level(vec2(1.-ease(f_t),0)+uv*length(uv-hash33(vec3(i_t,0,0)).xy+sin(uv*vec2(74.,59.)-t*40.)*.1*mix(hash33(vec3(i_t,0,0)).x,hash33(vec3(i_t+1,0,0)).x,ease(f_t))),t),
  level(vec2(0,1.-ease(f_t))+uv*length(uv-hash33(vec3(0,i_t,0)).xy+sin(uv*vec2(124.,39.)-t*20.)*.08*mix(hash33(vec3(0,i_t,0)).x,hash33(vec3(0,i_t+1,0)).x,ease(f_t))),t),
  level(vec2(1.-ease(f_t))+uv*length(uv-hash33(vec3(0,0,i_t)).xy+sin(uv*vec2(23.,197.)-t*5.)*.01*mix(hash33(vec3(0,0,i_t)).x,hash33(vec3(0,0,i_t+1)).x,ease(f_t))),t),
  0);
  paint.w=paint.x+paint.y+paint.z;
  paint.xyz/=max(.0001,paint.w);
  
  vec3 col = (pal[0]*paint.x)+(pal[1]*paint.y)+(pal[2]*paint.z);
  col=mix(bg,col,smoothstep(0.,1.,length(paint.xyz)));
  
  out_color=vec4(pow(max(col,0.),vec3(.454545)),1.);
}