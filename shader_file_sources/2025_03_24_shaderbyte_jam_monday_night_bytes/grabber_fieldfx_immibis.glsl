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

float pi = 3.14159265358979323846264338;
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

vec2 coord_p2m(vec2 v) { // pixel to mandelbrot
  v -= v2Resolution.xy / 2;
  v /= v2Resolution.yy / 2;
  v.x -= 0.5;
  return v;
}
vec2 coord_m2p(vec2 v) {
  v.x += 0.5;
  v *= v2Resolution.yy / 2;
  v += v2Resolution.xy / 2;
  return v;
}
vec2 coord_xy2uv(vec2 v) {
  return (v - (v2Resolution.xy/2)) / (v2Resolution.yy/2);
}
vec2 coord_uv2xy(vec2 v) {
  return (v * (v2Resolution.yy/2)) + (v2Resolution.xy/2);
}
vec2 mandelstep(vec2 z, vec2 c) {
  //return vec2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c;
  //return vec2(z.x*z.x + 1/(1 + sin(fGlobalTime/2))*z.y*z.y, (cos(fGlobalTime/2)+2)*z.x*z.y) + c;
  
  float fftx = (abs(z.y) + abs(z.x))/200;
  //float fftx = abs(z.x) / 30;
  
  float fftval = texture(texFFTSmoothed, fftx).x*fftx*300;
  fftval *= fftval * 6;
  
  return vec2(z.x*z.x - z.y*z.y, (2 - fftval)*z.x*z.y) + c;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  vec2 c = coord_p2m(gl_FragCoord.xy);
  
  vec2 z = c;
  //int iterCount = int(mod(fGlobalTime, pi*2)/pi*25) + 5;
  int iterCount = 20;
  if(ivec2(gl_FragCoord.xy) == ivec2(0,0)) {
    imageStore(computeTex[1], ivec2(0,0), uvec4(iterCount));
    return;
  }
  for(int i = 0; i < iterCount; i++) {
    z = mandelstep(z, c);
    imageAtomicAdd(computeTex[0], ivec2(coord_m2p(z)), 1);
    if(length(z) > 2) {
      break;
    }
  }
  
  
  
  
  float intens;
  
  if(true) {
    vec3 pos = vec3(0, 0, 1.3);
    vec2 uvhere = coord_xy2uv(gl_FragCoord.xy);
    rotate(pos.xz, fGlobalTime/3);
    rotate(pos.yz, fGlobalTime/2+0.3);
    
    vec3 lookdir = normalize(-pos);
    vec3 lookx = normalize(cross(lookdir, vec3(0, 1, 0)));
    vec3 looky = normalize(cross(lookdir, lookx));
    vec3 step_ = (lookdir + uvhere.x * lookx + uvhere.y * looky) * 0.02;
    if(pos.z > 0) pos *= (1 + pos.z*0.6);
    
    float accum = 0;
    for(int i = 0; i < 200; i++) {
      vec2 querypixel = coord_uv2xy(vec2(pos.z, length(pos.xy)));
      float query = float(imageLoad(computeTexBack[0], ivec2(querypixel)).x);
      //accum += query;
      accum = max(accum, query);
      //accum += sqrt(query);
      pos += step_;
    }
    //accum /= 3;
    
    {
      // starfield using the lower bits of the density buffer as a noise pattern
      uint starval = imageLoad(computeTexBack[0], ivec2(mod(pos.x/8, 1)*v2Resolution.x, 0)).x;
      if((starval & 1) == 0) accum += 16; // this doesn't seem to be doing what it says it does, but it still looks random
    }
    
    //intens = log(accum+3)/10;
    intens = sqrt(accum / 300);
  } else {
    // 2D
    uint prevIterCount = imageLoad(computeTexBack[1], ivec2(0,0)).x;
    
    // transformation of the whole image is done by transforming how we reead from the compute buffer
    vec2 uvhere = coord_xy2uv(gl_FragCoord.xy);
    vec2 queryuv = uvhere;
    //rotate(queryuv, texture(texFFTIntegrated, 0.001).x*0.5);
    //queryuv *= (1 + cos(texture(texFFTIntegrated, 0.002).x)/5);
    //queryuv.x *= 1 + queryuv.y * cos(texture(texFFTIntegrated, 0.002).x);
    //queryuv = max(min(queryuv, vec2(0.999)), vec2(-0.999));
    
    //rotate(queryuv, length(queryuv)*cos(fGlobalTime*0.1)*3);
    
    uint count = imageLoad(computeTexBack[0], ivec2(coord_uv2xy(queryuv))).x;
    
    
    //if(length(mandelstep(c, c)) < 2 && count > 0) count--;
    
    intens = count / (float(prevIterCount));
  }
  float intens_local = intens;
  
  vec2 uv = coord_xy2uv(gl_FragCoord.xy);
  // inverse feedback transform here
  uv *= 0.8;
  rotate(uv, texture(texFFTSmoothed, 0.001).x*0.3*sin(fGlobalTime*pi));
  //float prev = imageLoad(computeTexBack[1], ivec2(gl_FragCoord)).x / 65536.0;
  float prev = imageLoad(computeTexBack[1], ivec2(coord_uv2xy(uv))).x / 65536.0;
  intens += (prev-intens)*0.99;
  imageStore(computeTex[1], ivec2(gl_FragCoord), uvec4(intens * 65536.0));
  
  vec3 colour = vec3(intens_local, intens, intens_local);
  if(true) colour *= mat3(
    sin(fGlobalTime), cos(fGlobalTime), 1-sin(fGlobalTime)-cos(fGlobalTime),
  cos(fGlobalTime), 1-sin(fGlobalTime)-cos(fGlobalTime), sin(fGlobalTime),
  1-sin(fGlobalTime)-cos(fGlobalTime), sin(fGlobalTime), cos(fGlobalTime)
  )*0.5+0.5;
  else colour = vec3(prev, intens, intens_local);
  
  out_color.r = intens_local;
  out_color.g = intens;
  out_color.b = intens;
  out_color.rgb = colour;
  
  //if((7int(gl_FragCoord.y / 8) + int(gl_FragCoord.x / 4)) % 8 != int(mod(fGlobalTime, 0.25) * 32)) {
  //  out_color = texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy);
  //}
}
















































