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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float map(vec3 p) {
  vec3 q=p;
  p.xy += (1-length(p.xy));
  p.z -= mod(fGlobalTime*4,4);
  p.z += texture(texFFTSmoothed,0.01).r*10;
  p -= 5*clamp(round(p/5),-5,5);
  p.z -= 2;
  
  p.x += sin(fGlobalTime/1.3+sin(q.z)*3)/3;
  p.y += sin(fGlobalTime/1.8+texture(texFFT,0.1).r*10);  
  return length(p)-1;
} // yeah yeah

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

vec3 main2(vec2 uv)
{

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  
  float t=0,d;
  float glz=1e15;
  for (int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    glz=min(glz,d);
    if (d<0.01) break;
    t += d;
  }
  
  vec3 ld=normalize(vec3(3,4,-13));
  
	vec3 col = vec3(1);
  
  if (d <0.01) {
    vec3 p=ro+rd*t;
    vec3 n=gn(p);
    
    col=plas(uv, fGlobalTime+1*t).rgb;
    col *= 0.2+0.5*dot(n,ld);
    col += pow(max(0,dot(reflect(-ld,n),-rd)),4)*0.5;
  }
  col +=glz*0.4;
  col += exp(-0.001*t*t*t);
  
  
  float ft= mod(fGlobalTime,2)-1;
  //if (uv.y>ft) out_color.rgb=vec3(nz(uv)); //out_color.gb=out_color.rr;
  vec2 circ=vec2((0.5+0.5*sin(fGlobalTime*0.5))*sin(fGlobalTime),cos(fGlobalTime))*0.6;
  if (length(uv-circ)>0.2+texture(texFFTSmoothed,0.1).r*10) col=vec3(col.r)/4;
  return col;
}

float map2(vec3 p) {
  vec3 q=p;
  p.xz*=rot(fGlobalTime);
  p = abs(p)-vec3(2);
  float bocks = max(max(p.x,p.y),p.z);
  float flor = q.y+4.5;
  return min(bocks,flor);
}

float shad(vec3 p, vec3 ld) {
  float t=0.1,d;
  float h=1;
  for (int i=0; i<100; ++i) {
    d=map2(p-ld*t);
    h=min(h,8*d/t);
    if (d<0.01) break;
    t+=d;
  }
  return h;
}

void main(void) {
	vec2 uv
  = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  for (int i=0; i<100; ++i) {
    d=map2(ro+rd*t);
    if (d<0.01) break;
    t += d;
  }
  
  vec3 ld=normalize(vec3(3,4,-13));
  
  vec3 col = vec3(0);
  
  vec2 spot = vec2(sin(fGlobalTime*0.43),cos(fGlobalTime*0.3));
  if (length(uv-spot)<0.2) col=vec3(0.1);
  
  if (d<0.01) {
    vec3 p= ro+rd*t;
    if (p.y>-2.5) {
      col=main2(uv);
    } else {
      col=vec3(0.4);
      col *= shad(p,-ld);
    }
    vec3 n = gn(p);
    col *= 0.5+0.5*dot(ld,n);
  }
  out_color = vec4(col,1);
  
}
