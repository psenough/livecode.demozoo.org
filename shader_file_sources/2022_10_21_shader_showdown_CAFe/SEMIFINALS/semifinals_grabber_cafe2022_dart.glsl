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

mat2 rot(float a){
  return mat2(cos(a),sin(a),-sin(a),cos(a));
}

float box(vec3 p, vec3 c) 
{
  vec3 a = abs(p) -c;
  return max(max(a.x,a.y),a.z);
}
vec2 min2(vec2 a, float d, float m)
{
  if (a.x < d) {
    return a; //vec2(d,m);
  }
  return vec2(d,m);
}

vec3 objCol;

vec2 map(vec3 p0) 
{
  vec2 d = vec2(1e5,-1);
  {
    vec3 p=p0;
    p.yz *= rot(fGlobalTime) * sin(p.z);
    p.zx *= rot(p.z*0.1) ;
    p.y = abs(p.y);
    p.y -= 2;
    
    p.xy = mod(p.xy - 1, 2) - 1;
    //p.yz = mod(p.zy - 1, 2) - 1;
    //p.yz = mod(p.yz - 1, 2) - 1;
    
    d = min2(d, box(p, vec3(0.9,0.01,0.9)), 1);
    //d.x = min2(d, length(p) - 2.0, 2);
  }
  p0.xy *= rot(fGlobalTime);
  p0.yz *= rot(fGlobalTime);
  d = min2(d, box(p0, vec3(1)), 1);
    
  
  
    objCol = abs(p0)*0.03;
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(0,0,10);
  vec3 rd = normalize(vec3(uv,-1));
  
  vec3 col;
  vec2 d;
  float dt;
  int i;

  vec3 p = ro;

  for(i =0;i < 100; ++i) {
    d = map(p);
    if (d.x < 0.01) {
      break;
    }
    p += rd * d.x*0.8;
    col += objCol*0.9;
  }
  
  float s = 1.0 - float(i)/100.;
  col *= vec3(s);
  //col =objCol;
  
  out_color = vec4(col,1);
}