#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 uv) {return fract(sin(dot(vec2(3432.5, 5252.), uv) * 2023.0));}

float tt = mod(fGlobalTime + 0.001*hash(gl_FragCoord.xy/v2Resolution), 180.0);

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

float box(vec3 p) {
  return 0;
}

int bug[] = int[](
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
  0,0,0,2,2,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,2,2,2,0,0,0,0,
  0,0,0,2,2,0,2,0,2,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,2,0,2,0,0,0,0,
  0,0,0,2,2,2,2,0,2,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,2,2,2,0,0,0,0,
  0,0,0,2,0,2,2,0,2,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,2,0,2,0,0,0,0,
  0,0,0,2,2,2,2,2,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,2,2,2,0,0,0,0,
  0,0,0,2,2,2,0,2,0,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,0,
  0,0,0,2,0,0,0,2,0,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,
  0,0,0,2,0,2,0,2,0,0,2,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,0,
  0,0,0,2,0,2,0,2,0,0,2,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,2,0,2,0,2,0,0,2,0,1,1,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,
  0,0,0,2,2,2,0,0,2,2,0,0,0,1,0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,
  0,0,0,2,0,0,0,2,2,0,2,2,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,
  0,0,0,2,0,0,0,2,0,2,0,2,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,
  0,0,0,2,0,0,0,2,0,2,0,2,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,2,0,0,0,2,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,2,2,2,0,2,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
);

float sphere(vec3 p, float r) {
  return length(p) - r;
}

vec3 mapLogo(vec2 uv) {
  uv *= (0.5 + (2. * texture(texFFT, 0.01).r));
  float r = length(uv);
  //if (r < 0.5) {
    if (r < 0.12) uv *= rot2(tt * 0.7 + 3*sin(tt * 0.3)); else
    if (r < 0.18) uv *= rot2(tt * 1.5); else
    if (r < 0.25) uv *= rot2(tt * 0.3); else
    if (r < 0.4) uv *= rot2(tt * -1.3); else
                uv *= rot2(tt * 0.5);
      
    return textureLod(texRevisionBW, uv - vec2(0.5), 1).rgb;
  //} else return vec3(0.0);
  
}

vec3 triplanar(vec3 p, float t) {
  return (mapLogo(p.xy) + mapLogo(p.xz) + mapLogo(p.yz));
}

float map(vec3 p) {
  p.xy = abs(p.xy);
  p -= vec3(1.0);
  p.xz * rot2(tt*0.4);
  p.yz = abs(p.yz);
  p -= vec3(1.3);
  return sphere(p, 1.0) - 0.2*triplanar(p, tt).x;
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

void main(void)
{
	vec2 uv = (2.* (gl_FragCoord.xy / v2Resolution.xy) - 1.) * vec2(v2Resolution.x/v2Resolution.y, 1);
	
  uv.x += 1.4*fract(sin(fGlobalTime*4.6)*67.5*(round(uv.y*32)/32)) * texture(texFFT, 0.02).r;
  uv.y += 1.7*fract(sin(fGlobalTime*4.6)*47.5*(round(uv.y*32)/32)) * texture(texFFT, 0.01).r;

  
  vec3 color = vec3(abs(uv), 0.0);
  
  vec2 uuv = uv*rot2(tt*0.7);
  for (int i = 0; i < 5; i++) {
    uuv *= vec2(3);
    uuv = abs(uuv)*rot2(float(i+1)*0.3);
    color += -(1. / float(i+2))* mapLogo(uuv);
    //uuv = abs(uuv)*rot2(float(i+1)*0.3);
  }
  color += -1.0*texture(texFFT, abs(uuv.x*0.02)).rrr;
  color += (1.0*vec3(0.2 * hash(sin(uv.xy))*vec2(1.0, 2.0) + 0.3, 1.0));
  
  // time for raymarching!
  float fov = 0.2;
  float sp = 0.00;
  float ap = fov * 3.14159*2;
  float f = 1.0/ap;
  float r = length(uv);
  float phi = atan(uv.y, uv.x);
  float theta = atan(r/((1.+sp)*f))*(1+sp);
  
  vec3 ray = vec3(sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta));
  
  vec3 o = vec3(1.6 * sin(1.5 * tt), 3.4 * cos(tt*0.4), 2.4 * cos(tt*0.4));
  vec3 e = vec3(0.6 * sin(1.3 * tt), 0.4 * cos(tt*3.4), 0.4 * cos(tt*0.3));
  
  ray *= la(o, e, 0);
  
  float t = trace(o, ray);
  vec3 p = o+t*ray;
  
  if (!((t == 0.0) || (t > 128.0))) {
    color = 0.3*abs(norm(p));
  }
  
  ivec2 iuv = ivec2((gl_FragCoord.xy / v2Resolution.xy) * vec2(40,20) * (1.0 + 0.02*hash(uv.yx*texture(texFFT, 0.05).r))) ; 
  
  iuv.x += int(3.62*fract(sin(fGlobalTime*4.6)*67.5*(round(uv.y*32)/32)) * texture(texFFT, 0.02).r);
  iuv.y += int(1.57*fract(sin(fGlobalTime*4.6)*47.5*(round(uv.y*32)/32)) * texture(texFFT, 0.01).r);
  
  if ((bug[(20 - iuv.y) * 40 + iuv.x] == 1) && (texture(texFFT, 0.01).r > 0.085)) color = vec3(1.0) - color;
  if ((bug[(20 - iuv.y) * 40 + iuv.x] == 2) && (texture(texFFT, 0.01).r > 0.105)) color += 1.0;
  //if (((iuv.x ^ iuv.y) & 1) == 0) color *= 0.3;
  
  if (texture(texFFT, 0.04).r > 0.005) color *= clamp(1.0 - pow(r*0.3, 0.7), 0, 1);
  
  
  out_color = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}
