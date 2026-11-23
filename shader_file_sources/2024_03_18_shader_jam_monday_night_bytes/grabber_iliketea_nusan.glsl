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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = mod(fGlobalTime*.7, 300);

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void add(vec2 au, vec3 c){//add pixel to compute texture
  ivec2 u=ivec2(au);
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}

vec3 read(vec2 au){       //read pixel from compute texture
  ivec2 u=ivec2(au);
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}

vec2 rnd(vec2 uv) {
  return fract(sin(uv*574.537+uv.yx*384.714)*471.526);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x,max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float fft(float t) {
  return texture(texFFTSmoothed, fract(t)*.1).x;
}

float ffti(float t) {
  return texture(texFFTIntegrated, fract(t)*.1).x;
}

float map(vec3 p) {
  
  for(int i=0; i<5; ++i) {
    p.xz *= rot(ffti(0.01+i*.1)*.2+i);
    p.yz *= rot(ffti(0.03+i*.02)*.17);
    p=abs(p)-0.4-fft(0.04+i*0.02)*.3;
  }
  
  float d = box(p, vec3(0.3));
  
  return d;
}

void cam(inout vec3 p) {
  
  p.yz *= rot(time*.27);
  p.xz *= rot(time*.42);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv=abs(uv);
  
  if(gl_FragCoord.y<10000) {      //Amount / density of particle cloud
    
    vec3 s = vec3(0,0,-10);
    vec3 r = normalize(vec3(rnd(uv), 1));
    cam(s);
    cam(r);
    vec3 p = s;
    for (int i=0; i<100; ++i) {
      float d=abs(map(p));
      if(d<0.001) {
        vec2 pp = p.xy * 1 / (5+abs(p.z));
        pp += (rnd(uv+.1)-.5)*.2 * abs(0.3/(5+abs(p.z)));
        if (rnd(floor(uv*10-time)+.3).x<0.2) pp.x=-pp.x;
        add( (pp*1+.5)*v2Resolution.xy, max(vec3(fft(p.x*5.)*3,fft(p.y*5.)*5,sin(p.z*5-time)*.5+.5),vec3(0.)));
        d=0.1;
        r.xy = r.xy + (rnd(uv+.1)-.5)*.2;
        //break;
      }
      if(d>100.0) break;
      p+=r*d;
    }
  }
  
  
  vec3 col=vec3(0);
  
  vec3 s = read(gl_FragCoord.xy); //Read back compute texture pixel, *.3 controls the brightness of the  whole thing as it's additive
  float size = 7;
  for (float i=-size; i<size; ++i) {
    for (float j=-size; j<size; ++j) {
      vec2 off=vec2(i,j)*(fft(0.01)*17+0.1)*max(0,sin(uv.x*2+3*time)*0.7+0.2);
      s += read(gl_FragCoord.xy + off);// * vec3(vec2(i+size,j+size)*.2,0.3);
    }
  }
  s /= size*size;
  
  col += s;
  
  float t1 = sin(time*.1);
  col.xz *= rot(t1+uv.x);
  col.yz *= rot(t1*.2-uv.y);
  col=abs(col);
  
  col = smoothstep(0,1,col);
    
  //col += vec3(1-fract(abs(uv.x)-time),0.5,0.3)*step(abs(uv.y)*0.1, texture(texFFTSmoothed, floor(abs(uv.x)*30)/30*0.1).x);
  
  
	out_color = vec4(col, 1);
}