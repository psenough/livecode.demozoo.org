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
#define PI 3.1415927
float roundBox(vec2 coord, vec2 pos, vec2 b, float c) {
  return min(
            max(
                1.0 - floor(length(max(abs(coord - pos) - b, c))),0.0),1.0);
}
float circle(vec2 coord, vec2 pos, float size) {
  return -min(floor(distance(coord,pos)-size),0.0);
}
float capsule(vec2 coord, vec2 a, vec2 b, float r) {
   vec2 pa = coord - a, ba = b - a;
   float h = clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
   return max(-min(floor(length(pa-ba*h)-r),1.0),0.0);
}
mat2 rotate(float angle){
  mat2 rotate = mat2(
  vec2(cos(angle),sin(angle)),
  vec2(-sin(angle),cos(angle)));
  return rotate;
}

  float hexacon(vec2 coord, vec2 pos, float size, float thickness) {
    coord -= pos;
    float COLOR = 0.0;
    COLOR += 2.0 * capsule(coord, vec2(0.33,-0.53)*size, vec2(-0.33,-0.53)*size, thickness);
    COLOR += 2.0 * capsule(coord, vec2(0.33,-0.53)*size, vec2( 0.66, 0.0)*size, thickness);
    COLOR += 2.0 * capsule(coord, vec2(0.33, 0.53)*size, vec2( 0.66, 0.0)*size, thickness);
    COLOR += 2.0 * capsule(coord, vec2(0.33, 0.53)*size, vec2(-0.33, 0.53)*size, thickness);
    COLOR += 2.0 * capsule(coord, vec2(-0.33, 0.53)*size, vec2(-0.66, 0.0)*size, thickness);
    COLOR += 2.0 * capsule(coord, vec2(-0.33,-0.53)*size, vec2(-0.66, 0.0)*size, thickness);
    return min(max(COLOR,0.0),1.0);
  }
#define PALETTE_0 vec3(1.0,0.8,0.5)
#define PALETTE_1 vec3(0.2,0.6,0.6)
#define PALETTE_2 vec3(0.0,0.0,0.0)
#define PALETTE_3 vec3(1.0,1.0,1.0)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float vignette = 1.0 / max(0.25 + 1.5*dot(uv,uv),1.0);
  
  vec3 col = PALETTE_1;
  //if time add grid here
  if(mod(uv.y*400.0+uv.x*400,8.0)<1.1) {
    col -= vec3(0.05);
  }else if(mod(uv.y*400.0-uv.x*400,8.0)<1.1) {
    col -= vec3(0.05);
  }
  vec2 pp = uv;
  pp *= 10.0;
  pp.x = mod(pp.x,1.0) - 0.5;
  pp.y = mod(pp.y,1.0) - 0.5;
  float big = 0.0;
  big = capsule(pp,vec2(-0.15,-0.15), vec2(0.15,0.15), 0.05);
  big += capsule(pp,vec2( 0.15,-0.15), vec2(-0.15,0.15), 0.05);
  big = min(max(big,0.0),1.0);
  col -= big*0.2;
  for(float i=0.0;i<8.0; i++) {
    
    vec2 coord = uv + vec2(sin(i*3.0),0.5-(0.6+sin(i)*0.2)*abs(sin(i+fGlobalTime)));
    coord *= 0.9 + sin(i) * 0.5 + texture(texFFTSmoothed,0.2).x*100.0; 
    
    //rotate here
    coord *= rotate(sin(fGlobalTime*9.0)/12.0);
    
    col = mix(  col,  PALETTE_2, roundBox( coord * 12.0, vec2(0.0,0.0), vec2(3.40,0.4), 0.13));
    col = mix(  col,  PALETTE_2, roundBox( coord * 12.0, vec2(2.0,0.9), vec2(0.24,1.2), 0.1));
    col = mix(  col,  PALETTE_2, roundBox( coord * 12.0, vec2(-2.0,0.9), vec2(0.24,1.2), 0.1));
    
    col = mix(  col,  PALETTE_0, roundBox( coord * 12.0, vec2(0.0,0.0), vec2(3.20,0.2), 0.13));
    col = mix(  col,  PALETTE_0, roundBox( coord * 12.0, vec2(2.0,0.9), vec2(0.04,1.0), 0.1));
    col = mix(  col,  PALETTE_0, roundBox( coord * 12.0, vec2(-2.0,0.9), vec2(0.04,1.0), 0.1));
    
    
    col = mix(col, PALETTE_2, circle(coord,vec2(0.17,0.0),0.02));
    col = mix(col, PALETTE_2, circle(coord,vec2(-0.17,0.0),0.02));
    col = mix(col, PALETTE_2, capsule(coord,vec2(0.0,-0.04),vec2(0.0,-0.08),0.01));
    coord.y += cos(coord.x*12.0)*0.04;
    col = mix(col, PALETTE_2, capsule(coord,vec2(-0.04,0.0), vec2(0.04,0.0),0.01));
    
  }
  float t = fGlobalTime * 0.1;
  vec2 s = uv * (1.0 + sin(t+uv.x*1.5+uv.y*0.8)*0.4);
  s += vec2(t*4.0,t*2.2);
  s.x = mod(s.x+floor(s.y)*0.5,1.)-0.5;
  s.y = mod(s.y,1.0)-0.25;
    col = mix(  col,  PALETTE_3, hexacon( s, vec2( 0.0,0.0), 0.3, 0.02));
    col = mix(  col,  PALETTE_3, hexacon( s, vec2( 0.5,0.333), 0.3, 0.02));
    col = mix(  col,  PALETTE_3, hexacon( s, vec2(-0.5,0.333), 0.3, 0.02));
  col += capsule(s,vec2(-0.15,-0.15), vec2(0.15,0.15), 0.05) * 100.0;
  col += capsule(s,vec2( 0.15,-0.15), vec2(-0.15,0.15), 0.05) * 100.0;
	out_color = vec4(col*vignette,1.0);
}