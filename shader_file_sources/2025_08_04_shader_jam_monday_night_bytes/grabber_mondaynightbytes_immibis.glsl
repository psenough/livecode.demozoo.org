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



// UTILITIES
void cput(ivec2 pixel, uvec3 value) {
  imageStore(computeTex[0], pixel, value.xxxx);
  imageStore(computeTex[1], pixel, value.yyyy);
  imageStore(computeTex[2], pixel, value.zzzz);
}
uvec3 cget(ivec2 pixel) {
  return uvec3(imageLoad(computeTexBack[0], pixel).x, imageLoad(computeTexBack[1], pixel).x, imageLoad(computeTexBack[2], pixel).x);
}
void cputf(ivec2 pixel, vec3 value) {cput(pixel, uvec3(value * 65536.0));}
vec3 cgetf(ivec2 pixel) {return vec3(cget(pixel)) / 65536.0;}
void cputff(vec2 coord, vec3 value) {cputf(ivec2(coord * v2Resolution.yy/2 + v2Resolution.xy/2 + 0.5), value);}
void rotate(inout vec2 v, float a) {v = vec2(v.x*cos(a)+v.y*sin(a), v.y*cos(a)-v.x*sin(a));}
float slidestep(float f, float fraction) {float i=floor(f); f-=i; if(f<fraction) f/=fraction; else f=1.0; return i+f;}

// SDFs
float sdfCube(vec3 pos, float radius) {
  return max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-radius; // not accurate
}
float sdfAnticube(vec3 pos, float radius) {
  pos = abs(pos);
  return max(max(min(pos.x,pos.y), min(pos.x, pos.z)), min(pos.y, pos.z))-radius; // not accurate
  // how to exclude one dimension
  //return max(max(min(pos.x,pos.y), min(pos.x, pos.z)), pos.y)-radius;
}
float sdfSphere(vec3 pos, float radius) {
  return length(pos) - radius;
}
//vec3 reflect(vec3 v, vec3 normal) {return v - 2*dot(v,normal)*normal;} // GLSL builtin but here's the formula

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
vec3 campos;
void plot(vec3 v) {
  v.y /= 2;
  //rotate(v.xz, -fGlobalTime/2);
  //rotate(v.xz, fGlobalTime);
  //rotate(v.xy, fGlobalTime/3);
  v -= campos;
  if(v.z < 0) return;
  v.xy /= v.z;
  //rotate(v.xy, fGlobalTime);
  
  ivec2 iv = ivec2(v.xy * v2Resolution.yy/2 + v2Resolution.xy/2);
  imageAtomicAdd(computeTex[0], iv, 1);
}

float sdf(vec3 pos) {
  vec3 pos_ = pos;
  rotate(pos_.xy, fGlobalTime);
  float best = 9999;//min(length(pos_.xz), length(pos_.yz)) - 0.5;
  pos.y += 2;
  
  for(int j = 0; j < 3; j++) {
    pos = mod(pos, 8)-4;
    pos = abs(pos);
    //pos.x += pos.z*cos(fGlobalTime);
    //pos.y += pos.x*sin(fGlobalTime);
    //rotate(pos.xy, fGlobalTime);
    rotate(pos.xz, fGlobalTime/1.5+0.5);
    rotate(pos.xy, fGlobalTime/4.0+1.0);
    float x = sdfAnticube(pos-vec3(0,0,-1), 0.5);
    //x = mix(x, sdfSphere(pos-vec3(0,0,-1), 0.5), (1-abs(sin(fGlobalTime/2)))*0.5)+2*x;
    best = min(x, best);
  }
  return best;
}

void raymarch(vec3 pos, vec3 dir) {
  pos += dir*2;
  bool escaped = false;
  for(int i = 0; i < 50; i++) {
    float sdf_here = sdf(pos);
    if(sdf_here < 0.01) {
      if(!escaped) {
        pos += dir*0.1;
      } else {
        plot(pos);
        break;
      }
    } else {
      pos += dir*sdf_here;
      escaped = true;
    }
  }
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	//if(texture(texFFTSmoothed, uv.x).x*uv.x*100 > uv.y) {out_color = vec4(0,1,0,0); return;}
  
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 dir = normalize(vec3(uv,0.5));
  vec3 pos = vec3(0,0,-10);
  
  pos.z += texture(texFFT, 0.001).x*100;
  //pos.x += cos(fGlobalTime*30)*texture(texFFTSmoothed, 0.03).x*5;
  //pos.y += sin(fGlobalTime*30)*texture(texFFTSmoothed, 0.05).x*5;
  
  campos = vec3(0,0,-5);
  //rotate(dir.xz, fGlobalTime);
  //rotate(pos.xz, fGlobalTime);
  for(int i = 0; i < 1; i++) {
    //rotate(dir.xz, 3.1415926/3*2);
    //rotate(pos.xz, 3.1415926/3*2);
  
    raymarch(pos, dir);
  }

  int ivalue = int(imageLoad(computeTexBack[0], ivec2(gl_FragCoord.xy)).x);
  if(ivalue == 0) {out_color=vec4(0);}
  else if(ivalue < 4)
  switch((ivalue-1)%3) {
    case 0: out_color=vec4(1,0,0,0);break;
    case 1: out_color=vec4(0,1,0,0);break;
    default: out_color=vec4(0,0,1,0);break;
  } else {
    float value = 1-1/(float(ivalue)+1);
    out_color = vec4(0,0,value,0);
  }
  
  float a = (texture(texFFTIntegrated, 0.001).x - texture(texFFTIntegrated, 0.03).x*33)*0.3 + uv.x*uv.y*90;
  //float sp = texture(texFFTSmoothed, 0.001).x*300;
  float sp = 1;
  vec4 prev = texture(texPreviousFrame,vec2((gl_FragCoord.xy+vec2(sin(a),cos(a))*sp)/v2Resolution.xy));
  out_color = max(out_color*0.9, out_color+(prev-out_color)*0.98);
}

















































