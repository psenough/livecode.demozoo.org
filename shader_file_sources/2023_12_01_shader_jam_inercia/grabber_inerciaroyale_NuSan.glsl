#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=0;
float pul=0;

vec3 read(ivec2 iuv) {
  return vec3(imageLoad(computeTexBack[0], iuv).x
              ,imageLoad(computeTexBack[1], iuv).x
              ,imageLoad(computeTexBack[2], iuv).x) * 0.001;
}

void add(ivec2 uv, vec3 col) {
  ivec3 qcol=ivec3(col*1000);
  imageAtomicAdd(computeTex[0], uv, qcol.x);
  imageAtomicAdd(computeTex[1], uv, qcol.y);
  imageAtomicAdd(computeTex[2], uv, qcol.z);
}


mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}


float rnd(float t) {
  return fract(sin(t*542.412)*935.624);
}

vec2 rnd(vec2 t) {
  return fract(sin(t*542.412+t.yx*437.544)*935.624);
}

vec3 rnd(vec3 t) {
  return fract(sin(t*542.412+t.yzx*437.544+t.zxy*274.814)*935.624);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10));
}

float pulse(float t, float d) {
  t/=d;
  return mix(floor(t)+rnd(floor(t)), floor(t)+1+rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10))*d;
}

void circ(vec3 p, float r, vec3 col) {
    
  p.xz *= rot(time*0.3);
  p.yz *= rot(sin(time*.23)*0.5-0.6);
  
  
  float per=pow(max(abs(p.z)-0.5,0),0.5);
  p.z += 10.0;
  if(p.z<0) return;
  p.xy*=0.3+rnd(pul)*1.3;
  
  p.xy/=abs(p.z)+0.001;
  
  //if(p1.z<=0.0 && p2.z<=0.0) return;
  
  vec2 pos=vec2(p.xy*v2Resolution.y+v2Resolution.xy*0.5);
  float ratio=v2Resolution.y/v2Resolution.x;
  int sizey=int(clamp(20*per,3,50)*v2Resolution.y/1080.0);
  float mu=50.0/pow(float(sizey),1.8);
  vec2 dir=normalize(p.xy);
  for(int j=-sizey; j<=sizey; ++j) {
    float lj=j/float(sizey);
    int sizex = int(ceil(sqrt(1-lj*lj)*sizey));
    for(int i=-sizex; i<=sizex; ++i) {
      vec2 pc=pos + vec2(i,j);
      float l=length(ivec2(pc)-pos)/sizey;
      float fac=smoothstep(1.0,0.7,l)*(0.5+0.5*smoothstep(0.0,0.7,l));
      add(ivec2(pc), max(col + vec3(0,0,-1)*0.54*dot(dir,normalize(vec2(i,j))),0)*fac*mu);
    }
  }
  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time = mod(fGlobalTime, 300);
  pul = rnd(floor(fGlobalTime/2))*300;
  pul += rnd(floor(fGlobalTime/5)+.1)*300;
  time += pul;

  vec3 col=vec3(0);
  
  int dsize=40;
  if(gl_FragCoord.x<dsize && gl_FragCoord.y<dsize) {
    vec2 uv3 = gl_FragCoord.xy/dsize;
    float t=time+length(uv3)*0.5;
    float rs = 0.1;
    vec2 puv2 = uv3 + rnd(gl_FragCoord.xy/500.0+floor(t)) * rs;
    vec2 nuv2 = uv3 + rnd(gl_FragCoord.xy/500.0+floor(t)+1) * rs;
    vec2 uv2 = mix(puv2, nuv2, pow(smoothstep(0,1,fract(t)),10));
    vec3 tc = texture(texInercia, (uv2-.5)*1.0+0.5).xyz;
    //tc *= vec3(3,3,1);
        
    uv2-=0.5;
    uv2 *= 0.5;
    
    vec3 p=vec3(0);
    p.xz = uv2 * 30.0;
    p.y = curve(length(uv2)*30-time*3, 4)*3;
    p.y += curve(length(uv2)*30-time*6, 1.4)*2;
    
    
    p += sin(time*vec3(0.7,1.2,0.9)*.1) * vec3(1,0,1);
  
    circ(p, 1, tc*5.7);
  }
  
  if(gl_FragCoord.x<1 && gl_FragCoord.y<1) circ(vec3(0,1,0), 1, vec3(1,0.5,0.2)*0.7);
  
  vec2 fuv=gl_FragCoord.xy;
  if(rnd(pul+0.3)>0.7) fuv.x = abs(fuv.x-v2Resolution.x*0.5)+v2Resolution.x*0.5;
  if(rnd(pul+0.3)>0.7) fuv.y = abs(fuv.y-v2Resolution.y*0.5)+v2Resolution.y*0.5;
	col += read(ivec2(fuv));
  
  /*
  int bs=10;
  vec3 blur=vec3(0);
  for(int i=-bs;i<=bs;++i) {
    for(int j=-bs;j<=bs;++j) {
      float l=length(ivec2(i,j))/bs;
      blur += read(ivec2(gl_FragCoord.xy + ivec2(i,j))) * smoothstep(1,0,l);
    }
  }
  col += smoothstep(0,1,pow(blur/(bs*bs),vec3(2)))*1;
  */
  
  
  float t2 = time*0.1 + uv.x;
  col.xz *= rot(t2);
  col.yz *= rot(t2*1.3);
  col=abs(col);
  
  col += max(col.yzx-1,0)*0.25;
  col += max(col.zxy-1,0)*0.25;
  
  col *= 1.0 * (1.2-length(uv));
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
  col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).xyz, 0.5);
  
	out_color = vec4(col, 1);
}