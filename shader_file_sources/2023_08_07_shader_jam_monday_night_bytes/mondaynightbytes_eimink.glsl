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

const float E = 0.001;
const int STEPS = 64;
const float FAR = 40.0;

float fft = texture(texFFTIntegrated, 0.1).r;

struct MarchResult
{
  float id;
  float t;
  vec3 p;
  vec3 n;
  float d;
};

float box(vec3 position, vec3 dimensions){
  vec3 b = abs(position)-dimensions;
  return length(max(b, 0.0)) + min(max(b.x, max(b.y, b.z)), 0.0); 
}

vec2 opU(vec2 d1, vec2 d2)
{
    return (d1.x < d2.x) ? d1 : d2;
}

vec2 scene(vec3 p){
  vec3 pp = abs(p);
  vec2 res = vec2(1.,0.);
  
  for (int i=0; i < 35.; ++i)
  {
    float a = box(p+vec3(0.,0.+sin(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    float b = box(p+vec3(0.,2.+sin(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    float c = box(p+vec3(0.,4.+sin(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    float d = box(p+vec3(0.,6.+sin(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    float e = box(p+vec3(0.,8.+sin(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    res = opU(res,opU(opU(vec2(d,2.0),vec2(e,1.0)),opU(vec2(c,3.0),opU(vec2(a,1.0),vec2(b,2.0)))));
  }    
  
  return res;
  
}

vec3 calcNormal(vec3 pos) 
{
    vec2 e = vec2(0.00001, 0.0);
    return normalize( vec3(scene(pos+e.xyy).x-scene(pos-e.xyy).x,
                           scene(pos+e.yxy).x-scene(pos-e.yxy).x,
                           scene(pos+e.yyx).x-scene(pos-e.yyx).x ) );
}

MarchResult march(vec3 ro, vec3 rd)
{
  float t = E;
  float id = 0.0;
  vec3 position = ro;
  for (int i = 0; i < STEPS;++i){
    vec2 d = scene(position);
    t +=d.x;
    id = d.y;
    position = ro+rd*t;
    if (d.x < E || t > FAR) break;
  }
  MarchResult res;
  res.t = t;
  res.id = id;
  res.p = position;
  res.n = calcNormal(position);
  return res;
}

vec3 colorize(MarchResult m, vec3 ld)
{
  float t = m.d;
  vec3 p = m.p;
  vec3 col = vec3(0.0);
  if (m.id == 2.0)
  {
      col = vec3(1.0,.2,.9) + clamp(dot(m.n,ld),0.0,1.0);
  }
  else if (m.id == 3.0)
  {
    col = vec3(.8) + clamp(dot(m.n,ld),0.0,1.0);
  }
  else if (m.id == 1.0)
  {
    col = vec3(.2,.5,1.0) + clamp(dot(m.n,ld),0.0,1.0);
  }
  else col = vec3(0);
  return col;
}

void main(void)
{
    
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvv = -1.0 + 2.0*uv;
  uvv.x *= v2Resolution.x / v2Resolution.y;
    
  vec3 rayOrigin = vec3(sin(fft*.5)*10.,sin(fft*2.)*2.-5.0,cos(fft*.5)*10.-10.0);
  vec3 lookAt = vec3(0.0, -5.0, 0.0);
  
  vec3 z = normalize(lookAt - rayOrigin);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rayDirection = normalize(mat3(x, y, z) * vec3(uvv, radians(60.00)));
  
  vec3 lightDirection = -rayDirection;
  
  vec3 col = vec3(0.0);
  
  MarchResult t = march(rayOrigin, rayDirection);
  if ( t.t < FAR){
    col = colorize(t,lightDirection);
  }
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(20.0/v2Resolution.x, 20.0/v2Resolution.y);
  vec4 kertoimet = vec4(0.1531, 0.12245, 0.0918, 0.051);
  pcol = texture2D(texPreviousFrame, uv) * 0.1633;
  pcol += texture2D(texPreviousFrame, uv) * 0.1633;
  for(int i = 0; i < 4; ++i){
    pcol += texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i];
  }
  col += pcol.rgb;
  col *= 0.25;
  
  col = mix(col, texture2D(texPreviousFrame, uv).rgb, 0.5);
  
  col = smoothstep(-0.2, 1.1, col);
  
	out_color = vec4(col,1.0);
}