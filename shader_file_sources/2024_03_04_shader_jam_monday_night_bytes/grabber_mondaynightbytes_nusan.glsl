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

float time = mod(fGlobalTime*0.6, 300.0);

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
  return fract(sin(t*457.532)*947.231);
}

vec2 rnd(vec2 t) {
  return fract(sin(t*457.532+t.yx*374.887)*947.231);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0.,1.,fract(t)),10));
}

float map(vec3 p) {
  
  vec3 bp=p;
  float off=length(p)*.07;
  for (int i=0; i<3; ++i) {
    p.xz *= rot(curve(time*0.3+i+off, 2.2)*4);
    p.yz *= rot(curve(time*0.4-i*.3+off, 2.1)*7);
    p.xz = abs(p.xz);
  }
  
  float d=box(p, vec3(0.3));
  for (int i=0; i<5; ++i) {
    p=abs(p)-0.7-i*0.07;
    d=min(d, box(p, vec3(0.1)));
  }
  
  float ss=0.01;
  float d2 = length(p.xz)-ss;
  d2 = min(d2, length(p.xy)-ss);
  d2 = min(d2, length(p.zy)-ss);
  if(fract(time*0.5)<0.5) d=min(d, d2);
  
  if(fract(time*0.3)<0.5) d=max(d, 4.-length(bp));
  
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 col=vec3(0);
  
  float section = rnd(floor(length(uv)*0.2-time*0.5))*300.0 + rnd(floor(abs(uv.x)*0.2-time*0.5-0.5))*300.0;
  
  float seg = rnd(floor(pow(abs(uv.x),0.7)*5.0-time*2.0));
  
  time += (seg-0.5)*1.0*curve(time, 0.4);
  
  float pu=pow(curve(time, 0.2),0.5)*4.;
  float dens=length(uv)*0.7-curve(time, 0.4)*0.4-0.1;
  if(rnd(floor(time*10.0)+floor(uv*30+section*1.0+time*3.-seg*100.0)).x<dens) uv=uv+0.04*pu;
  if(rnd(floor(time*10.0)+floor(uv*50-section*1.5-time*4.-seg*100.0)).x<dens) uv=uv-0.04*pu;
  
  
  vec3 s=vec3(0,0,-10);
  float t1 = rnd(section)*300.0 + time*0.2;
  s.x+=(rnd(section+0.2)-0.5)*10.0;
  s.xy *= rot(t1);
  s.xz *= rot(t1*.7);
  float fov=rnd(section+.4)*5.0+0.1;
  vec3 r=normalize(vec3(uv, fov));
  r.xy *= rot(t1);
  r.xz *= rot(t1*.7);
  
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    float d=abs(map(p))*0.7;
    if(d<0.02) {
      //col += map(p-r);
      d=0.1;
      //break;
    }
    if(d>100.0) break;
    p+=r*d;
    col += max(vec3(0), vec3(0.5+sin(length(p)-curve(time,0.2)*4.),0.7,0.9-curve(time, 0.3)*curve(time,0.4)) * 0.005/(0.01+length(d)+abs(d)));
  }
  
  if(length(uv+vec2(curve(time,0.4)-.5, curve(time+17.3,0.3)*.5-.25))<curve(time, 0.45)*0.4) col=1.-col;
  if(abs(length(uv+vec2(curve(time+7.,0.4)-.5, curve(time+27.3,0.3)*.5-.25))-curve(time+13., 0.45)*0.4) < 0.005) col=1.-col;
 
  float desa=pow(seg,0.4)*2.;
  if(fract(section)<0.4) desa=1.0;
  col = mix(col, vec3(dot(col,vec3(0.33))), desa);
  
  col *= 0.7;
  
  vec2 ofu = 0.05*uv;
  col.x += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy+ofu).x*0.4;
  col.y *= 1.4;
  col.z += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy-ofu).z*0.4;
 
  
	out_color = vec4(col, 1);
}