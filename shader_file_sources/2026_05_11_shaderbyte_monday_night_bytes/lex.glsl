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

float chaos(float n){
  return mod(sin(n)+sin(n*0.5)+sin(n*3)+sin(n*0.3), 1.0);
}

vec4 particle(vec4 col_in, vec2 uv, vec2 init_pos, float size, vec2 vel, float a1, float a2){
  vec4 col = vec4(1.0,1.0,1.0,0.0);
  float dur = abs(init_pos.x*2 / vel.x);
  vec2 pos = init_pos + (vel * mod(fGlobalTime,dur));
  pos += vec2(0.0,(sin(pos.x*a1*10) + sin(pos.x*a2*7))/50);
  vec2 d = uv - pos;
  float sqdist = (d.x*d.x)+(d.y*d.y);
  col.a = clamp(1.0-(sqdist/size), 0.0,1.0);
  return vec4(col_in.rgb + (col.rgb * col.a), 1.0);
}

vec4 particles(vec4 col_in, vec2 uv, float seed){
  vec4 c = col_in;
  float r = seed;
  float f = texture( texFFTSmoothed, 0.05 ).r * 0.1;
  for (int i = 0; i< 20; i++){
    float a1 = chaos(r); r += 1.0;
    float a2 = chaos(r); r += 1.0;
    float a3 = chaos(r); r += 1.0;
    float a4 = chaos(r); r += 1.0;
    float a5 = chaos(r); r += 1.0;
    float a6 = chaos(r); r += 1.0;
    c = particle(c, uv, vec2(1.0 + (a1),-0.5+(a4*1.0)), f+a2*0.002, vec2(-0.2-a3*0.6,0), a5, a6);
  }
  return c;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	float f = texture( texFFTSmoothed, 0.15 ).r * 60;
  float f2 = texture( texFFTSmoothed, 0.01 ).r * 1;
  float f3 = texture( texFFTSmoothed, 0.05 ).r * 1;
  
  float sqdist = (uv.x*uv.x) + (uv.y*uv.y);
  vec2 uv2 = uv + vec2(-2.0 + mod(fGlobalTime, 4.0),0.0);
  float sqdist2 = (uv2.x*uv2.x) + (uv2.y*uv2.y);

	out_color = clamp(f,0.0,1.0) * vec4(0.7,0.4,0.4,1);
  if ((uv.y-0.1-f3) < (sin(uv.x*10 + (fGlobalTime*3.6))/20)){
    out_color += vec4(0.3,0.0,0.0,0.0);
  }
  if ((uv.y+0.4-f2) < (sin(uv.x*7 + (fGlobalTime*2.8))/20)){
    out_color += vec4(0.3,0.0,0.0,0.0);
  }
  
  float seed = 0.0;
  out_color = particles(out_color, uv, seed);
  
  if (sqdist < 0.1){
    out_color = vec4(1.0,1.0,1.0,1.0) * clamp((1.0-(sqdist2*4)),0.0,1.0);
    out_color.r = (sin(uv.x*20+fGlobalTime*1.5)+sin(uv.x*77 + fGlobalTime)) * sin(uv.y*47 +(fGlobalTime*2));
    out_color.g = (sin(uv.x*26+fGlobalTime*1.7)+sin(uv.x*107 + fGlobalTime)) * sin(uv.y*47 +(fGlobalTime*2));
  }
  
  seed += 999.9;
  out_color = particles(out_color, uv, seed);
}
