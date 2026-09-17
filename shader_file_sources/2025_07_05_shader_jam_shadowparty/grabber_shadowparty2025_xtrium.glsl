#version 460 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float map(vec3 p)
{
    p.x += sin(p.z * 0.1 + fGlobalTime) * 4.0;
    p.y += pow(sin(p.z * 0.1 + fGlobalTime), 2.0) * 2.0;
  
    vec3 pp = p;
    pp.xz = mod(pp.xz, 2.) - vec2(1.);
    vec2 cell = floor(pp.xz - p.xz);
    float disp = 1.-rand(cell);
    float size = fract(fGlobalTime - cell.y*1.768);
    disp += size;
    return length(pp - vec3(0.0,disp,0.0)) - (0.1666 - .25 * sin(length(pp - p) * 0.1 + fGlobalTime)) * (1.-size);
}

bool march(inout vec3 p, vec3 rd, out int i, out float dMin)
{
    dMin = 1000.;
    for (i = 0; i < 100; ++i)
    {
      float d = map(p);
      dMin = min(d, dMin);
      if (d < .001)
        return true;
      p += rd * d;
    }
    return false;
}

vec3 sky(vec3 rd)
{
    vec3 rdd = rd;
    rd = floor(rd * (4.0 + 2.0 * fract(fGlobalTime * 4.0)));
    float BASS = texture(texFFT, 0.2).x * 81.0;
   float r = rand(rd.xy + rd.yz + rd.zy + vec2(floor(fGlobalTime * 8.0))) / 1.0;
  float rr = rand(rdd.xy + rdd.yz + rdd.zy * 0.1 + vec2(fGlobalTime*0.0001));
   return vec3(step(0.9, r)*BASS*0.4 + step(0.998, rr));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv.y += 0.1 * sin(uv.x + texture(texFFTSmoothed, 0.15).x * 16.0) * 0.3;
  uv.x += sin(uv.y + fGlobalTime + rand(uv)*0.1)*0.1;
  uv.y += sin(uv.x + fGlobalTime + rand(uv)*0.1)*0.1;

  float fft = texture(texFFT, 0.1).x;
  vec3 ro = vec3(sin(fGlobalTime*0.3)*30.0,5. - texture(texFFTSmoothed, 0.15).x*0.001 ,5. + fGlobalTime * 20.0);
  vec3 rd = normalize(vec3(uv,-1.5) + vec3(0.0,-.5+.1*+fft,0.0));

	out_color = vec4(sky(rd),1.);
     
  float dMin;
  int i;
  vec3 p = ro;
  bool b = march(p, rd, i, dMin);
  float d = distance(p, ro);

  if (b)
    out_color = vec4(fract(d * .1 + fGlobalTime * 0.25) * vec3(0.7, 0.4, 0.3), 1.);
  else
  {
    out_color += vec4(0.1/(0.25+dMin*dMin*10.)*vec4(0.8,0.5,0.65,1.)*sin(dMin) + 0.0501/(.1+dMin * 0.5)*vec4(1.33,0.3,0.8,1.0));
  }
  
  float id = 100.-d;
  out_color.rgb = out_color.rgb + pow(out_color.rgb / (id*id*0.0001), vec3(1./2.2));
  
  float a = floor(((3.14+atan(uv.y, uv.x))/6.28)*16.)/16.;
  float dd = length(uv);
  float aperture = step(dd, fract(fGlobalTime+a));
  out_color = out_color * 0.5 + 0.5 * out_color * vec4(aperture) - (1. - dd*a)*0.1;
}