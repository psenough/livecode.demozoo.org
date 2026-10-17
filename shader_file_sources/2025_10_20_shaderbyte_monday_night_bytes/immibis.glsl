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
float mmod(float a, float b) {
  return mod(a+b/2, b)-b/2;
}
float sdf(vec3 pos) {
  pos -= vec3(0,0,50);
  rotate(pos.xz, fGlobalTime*1.1);
  rotate(pos.yz, fGlobalTime+0.5);
  pos.x = mmod(pos.x, 20);
  pos.z = mmod(pos.z, 20);
  rotate(pos.xz, fGlobalTime*3);
  pos.y = mmod(pos.y, 20);
  return sdfAnticube(pos, 1);
}
float sdf2(vec3 pos) {
  pos.x = mmod(pos.x, 20);
  pos.y = mmod(pos.y, 20);
  rotate(pos.xy, fGlobalTime*1.5);
  pos.z = mmod(pos.z, 20);
  rotate(pos.yz, fGlobalTime*1.2);
  rotate(pos.xz, fGlobalTime*3);
  return sdfCube(pos, 3);
}

vec3 raymarch(vec3 pos, vec3 dir) {
  pos += dir*5;
  bool escaped = false;
  for(int i = 0; i < 50; i++) {
    float sdf_here = sdf(pos);
    if(sdf_here < 0.01) {
      if(!escaped) {
        pos += dir*0.1;
      } else {
        return pos;
      }
    } else {
      pos += dir*sdf_here;
      escaped = true;
    }
  }
  return pos;
}
vec3 raymarch2(vec3 pos, vec3 dir) {
  pos += dir*2;
  bool escaped = false;
  for(int i = 0; i < 50; i++) {
    float sdf_here = sdf2(pos);
    if(sdf_here < 0.01) {
      if(!escaped) {
        pos += dir*0.1;
      } else {
        return pos;
      }
    } else {
      pos += dir*sdf_here;
      escaped = true;
    }
  }
  return pos;
}

vec4 mandelbrot(vec2 c) {
  vec2 z = c;
  for(int i = 0; i < 30; i++) {
    z = vec2(z.x*z.x-z.y*z.y,sin(fGlobalTime)*z.x*z.y)+c;
    if(length(z) > 2) {
      return vec4(float(i)/10.0,0,0,1);
    }
  }
  return vec4(abs(z),0,0);
}

void main(void)
{
  vec2 c = gl_FragCoord.xy/v2Resolution;
  c-=0.5;
  vec2 c_ = c*2;
  //c/=1+0.5*sin(fGlobalTime);
  //c = vec2(atan(c.x,c.y)/3.14159/2,length(c));
  c+=0.5;
  float t1 = texture(texFFTIntegrated,0.01).x;
  
  int variant = int(fGlobalTime) % 3;
  
  if(variant == 0) c -= 0.5;
  ivec2 munchc = ivec2(c*40);
  //munchc.x += int((munchc.y-16) * (texture(texFFT,0.01).x-0.1)*5);
  //float munch = (munchc.x & int(fGlobalTime*7)) ^ (munchc.y | int(fGlobalTime*4)) - int(fGlobalTime*2);
  int munch = munchc.x ^ munchc.y;
  if(variant != 2) munch = munchc.x * munchc.y;
  munch ^= int(fGlobalTime*16);
  //munch += t1;
  out_color = vec4(sin(munch)*0.5+0.5, 1-c.y*0.7, cos(munch)*0.5+0.5, 1);
  if((int(munch) % 7) < 3) {
    vec3 pos = raymarch(vec3(0), vec3(c_, 1));
    out_color = vec4(0.5,0,1.0,0)*(1-length(pos)/100);
  } else {
    vec3 pos = raymarch2(vec3(0), vec3(c_, 1));
    out_color = vec4(0,1,0,1)*(1-length(pos)/100);
    if(out_color.a < 0) {
      //out_color = vec4(1,1,1,1);
      out_color = mandelbrot(c_);
    }
  }
}

















































