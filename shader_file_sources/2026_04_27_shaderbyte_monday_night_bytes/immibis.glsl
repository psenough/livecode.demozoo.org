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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float cube_sdf(vec3 pos, float radius) {
  pos = abs(pos);
  return max(max(pos.x,pos.y),pos.z)-radius;
}

float scene_sdf(vec3 pos) {
  vec3 pos_ = pos;
  
  //pos.x += pos.z*sin(fGlobalTime)+(pos.y+pos.x)*pos.y*cos(fGlobalTime*1.1);
  pos.y += sin(pos.x)*fract(fGlobalTime*2.8);
  pos = mod(pos+1, 2)-1;
  float sdf = cube_sdf(pos+vec3(0,0.7,0),0.2);
  
  vec3 pos2 = mod(pos_+1.5, 3)-1.5;
  float sdf2 = length(pos2)-0.3;
  
  float dumbSdf = 100;//sin(pos_.x)+sin(pos.x)+sin(pos2.z+pos_.x)+0.8;
  
  return min(min(sdf, sdf2), dumbSdf);
}

vec3 modelview_pos;
vec3 mv_up, mv_fwd, mv_right;
mat3 mv_rot;

mat2 rot(float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}
void plot(vec3 pos,uint intens) {
  
  //pos = pos.x*mv_right + pos.y*mv_up + pos.z*mv_fwd;
  //pos.xyz = pos.zxy;
  pos -= modelview_pos;
  pos = mv_rot*pos;
  
  pos.y += pos.z*0.4; // hack to force a more downwards angle
  
  //vec3 campos = 
  
  //pos.z -= -10;
  //pos.z = -pos.z;
  
  
  
  //pos.yz *= rot(sin(fGlobalTime*1.3));
  //pos.xz *= rot(cos(fGlobalTime*0.2));
  //pos.xy *= rot(fGlobalTime/2);
  if(pos.z >= 0) {
    vec2 uv;
    /* // orthographic
    uv = pos.xy/30;
    /*/
    uv = pos.xy / pos.z;
    // */
    
    imageAtomicAdd(computeTex[0], ivec2((uv*v2Resolution.yy)+v2Resolution.xy/2), intens);
  }
}
void trace(vec3 pos, vec3 dir) {
  
  for(int i = 0; i < 100; i++) {
    float sdf_ = scene_sdf(pos);
    vec3 prev = pos;
    pos += dir*min(0.3,sdf_);
    if(sdf_ < 0.01) {
      plot(pos,500);
      //out_color = vec4(1,0,0,1); return;
      pos += dir;
      //break;
    }
    plot(pos+(prev-pos)*fract(fGlobalTime*2.4),1);
  }
}
void main(void)
{
  
  modelview_pos = vec3(sin(fGlobalTime)*6, cos(fGlobalTime)*5, sin(fGlobalTime*0.4)*10+30);
  //modelview_pos = vec3(50,0,sin(fGlobalTime)*10+15);
  
  mv_fwd = -normalize(modelview_pos);
  mv_right = normalize(cross(mv_fwd, vec3(1,0,1)));
  mv_up = normalize(cross(mv_right, mv_fwd));
  mv_rot = mat3(mv_right, mv_up, mv_fwd);
  mv_rot = inverse(transpose(mv_rot));
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	//uv *= vec2(v2Resolution.x / v2Resolution.y, 5);
  
  trace(vec3(0,0,0), normalize(vec3(uv,0.1)));
  //trace(vec3(uv*60,0), normalize(vec3(uv*0.1,1)));
  //trace(vec3(uv*30,50), normalize(vec3(uv*0.1,-1)));
  
  //uv = abs(uv);
  uv += 0.5;
  uv *= v2Resolution.xy;
  out_color = vec4(imageLoad(computeTexBack[0], ivec2(uv)).xxxx*0.001);
}
