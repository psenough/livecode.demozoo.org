#version 420 core

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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// Going to try playing with Wrighter's flame fractal code tonight
// https://gist.github.com/wrightwriter/53395a7a50f38eb5079cce80306360e3

uint seed = 12512;
uint hashi( uint x){
    x ^= x >> 16;x *= 0x7feb352dU;x ^= x >> 15;x *= 0x846ca68bU;x ^= x >> 16;
    return x;
}

float hash_f() {
  return float(seed = hashi(seed))/float(0xffffffffU);
}

ivec2 proj_p(vec3 p, float t) {
  ivec2 q = ivec2((p.xy+vec2(v2Resolution.x/v2Resolution.y,1)*0.5)*vec2(v2Resolution.y/v2Resolution.x,1)*v2Resolution);
  if(any(greaterThan(q,ivec2(v2Resolution))) || any(lessThan(q,ivec2(0)))) {
    q = ivec2(-1);
  }
  return q;
}

void store_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  // no clue why it wants ivec4() here...
  imageStore(computeTex[0], px_coord, ivec4(quant_col.x)); 
  imageStore(computeTex[1], px_coord, ivec4(quant_col.y)); 
  imageStore(computeTex[2], px_coord, ivec4(quant_col.z)); 
}

void add_to_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  imageAtomicAdd(computeTex[0], px_coord, quant_col.x);
  imageAtomicAdd(computeTex[1], px_coord, quant_col.y);
  imageAtomicAdd(computeTex[2], px_coord, quant_col.z);
}

vec3 read_pixel(ivec2 px_coord){
  return 0.001*vec3(
    imageLoad(computeTexBack[0],px_coord).x,
    imageLoad(computeTexBack[1],px_coord).x,
    imageLoad(computeTexBack[2],px_coord).x
  );
}

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float bblrad = 2;


float smin(float a, float b, float k) {
  float h=max(k-abs(a-b),0.0);
  return min(a,b) - h*h*0.25/k;
}

float map(vec3 p, out vec3 uvw) {
  p.x-=4;
  p.xz = p.xz - 8*round(p.xz/8);
  float bb = length(p) -bblrad;
  vec3 q = p;
  float sm = max(length(q.xz)-0.3,abs(q.y-2)-0.7);
  uvw = p;
  return smin(bb,sm,0.35);
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  vec3 ig;
  return normalize(map(p,ig)-vec3(map(p-e.xyy,ig),map(p-e.yxy,ig), map(p-e.yyx,ig)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
	seed = 215125125;
  seed += hashi(uint(gl_FragCoord.x)) + hashi(uint(gl_FragCoord.y)*125);
  
  float tm=fGlobalTime*0.6;
  
  vec3 p = vec3(hash_f(),hash_f(),hash_f());
  
  if(gl_FragCoord.x<200) {
    for(float i=0.;i<100; ++i) {
      p /=dot(p,p);
      float r = hash_f();
      
      if (r<.3) {
        p -= vec3(0.1,0.4,0.2)*3.7 + sin(tm+sin(tm))*0.3;
        p /= dot(p,p);
        p.xz *= rot(0.3 + texture(texFFTIntegrated,0.1).x);
      } else {
        p = -p;
        p.xy *= rot(0.5+sin(texture(texFFTIntegrated,0.2).x));
      }
      
    }
    
    ivec2 q = proj_p(p,tm);
    if (q.x >= 0) {
      add_to_pixel(q,0.5+0.5*sin(vec3(3,2,1)*(1.+p.z*0.5) + p.z));
    }
  }
  
  float pi = acos(-1);
  vec3 ro= vec3(sin(fGlobalTime)*1.5,0,texture(texFFTIntegrated,0.01).x*4);
  vec3 la = vec3(0,0,ro.z) + vec3(0,0,3);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(r,f);
  
  vec3 rd=normalize(f + r*uv.x + u*uv.y);
  float t=0, d;
  vec3 uvw;
  
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t,uvw);
    if (d<0.01) {
      break;
    }
    t += d;
    if (t>100) break;
  }
  
  vec3 bgcol = vec3(0.1,0.5,0.1)*0.2*(1+uv.y);
  vec3 col = bgcol;
  
  vec3 ld = normalize(vec3(1,1,1));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    vec2 m = vec2(atan(-uvw.z,uvw.x),uvw.y);
    m += vec2(pi*.4,2);
    m = m * v2Resolution/8;
    col = read_pixel(ivec2(m)) *.35-0.25;
    col = mix(col,vec3(0.5),smoothstep(2.,2.1,p.y));
    vec3 hw = normalize(ld-rd);
    col += pow(clamp(dot(n,hw),0.,1.),4)*0.36;
    col += clamp(1+dot(n,rd),0,1)*0.4;
  }
  
  col = mix(vec3(0.4,0.1,0.1),col,length(col));
  
  col = mix(bgcol,col,exp(-t*t*t*0.00001)*1);
  
  col = pow(col,vec3(0.75454));
  
  out_color=vec4(col,1);
}