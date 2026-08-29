#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texInercia2025;
uniform sampler2D texInercia2025_t;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaBW_t;
uniform sampler2D texInerciaID;
uniform sampler2D texInerciaID_t;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}




float mod1(float f) {
  f = mod(f,1);
  if(f<0) return mod(f+1,1); else return f;
}

void main(void)
{
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  uv.x = abs(uv.x);
  uv.y = abs(uv.y);
  if(uv.x>uv.y) uv=-uv;
  if(uv.x>-uv.y) uv=-uv;
	
  vec2 uvoffset = vec2(sin(fGlobalTime),cos(fGlobalTime))*0.05;
  uv += uvoffset;
  vec2 whichPixel = floor(uv*20);
  vec2 posInPixel = ((uv*20-whichPixel)-0.5)*2.0; // +/- 1
  
  //uv = vec2(whichPixel+0.5)*0.1;
  
  // can be used in combination!
  //uv -= mod(uv, length(uv-3*uvoffset)*0.1);
  //uv -= mod(uv, length(uv-3*uvoffset)*cos(fGlobalTime));
  uv -= mod(uv, length(uv-3*uvoffset)*(0.5+0.5*sin(fGlobalTime)));
  
  // glitch pixels (different versions depending on which is uncommented)
  //whichPixel = floor(uv*20);
  //posInPixel = ((uv*20-whichPixel)-0.5)*2.0; // +/- 1
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = 0;//texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25 + sin(fGlobalTime);

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = 1-(f + t);
  
  vec2 pspos = whichPixel;
  rotate(pspos, fGlobalTime*0+cos(fGlobalTime/10)*20);
  float pixelSize = pow(0.5 + 0.4*sin(pspos.x*0.3 + fGlobalTime*3), 2.0) + texture(texFFTSmoothed,pspos.x).x*30/pspos.x;
  pixelSize += abs(fract(pspos.x))*0.5 - abs(fract(pspos.y))*0.5;
  //pixelSize *= fract(pspos.x)+1.0;
  pixelSize = min(1, pixelSize);
  //pixelSize = 1-(1-pixelSize)*(1-texture(texFFTSmoothed, pspos.x).x*100);
  //if(pixelSize < 0) {out_color=vec4(1);return;}
  if(length(posInPixel) > pixelSize) {
    //out_color = texture(texInercia2025, gl_FragCoord.xy/v2Resolution*vec2(1,-1));
    //out_color = 1-out_color;
    out_color.rgb = out_color.brg;
  }
}
















































