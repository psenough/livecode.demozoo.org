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

// hello Revision!
float time=mod(fGlobalTime * 0.2, 300);

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float rnd(float t) {
  return fract(sin(t*362.984)*574.773);
}

vec3 rnd(vec3 t) {
  return fract(sin(t*847.627+t.yzx*463.994+t.zxy*690.238)*492.094);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10));
}

float curvei(float t, float d) {
  t/=d;
  return mix(floor(t)+rnd(floor(t)), floor(t)+1+rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10))*d;
}

float smin(float a, float b, float h) {
  float k=clamp((a-b)/h*0.5+0.5, 0, 1);
  return mix(a,b,k) - k * (1-k) * h;
}

vec3 am=vec3(0);
float map(vec3 p) {
  
  //p.xy *= rot(time*0.4 + sin(p.z*0.134));
  //p.xy = abs(p.xy) - sin(time - p.z * 0.02)*5-10;

  
  vec3 bp=p;
  float t=time*0.3 + curvei(time, 0.7) + curvei(time, 0.2);
  
  
  for(int i=0; i<3; ++i) {
    p.xz *= rot(t + sin(p.y*0.1));
    p.xy *= rot(t*0.7 + sin(p.z*0.14));
    p.xz =abs(p.xz)-1.9-curve(time, 0.2)*10;
  }
  
  float d = box(p, vec3(1));
  d = smin(d, length(p.xy)-0.3, 0.2);
  
  d = smin(d, abs(length(bp)-5-curve(time, 0.3)*6), 3.9);
  
  p=abs(p)-2;
  float d3 = length(p)-0.2;
  d3 = min(d3, length(p.xz)-0.15);
  d3=smin(d3, length(bp)-15, -4);
  d=min(d, d3);
  
  am += vec3(0.6,0.4,0.2) * 0.004/(0.01 + abs(d3));
  
  d *= 0.7;
  
  return d;
}

vec3 norm(vec3 p, float t) {
  vec2 off=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.y -= curve(time, 0.1)*0.1;
  
  float t5=time*10;
  uv.x += max(curve(t5+rnd(floor(uv.y*448)),0.2)-0.5-curve(t5*5+uv.y*0.2, 0.3),0) * 0.2;

  uv *= 1 + length(uv);
  
  vec3 s=vec3(0,0,-22);
  float fov = 0.4 + curve(time, 0.5);
  vec3 r2=normalize(vec3(uv,fov));
  
  vec3 col=vec3(0);
  float ste=10;
  for(int j=0; j<ste; ++j) {
    float dd=0;
    vec3 p=s;
    vec3 r=r2;
    am=vec3(0);
    for(int i=0;i<60;++i) {
      float d=abs(map(p));
      if(d<0.001) {
            
        float fog=1-clamp(dd/100.0, 0,1);
        vec3 n=norm(p, 0.01);
        
        float rough = 0.3;
        r = reflect(r,normalize(n+rough * rnd(vec3(uv,j+i*6.1))));
    
        d=0.1;
        //break;
      }
      if(d>100.0) break;
      p+=r*d;
      dd+=d;
    }
    
    col += am / ste;
    col += pow(abs((r.x*sin(vec3(1,2,3)*0.2+time*4))), vec3(4)) / ste;
  }
  
  col *= 1.5;
  float t3=time*0.2;
  col.xz *= rot(t3*0.7);
  col.xz *= rot(t3);
  col=abs(col);
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
  vec2 uv2 = gl_FragCoord.xy / v2Resolution.xy;
  uv2-=0.5;
  uv2 *= 1.02;
  uv2+=0.5;
  vec3 prev = texture(texPreviousFrame, uv2).rgb;
  float fr=0.4+0.6*pow(fract(time*0.2),5) * smoothstep(0.5,0.6,length(uv2-0.5));
  //col = mix(col, prev, fr);
  
	out_color = vec4(col, 1);
}