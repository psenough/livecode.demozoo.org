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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( (v.x+ v.y) * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	//return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  
  vec4 x = vec4(sin(time+v.x*3)*0.5+0.5, 0, 0, 1);//*(sin(fGlobalTime)*1.5+0.5);
  //x.g = sin(texture(texFFTIntegrated,v.x/3.14).x)*0.5;
  //x.g = texture(texNoise, vec2(v.x/3.14, 0.5)).x*0.5;
  x -= mod(x, 0.15);
  return x;
}
vec2 rec2polar(vec2 uv) {
  //return vec2(atan(uv.x, uv.y) / 3.14, 1 / length(uv) * .2);
  return vec2(atan(uv.x, uv.y) / 3.14, 1 / max(abs(uv.x),abs(uv.y)) * .2);
}
vec2 pixelize(vec2 uv) {
  float f2 = texture(texFFT, 0.01).x*0.2;
  f2 = max(f2-0.01,0);
  //f2 = min(f2, 0.05);
  if(f2>0) {
    uv += f2*2;
    uv = uv - mod(uv, f2*2)*2;
    //uv += f2;
  }
  return uv;
}
vec4 getcol(vec2 uv) {
  uv /= v2Resolution;
  vec2 framecoords = uv;
  
  /*if(texture(texFFTSmoothed, 0.02).x > 0.1) {
    uv = mod(uv*3, 1) + uv-0.5;
  }*/
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.x += texture(texFFT, uv.y+0.5).x*2;//*(mod(gl_FragCoord.y,2)*2-1);

  //uv = pixelize(uv);
  

	vec2 m = rec2polar(/*pixelize*/(uv));
	
  vec2 m2 = rec2polar(uv);
	float f = texture( texFFTSmoothed, m2.y+mod(m2.x*2,1)+/*texture(texFFTIntegrated, 0.02).x+*/fGlobalTime).r * 6;
  //f += texture( texFFTSmoothed, abs(-d)+mod(-m.x/3.14,1)-fGlobalTime).r * 60;
  //f /= 3;
	m.y += fGlobalTime * 0.25;
	m.x += sin( fGlobalTime ) * 0.1;
  
  float a = texture(texFFTIntegrated, 0.01).x*0.1;
  m.x += a;

  m.x += texture(texFFTSmoothed, m.y).x*3.14*3;
  
	vec4 t = plas( m * 3.14, fGlobalTime );// / d;
  t = clamp( t, 0.0, 1.0 );
	vec4 out_color = f + t;
  
  if(false) {
    vec2 pc = framecoords + texture(texFFT, uv.y+0.5).x*2;
    vec4 p = (pc.x < 0 || pc.y < 0 || pc.x > 1 || pc.y > 1 ? vec4(0) : texture(texPreviousFrame, framecoords));
    out_color.b += max(0, p.r - out_color.r)*10;
  }
  return out_color;
}
mat2 rot(float ang) {return mat2(vec2(cos(ang),sin(ang)),vec2(-sin(ang),cos(ang)));}
void main2(void) {
  vec2 uv = gl_FragCoord.xy;
  uv -= v2Resolution/2;
  uv.x = abs(uv.x);
  uv.y = abs(uv.y);
  uv *= rot(fGlobalTime);
  uv += v2Resolution/2;
  
  out_color = getcol(uv);
}
vec2 kaleido(vec2 uv, vec2 center, float multiplier) {
  uv.x = abs(uv.x);
  uv.y = abs(uv.y);
  uv -= center;
  uv *= rot(multiplier);
  uv += center;
  //uv = rec2polar(uv);
  return uv;
}
void main(void)
{
 	vec2 uv = gl_FragCoord.xy;
  uv -= v2Resolution/2;
  uv = pixelize(uv);
  uv.x += texture(texFFT, uv.y+0.5).x*100;//*(mod(gl_FragCoord.y,2)*2-1);
  uv.y += texture(texFFTSmoothed, uv.y+0.5).x*100;//*(mod(gl_FragCoord.y,2)*2-1);
  /*uv.x = abs(uv.x);
  uv.y = abs(uv.y);
  uv *= rot(fGlobalTime);*/
  uv = kaleido(uv, vec2(0, 0), 1.0*texture(texFFTIntegrated,0.1).x);
  uv = kaleido(uv, vec2(0.5, 0.7), sin(fGlobalTime*0.7));
  uv += v2Resolution/2;
  
  out_color = getcol(uv)*0.2;
  float ofs=1;
  out_color += abs(getcol(uv+vec2(0,ofs))-getcol(uv+vec2(0,-ofs)))*5;
  out_color += abs(getcol(uv+vec2(ofs,0))-getcol(uv+vec2(-ofs,0)))*5;
  
  if(true) {
    float zoom = texture(texFFTSmoothed, 0.05).x;
    vec2 pc = gl_FragCoord.xy/v2Resolution + texture(texFFT, (uv.y/v2Resolution.y-0.5)*(0.99-zoom)+0.5).x*2;
    vec4 p = (pc.x < 0 || pc.y < 0 || pc.x > 1 || pc.y > 1 ? vec4(0) : texture(texPreviousFrame, uv/v2Resolution));
    out_color.b += max(0, p.r - out_color.r)*10;
    out_color += max(vec4(0), (p-out_color))*(0.99 - texture(texFFT, 0.01).x);
  }
  
}