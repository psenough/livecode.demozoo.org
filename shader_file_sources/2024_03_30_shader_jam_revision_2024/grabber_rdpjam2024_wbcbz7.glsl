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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 2300.0));}

float time = fGlobalTime;
float tt = mod(fGlobalTime + 0.01*hash(gl_FragCoord.xy/v2Resolution), 180.0);

const float PI = 3.14159265359;

float star(vec2 uv, float t) {
    float r = length(uv)*32.;
    float a = atan(uv.y, uv.x) - PI;
    float v = (1.+sin(r*(1.-.4*sin(5.*a + PI/3.))+0.3*t)) *.7;
    return v; 
}

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

vec3 mapLogoRot(vec2 uv) {
  uv *= (1.0 + (0.2 * texture(texFFT, 0.01).r));
  float r = length(uv);
  //if (r < 0.5) {
    if (r < 0.12) uv *= rot2(tt * 0.7 + 3*sin(tt * 0.3)); else
    if (r < 0.18) uv *= rot2(tt * 1.5); else
    if (r < 0.25) uv *= rot2(tt * 0.3); else
    if (r < 0.4) uv *= rot2(tt * -1.3); else
                uv *= rot2(tt * 0.5);
      
    return textureLod(texRevisionBW, clamp(uv+vec2(0.5), vec2(0), vec2(1)), 1).rgb;
  //} else return vec3(0.0);
  
}

vec3 mapLogo(vec2 uv) {
  return texture(texNoise, uv).rgb;
}

vec3 triplanar(vec3 p) {
  return (mapLogo(p.xy) + mapLogo(p.xz) + mapLogo(p.yz));
}

float sphere(vec3 p, float r) {
  return length(p) - r - (0.5*triplanar(p*0.7).r);
}

vec3 mod3(vec3 p, vec3 s, vec3 l) {
  vec3 q = p - s*clamp(round(p/s),-1,1);
  return q;
}

float map(vec3 p) {
  p.xz *= rot2(0.4*time);
  p = abs(p - vec3(1.4));
  p.xy *= rot2(0.9*time);
  p = abs(p - vec3(1.6));
  p.yz *= rot2(0.8*time);
  return sphere(mod3(p, vec3(5.0), vec3(5.0)), 2.0+2.3*texture(texFFT, 0.01).r);
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


void main(void) {
	vec2 src_uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = src_uv - vec2(0.5);
  
	uv *= vec2(v2Resolution.x / v2Resolution.y, 1);
  uv.x += 0.03*(sin(fGlobalTime*4.6))*hash(vec2(tt, tt))* sqrt(texture(texFFT, 0.01).r);
  uv.y += 0.03*(sin(fGlobalTime*7.6))*hash(vec2(tt, tt))* sqrt(texture(texFFT, 0.01).r);

  vec3 color = vec3(0.0);
  
  uv.x += 0.05*fract(sin(fGlobalTime*4.6)*67.5*(round(uv.y*32 + 15)/32)) * sqrt(texture(texFFT, 0.02).r);
  uv.y += 0.05*fract(sin(fGlobalTime*4.6)*47.5*(round(uv.y*32 + 15)/32)) * sqrt(texture(texFFT, 0.02).r);
  
  // backdrop
  float spiral = star(rot2(tt*1.4)*uv*(0.1+0.7*sin(time*1.4)), time);
  float tex = -mapLogoRot(uv).r;
  //float tex   = -texture(texRevisionBW, clamp(uv+vec2(0.5), vec2(0), vec2(1))).r;
  float noise = texture(texNoise, (uv*5)+tt*10).r*2;
  color = (((spiral + noise)+tex) > 1.0 ? 
    mix(vec3(0.4, 0.5, 0.4), vec3(0.4, 0.6, 0.7), 2*(texture(texFFT, 0.03).r)) :
    vec3(0.3, 0.42, 0.4));
  
  // now time to at least SOME raymarching stuff AAAAAAAAAAAAAAA FUUUUUUUUUUUUUKA
  // trace something
  float fov = 0.3;
  float sp = 7.60;
  float ap = fov * 3.14159*2;
  float f = 1.0/ap;
  float r = length(uv);
  float phi = atan(uv.y, uv.x);
  float theta = atan(r/((1.+sp)*f))*(1+sp);
  vec3 ray = vec3(sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta));
  vec3 o = vec3(-4 * cos(0.1*time), -3 * cos(1*time), -2 * sin(1*time) - 14);
  vec3 e = vec3(0, 0, 0);
  ray *= la(o, e, 0.0);
  
  float t = trace(o, ray);
  vec3 p = o+t*ray;
  
  p = mix(p, norm(p), 0.5);
  if (!((t == 0.0) || (t > 128.0))) {
    vec3 n = p;//norm(p);
    //n = cross(n,p);
    color += 0.5*pow(0.5+0.5*vec3(sin(1.3*n.x),cos(1.3*n.y),sin(1.7*n.z)), vec3(1.0));
  }
  
  // random lines
  if (hash(vec2(float(int(src_uv.y*50))+mod(time,1))) > (0.2+2.7*sqrt(texture(texFFT, 0.02).r))) color += vec3(0.03);
  if (hash(vec2(float(int(src_uv.y*30))+mod(time,5))) > (0.2+2.7*sqrt(texture(texFFT, 0.04).r))) color -= vec3(0.03);
  
  
  
  // vingette
  color *= 1.0-0.9*length(src_uv-vec2(0.5));
  //color = pow(color, vec3(0.7));
  
  out_color = vec4(color,1);
}