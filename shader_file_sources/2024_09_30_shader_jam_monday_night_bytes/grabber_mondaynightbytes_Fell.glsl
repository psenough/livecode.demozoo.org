/*
MondayNightBytes: Enabling Monday-night drinking since 20XX


Sweet greets:
  BRAINCHILD ON THE DECKS
  
  synatheaseassssaaia (I can never spell it!)
  Aldroid (sick camera on your effect mate)
  LittleTheremin }--- kicking ASS
  catnip         }
  
  suuuuule skpfreak tekiket amigabeanbag <3<3 mahy_9 dokthar
  wbcbz7 daeghnao RuaWhitepaw g33kou RaccoonViolet 43fluxx
  flexion__  
  
  Big ups the shadin' massive
*/


































































// Practicin' mah planet
// @estrellasadie sends love too!

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// rotate mah shiz pls
vec2 rot2(vec2 p,float q){
  return vec2(cos(q)*p.x + sin(q)*p.y, -sin(q) * p.x + cos(q)*p.y);
}

// let's get some 3d noise outta the 2d noise texture using the old classic triplanar texture mapping (gpu gems)
float t3(vec3 p, vec3 q) {
    q=max(abs(q),vec3(.001));
    q/=q.x+q.y+q.z;
  return texture(texNoise,p.zy).r*q.x + 
    texture(texNoise,p.zx).r*q.y + 
    texture(texNoise,p.xy).r*q.z;
}

float BASSSSSS=.002;
float BASS=.02;
float TREBLE=.8;

float noise;
float h(vec3 p){
    p.xy=rot2(p.xy, texture(texFFTIntegrated, BASS).r*.2);
    p.yz=rot2(p.yz, texture(texFFTIntegrated, BASS).r*.4);
    p.xz=rot2(p.zx, texture(texFFTIntegrated, TREBLE).r*.6);
    noise=abs(t3(p*.3, normalize(p)*.8 /*lol*/));
    return length(p)-max(.2,noise) - 1;
}

float cloud;
float hcloud(vec3 p){
  p.xy=rot2(p.xy, texture(texFFTIntegrated, BASS).r*.2 + fGlobalTime);
  p.yz=rot2(p.yz, texture(texFFTIntegrated, BASS).r*.4 + fGlobalTime);
  p.xz=rot2(p.zx, texture(texFFTIntegrated, TREBLE).r*.6 + fGlobalTime);

  cloud = pow(t3(p*.3,normalize(p)),4) * 16;
  cloud += pow(t3(p*.17,normalize(p)),4) * 16;
  
  cloud = max(0, cloud-.005);
  cloud=pow(cloud,1.4);
  
  return length(p) - 1.5;
}

float glow;
float hglows(vec3 p){
   // errr how to encode the glowiness
   //glow = lerpyderps(length(p)-.1.2, length(p)-.1.0, vec3(.................
  
    // ....!
  
   float l1=length(p)-1.32,
    l2=length(p)-1.;
  
   glow=pow(l1-l2,2);
  
   return l1;
}

// normalz
vec3 n(vec3 p){
  vec2 e=vec2(.001,0);
  return normalize(
    vec3(
      h(p+e.xyy) - h(p-e.xyy),
      h(p+e.yxy) - h(p-e.yxy),
      h(p+e.yyx) - h(p-e.yyx)
    )
  );
}

void main(void)
{  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  if(mod(fGlobalTime,4)<2){
    uv=mod(uv,vec2(sin(fGlobalTime*.5)));
    uv+=.5;
  }

   vec3 c=vec3(.6,.2,.6)*texture(texFFTSmoothed, BASSSSSS).r*1;
  
  // now for some stars ^_^
  //vec2 uv2=uv*.1+vec2(fGlobalTime * .0001,0);
  // now with EXTRA SPARKLES
  vec2 uv2=uv*.1+vec2(fGlobalTime * .001,0);
  float starz=texture(texTex2, uv2 * 17).r + texture(texNoise, uv2 * 100).r;
  starz = pow(starz, 12);
  c+=vec3(starz);
  
  vec3 rd=vec3(uv,1);
  
  vec3 campos=vec3(uv,-5 + texture(texFFTSmoothed, BASSSSSS).r * 7);
  
  // glowy part
  float d=0;
  vec3 p=campos;
  for (int i=0; i<32; i++) {
    d=hglows(p);
    if(d<.001||d>10)  // hmmmmm
      break;
    p+=rd*d;
  }
  
  if(d<.001) {
    c=vec3(1,.4,0) * glow;
  }
  
  
  // actual planet
  d=0;
  p=campos;
  for (int i=0; i<512; i++) {
    d=h(p);
    if(d<.001||d>10)
      break;
    p+=rd*d;
  }
  
  if(d<.001) {
    c = noise < .2 ? vec3(0,.2,.6) : 
      noise < .21 ? vec3(1,1,0) : 
      noise < .3?mix(vec3(.5,.1,.1),vec3(.1,.6,.1),sin(fGlobalTime)): // aii
      mix(vec3(.6,.1,.05),vec3(1),sin(fGlobalTime*.3)); 
    
    vec3 nr = n(p);
    //c=max(0,dot(nr,normalize(vec3(??) * ....... ; // brainfart ensues
    c *= max(0,dot(nr,normalize(vec3(1,1,0) )));
  }
  
  // cloudzzzz
  p=campos;
  for (int i=0; i<32; i++) {
    d=hcloud(p);
    if(d<.001||d>10)
      break;
    p+=rd*d;
  }
  
  if(d<.001){
      c+=vec3(cloud);
  }
  
  out_color=vec4(c,1);
}