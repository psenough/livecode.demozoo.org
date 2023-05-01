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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// cut and paste from https://iquilezles.org/articles/distfunctions/
float opSmoothUnion( float d1, float d2, float k ) {
  float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
  return mix( d2, d1, h ) - k*h*(1.0-h);
}

float gloze = 1e15;

float squn(vec3 p) {
  p.z += fGlobalTime;
  p.z = mod(p.z,4)-2;
 vec3 q=abs(p)-1;
 float sq = max(q.x,max(q.y,q.z));
  gloze=min(gloze,sq);
  return sq;

}


float trect(vec3 p) {
  float trectsize = 5+5*texture(texFFTSmoothed,0.01).r;
  vec3 q = abs(p)-vec3(trectsize,trectsize,.1);
  if (p.z<0.6 && texture(texSessions,vec2(1,-1)*p.xy/(2*trectsize)+0.5).r < 0.1) return 0.1;
  return max(q.x,max(q.y,q.z));
}

vec2 min2(vec2 a, vec2 b) {
  return a.x < b.x ? a : b;
}

vec2 map(vec3 p) {
  float squnnel = 1e15;
  for (float f=0; f < 3.1415*2; ++f ) {
    squnnel = opSmoothUnion(squnnel, squn(p+vec3(vec2(6)*rot(f+sin(fGlobalTime+f)),0)),0.5);
  }
  
  vec2 squns = vec2(squnnel,1);
  vec2 trec = vec2(trect(p),2);
  return min2(squns,trec);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 puv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = puv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  vec3 ro=vec3(sin(fGlobalTime/4)*4,cos(fGlobalTime/3)*6,-10);
  vec3 la = vec3(0);
  vec3 f = normalize(la-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(r,f);
  vec3 rd = f + uv.x*r - uv.y*u;
  
  float t=0;
  vec2 d;
  
  for (int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d.x<0.01) break;
    t += d.x;
  }
  
  vec3 ld=normalize(vec3(3,4,-13));
  
  vec3 bgc=vec3(1-length(uv))*0.2+0.7*texture(texPreviousFrame,puv).rgb;
  vec3 col = bgc;
  if (d.x<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    if (d.y==1) {
      col=(0.2+0.7*dot(n,ld)* floor(mod((p.z+p.y+fGlobalTime)*2,2))) *vec3(0.9,0.9,1);
    } else if (d.y==2) {
      col=(0.2+0.7*dot(n,ld))*vec3(0.5,0.5,1);
    }
    col += pow(max(0,dot(reflect(-ld,n),-rd)),4)*(0.5+texture(texFFTSmoothed,0.1).r);
    
  }
  
  col += exp(-0.001*gloze*gloze*gloze)*vec3(0.5,0.3,0);
  
  col = mix(bgc,col,exp(-0.0001*t*t*t));
  
  //col=pow(col,vec3(0.45));
  
  out_color = vec4(col,1);
}