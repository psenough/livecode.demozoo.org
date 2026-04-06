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
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texZX;
uniform sampler2D texDritter;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define T fGlobalTime
#define Res v2Resolution
#define S smootstep
#define frag gl_FragCoord

//GREETINGS TO MAREX,CANMOM AND ALL THE OTHER LIVECODERS
//Thx to totematt, ps and diffty for organizing
mat2 rot2d(float a){
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec3 palette(float t){
  return .5+.5*cos(6.28318*(t*vec3(.3,.416,.557)));
}

float sdOcta(vec3 p, float s){
  p=abs(p);
  return(p.x+p.y+p.z-s)*0.57735027;
}

float map(vec3 p){
  p.z += T*.4;
  p.xy = fract(p.xy)-.5;
  p.z=mod(p.z,.25)-.125;
  //p=fract(p)-.5;
  return sdOcta(p,.2);  
}

void main(void)
{
	vec2 uv = (frag.xy*2-Res.xy)/Res.y;
  vec2 m = vec2(cos(T*.7),sin(T*.7));
  
  vec3 ro=vec3(0,0,3);
  vec3 rd=normalize(vec3(uv,1.));
  vec3 col=vec3(0);
  float t;
  
  int i;
  for(i=0;i<80;i++){
    vec3 p = ro+rd*t;
    p.xy*=rot2d(t*.15*m.x);
    p.y +=sin(t*(m.y+6.)*.7)*.35;
    float d = map(p);
    t+=d;
    if(d<.001||t>100.)break;
    
  }
	col = palette(t*.04+float(i)*.005);
  col*=vec3(.4545);
  
	out_color = vec4(col,1.);
}