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
uniform sampler2D texText;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 txt(vec2 uv){
   vec2 puv = uv * vec2(v2Resolution.y / v2Resolution.x, 1);
  puv+=.5;

  puv*=v2Resolution.xy*vec2(1,-1);
  puv.y+=256;
  
  ivec2 gl = ivec2(puv);
  int offset = 88+0*int(sin(fGlobalTime*4)*13+13);
  return texelFetch(texText,gl,0).aaa;
  return texelFetch(texText,clamp(gl,ivec2(offset,19),ivec2(10+offset,19+19)),0).aaa;
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col =vec3(0.);
    float lol = tanh(sqrt(texelFetch(texFFT,int(+gl_FragCoord.x / v2Resolution.x*128)%128,0).r));
   if(abs(uv.y)>.4-lol*.5) uv*=(3.);
  vec2 ouv =uv; float rnd = (floatBitsToInt(uv.x)^floatBitsToInt(gl_FragCoord.y))*(floatBitsToInt(uv.y)^floatBitsToInt(gl_FragCoord.x))/2.19e9;
   float bpm = texture(texFFTIntegrated,.3).r+rnd*.01+exp(-3*fract(fGlobalTime*170/60*.25))*sqrt(length(uv));
  bpm = floor(bpm)+smoothstep(0.,1.,fract(bpm));
  
  vec2 zuv = vec2(atan(uv.x,uv.y),log(length(uv)));
  zuv.yx+=-fGlobalTime*.5+tanh(sin(bpm*5)*2);
  zuv = asin(sin(zuv*4))/4;  zuv = vec2(atan(zuv.x,zuv.y),log(length(zuv)));
  zuv.y+=.5+sin(bpm+zuv.y);
  zuv =  asin(sin(zuv));
 
  uv = mix(uv,zuv,tanh(sin(fGlobalTime)*5)*.5+.5);
  
 
  float lim=5.;
    for(float i=0.;i++<lim;){
      vec2 luv = uv;
      float q = fract(-bpm*.5+i/4);
      float sc =mix(.1,30.+sin(bpm)*15,q);
      luv *= sc;
      luv.x +=fGlobalTime;
      float rr = fract(458.88*sin(i*455.25));
      float tt = texture(texFFTSmoothed,floor(rr+1/i*luv.x*10+.5)/20).r;
      col += smoothstep(uv.y+.4,uv.y+.6,sqrt(tt)*3)*exp(1-q)*log(1.1+tt);
    }
    ivec2 gl= ivec2(gl_FragCoord.xy);
    
    vec2 uuv = floor(ouv*10)/10;
    ivec2 off=  ivec2(5*+texture(texFFTSmoothed,dot(sin(uuv*5.7+bpm*4),cos(uuv.yx*2.5))).r*100);
    float vr = texelFetch(texPreviousFrame,gl+off,0).a;
    float vg = texelFetch(texPreviousFrame,gl-off,0).a;
    float vb = texelFetch(texPreviousFrame,gl-off,0).a;
    
    vec3 fcol = vec3(vr,vg,vb);
    // if(fract(fGlobalTime*175/60*.5)>.8){fcol = 1-fcol;}
    fcol  = mix(fcol,1-fcol,exp(-3*fract(uv.y+fGlobalTime*170/60*.25)));
	out_color = vec4(fcol,.2/col.r);
}