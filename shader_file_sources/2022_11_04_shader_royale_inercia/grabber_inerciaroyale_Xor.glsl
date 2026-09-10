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

vec3 path(float z)
{
    return vec3(cos(z/vec2(13,15))*vec2(4,1)-vec2(0,1)*((tanh(mod(z-2e1,4e1)-2e1)*.2)+1.)+texture(texFFT,0.0).r/.01,0);
}

float dist(vec3 p)
{
  p += path(p.z);
  float m = 1e3;
  m = min(m,min(p.y+6.+cos(ceil(p.x)*(2.+cos(ceil(p.z/ceil(8.+7.*cos(ceil(p.x)))+ceil(p.x))))),max(10.-abs(p.x),5.-p.y)));
  m = min(m,max(abs(length(p.xy)-(10.+texture(texFFT,0.0).r/.1+.4*sign(cos(atan(p.y,p.x)/.1+p.z)))/(2.+cos(ceil(p.z/4e1))))-1.,abs(mod(p.z,4e1)-2e1)-6.-5.*cos(pow(ceil(p.z/4e1),2.))));
  vec3 a = abs(mod(p+vec3(0,0,0),2e1)-10.);
  m = min(m,length(min(a,a.yzx))-1.);
  vec3 M = mod(p+vec3(cos(pow(ceil(p.y+9.),2.))*texture(texFFT,0.5).r*5e2,20,cos(ceil(p.x/4e1))*fGlobalTime*3e1),4e1)-2e1;
  M.z -= clamp(M.z,-4.,4.);
  m = min(m,length(max(abs(M)-4.,-.5))-1.);
  return m+texture(texFFT,p.z/1e2).r/.1;
}
vec3 nor(vec3 p)
{
  vec2 e = vec2(.1,-.1);
    return normalize(dist(p+e.yxx)*e.xyy+dist(p+e.xyx)*e.xxy+dist(p+e.xxy)*e.xxy+dist(p+e.y)*e.y);
  
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 puv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= mat2(cos(cos(fGlobalTime*.1)*.2+vec4(0,11,33,0)));
  
  uv.x += cos(pow(floor(uv.y/.1),3.0))*(texture(texFFT,uv.x-.5).r);
  uv.y += cos(pow(floor(uv.x/.1),3.0))*texture(texFFT,uv.y-.5).r;
  //uv = fract(uv-.5)-.5;

  vec3 d = normalize(vec3(uv,1));
  
  d.zx *= mat2(cos(tanh(cos(fGlobalTime*.3)/.1-8.)*.75+.75+vec4(0,11,33,0)));
  vec3 p = vec3(0,0,fGlobalTime/.1);
  vec3 cam = path(p.z);
  p -= cam;
  
  int i = 0;
	for(;i<99;i++)
  {
      float s = dist(p);
    
       p += d*s;
    if (s<0.01) break;
  }
  vec3 n = nor(p);
  vec3 r = reflect(d,n);
  vec3 l = normalize(vec3(1,2,cos(fGlobalTime)));
  float d_l = dot(n,l);
  float lig = max(d_l,d_l*.1+.1);
  //lig *= clamp(dist(p+n*.1)/.1,0.,1.);
  vec3 c = max(cos(pow(ceil((p+cam).z),3.)+vec3(0,2,4)),0.)*lig/float(i)*1e1+max(dot(r,l)*9.-8.,0.);
  c.yz /= 1.+.02*(p-vec3(0,0,fGlobalTime/.1)).yz;
  c[int(fGlobalTime)%3] = texture(texPreviousFrame,puv)[int(fGlobalTime+1.4+.5*cos(fGlobalTime*.3))%3];
  
  
	out_color = vec4(c,1);
}