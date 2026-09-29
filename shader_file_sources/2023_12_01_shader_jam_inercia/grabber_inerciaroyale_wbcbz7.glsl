#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

// we'll start with simple atmta stuff just to fill the screen time =)

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 2300.0));}

float time = fGlobalTime;
float tt = mod(fGlobalTime + 0.001*hash(gl_FragCoord.xy/v2Resolution), 180.0);

vec3 mapLogo(vec2 uv) {
  return texture(texNoise, uv).rgb;
}

vec3 triplanar(vec3 p) {
  return (mapLogo(p.xy) + mapLogo(p.xz) + mapLogo(p.yz));
}

vec3 mod(vec3 p, vec3 s, vec3 l) {
  vec3 q = p - s*clamp(round(p/s),-1,1);
  return q;
}

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

float sphere(vec3 p, float r) {
  return length(p) - r - (0.7)*triplanar(p).r;
}

float map(vec3 p) {
  p = abs(p - vec3(0.4));
  p.xy *= rot2(0.3*time);
  p = abs(p - vec3(0.76));
  p.yz *= rot2(0.5*time);
  return sphere(mod(p, vec3(12.0), vec3(2.0)), 1.0+1.3*texture(texFFT, 0.01).r);
}

vec3 norm(vec3 p) {
  vec2 b = vec2(0., 0.01);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}


float trace(vec3 o, vec3 d) {
  float t = 0.;
  for (int i = 0; i < 256; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((abs(ct) < 0.001) || (t > 128.)) break;
    t += ct;
  }
  
  return t;
}

mat3 la(vec3 o, vec3 t, float r) {
  vec3 rr = vec3(sin(r), cos(r), 0.0);
  vec3 ww = normalize(t - o);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}

// DXM COLORS LOL

void main(void)
{
	vec2 src_uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = src_uv - vec2(0.5);
  
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv += 0.1*hash(vec2(time, time));

  vec3 color = vec3(0.0);
  
  uv.x += 0.02*fract(sin(fGlobalTime*4.6)*67.5*(round(uv.y*32 + 15)/32)) * sqrt(texture(texFFT, 0.02).r);
  uv.y += 0.02*fract(sin(fGlobalTime*4.6)*47.5*(round(uv.y*32 + 15)/32)) * sqrt(texture(texFFT, 0.02).r);
  
  // rotator
  vec2 uuvv = uv;
  uuvv *= rot2(time*0.9)*1.2;
  uuvv += 0.2*sin(time*0.01);
  uuvv = abs(uuvv);
  uuvv *= rot2(time*0.8);
  uuvv = abs(uuvv) - 0.4;
  uuvv *= rot2(time*0.6);
  uuvv += vec2(time)*0.2;
  
  color += mix(texture(texInercia, uuvv).rgb, pow(textureLod(texPreviousFrame, uuvv, 2).rgb, vec3(2)), 0.3);
  color += sqrt(texture(texFFT, pow(length(uv), 2.6)).rrr);
  color = mix(color, pow(textureLod(texPreviousFrame, src_uv, 1).rgb, vec3(2)), 0.3 + 0.4*sin(time*0.2));
  
  // some logical stuff
  ivec2 iuv = ivec2(uv * vec2(320, 180));
  if ((((iuv.x ^ iuv.y ^ int(time*70)) & ((iuv.x * iuv.y)>>1) & ((iuv.x ^ iuv.y ^ int(time * 6)) >> (int(time*7) % 9))) & 1) == 0) {
    color = color * 0.4*mix(vec3(1), color, 0.1);
  }
  
  // trace something
  float fov = 0.3;
  float sp = 7.60;
  float ap = fov * 3.14159*2;
  float f = 1.0/ap;
  float r = length(uv);
  float phi = atan(uv.y, uv.x);
  float theta = atan(r/((1.+sp)*f))*(1+sp);
  vec3 ray = vec3(sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta));
  vec3 o = vec3(-12 * cos(0.1*time), -12 * cos(1*time), -12 * sin(1*time));
  vec3 e = vec3(0, 0, 0);
  
  ray *= la(o, e, 1.0);
  ray.xy *= rot2(time*0.6);

  
  float t = trace(o, ray);
  vec3 p = o+t*ray;
  
  p = mix(p, norm(p), 0.5);
  if (!((t == 0.0) || (t > 128.0))) {
    color = 0.1* color + 0.8*vec3(cos(p.x), sin(p.y), sin(p.x)*cos(p.y));
  }
  
  color = pow(color, vec3(0.5));
  
  if ((int(time) % 3) > 1) {
    color = vec3(ivec3(color * vec3(5))/vec3(3));
  }
  
	out_color = vec4(color, 1.0);
}