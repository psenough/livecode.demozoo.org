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

float randomi(int i) {
  i ^= i >> 16;
  i ^= i * 634729823;
  i ^= i >> 16;
  i ^= i * 634729823;
  return float(i & 65535) / 65536.0;
}
float random(float f) {
  int i = int(floor(f));
  float a = randomi(i);
  float b = randomi(i+1);
  return a+(b-a)*(f - floor(f));
  //return a;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float modtime = slidestep(texture(texFFTIntegrated, 0.001).x/3, texture(texFFTSmoothed, 0.001).x*3);
  
  //vec4 noise = texture(texNoise, vec2(modtime/100));
  vec2 noise = vec2(random(modtime/3), random(modtime/3 + 56345));
  uv.x += sin(noise.r*6.28)/3*noise.g;
  uv.y += cos(noise.r*6.28)/3*noise.g;
  
  float rot = fGlobalTime - modtime;
  float rotamt = 1;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = pow(max(0, length(uv) + (uv.x*cos(rot) + uv.y*sin(rot))*rotamt), sin(fGlobalTime + modtime)*3+3) * .2;
  float d = m.y;
  

	float f = 0;//texture( texFFTSmoothed, d ).r * 100;
	m.x += fGlobalTime * 0.1;
	m.y += modtime * 0.25 - texture(texFFTSmoothed, 0.01).x;

	vec4 t = plas( m * 3.14, modtime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  
  //out_color += (texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution)-out_color)*0.9;
  //out_color += cget
  
  const int radius = 2;
  ivec2 intcoord = ivec2(gl_FragCoord.xy);
  if((intcoord.x & 1) == 0) {
    vec2 ivel = vec2(uintBitsToFloat(imageLoad(computeTexBack[0], intcoord).x), uintBitsToFloat(imageLoad(computeTexBack[0], intcoord+ivec2(1,0)).x));
    vec2 ipos = vec2(uintBitsToFloat(imageLoad(computeTexBack[1], intcoord).x), uintBitsToFloat(imageLoad(computeTexBack[1], intcoord+ivec2(1,0)).x));
    
    vec4 framecol = texture(texPreviousFrame, ipos*0.5+0.5);
    
    vec2 targetPos = ((gl_FragCoord.xy/v2Resolution)-0.5)*2.0;
    ivel.x += texture(texFFT, targetPos.x).x - texture(texFFT, targetPos.x + 0.01).x;
    //rotate(targetPos, fGlobalTime);
    ivel.x += texture(texFFT, targetPos.y).x - texture(texFFT, targetPos.y + 0.01).x;
    ivel += (targetPos - ipos)*0.01;
    ipos += ivel * fFrameTime * (1 + framecol.b*4) * 10;
    ivel *= pow(0.05, fFrameTime);
    
    if(max(abs(ipos.x), abs(ipos.y)) < 1.0) {
      vec2 framevel = framecol.rg*0.03;
      rotate(framevel, framecol.b+fGlobalTime+targetPos.x+targetPos.y);
      ivel += framevel;
    }
    
    imageStore(computeTex[0], intcoord, floatBitsToUint(ivel.x).xxxx);
    imageStore(computeTex[0], intcoord+ivec2(1,0), floatBitsToUint(ivel.y).xxxx);
    imageStore(computeTex[1], intcoord, floatBitsToUint(ipos.x).xxxx);
    imageStore(computeTex[1], intcoord+ivec2(1,0), floatBitsToUint(ipos.y).xxxx);
    imageAtomicAdd(computeTex[2], ivec2((ipos*0.5+0.5)*v2Resolution.xy), 1);
    
    for(int dx = -radius; dx <= radius; dx++) {
      for(int dy = -radius; dy <= radius; dy++) {
        imageAtomicMax(computeTex[2], ivec2((ipos*0.5+0.5)*v2Resolution.xy)+ivec2(dx,dy), radius+1-max(abs(dx),abs(dy)));
      }
    }
    
  }
  
  //out_color = vec4(0);
  uint particleHere = imageLoad(computeTexBack[2], intcoord).x;
  if(particleHere!=0) {
    float frac = 1-float(particleHere)/(radius+1);
    out_color = min(out_color, vec4(frac));
    //out_color=vec4(0);// else out_color=vec4(0);
  }
}















































