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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 sptx(vec2 uv)
{
  uv = floor(uv)/1;
  float bt = -fGlobalTime/20;
  uv *= 0.02;
  uv.x += 2+sin(fGlobalTime*0.11)*0.3;
  uv.y += sin(fGlobalTime*0.1)*0.3;

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( bt ) * 0.1;
	m.y += bt * 0.25;

	vec4 t = plas( m * 3.14, bt ) / d;
	t = clamp( t, 0.0, 1.0 );
	return (f*0.1 + t).rgb;
}

float map(vec3 p, out vec3 uvw, out int tex) {
  tex = 1;
  uvw = p.xzy;
  float fl= p.y+1;
  
  float res = fl;
  
  float bac = 5-p.z;
  if (bac < res) {
    tex = 2;
    uvw = p;
    res = bac;
  }
  
  float cir = length(p+vec3(0,1+.5*sin(fGlobalTime),0))-3-14*texture(texFFT,0.1).x;
  if (cir < res) {
    tex = 1;
    uvw = p;
    res = cir;
  }
  
  return res;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  vec3 u;
  int t;
  return normalize(
  map(p,u,t) 
  - vec3(
    map(p-e.xyy,u,t), 
    map(p-e.yxy, u, t), 
    map(p-e.yyx,u,t) ) );
}

void main(void) 
{
  float bt = -fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(
    cos(texture(texFFTIntegrated,0.1).x)*4,
    .4+sin(texture(texFFTIntegrated,0.1).x)*0.25,
    -13);
  vec3 la=vec3(0,0,0);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(vec3(0,1,0),f);
  vec3 u = cross(f, r);
  vec3 rd = normalize(f+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  vec3 uvw;
  int tex;
  
  float reflections = 0;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t,uvw,tex);
    if (d<0.01) {
      if (tex == 1) {
        ro = ro + rd *t;
        vec3 nm =gn(ro);
        nm.x += cos(ro.z*10)*0.01;
        nm.y += cos(ro.x*11+sin(ro.z))*0.01;
        rd = reflect(rd,nm);
        reflections += t/10 ;
        t=0.1;
      } else {
        break;
      }
    }
    t += d;
    
  }
  
  vec3 col=vec3(sptx(uv));
  
  if (d < 0.01) {
    col = vec3(1);
    if (tex == 2) {
      vec3 p = ro+rd*t;
      col = sptx(p.xy)*(1-reflections*0.5);
      
    }
  }
  
  out_color.rgb = col;
}