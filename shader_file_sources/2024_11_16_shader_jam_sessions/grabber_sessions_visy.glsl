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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t;

mat3 rotate_x(float a){float sa = sin(a); float ca = cos(a); return mat3(vec3(1.,.0,.0),    vec3(.0,ca,sa),   vec3(.0,-sa,ca));}
mat3 rotate_y(float a){float sa = sin(a); float ca = cos(a); return mat3(vec3(ca,.0,sa),    vec3(.0,1.,.0),   vec3(-sa,.0,ca));}
mat3 rotate_z(float a){float sa = sin(a); float ca = cos(a); return mat3(vec3(ca,sa,.0),    vec3(-sa,ca,.0),  vec3(.0,.0,1.));}

// rhomby
float sdf(vec3 pos, float size, float edge) {
  pos = abs(pos);
  pos*=rotate_y(pos.z*0.1)*0.8;
  pos*=rotate_z(pos.y*0.1)*1.4+cos(pos.z*10.3)*0.01;
  pos*=rotate_x(pos.x);

  pos = vec3(
    pos.y + pos.z,
    pos.x + pos.z,
    pos.x + pos.y
  );

  pos -= clamp(pos, 0.0, size-edge);

  return length(pos)-edge; 
};


vec3 calcNormal(vec3 p) {
  float h = 1;
  return normalize(vec3(
        sdf(p + vec3(h, 0, 0), 1.0, 0.2) - sdf(p - vec3(h, 0, 0), 1.0, 0.2),
        sdf(p + vec3(0, h, 0), 1.0, 0.2) - sdf(p - vec3(0, h, 0), 1.0, 0.2),
        sdf(p + vec3(0, 0, h), 1.0, 0.2) - sdf(p - vec3(0, 0, h), 1.0, 0.2)
  ));
}

float raymarch(vec3 ro, vec3 rd) {
  float dist = 0.0;
  for (int i = 0; i < 20; i++) {
    vec3 p = ro + rd * dist;
    p = mod(p,6)-cos(rd.z+1.0)*3;
    float d = sdf(p,3.,1.0);
    if (d < 1.0) return dist;
    dist += d;
    if (dist > 15.0) break;
  }
  return -1.0;
}

vec3 getTexture(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,t*0.2+uv*vec2(1,1*ratio)-.5).rgb*10.5;
}

vec3 getTexture2(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,-t*0.2+uv*vec2(1,1*ratio)-.5).rgb*10.5;
}


void main(void)
{
  vec2 uv = (gl_FragCoord.xy / v2Resolution.xy) * 2.0 - 1.0;
  uv.x *= v2Resolution.x / v2Resolution.y;

  t = mod(fGlobalTime,64.0);
  
  // cam
  float z = t*3.;
  vec3 ro = vec3(0.1+cos(t*3.5)*0.5,sin(t*3.5)*0.5,0+z);
  vec3 rd = normalize(vec3(uv, -1.0));
  
  // march
  float result = raymarch(ro,rd);
  if (result > 0.0) {
    vec3 pos = ro + rd * result;
    vec3 normal = calcNormal(pos);
    vec3 lightDir = normalize(vec3(0.,1.0,-1.5+cos(t*0.5)*2));
    float diffuse = max(dot(normal, lightDir), 0.0);
    
    vec3 color = vec3(0.2+result*cos(0.09+mod(result,1))*0.04,0.6-result*0.01,0.9/cos(-result*0.04)) * diffuse;
    out_color = vec4(1.0*color,1.0);
    out_color -= vec4(getTexture2(uv),1.0);
  }
  else {
    out_color += vec4(getTexture(uv)*0.2,1.0);
  }

}