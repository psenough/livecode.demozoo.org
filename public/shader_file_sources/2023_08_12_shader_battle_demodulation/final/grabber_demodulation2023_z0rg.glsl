#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texLogoBW;
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
#define sat(a) clamp(a, 0., 1.)
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}
float _seed;
float rand()
{
  return hash11(_seed++);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+r*uv.x+u*uv.y);
}

float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}

mat2 r2d(float a)
{
  float c= cos(a);
  float s = sin(a);
  return mat2(c, -s, s, c);
}

float map(vec3 p)
{
    vec3 rep = vec3(7.);
  vec3 id = floor((p+rep*.5)/rep);
  p = mod(p+rep*.5,rep)-rep*.5;
  
  p.xy *= r2d(fGlobalTime*sin(id.x));
  p.yz *= r2d(fGlobalTime*1.73*sin(id.y*.78));
  float shape = _cube(p, vec3(1.5));
  shape = max(shape, -(length(p.xy)-1.));
  shape = max(shape, -(length(p.xz)-1.));
  shape = max(shape, -(length(p.yz)-1.));
  return shape;
}

vec3 rdr(vec2 uv)
{
    vec3 col = vec3(0.);
  vec2 off = (vec2(rand(),rand())-.5)*.1*0.;
  vec3 ro = vec3(sin(fGlobalTime*.33)*5.,5.,-5.);
  ro.xy += off*1.5;
  vec3 ta = vec3(5.*(hash11(floor(fGlobalTime))-.5),5.*(hash11(floor(-fGlobalTime))-.5),0.);
  vec3 rd = normalize(ta-ro);
  rd.xy -= off*.05;
  rd = getCam(rd, uv);
  vec3 p = ro;
  for (int i= 0; i < 128; ++i)
  {
    float res = map(p);
    if (res < 0.01)
    {
      col = vec3(.1);
      vec3 rgb = vec3(sin(fGlobalTime+abs(uv.x*5.))*.5+.5,.5,cos(fGlobalTime*.3)*.3+.7);
      col = rgb*sat(sin(length(p)*100.+fGlobalTime*30.))*3.;
    }
    p+=rd*res;
  }
  float d = distance(p, ro);
  col = mix(col, vec3(.5,.2,.9)*(1.-abs(uv.y)*3.), 1.-exp(-d*0.05));
  
  return col;
}

void main(void)
{
  vec2 ouv = gl_FragCoord.xy/v2Resolution.xy;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float pix = mix(0.001,0.02, length(uv));
  //uv = floor(uv/pix)*pix;
  _seed = texture(texNoise, uv).x+fGlobalTime;
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, abs(uv.x)-abs(uv.y) ).r * 100;
  vec3 col = vec3(sin(fGlobalTime+abs(uv.x*5.))*.5+.5,.5,cos(fGlobalTime*.3)*.3+.7)*f*sat(length(uv)-.35);
  col += rdr(uv);
  col += pow(rdr(uv+(vec2(rand(), rand())-.5)*.05), vec3(4.))*.1;
  vec3 col2 = texture(texLogo, vec2(1.,-1.)*uv-.5).xyz;
  col2 += col.yzx*.5;
  float ring = sin(length(uv)-fGlobalTime*2.);
  col = mix(col, col2, sat(ring*100.));
  col = mix(col, texture(texPreviousFrame, ouv).xyz, .5);
	out_color = vec4(col,1.);
}