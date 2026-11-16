#version 410 core

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

struct Hit
{
  float dist;
  int id;
};

float fft = .0;

//iq :D
float torus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x, p.y);
  return length(q) - t.y;
}

float smin(float a, float b, float k)
{
  float h = clamp(0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k * h * ( 1. - h);
}

mat2 rot(float r)
{
  float c = cos(r), s = sin(r);
  return mat2(c, s, -s , c);
}

Hit opUnion(Hit a, Hit b)
{
  if (a.dist < b.dist) return a;
  return b;
}

Hit map(vec3 p) 
{
  float t = fGlobalTime;
  float blob = length(p) - 1. + cos(fft * 100.0 + sin(p.z * 10.0f + fft) + sin(p.x * 10.0f + fft * fft) + sin(p.y  * 12.0 + sin(fGlobalTime * 10.0 + fft))) * 0.05;
  for (float i = 0.0; i < 3.0; i += 0.5)
  {
    blob = smin(blob, length(p + sin(p.x + p.y + p.z) * vec3(cos(t + i * 10.0), sin(t + i * 10.0), -cos(t - i * 10.0))) - 0.3, 0.5);
  }
  Hit blobHit = Hit(blob, 0);
  vec3 p0 = p;
  vec3 p1 = p;
  p0.yz *= rot(fGlobalTime);
  p1.xy *= rot(fGlobalTime);
  float t0 = torus(p0, vec2(1.6, 0.1));  
  float t1 = torus(p1, vec2(1.8, 0.1));  
  Hit ringHit = Hit(min(t0, t1), 1);
  return opUnion(ringHit, blobHit);
}

vec3 norm(vec3 p)
{
  vec2 e = vec2(0, 0.001);
  return normalize(vec3(
    map(p + e.yxx).dist - map(p - e.yxx).dist,
    map(p + e.xyx).dist - map(p - e.xyx).dist,
    map(p + e.xxy).dist - map(p - e.xxy).dist
  ));
}

bool trace(vec3 ro, vec3 rd, out Hit hit)
{
  float t = 0.;
  for (int i = 0; i < 100; ++i)
  {
    Hit h = map(ro + rd * t);
    if (h.dist < 0.001) 
    {
      hit.dist = t;
      hit.id = h.id;
      return true;
    }
    t+=h.dist;
    if (t > 100.) break;
  }
  hit = Hit(100.0, -1);
  return false;
}

vec3 render(vec2 uv)
{
  fft = texture(texFFT, 0.0).r * 0.5;
  vec3 ro = vec3(0, 0, -5 + sin(fGlobalTime) * 1.5);
  vec3 rd = normalize(vec3(uv, 1));
  
  ro.xz *= rot(fGlobalTime);
  rd.xz *= rot(fGlobalTime);
  
  Hit sceneHit;
  if (trace(ro, rd, sceneHit))
  {
    vec3 matColor = vec3(0);
    if (sceneHit.id == 0)
    {
      matColor = vec3(1, 205.0/255.0,178.0/255.0) * 0.25;
    }
    else if (sceneHit.id == 1)
    {
      matColor = vec3(1);
    }
    vec3 n = norm(ro + rd * sceneHit.dist);
    vec3 l = vec3(sin(fGlobalTime), 0.2, 1);
    l.xz *= rot(fGlobalTime);
    vec3 h = normalize(n + l);
    float ndl = max(dot(n, l), 0.0);
    float sp = pow(max(0.0, dot(h, n)), 6.0);
    
    vec3 color = matColor * 0.01 + (matColor * ndl) + vec3(0.01, 0.01, 0.05) + sp * vec3(1., 0.9, 0.5);
    if (sceneHit.id == 0)
    {
      vec3 rd2 = l;
      vec3 ro2 = (ro + rd * sceneHit.dist) + rd2 * 0.1;
      for (int j = 0; j < 32; ++j)
      {
        float d = map(ro2 + rd2 * 0.25).dist * 0.8;
        if (d < 0.)
          break;
        color += (matColor + vec3(0.5, 0.2, 0.1)) * (d * d) * 0.5;
      }      
    }
    ndl = max(dot(n, -l), 0.0);
    color += (matColor * 0.01 + (matColor * ndl) + sp * vec3(1)) * 0.01;
    if (sceneHit.id == 0)
    {
      vec3 rd2 = -l;
      vec3 ro2 = (ro + rd * sceneHit.dist) + rd2 * 0.1;
      for (int j = 0; j < 32; ++j)
      {
        float d = map(ro2 + rd2 * 0.25).dist * 0.8;
        if (d < 0.)
          break;
        color += 0.03*((matColor + vec3(0.5, 0.2, 0.1)) * (d * d) * 0.5);
      }      
    }
    
    if (sceneHit.id == 1)
    {
      vec3 rd1 = normalize(refract(rd, n, 1.0/ 1.2));
      vec3 ro1 = ro + rd1 * .2;
      Hit refHit;
      float t = 0.;
      for (int i = 0; i < 100; ++i)
      {
        Hit h = map(ro + rd * t);
        if (h.dist < 0.001 && h.id == 0) 
        {
          refHit.dist = t;
          refHit.id = h.id;
          break;
        }
        t+=h.dist;
        if (t > 100.) break;
      }
      refHit = Hit(100.0, -1);
      
      if (refHit.id == 0)
      {
          if (sceneHit.id == 0)
          {
            matColor = vec3(1, 205.0/255.0,178.0/255.0) * 0.25;
          }
          else if (sceneHit.id == 1)
          {
            matColor = vec3(1);
          }
          color += matColor * 0.01 + (matColor * ndl) + vec3(0.01, 0.01, 0.05) + sp * vec3(1., 0.9, 0.5);
      }
    }
    return color;
  }
  return vec3(0.045);
}

void main(void)
{
  // oliwi :3
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 color = render(uv);
	out_color = vec4(color, 1);
}