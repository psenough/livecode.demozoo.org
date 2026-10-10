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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}
float octa(vec3 pos, float rad) {
  return (abs(pos.x)+abs(pos.y)+abs(pos.z)-rad)*0.5773; // iq inexact
  //return max(abs(pos.x),max(abs(pos.y),abs(pos.z)))-rad;
}
int material;
float sdf_octa(vec3 pos) {
  if(true){ 
    pos.xy *= rot(fGlobalTime*0.1);
    pos.xz *= rot(fGlobalTime*0.3);
  }
  return octa(pos, 1);
}
float sdf_bg(vec3 pos) {
  pos.x += fGlobalTime*3.5;
  float radius = 2;
  
  float spacing = 1.5;
  float movedir = mod(pos.x,spacing);
  
  float sdf = min(radius-abs(pos.y), radius-abs(pos.z));
  
  if(sdf < -0.3) return 1000; // past outer radius
  
  if(movedir > 0.5) sdf = max(sdf, spacing - movedir);
  
  return sdf;
}
float sdf_bg2(vec3 pos) {
  pos.zy *= rot(3.14159/4);
  pos.x += fGlobalTime;
  float radius = 5;
  
  float spacing = 3.2;
  float movedir = mod(pos.x,spacing);
  
  float sdf = min(radius-abs(pos.y), radius-abs(pos.z));
  
  if(sdf < -0.3) return 1000; // past outer radius
  
  if(movedir > 0.5) sdf = max(sdf, spacing - movedir);
  
  return sdf;
}
float combine_sdf(float accum, float newval, int materialID) {
  if(newval < accum) {
    material = materialID;
    return newval;
  }
  return accum;
}
float sdf(vec3 pos) {
  float sdf = 999999;
  sdf = combine_sdf(sdf, sdf_octa(pos), 0);
  sdf = combine_sdf(sdf, sdf_bg(pos), 1);
  sdf = combine_sdf(sdf, sdf_bg2(pos), 2);
  return sdf;
}
vec3 norm(vec3 pos) {
  // deliberately blurry normal
  vec2 d = vec2(0.05,0);
  pos -= d.xxx/2;
  
  return (vec3(
    sdf(pos+d.xyy), sdf(pos+d.yxy), sdf(pos+d.yyx)
  )-sdf(pos))/d.x;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void add_colour(vec4 a) {
  a = clamp(a,0,1);
  //a.r = max(a.r, 0);
  //a.r = min(a.r, 1);
  //a.a = max(a.a, 0);
  //a.a = min(a.a, 1);
  
  a.rgb *= a.a;
  
  out_color.rgb += a.rgb*(1-out_color.a);
  //out_color.rgb += (a.rgb-out_color.rgb)*a.a*(1-out_color.a);
  out_color.a = (1-out_color.a)*(1-a.a);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  out_color = vec4(0);
  
  vec3 pos = vec3(0,0,-4);
  vec3 step_ = normalize(vec3(uv*3,1));
  if(true){
    float f = 0.4;
    pos.xy *= rot(cos(fGlobalTime)*f);
    pos.xz *= rot(sin(fGlobalTime*0.7)*f+1.5);
    step_.xy *= rot(cos(fGlobalTime)*f);
    step_.xz *= rot(sin(fGlobalTime*0.7)*f+1.5);
  }
  vec4 col = vec4(0);
  for(int i = 0; i < 100; i++) {
    float sdfHere = sdf(pos);
    pos += step_*sdfHere;
    if(sdfHere < 0.01) {
      //if(material == 1) {out_color = vec4(0,0,1,1); return;}
      if(material == 1) {
        add_colour(vec4(0,1,0.5,0.3));
        //break;
      } else {
        add_colour(vec4(1,0,0,0.15));
      }
      
      vec3 normHere = norm(pos);
      step_ = reflect(step_, normHere);
      pos += step_;
      /*for(int j = i; j < 100; j++) {
        pos += step_;
        if(length(pos) >= 10000) break;
      }
      //out_color=vec4(pos,1);return;
      break;
      */
    }
    if(length(pos) >= 10000) break;
  }
  
  // direction of travel is X
  vec3 p2 = normalize(pos);
  vec3 p3 = pos/max(abs(pos.y),abs(pos.z));
  
  float c = 1;//pow(sin((p3.x+fGlobalTime)*15),3);
  if(mod(p3.x+fGlobalTime,1)<0.2) {
    add_colour(vec4(vec3(2/abs(p3.x)),1));
  }
}

