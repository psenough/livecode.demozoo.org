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
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
// BONJOURHAAAAAAAAN

vec3 read (ivec2 pix)
{
  float px = imageLoad(computeTexBack[0], pix).x / 1000.;
  float py = imageLoad(computeTexBack[0], pix+ ivec2(0, 400)).x / 1000.;
  float a = imageLoad(computeTexBack[1], pix).x / 1000.;
  return vec3 (px, py,a );
}

void write (ivec2 pix, vec3 v)
{
  imageStore(computeTex[0], pix, ivec4(v.x * 1000.));
  imageStore(computeTex[0], pix + ivec2(0, 400), ivec4(v.y * 1000.));
  imageStore(computeTex[1], pix, ivec4(v.z * 1000.));
}

void trailw (ivec2 pix, float f)
{imageStore(computeTex[2], pix, ivec4(f * 1000.));}

float trailr (ivec2 pix)
{return imageLoad(computeTexBack[2], pix).x /1000.;}

#define width int(v2Resolution.x)
#define height int(v2Resolution.y)

#define time fGlobalTime
#define PI acos(-1.)
#define speed 2.
#define dR 0.9
#define dcR 0.02
#define so 5.
#define aspace (17. * PI/180)
#define tspeed (0.1 *2. * PI)

float hash (float p)
{
  p = fract(p*0.1344);
  p *= p+33.33;
  p *= p+p;
  return fract(p);
}

void diff (ivec2 p)
{
  float mean = 0.;
  float o = trailr(p);
  for (int i=-1; i<=1; i++)
  {
      for (int j=-1; j<=1; j++)
      {
        mean += trailr(p + ivec2(i,j));
      }
  }
  mean /= 9;
  float nc = mix(o, mean, dR);
  if (time < 0.1)
  {
    trailw(p, 0);
  }
  else
  {
    trailw(p, max(0, nc - dcR));
  } 
}

float sense (vec3 data, float ao)
{
  float na = data.z + ao;
  vec2 dir = vec2(cos(na), sin(na));
  vec2 np = data.xy + dir * so;
  float sum = 0.;
    for (int i=-1; i<=1; i++)
  {
      for (int j=-1; j<=1; j++)
      {
        ivec2 sampled = ivec2(min(width-1, max(0, np.x + i)), min(height-1, max(0, np.y + j)));
        sum += trailr(sampled);
      }
  }
  return sum;
}

void sim (ivec2 pix)
{
  uint id = pix.y * width + pix.x;
  if (id > 1920*100) return;
  
  if (time < 0.1)
  {
    write(pix, vec3(width/2, height/2, pix + 2.*PI));
  }
  else
  {
    vec3 data = read(pix);
    vec2 dir = vec2(cos(data.z),sin(data.z));
    vec2 np = data.xy + dir*speed;
    
    float rand = hash(data.y * width + data.x + hash(id));
    
    float sF = sense(data, 0);
    float sL = sense(data, -aspace);
    float sR = sense(data, aspace);
    
    if (sF > sL && sF > sR)
    {
      data.z += 0.;
    }
    else if (sF < sL && sF < sR)
    {
      data.z += (rand - 0.5)*2. * tspeed;
    }
    else if (sL>sR)
    {
      data.z -= rand * tspeed;
    }
    else if (sL<sR)
    {
      data.z += rand * tspeed;
    }
    
    if (np.x <= 0. || np.x > width || np.y <= 0. || np.y > height)
    {
      np.x = min(width-1,max(0, np.x));
      np.y = min(height-1,max(0, np.y));
      data.z += rand * 2. * PI;
    }
    else
    {
      trailw(ivec2(np), 1.);
    }
    write(pix, vec3(np, data.z));
  }
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ivec2 pix = ivec2(gl_FragCoord.xy);
  
  sim(pix);
  diff(pix);
  
  if (fract(time*0.1) < 0.1)
  {
    vec2 u = uv - .5;
    float t= texture(texRevisionBW, u).x;
    //imageAtomicAdd();
  }
  
  vec3 col = trailr(pix).xxx;
  
	out_color = vec4(col, 1.) + texture(texPreviousFrame, vec2(gl_FragCoord.xy/v2Resolution) + length(uv)*0.1)*mix(0.1, 0.8, clamp(exp(-fract(time)*10.), 0., 1.));
}