#version 410 core

// i have absolutely no idea what to do lol :D

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 2300.0));}

float time = fGlobalTime;
float tt = mod(fGlobalTime + 0.001*hash(gl_FragCoord.xy/v2Resolution), 180.0);

// THAT'S NOT ALL LOL

vec3 mapLogo(vec2 uv) {
  return texture(texSessionsShort, uv).rgb;
}

vec3 triplanar(vec3 p) {
  return (mapLogo(p.xy) + mapLogo(p.yz) + mapLogo(p.xz));
}

float sphere(vec3 p, float r) {
    return length(p) - r;
}

mat2 rot2(float a) {return mat2(cos(a), -sin(a), sin(a), cos(a)); }

float map(vec3 p) {
  p.x = mod(p.x-5, 10.0)-5;
  
  p.yz *= rot2(tt*0.3);
  p.xz *= rot2(tt*0.2);
  p = abs(p);
  p -= vec3(1.0);
  p.xz = abs(p.xz);
  p.xz *= rot2(tt*0.4);
  p.xz = abs(p.xz);
  
  float m = sphere(p, 1.0);
  m -= 0.2*texture(texFFT, abs(p.x*2.7)*0.02).r;
  m -= 0.2*texture(texFFT, abs(p.y*3.6)*0.01).r;
  m -= 0.05*triplanar(p).x;
  return m;
}

vec2 trace(vec3 o, vec3 d) {
    float t = 0., min_ct = 100000.;
  
    for (int i = 0; i < 256; i++) {
      vec3 p = o + t*d;
      float ct = map(p);
      if ((abs(ct) < 0.001) || (t > 128.)) break;
      t += ct;
      min_ct = min(min_ct, ct);
    }
    
    return vec2(t, min_ct);
}

vec3 normal(vec3 p) {
  vec2 b = vec2(0, 0.01);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}

mat3 la (vec3 o, vec3 t, float r) {
  vec3 rr = vec3(sin(r), cos(r), 0.0);
  vec3 ww = normalize(t - o);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(rr, vv, ww);
}

void main(void)
{
	vec2 uv = (2. * (gl_FragCoord.xy / v2Resolution.xy) - 1.) * vec2(v2Resolution.x/v2Resolution.y, 1);
  
  uv.x += 0.3*fract(sin(fGlobalTime*2.3)*45.3*(round(uv.y*32)/32)) * texture(texFFT, 0.02).r;
  uv.y += 0.2*fract(sin(fGlobalTime*2.3)*45.3*(round(uv.x*32)/32)) * texture(texFFT, 0.01).r;
  vec2 fuv = uv;
  
  vec3 color = vec3(abs(uv), 1.0);
  float ttt = tt + texture(texFFT, 0.3).r;
  // logo mapper 
  uv *= 1.0 + 0.4*sin(ttt*0.7);
  vec2 uuv = uv * rot2(ttt*0.4);
  for (int i = 0; i < 3; i++) {
    color = mix(color, 1.0*mapLogo(uuv), 0.5);
    uuv = abs(uuv) * rot2(float(i+1)*0.5 + tt*0.2);
    uuv *= vec2(6);
  }
  color *= 0.1+0.9*mapLogo(abs(uv*rot2(tt*0.6)) * rot2(tt*0.4));
  color += texture(texFFT, abs(fuv.x*0.01)).r*texture(texFFT, abs(fuv.y*0.02)).r;
  
  // raymarch
  vec3 o = vec3(0, 0, 6);
  vec3 e = vec3(0, 3, 1);
  vec3 ray = normalize(vec3(fuv, -1.2));
  
  //ray *= la(o, e, 0);
  
  vec2 t = trace(o, ray);
  vec3 p = o+t.x*ray;
  
  color += 0.04*clamp(15.0/t.y, 0, 1);
  if (!((t.x == 0.0) || (t.x > 128.0))) {
    vec3 xx = abs(normal(p));
    color = mix(vec3(0.1, 0.1, 0.2), vec3(0.7, 1.0, 0.8), sin(xx.x * xx.y * xx.z* 3.5));
  }
  
  color += 0.3*textureLod(texPreviousFrame, (gl_FragCoord.xy / v2Resolution.xy), 4).rgb; 
  
  color *= pow(1.0 - 0.3*length(fuv), 1.8);
  color *= mix(vec3(0.9, 1.0, 0.9), vec3(0.8, 0.5, 0.4), clamp(uv.x*uv.y, 0, 1));
  out_color = vec4(pow(color, vec3(0.45)), 1.0);
  
}