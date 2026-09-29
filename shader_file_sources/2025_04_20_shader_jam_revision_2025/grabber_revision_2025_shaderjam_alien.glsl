#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texTex5;
uniform sampler2D texTex6;
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define iTime fGlobalTime
#define one_bpm 60./175.
#define beat(a) fract(iTime/(one_bpm*a))
mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }
float rng(vec2 p) { return fract(sin(dot(p, vec2(42312.23142, 831234.23124)))*214130.213213); }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float l = 32;
  
  if (beat(l) < 0.2) {
    uv *= 4.0;
  }
  else if (beat(l) < 0.4) {
    uv *= rot(0.4);
  }
  else if (beat(l) < 0.6) {
    if(rng(uv) < 0.5) {
      uv += uv.yx;
    }
    else {
      uv -= uv.yx;
    }
    
  }
  else if (beat(l) < 0.8) {
    uv += beat(4)*0.5*texture(texNoise, vec2(rng(uv) ) ).xx ;
  }
  else {
  uv /= beat(4)*0.5*texture(texLynn, vec2(rng(uv) ) ).xx ;;  
  }
  
  
  
  vec2 ouv = uv;
  vec4 otext = texture(texTex6, uv * beat(2)).aaaa ;
  vec2 uuv = 1-uv ;
  uuv -= 0.5;
  
  uv.x += iTime * 0.1;
  
  vec4 text = vec4(0);
  
  if (beat(8) < 0.5 ) {
    if (beat(4) < 0.5 ) {
      uv.x = iTime * 0.5;
    }
    else {
      uv.y = iTime * 0.5;
    }
    
    text = texture(texTex6, uv ).aaaa ;
  }
  else {
    
    uv.x += beat(2);
    text = texture(texTex6, uv ).aaaa ;
  }
  
  if(beat(16)<  0.5) {
    uv = uuv;
  }
  

  
  // vec2 id = floor(uv * 2.0);
  // vec2 uuv = fract(uv * 2.0);
  
  vec3 color = vec3(0);
  
   
    
   vec2 uv2 = fract(uuv );
  uv2.x += beat(2);
  
  
  
  vec4 lyn = texture(texLynn, uv);
  text = mix(text, lyn, 0.7);
  
  if(beat(8) < 0.5) {
    uv2 = fract(uv2*10);
  }
  
  
  
  vec4 rev = texture( texRevisionBW, uv2  ) ;
  //text = rev;
  
  
  uuv.x += iTime;
  
  
  if (beat(16) < 0.5) {
    text *= rev;
  }
  else {
    text *= 1-rev;
  }
  
  
  
  
  if (beat(2) < 0.5) {
    text -= otext;
  }
  else {
    text *= otext;
  }
  if(beat(4) < 0.5) 
  {
    text = texture(texLeafs, text.xy);
  }
  
  
  
  
  vec4 flyn = vec4(0);
  
  if (beat(16) < 0.8) {
    flyn = texture(texLynn, 1-ouv - 0.5) ;
  }
  else {
    flyn = texture(texAcorn1, 1-ouv - 0.5 - vec2(0.9, 0.2)) ;
  }
  
  
  
  flyn *= step(2.0*(0.5+abs(beat(6)))*length(ouv + vec2(-0.0,0)) - 0.5, 0.05 *rng(rev.xx));
  
  text += mix(flyn, text, beat(2));
  
  
  
  if (beat(2) < 0.5) {
    text += mix(text, fract(flyn * 100.0), 0.5);
  }
  
  
  
  
  
	out_color = vec4(text);
  
}