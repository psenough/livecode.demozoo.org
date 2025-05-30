#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define BG vec3(0.9,0.05,0.3)
#define PI 3.14159

mat3 rot3(vec3 axis, float angle) { // 3D rotation along axis
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;
  return mat3(
		oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c
	);
}

mat2 rot2(float angle) {  // 2D rotation
	float s = sin(angle);
	float c = cos(angle);
	return mat2(
		c, -s,
		s, c
	);
}

vec3 hsv2rgb(in vec3 c)
{
    vec3 o;
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    o = c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
  return o;
}

vec4 sdCappedCylinder( vec3 p, float h, float r )
{
  //p = p.xzy;
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(h,r);
  vec3 c = vec3(p.x/h, p.y/r, p.z/h);
  return vec4(min(max(d.x,d.y),0.0) + length(max(d,0.0)), c);
}

float sdTri( in vec2 p )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

vec3 shading(vec3 c)
{
  float mask = step(0.9, length(c.xz));
  
  // Topside
  vec2 pe = c.xz;
  pe.x = abs(pe.x);
  #define EYEELLIPSE 0.4
  pe.y *= EYEELLIPSE;
  vec2 eyepos = vec2(0.3, 0.4*EYEELLIPSE);
  float ffti = texture(texFFTSmoothed, 0.3).x*3;
  float topmask = 1.-smoothstep(0.14+ffti, 0.15+ffti, length(pe-eyepos));
  
  float mouthangle = 0.55;
  
  float arg = atan(c.x, c.z);
  float argfft = pow(texture(texFFTSmoothed, abs(arg)*0.3).x*10, 0.5);
  float ends = (1-step(PI*(mouthangle+0.02), abs(arg)))*0.05;
  float circle = step(0.65-ends-argfft, length(c.xz)) - step(0.75+ends+argfft, length(c.xz));
  topmask = max(topmask, circle*step(PI*mouthangle, abs(arg)));
  
  mask = max(mask, topmask* step(0, +c.y));
  
  // Bottomside
  vec2 pt = c.xz * vec2(-1,1) / (-ffti*40);
  arg = mod(atan(pt.x, pt.y)+(4.5/3*PI), 2*PI);
  pt *= rot2(floor(arg/(PI*2/3))*(PI*2/3)-(0/3*PI));
  float botmask = (1-smoothstep(-0.15, -0.14, sdTri(pt))) * smoothstep(-0.15, -0.14, sdTri(pt-vec2(0,-sqrt(3)*0.5)) );
  
  mask = max(mask, botmask* step(0, -c.y));
  
  
  return vec3(mix(BG, vec3(0), mask));
}

vec4 dist(vec3 p)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); // Regular UV
  vec4 prevp = texture(texPreviousFrame, uv);
  float ffti = texture(texFFTIntegrated, 0.3).x;
  mat3 rot = rot3(vec3(sin(fGlobalTime*0.0124*sqrt(3) + uv.y*2), 1, cos(fGlobalTime*0.24576*sqrt(2))), fGlobalTime+uv.x*10 + ffti*0.4 + length(prevp*0));
  //mat3 rot = rot3(vec3(0,1,0), fGlobalTime*sqrt(2)*0.1) * rot3(vec3(1,0,0), fGlobalTime*0.8 + ffti);
  vec4 d = sdCappedCylinder(p*rot-vec3(0,0,0), 0.2, 0.03);
  return d;
}

vec4 rm(vec3 ro, vec3 rd)
{
  float d = 0.;
  vec3 c = vec3(0);
  for(int i=0;i<100;i++)
  {
    vec3 p = ro + rd*d;
    d += dist(p).x;
    c = dist(p).yzw;
    if(d>100||d<0.01){break;}
  }
  return vec4(d, c);
}

float rm2(vec3 ro, vec3 rd)
{
  float d = 0.;
  for(int i=0;i<15;i++)
  {
    vec3 p = ro + rd*d;
    d += dist(p).x;
    if(d>100||d<0.01){break;}
  }
  return d;
}

vec2 uvcenterscale(vec2 uv, float scale) {
  return (uv - 0.5) * scale + 0.5;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); // Regular UV
  vec2 uvc = uv - vec2(0.5);  // UV with origin in screen center
  vec2 uv11 = uvc*2.; // Centered UV but going from -1 to 1 from edge to edge
  vec2 uvca = uvc * vec2(v2Resolution.x/v2Resolution.y, 1); // Centered uv with aspect ratio compensation
  vec2 uv11a = uv11 * vec2(v2Resolution.x/v2Resolution.y, 1); // Centered uv11 with aspect ratio compensation
  
  vec3 ro = vec3(0,sin(fGlobalTime*0.)*0.2,1); // Ray Origin/Camera
  vec3 rd = normalize(vec3(uvca.x,uvca.y,-1.5)); // Ray Direction
  
  vec4 r = rm(ro,rd);  // Raymarching
  float d = r.x;  // Distance field
  vec3 c = r.yzw;  // Local coordinates on cylinder
  
  vec4 fft = texture(texFFTSmoothed, 0.05);
  float ffti = pow(fft.x, 0.5);
  
  float ffts = texture(texFFTIntegrated, 0.3).x;
  
  vec4 prevp = texture(texPreviousFrame, uv);
  
  vec4 prev = texture(texPreviousFrame, uvcenterscale(uv, 0.99 - ffti*0.01) - (prevp.rb*rot2(atan(uv11.y, uv11.x)+PI*ffts))*0.003);
  
  vec3 cylcol = shading(c);
  
  float pillmask = step(10, d);
  float pillmask_expanded = step(10, rm2(ro,rd));
  
  vec3 bgcol = mix(vec3(hsv2rgb(vec3(length(uv11*10) + fGlobalTime*3, 0.7, 0.8))), BG, pillmask_expanded);
  bgcol = mix(bgcol, prev.rgb, 0.99 * pillmask_expanded);
  
  
  
	out_color = vec4(mix(cylcol, bgcol, step(10, d)), 1.);
  
  //out_color = vec4(pillmask, pillmask_expanded,ffti*5,0);
}