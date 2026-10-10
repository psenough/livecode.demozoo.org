#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t() {
    return fGlobalTime;
  }
  
mat3 rotX(float a) {
   float s = sin(a);
  float c = cos(a);
  return mat3(
    c, 0., s,
    0, 1, 0,
    -s, 0., c
  );

}


mat3 rotY(float a) {
   float s = sin(a);
  float c = cos(a);
  return mat3(
    1., 0., 0,
    0, c, -s,
    0, s, c
  );
}

vec2 fold(vec2 p, float a) {
    vec2 n = vec2(cos(-a),sin(-a));
    return p - 2. * max(0., dot(p,n)) * n;
  }
  
float de(vec3 p) {
  
  p = rotX(t() * .2) * rotY(t() * .113 ) * p;
  
  int n = 4;
  for(int i = 0; i < n; i++) {
    p *= 2.;
    p.x += 0.5;
    p.xy = fold(p.xy, .3);
    p.z -= .1;
    p.yz = fold(p.yz, .2  + sin(t()) * .1 + texture(texFFT, .01).r * 50.);
    p.x += .5;
    //p.y -= .4;
    p.xz = fold(p.xz, .4);
  }
  
  return length(p) / pow(2, n);
}
  
vec3 march(vec3 p, vec3 d) {
    float t = 0.;
   for(int i=0; i < 100;i++)  {
      float step = de(p + d * t);
      t += step;
     if( step < .05) {
        return vec3(vec3(.45, .2, .9) + vec3(.1, .4, .8) * cos(vec3(.5, .4, .1) + vec3(.7, .8, .7) * step * 29 + fGlobalTime));
     }
   }
   return vec3(0.);
}
  
  

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv.x = abs(uv.x);
  vec3 p = vec3(0., 0., -4.);
  vec3 d = normalize(vec3(uv.xy * .24, 1.));
  vec3 mc = march(p, d);
  vec4 c = vec4(mc, 1.);
  
  if(length(mc) < .1) {
       c += texture(texPreviousFrame, texture(texNoise, uv).xy + vec2(t() * .2) ) * .7;
    }
  
	float f = texture( texFFT, .1 ).r * 100;
	//out_color = vec4(uv, 0., 1.);
  out_color = c;
}