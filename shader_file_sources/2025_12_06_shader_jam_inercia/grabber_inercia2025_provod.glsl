#version 420 core

// sorry im late lol

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//float h1(float f){return fract(sin(f)*56532.324);}
//float h2(vec2 v){return h1(dot(v,vec2(17.3,19.7)));}

vec4 noise2(vec2 v){
  return texture(texNoise, v/textureSize(texNoise, 0));
}

const float PI=3.1415926;
vec2 pol(vec3 p){
  return vec2(atan(p.x,p.y)/PI*.5+.5, p.z);
}
float w(vec3 p){
  vec2 po=pol(p);
  //float R = texture(texNoise, po*vec2(0., 0.)).r*4.;
  float R = texture(texNoise, po*vec2(1., 0.005)).r*4.;
  float r = 2. - R - length(p.xy);
  return r;
}

float tr(vec3 o,vec3 d,float l, float L){
  for (float i=0.;i<100.;i+=1.){
    float dw=w(o+d*l);l+=dw;
    if (dw<.001||l>L)break;
  }
  return l;
}
float t;

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
  t=fGlobalTime;
  vec3 C=vec3(0.);
  vec3 bg=vec3(2.);
  vec3 O=vec3(0.,0.,mod(-t*30.,1500.)),D=normalize(vec3(uv, -2.));
  float L=50.,l=tr(O,D,0.,L);
  float tl=clamp(0., 1., l/L);
  vec3 P=O+D*l;
  if (l<L){
    vec2 po=pol(P);
    C=texture(texInercia2025, po.yx*vec2(.02,1.)).rgb;
  }
  C = mix(C, bg, pow(tl, 3.));
  
  //C=vec3(texture(texNoise, uv*40.));
	out_color = vec4(sqrt(C), 0.);
}