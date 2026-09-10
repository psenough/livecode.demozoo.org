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
uniform sampler2D texTexBee;
uniform sampler2D texTexOni;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(0.,.4,.6)));}
vec3 grid(vec2 uv,float off){
    vec2 uuv=uv;
    float tt = texture(texFFTIntegrated,.3).r;
    float ttt =texture(texNoise,uv).r;
    float tttt=texture(texFFT,.6).r*50.;
    uv*=rot(floor(tt*50.)*.785*.5);
    uv = abs(fract(uv+ttt*tttt)-.5);

    if(uv.x <=.002) return pal(.1+off)*length(uv)*2.*clamp((length(uuv)-.5),.0,1.);
     return vec3(.0);
}
vec3 layer(vec2 uv,float off){
  uv.x +=off*.2;
    uv.y +=off*.2;
  float tuv = abs(atan(uv.x,abs(uv.y)))*.05;
  float tt =texture(texFFTIntegrated,floor(100*tuv)/100).r;
  float ttt =texture(texFFT,floor(100*tuv)/100).r;
  
  float d = length(uv)-.2-ttt ;cos(floor(tt*10))*.01;
  d = abs(d)-.007+cos(tt)*.01;
  d = abs(d)-.0020-ttt*.1;
  d = smoothstep(fwidth(d),0.,d);
  return vec3(d)*pal(off+ttt*10.)+grid(uv+ttt,off*3.33);;
  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 puv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
 
	vec3 col = vec3(.01);
   float d = 0;
  float tttt=texture(texFFTIntegrated,.2).r*100.;
  const float lim = 20;;
  for(float i=0;i<=lim;i++){
    float it=i/lim;
    float itt = fract(it+fGlobalTime*.01+tttt*.005);
    
    float z = mix(.001,20.,itt);
    vec3 d = layer((uv*z)*rot(.785*i), it);
    col +=vec3(d)*(1.-itt);
  }
   vec3 pcol = texture(texPreviousFrame,puv).rgb;
   col = mix(col,pcol,.7);
  //col =vec3(d);
	out_color = vec4(col,1.);
}