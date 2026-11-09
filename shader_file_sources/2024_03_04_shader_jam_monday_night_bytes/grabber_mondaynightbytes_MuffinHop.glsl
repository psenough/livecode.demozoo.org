#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
//can you see the sun shinin on me
//it makes me feel so free so alive
//it makes me want to survive
//and the sky it makes me feel so high
//the bad tiems pass me by
//cause today is gonna be a brighter day
//can you feel the sunshine
//does it brighten up your day
//don't you feel that sometimes
//you just neeed to run away?
#define TAU 6.283185
#define A 1.0
#define B 1.9
vec3 WHITE = vec3(1.0);
vec3 RED = vec3(0.698,0.132,0.203);
vec3 BLUE = vec3(0.234,0.233,0.430);
float random(vec2 coordinate) {
  return fract(sin(dot(coordinate.xy,vec2(12.9898,78.233))) * 43758.5453);
}
float RoundedBox(vec2 point, vec2 center, vec2 size) {
  return length(max(abs(point - center) - size,0.0));
}
mat2 rotate(float Angle) {
  mat2 rotation = mat2(
  vec2(cos(Angle),sin(Angle)),
  vec2(-sin(Angle),cos(Angle)));
  return rotation;
}
float starPlane(vec2 pos, float shift, int i, float pixelSize) {
  float angle = TAU/5.0*float(i);
  vec2 a = vec2(cos(angle),sin(angle));
  vec2 n = vec2(a.y,-a.x);
  return clamp((dot(pos-a,n)+shift)/(A*pixelSize)+0.5,0.0,1.0);
}
float star(vec2 pos, float radius, float pixelSize) { 
  float shift = 0.25*(sqrt(5.0)-1.0)*radius;
  float total = 
  starPlane(pos,shift,0,pixelSize) + 
  starPlane(pos,shift,1,pixelSize) + 
  starPlane(pos,shift,2,pixelSize) + 
  starPlane(pos,shift,3,pixelSize) +
  starPlane(pos,shift,4,pixelSize); 
  return clamp(total-3.0,0.0,1.0);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float aspectratiocorrection = (v2Resolution.x/v2Resolution.y);
  uv = 2.0*uv -1.0;
  uv.x *= aspectratiocorrection;
  vec4 result;
  vec4 final = vec4(0.0);
  float f = (texture(texFFT, 0.7).r-0.5) * 0.2 + sin(fGlobalTime)*0.2;

  for(float colorIndex = 0.0; colorIndex < 2.0; colorIndex++) {
    vec2 coordinate = uv;
    coordinate.x *= 1.0 + colorIndex * 0.009;
    result.rgb = vec3(140.0/255.0,110.0/255.0,135.0/255.0);

    vec2 funny = vec2(-0.0,0.0);
    vec2 coordinate2 = coordinate;
    coordinate2.x -= 0.8;
    coordinate2 *= rotate(fGlobalTime*0.1);
    result.rgb = mix(result.rgb, vec3(0.0), star(coordinate2+funny,1.9,0.004));
    result.rgb = mix(result.rgb, BLUE, star(coordinate2+funny,1.6,0.004));
    result.rgb = mix(result.rgb, WHITE, star(coordinate2+funny,1.4,0.004));
    
    coordinate.x += 0.766;
    coordinate *=rotate(sin(fGlobalTime*2.0/3.0)/3.0);
    coordinate *=1.333;
    
    
    //ears
    if(RoundedBox(coordinate, vec2(0.0,0.6), vec2(0.2)) < 0.2)
       result.rgb = vec3(1.,.6,.0);
    if(RoundedBox(coordinate,vec2(-0.9,0.6),vec2(0.2))<0.2)
      result.rgb = vec3(1.,.6,.0);
    
    //head
    if (RoundedBox(coordinate,vec2(0.0), vec2(.7))<0.2)
      result.rgb = vec3(1.0,0.6,0.0) *floor(mod(coordinate.x + coordinate.y + fGlobalTime,1.0) + .4);
    if(RoundedBox(coordinate,vec2(0.0),vec2(.5))<0.2)
      result.rgb = vec3(1.,.6,.0);
    
    //nuzzle
    if(RoundedBox(coordinate,vec2(0.4,-0.4),vec2(.2))<0.2)
      result.rgb = vec3(1.,.8,.6);
    
    //eyes
    if(RoundedBox(coordinate,vec2(0.5,0.3), vec2(.1))<0.2)
      result.rgb =vec3(1.);
    if(RoundedBox(coordinate,vec2(-0.5,0.3),vec2(.2))<0.2)
      result.rgb=vec3(1.0);
    if(RoundedBox(coordinate,vec2(0.5+f,0.3),vec2(.012))<0.12)
      result.rgb=vec3(0.0);
    if(RoundedBox(coordinate,vec2(-0.5+f,0.3),vec2(0.012))<0.12)
      result.rgb=vec3(0.0);
    
    //teeth
    if(RoundedBox(coordinate,vec2(0.6,-0.725),vec2(0.10,0.11))<0.03112)
      result.rgb=vec3(0.0);
    if(RoundedBox(coordinate,vec2(0.6,-0.725),vec2(0.08,0.10))<0.03112)
      result.rgb=vec3(1.0);
    if(RoundedBox(coordinate,vec2(0.6,-0.724),vec2(0.001,0.12))<0.00412)
      result.rgb=vec3(0.0);
    
    //mouth
    if(RoundedBox(coordinate,vec2(0.49,-0.6),vec2(0.3,0.012))<0.0112)
      result.rgb=vec3(0.0);
    result.rgb = result.rgb - vec3(min(max(-0.35 + length(coordinate) * 0.31,0.0),1.0)) +
                vec3(0.16 *random(vec2(coordinate.x + coordinate.y, 1.01*coordinate.y * coordinate.x)));
  }
	//float f = texture( texFFT, uv.x ).r * 100.0;
	out_color = result;
}








































