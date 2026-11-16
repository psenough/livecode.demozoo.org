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
float circ(vec2 p, float r) {
  return length(p) - r;
}
void main(void)
{
    float ff = texture( texFFT, .1 ).r * 100;
    vec2 uv = (2 * gl_FragCoord.xy - v2Resolution) / v2Resolution.y;
  float a = fGlobalTime;
  mat2 r1 = mat2(cos(a),-sin(a),sin(a),cos(a));
  mat2 r2 = mat2(cos(a),sin(a),-sin(a),cos(a));
  vec2 ruv1 = uv * r1;
  vec2 ruv2 = uv * r2;
  float r = .22;
  float sdf[] = float[](
    circ(ruv2-vec2(-.8, 0), ff*.05),
    circ(ruv1-vec2(-.25, -.25), r),
    circ(ruv1-vec2(-.25, .25), r),
    circ(ruv1-vec2(.25, .25), r),
    circ(ruv1-vec2(.25, -.25), r),
    circ(ruv2-vec2(-.15, 0.), .20)
  );
  vec4 col[] = vec4[](
    vec4(.75, .75, 0.25, 1.), 
    vec4(.5, .1, .1, 1.), 
    vec4(.7, .2, .2, 1.), 
    vec4(.9, .4, .4, 1.), 
    vec4(1., .1, .1, 1.),
    vec4(1., .6, .6, 1.)
  );
  int id = 0;
  for (int i=1; i<sdf.length(); i++) {
    if (sdf[i] < sdf[id]) {
      id = i;
    }
  }
  float fw = fwidth(sdf[id]);
  float aa = smoothstep(-fw, fw, sdf[id]);
  vec4 bg = vec4(0., 0., 0.25, 1.);
  out_color = mix(col[id], bg, aa);
}