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

float time=mod(fGlobalTime, 300.0);
vec2 ratio=vec2(v2Resolution.x/v2Resolution.y,1);

vec4 pack(vec2 p) {
  vec4 v=vec4(0);
  v.xy = floor(p*255.0)/255.0;
  v.zw = (p-v.xy)*255.0;
  return v;
}

vec2 unpack(vec4 p) {
  return p.xy+p.zw/255.0;
}

vec4 packspeed(vec2 p) {
  p+=0.5;
  vec4 v=vec4(0);
  v.xy = floor(p*255.0)/255.0;
  v.zw = (p-v.xy)*255.0;
  return v;
}

vec2 unpackspeed(vec4 p) {
  return p.xy+p.zw/255.0-0.5;
}

vec2 rnd(vec2 t) {
  return fract(sin(t*452.214+t.yx*840.517)*642.324);
}

float box(vec2 p, vec2 s) {
  p=abs(p)-s;
  return max(p.x,p.y);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float smin(float a, float b, float h) {
  float k=clamp((a-b)/h*0.5+0.5,0,1);
  return mix(a,b,k)-k*(1-k)*h;
}

float map(vec2 p) {
  p-=0.5;
  p*=ratio;
  
  float d=-box(p, vec2(0.92,0.48));
  
  vec3 p2 = vec3(p,0);
  float t=time*0.1;
  p2.xz *= rot(t*0.7);
  p2.yz *= rot(t*0.6);
  
  p2=abs(p2)-0.4;
  p2=abs(p2)-0.2;
  d=min(d, box(p2.xy, vec2(0.05)));
  d=min(d, box(p2.zy, vec2(0.05)));
  d=min(d, box(p2.xz, vec2(0.05)));
  
  p2.xz *= rot(t*.3);
  p2=abs(p2)-0.1;
  d=min(d, length(p2)-0.05);
  
  return d;
}

vec2 norm(vec2 p) {
  vec2 off=vec2(0.01,0);
  return normalize(vec2(map(p+off.xy)-map(p-off.xy), map(p+off.yx)-map(p-off.yx)));
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  vec2 ida = gl_FragCoord.xy;
  ivec2 id = ivec2(gl_FragCoord.xy);
	
  vec4 col=texelFetch(texPreviousFrame, id, 0);
  
  float pulse=6.0;
  time = time + rnd(vec2(floor(time/pulse),.7)).x*300;
  time += sin(time*0.2)*5.0;
  
  bool reset=fract(time/pulse)<0.02;
  if(texelFetch(texPreviousFrame, ivec2(0,2), 0).x<0.5) reset=true;
  
  if(id.y==0) {
    
    vec2 pos=unpack(col);
    vec2 speed=unpackspeed(texelFetch(texPreviousFrame, ivec2(id.x,1), 0));
    
    float d=map(pos);
    float l=length(speed);
    if(l<0.01 || l>0.9) reset=true;
    if(reset) {
      //pos=rnd(ida + fract(time) + 0.7);
      pos=sin(time*vec2(0.3,0.4)*.2)*0.4+0.5;
    }
    
    pos += speed*0.08/ratio;
    
    col=pack(pos);
  } else if(id.y==1) {
    
    vec2 speed=unpackspeed(col);
    vec2 pos=unpack(texelFetch(texPreviousFrame, ivec2(id.x,0), 0));
    
    float d=map(pos);
    float l=length(speed);
    if(l<0.01 || l>0.9) reset=true;
    if(reset) {
      speed=(rnd(ida + fract(time))-0.5)*0.5;
    }
    
    if(d<0.01) {
      vec2 n=norm(pos);
      if(dot(n,speed)<0.0) {
        speed=reflect(speed, n);
        speed*=0.9;
      }
    }
    
    speed*=0.98;    
    speed.y-=0.005;
        
    col=packspeed(speed);
    
  } else if(id.y==2 && id.x==0) {
    col=vec4(1);
  } else {
    col.xyz *= vec3(0.98,0.95,0.7);
    
    float sd=10;
    for(int i=0; i<300; ++i) {
      
      vec2 pos=unpack(texelFetch(texPreviousFrame, ivec2(i,0), 0));
      float d=length((pos-uv)*ratio);
      //col.xyz += vec3(1,0.5,0.3)*0.2*smoothstep(0.015,0.0,length(d));
      sd = smin(sd, d,.03);
    }
    
    col.xyz += vec3(1,0.5,0.9)*0.15*smoothstep(0.012,0.0,sd);
    
    float dd=map(uv);
    col.xyz += 0.1 * vec3(0.2,0.3,2.4) * smoothstep(0.,-.003,dd) * (1+dd*30.0);
  }
  
	out_color = col;
}