#version 410 core
uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// Hey it's my first shader -- audio reactive tiled 3D cubes and spheres in 2D. They spin, pulse and twist in time to the bass.

#define PI 3.14159265359

mat2 rotate2d(float _angle) {
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}
float box(vec2 _st, vec2 _size) {
    _size = vec2(0.5)-_size*0.5;
    vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st);
    uv *= smoothstep(_size,_size+vec2(1e-4),vec2(1.0)-_st);
    return uv.x*uv.y;
}
float sdCircle(vec2 uv) {
  float c = length(uv) < (0.08+texture(texFFT,0.01).r) ? 0.4 : 0.5;
  return c;
}
vec2 tile(vec2 _st, float _zoom) {
    _st *= _zoom;
    _st.x += step(1., mod(_st.y,2.0)) * 0.5*sin(fGlobalTime)*4.; // offset
    return fract(_st);
}

void main(void)
{
  vec2 uv = out_texcoord;
  uv -= vec2(0.5); // move space from the center to the vec2(0.0)
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float energy = texture(texFFTSmoothed,0.011).r;
  uv = rotate2d( (sin(fGlobalTime)/texture(texFFTSmoothed,0.011).r/100)*PI+energy ) * uv; // rotate
  uv.x += fGlobalTime/3; // move (AFTER rotating!)
  uv += vec2(0.5); // move back to the original place

  vec3 col = vec3(0.);
  uv -= vec2(0.0); 
  uv = tile(uv,5.);
  float size = 0.4;
  float ext = texture(texFFTSmoothed,0.013).r*3.;
  col = vec3(box(uv,vec2(size+ext)),0.,0.);
  uv -= vec2(0.5); col += vec3(0.,sdCircle(uv),1.);
  //col += vec3(uv,0.); // visualise space

  out_color = vec4(col,1.);
}
