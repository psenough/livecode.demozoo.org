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
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float hawk(vec3 p) {
  float res = 0;
  for (int j=0;j<2; ++j) {
    p.x += 3;
    p.xz *= rot(0.6);
    p.y -=3;
    p.x -= 3.3;
    
    for (int i=0;i<4;++i) {
      p.x=abs(p.x);
      p.x -= 5.4;
      res = max(p.y+1,res);
      vec3 q = abs(p) - 4.6;
      res = max(res,-max(q.x,max(q.y,q.z)));
      p.xy*=rot(0.64);
      p.yz*=rot(.15);
      p.y -= 0.5;
      p*=0.8;
    }
  }
  return res;
}

float map(vec3 p) {
  p.z += 25;
  p.z = abs(p.z);
  p.z -= 25;
  float res = hawk(p-vec3(60,20,10));
  return res;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy), map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float tr = sin(texture(texFFTIntegrated,0.1).x);
  float bm = -80+texture(texFFT,0.15).x*40-texture(texFFT,0.05).x*10;
  vec3 ro=vec3(bm *cos(tr),10,bm *sin(tr));
  vec3 la=vec3(0,2,0);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross (r,f);
  
  vec3 rd = normalize(f +uv.x*r +uv.y*u);
  
  float t=0,d;
  
  vec3 lcs[3];
  lcs[0] = vec3(1,0,0);
  lcs[1] = vec3(0,1,0);
  lcs[2] = vec3(0,0,1);
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (d>100) break;
  }
  
  vec3 col=mix(vec3(0.3,0.1,0.4),vec3(0.5,0.3,0.1),uv.y);
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    for (int i=0;i<3;++i) {
      float lt = texture(texFFTIntegrated, 0.05+0.1*float(i)).x;
      float lr = 50+500*texture(texFFTSmoothed,0.1).x;
      vec3 lp = vec3(cos(lt)*lr,-20,sin(lt)*lr);
      vec3 ld = normalize(p-lp);
      
      vec3 ha = normalize(ld-rd);
    
      col += pow(clamp(dot(n,ha),0,1),5);
    
      col += lcs[i] * dot(n,ld);
    }
    
  }
  
	out_color.rgb = col;
}