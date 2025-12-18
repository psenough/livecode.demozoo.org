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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
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

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25);
}
vec3 plas2(vec2 uv) {
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  t += f;
  return t;
}

float sdBox(vec3 p, vec3 sc) {
  p = abs(p) - sc;
  p.x+=texture(texFFTSmoothed,p.y/1).x*100;
  return max(p.x,max(p.z,p.y));
}

vec2 scuv;

float map(vec3 p) {
  p.x += fGlobalTime*2;
  
  p.x = mod(p.x+5,10)-5;
  p.xz *= rot(fGlobalTime);
  scuv = p.xy;
  return sdBox(p,vec3(2));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv.y += texture(texFFTSmoothed,0.01).x*2-3;
  uv.y = mod(uv.y,1);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  
  float d,t=0;
  
  for (int i=0; i < 100; ++i) {
    d = map(ro+rd*t);
    if (d < 0.01) break;
    t +=d;
  }

  float bassam = (uv.x+uv.y+fGlobalTime*texture(texFFT,uv.y+1).x/1000)*(10-length(uv)*texture(texFFT,0.1).x*10);
  vec3 col = vec3(floor(mod(bassam-0.1,2)),floor(mod(bassam,2)),floor(mod(bassam,2)));
  add_to_pixel(ivec2(
    gl_FragCoord.xy+vec2(sin(fGlobalTime)*uv.x,cos(fGlobalTime)*uv.y)*50
  ),col*length(uv));
  
  add_to_pixel(ivec2(gl_FragCoord.xy),plas2(uv)*0.1);
  
  if (d< 0.01) {
    //col = plas2(scuv/5);
    col = read_pixel(ivec2(scuv*100+300));
  }
  
  // a vignette? with my reputation?
  
  col *= pow(max(1-length(uv),0),0.3)*1.3;
  
	out_color = vec4(col,1);
}