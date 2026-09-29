#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
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

vec3 glow = vec3(0.0);

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

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
  vec3 pp = p;
  vec3 ppp = p;
  vec2 res = vec2(1.,0.);
  vec2 res2 = vec2(1.,0.);
  vec2 res3 = vec2(1.,0.);
  for (int i = 0; i < 16; i++) {
    rot(pp.xz, fGlobalTime*0.01);
    rot(pp.zy, fGlobalTime*0.01);
    float a = box(pp+vec3(0.+cos(fGlobalTime+i),0.+sin(fGlobalTime-i),15.0-i),vec3(1.,1.,1.0));
    float b = box(pp+vec3(1.+sin(fGlobalTime+i),1.+sin(fGlobalTime-i),14.0-i),vec3(1.,1.,1.0));
    float c = box(pp+vec3(2.+cos(fGlobalTime+i),2.+cos(fGlobalTime-i),13.0-i),vec3(1.,1.,1.0));
    res = opU(res,opU(vec2(c,1),opU(vec2(b,1),vec2(a,1))));
    rot(ppp.zy, fGlobalTime*0.01);
    rot(ppp.zx, fGlobalTime*0.01);
    float d = box(ppp+vec3(0.+cos(fGlobalTime+i),6.+sin(fGlobalTime-i),12.0-i),vec3(1.,1.,1.0));
    float e = box(ppp+vec3(1.+sin(fGlobalTime+i),7.+sin(fGlobalTime-i),11.0-i),vec3(1.,1.,1.0));
    float f = box(ppp+vec3(2.+cos(fGlobalTime+i),8.+cos(fGlobalTime-i),10.0-i),vec3(1.,1.,1.0));
    res2 = opU(res2,opU(vec2(d,2),opU(vec2(e,2),vec2(f,2))));
    
    rot(p.zy, fGlobalTime*0.01);
    rot(p.xz, fGlobalTime*0.01);
    float g = box(p+vec3(0.+cos(fGlobalTime+i),12.+sin(fGlobalTime-i),9.0-i),vec3(1.,1.,1.0));
    float h = box(p+vec3(1.+sin(fGlobalTime+i),13.+sin(fGlobalTime-i),8.0-i),vec3(1.,1.,1.0));
    float j = box(p+vec3(2.+cos(fGlobalTime+i),14.+cos(fGlobalTime-i),7.0-i),vec3(1.,1.,1.0));
    res3 = opU(res3,opU(vec2(j,3),opU(vec2(h,3),vec2(g,3))));
  } 
  glow += vec3(0.85,0.08,0.45)*0.0012 / abs(res.x)+0.0001;
  glow += vec3(0.02,0.08,0.45)*0.005/ abs(res2.x)+0.001;
  glow += vec3(0.4,0.08,0.4)*0.002 / abs(res3.x)+0.0001;
  return opU(res3,opU(res2,res));
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
  if (m.id == 1.0)
  {
      col = vec3(1.0,.2,.8) + clamp(dot(m.n,ld),0.0,1.0);
  }
  else if (m.id == 2.0)
  {
      col = vec3(0.2,0.2,1.0) + clamp(dot(m.n,ld),0.0,1.0);
  }
  else if (m.id == 3.0)
  {
      col = vec3(0.4,0.1,0.4) + clamp(dot(m.n,ld),0.0,.5);
  }
  else col = vec3(0);
  return col;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvv = -1.0 + 2.0*uv;
  uvv.x *= v2Resolution.x / v2Resolution.y;
    
  vec3 rayOrigin = vec3(sin(fGlobalTime*.5)*10.,sin(fGlobalTime*2.)*2.-5.0,cos(fGlobalTime*.5)*20.-10.0);
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
  
  col = col + glow*0.01;
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(20.0/v2Resolution.x, 20.0/v2Resolution.y);
  vec4 kertoimet = vec4(0.1531, 0.12245, 0.0918, 0.051);
  pcol = texture(texPreviousFrame, uv) * 0.1633;
  pcol += texture(texPreviousFrame, uv) * 0.1633;
  for(int i = 0; i < 4; ++i){
    pcol += texture(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i];
  }
  col += pcol.rgb;
  col *= 0.25;
  
  col = mix(col, texture(texPreviousFrame, uv).rgb, 0.5);
  
  col = mix(col, texture(texInerciaLogo2024,vec2(uv.x,uv.y*-1.0)).rgb,0.2);
  
  col = smoothstep(0.0,1.0,col);
  
	out_color = vec4(col,1.0);
}