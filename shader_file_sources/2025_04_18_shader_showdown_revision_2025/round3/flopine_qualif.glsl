#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
//  coucou ) 0) 

#define read(n, u) imageLoad(computeTexBack[n], u).x
#define write(n, u, c) imageStore(computeTex[n], u , ivec4(c))

#define hash21(u) fract(sin(dot(vec2(164.6, 236.1), u))*1635.7)

float truchetloul (vec2 uv)
{
    vec2 id = floor(uv);
    uv = fract(uv)- .5;
    uv.x *= (hash21(id*.27) > .5) ? 1. : -1;
  float s = (uv.x > -uv.y) ? 1.:-1;
  
    uv -= .5*s;
    return step(abs(length(uv)-.5), 0.1);
}

float neigh (ivec2 pi)
{
    float n = 0.;
    n += read(0, pi+ivec2(-1, -1));
  n += read(0, pi+ivec2(0, -1));
  n += read(0, pi+ivec2(1, -1));
  n += read(0, pi+ivec2(-1, 0));
  n += read(0, pi+ivec2(1, 0));
  n += read(0, pi+ivec2(-1, 1));
  n += read(0, pi+ivec2(0, 1));
  n += read(0, pi+ivec2(1, 1));
  
  return n;
}
#define hr vec2(1.,sqrt(3.))
vec4 hgrid(vec2 uv)
{
    vec2 ga = mod(uv, hr)-hr*.5, gb=mod(uv-hr*.5, hr)-hr*.5, guv=dot(ga,ga)<dot(gb,gb)?ga:gb, gid=uv-guv;
  return vec4(guv, gid);
}

float hex(vec2 p)
{
  p = abs(p);
  return  max(p.x, dot(p, normalize(hr)));
  }

void alive (float st, float nei, ivec2 pi)
{
    if (st == 1.)
    {
       if (nei<2. || nei>3.) st = 0;
    }
    else
    { 
      if (nei == 3) st = 1;
    }
    
    write(0, pi, st);
}

#define time mod(fGlobalTime, 5)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ivec2 pix = ivec2(gl_FragCoord.xy);
   if (time < .1)
   {
     vec4 hg = hgrid(uv);
    float st = mix(truchetloul(uv*30.), step(abs(hex(hgrid(uv*50.).xy)-.4), .05), ceil(sin(fGlobalTime)));
     //st = step(abs(hex(hgrid(uv*50.).xy)-.4), .05);
     st += texture(texFFT, abs(uv.x)+abs(uv.y)).x*2.;
     write(0, pix, st);
     return;
   }
   
   float cur = read(0, pix);
   float n = neigh(pix);
   alive(cur, n, pix);
   
  out_color = vec4(texture(texPreviousFrame, vec2(gl_FragCoord.xy/v2Resolution)+0.001).r,
texture(texPreviousFrame, vec2(gl_FragCoord.xy/v2Resolution)).g,
texture(texPreviousFrame, vec2(gl_FragCoord.xy/v2Resolution)-0.001).b,
1.)  *.92 ;
   out_color += vec4(read(0, ivec2(pix*.5))); 
}