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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(dot(p,ax) * ax, p, cos(a)) + cross(ax,p) * sin(a);
}


float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k* h * (1.-h);
}

float caps( vec3 p, float h, float r )
{
  p.y -= clamp( p.y, 0.0, h );
  return length( p ) - r;
}

float hed(vec3 p, out vec3 col) {
  p = erot(p, vec3(0,1,0), .8*sin(fGlobalTime));
  p = erot(p, vec3(1,0,0), texture(texFFTSmoothed,0.1).x*40-.4);
  col = vec3(.5,.2,.01)*.5;
  
  vec3 q = p;
  q.z += 0.5;
  q.y -= 0.1;
  q = erot(q, vec3(1,0,0), .4);
  q.z *= 0.75;
  float hed = length(q)-2.4;
  
  q = p;
  
  
  q.x = abs(q.x);
  q.x -= .5;
  q.y += .94;
  q = erot(q,vec3(0,0,1),.45);
  q.z += 3.4;
  q.y *= 1.5;
  q.z *= 1.5;
  float snoot = length(q)-0.8;
  
  q=p;
  q.z += 3.8;
  q.y += 0.55;
  
  q = erot(q, vec3(1,0,0),-.75);
  
  float lno = caps(q, 2,.3);
  
  q = p;
  
  q.z += 2.8;
  q.y += 1.3;
  
  float chin = length(q)-0.8;
  q = p;
  q.x = abs(q.x);
  q.x -= 2.5;
  q.z += 1;
  q.y -= 1;
  q = erot(q, normalize(vec3(0,-.95,1)), -0.4);
  q.y *= 1.5;
  
  float er = length(q) - 1.3;
  er = max(-er, length(q+vec3(0,0,-.9))-1.2);
  
  float fluffybits = smin(hed, snoot,.7);
  
  fluffybits = smin(fluffybits, lno,.4);
  fluffybits = smin(fluffybits, chin,.4);
  fluffybits = smin(fluffybits, er,.4);
  
  q = p;
  
  q.z += 3.3;
  q.y -= 0.3;
  q.x = abs(q.x);
  q.x -=0.6;
  float ei = length(q)-0.3;
  
  q = p;
  q.z += 3.9;
  q.y += .6;
  q.x = abs(q.x);
  q.z *= 1.2;
  q = erot(q, vec3(0,0,1), -0.4);
  q.x -= .05;
  
  float nz = length(q) -.3;
  
  
  float res = fluffybits;
  if (ei < res) {
    col = vec3(0);
    res = ei;
  }
  if (nz < res) {
    col = vec3 (1,0.8,0.8);
    res= nz;
  }
  return res;
}

float bod(vec3 p, out vec3 col) {
  col = vec3(.5,.2,.01)*.5;
  vec3 q =p;
  q.z -= 6;
  q.y += 4;
  q=erot(q, vec3(1,0,0), -.4);
  q.z *= .5;
  return length(q)-3.5;
}

vec3 sk(vec2 uv) {
  float res = 0;
  float a=0.4;
  for (int i = 0;i<3;++i) {
    res += a * texture(texNoise, uv).x;
    uv *= 2;
  }
  return mix(vec3(0.4,0.45,1), vec3(0.97), res);
}

float map(vec3 p, out vec3 col) {
  
  float hednod = clamp (.8*sin(fGlobalTime*.4), -.3,.3);
  p = erot(p, vec3(0,1,0), hednod);
  vec3 col1, col2;
  float hedval = hed(p,col1);
  float bodval = bod(p,col2);
  col = col1;
  if (hedval > bodval) {
    col = col2;
  }
  return smin(hedval, bodval, 0.7);
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  vec3 ig;
  return normalize(map(p,ig) - vec3(map(p-e.xyy,ig),map(p-e.yxy, ig), map(p-e.yyx,ig)));
}  

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  vec3 texcol = vec3(0);
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t, texcol);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  
  vec3 bgcol = sk(rd.xy);
  
  vec3 col = bgcol;
  
  vec3 ld = normalize(vec3(3,2,-1));
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    col = texcol;
    col *= 0.2 + 0.8*clamp(dot(n, ld),0.0,1.0);
    
    float sp = pow(max(dot(reflect(-ld,n),-rd),0),30);
    col += sp*vec3(0.2,0.4,0.4);
    
    float fr = pow(clamp(1+dot(rd,n),0.0,1.0),4);
    col = mix(col, bgcol, fr);
  }
  
  col = pow(col,vec3(0.45));
  
  out_color.rgb = col;
}