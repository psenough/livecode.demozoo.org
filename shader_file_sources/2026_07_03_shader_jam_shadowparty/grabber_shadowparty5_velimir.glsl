#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.1415926535
#define TAU (2. * PI)
#define MAX_STEPS 50
#define MAX_DIST 100.
#define EPSILON 0.001
#define _cos(x) (cos(x) * .5 + .5) 
#define _sin(x) (sin(x) * .5 + .5) 

float sceneSDF(vec3 p) {
    return length(p - vec3(0., 0., 5.)) - .5;
}

vec3 calcNormal( in vec3 p ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(sceneSDF(p+h.xyy) - sceneSDF(p-h.xyy),
                           sceneSDF(p+h.yxy) - sceneSDF(p-h.yxy),
                           sceneSDF(p+h.yyx) - sceneSDF(p-h.yyx) ) );
}

float rayMarch(vec2 uv, out float dist, out vec3 pos) {
    vec3 rayOrigin = vec3(0.0);
    float fov = 90.;
    vec3 rayDir = normalize(vec3(uv * sin(fov / 2.), 1.));
    dist = 0.;
  
    for (int i = 0; i < MAX_STEPS && dist < MAX_DIST; i++) {
       pos = rayOrigin + rayDir * dist;
       float stepSize = sceneSDF(pos);
       dist += stepSize;
       if (stepSize < EPSILON) {
          return 1.;
       }
    }
    
    return 0.;
}

vec3 light(vec3 pos, vec3 lightPos) {
    vec3 normal = calcNormal(pos);

   
    return vec3(dot(normalize(lightPos - pos), normal));
}

#define iTime fGlobalTime

void main(void)
{
	vec2 uv = (gl_FragCoord.xy - v2Resolution * .5) / min(v2Resolution.x, v2Resolution.x);

  float turn = (atan(uv.y, uv.x) + TAU) / TAU;
  float nbParts = 32.;
  float part = floor(turn * nbParts) / nbParts;
  float maxFreq = 2000.;
  float minFreq = 100.;
  float intensity = texture(texFFT, 100. * pow(2., part)).r;
  intensity = pow(intensity, .3);

  vec3 color;
  
  color = vec3(step(length(uv), intensity));

  float dist;
  vec3 pos;
  vec3 lightPos = 3. * vec3(cos(iTime), sin(iTime), 0.);
  if (rayMarch(uv, dist, pos) > .5) {
     //color = vec3(1.);
     //color = vec3(1./ length(dist));
     color = light(pos, lightPos);
  }
  

  out_color = vec4(color, 1.);
}