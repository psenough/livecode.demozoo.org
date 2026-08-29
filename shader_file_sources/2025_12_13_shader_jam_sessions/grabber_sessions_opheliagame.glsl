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

mat2 rotate2d(const in float r){
    float c = cos(r);
    float s = sin(r);
    return mat2(c, s, -s, c);
}

vec2 rotate(in vec2 v, in float r, in vec2 c) {
    return rotate2d(r) * (v - c) + c;
}

vec2 rotate(in vec2 v, in float r) {
    #ifdef CENTER_2D
    return rotate(v, r, CENTER_2D);
    #else
    return rotate(v, r, vec2(.5));
    #endif
}


float random(in float x) {
#ifdef RANDOM_SINLESS
    x = fract(x * RANDOM_SCALE.x);
    x *= x + 33.33;
    x *= x + x;
    return fract(x);
#else
    return fract(sin(x) * 43758.5453);
#endif
}

float pointedArchSDF(vec2 st, vec2 center) {
  vec2 left  = vec2(center.x-0.5, center.y-0.5);
  vec2 right = vec2(center.x+0.5, center.y-0.5);
  
  float a = length(st - left)  * 1.0;
  float b = length(st - right) * 1.0;

  // return a+b-(a*b);
  // return max(a, b);
  // return a+b-(a*b);
  return st.y > 0.0 ? max(a, b) : 2.0;
  // return min(max(a, b), -st.y*5.0);
}

float pointedArchSDF(vec2 st) {
  return pointedArchSDF(st, vec2(0.5));
}


vec2 get_st(vec2 st, vec2 res) {

  float angle = atan(st.x-0.5, st.y);

  st = vec2(angle, pointedArchSDF(st));
  st *= res;
  st = fract(st);
  
  return st;
} 

// just started using bonzomatic!!! so going to be very simple things today!!! thanks for watching!!
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	

  vec4 tex = texture( texPreviousFrame, fract(uv * random(fGlobalTime ) * 12.0));

  float t1 = fGlobalTime * 0.1;

  vec2 onemore1 = get_st(uv, rotate(uv, t1 + uv.x + tex.x * 0.2) );

  vec2 onemore = get_st(onemore1, vec2(tex.y * sin(fGlobalTime * 0.1) * 0.2 + 2.0,  tex.x ));

	vec4 t =  vec4(onemore.x, onemore.x, onemore.y + t1 * random(t1), onemore.y);
	t = clamp( t, 0.0, 1.0 );
	out_color =  t;
}