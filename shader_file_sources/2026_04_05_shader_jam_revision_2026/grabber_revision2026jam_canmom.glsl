#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


float particle_size = 80.0;

void splat(ivec2 UV,vec2 hash) {
  
  for (int i = 0; i < int(particle_size*hash.x); i++) {
    for (int j = 0; j < int(particle_size*hash.x); j++) {
      vec2 sample_location = vec2(i,j)/(particle_size*hash.x);
      if (hash.y > 1.0) {
        imageAtomicAdd(computeTex[0],UV+ivec2(i,j), uint(texture(texDritterLogo,sample_location).r * 2));
      } else {
        imageAtomicAdd(computeTex[0],UV+ivec2(i,j),uint(texture(texRevisionBW,sample_location).r*2));
      }
    }
  }
}

float read(ivec2 UV) {
  return imageLoad(computeTexBack[0],UV).r/32.0;
}

vec2 pcg2d(uvec2 v)
{
    v = v * 1664525u + 1013904223u;

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    return vec2(v)/float(0xffffffffu);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //uv += 0.5;
  
  ivec2 UV = ivec2(gl_FragCoord.xy);
  
  vec2 pixel_hash = pcg2d(UV);
  
  float c = cos(texture(texFFTIntegrated,0.8)*pixel_hash.x).r;
  float s = sin(texture(texFFTIntegrated,0.4)*pixel_hash.y).r;

  
  if (gl_FragCoord.x < 30.0 && gl_FragCoord.y < 30.0) {
    splat(ivec2(v2Resolution * 0.5 * vec2(c+1.0, s+1.0)),pixel_hash+10.0*vec2(texture(texFFT,0.1).r));
  }
  
  vec2 uvr = vec2(c*uv.x + s*uv.y, -s*uv.x + c*uv.y);
  
  vec4 prev = texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution);

	out_color = vec4(vec3(read(UV)),1.0)+prev*0.95*vec4(pixel_hash,0.9,1.0);
}