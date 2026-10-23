#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 getTexture(sampler2D sampler, vec2 uv){
                vec2 size = textureSize(sampler,0);
                float ratio = size.x/size.y;
                return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}

vec2 pModMirror2(inout vec2 p, vec2 size) {
  vec2 halfsize = size * 0.5;
  vec2 c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  p *= mod(c, vec2(2)) * 2.0 - vec2(1);
  return c;
}


vec2 pModGrid2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size * 0.5) / size);
  p = mod(p + size * 0.5, size) - size * 0.5;
  p *= mod(c, vec2(2)) * 2.0 - vec2(1);
  p -= size / 2.0;
  if (p.x > p.y) p.xy = p.yx;
  return floor(c / 2.0);
}


float sdSphere(vec3 p, float r) {
    return length(p) - r;
}




vec2 map(vec3 p) {
  vec2 pid = pModGrid2(p.xy, vec2(.2));
  float sph = sdSphere(p, .1 + texture(texFFT, 0.).r);
  
  
  float m = 999.;
  float mm = 0.;
  if (sph < m) {
   m = sph;
    mm = 0.;
  }
  
  return vec2(m, mm);  
}

vec3 f_norm(vec3 p) {
  float E = 0.0001;
  vec2 k = vec2(1.0, -1.0);
  return normalize(
    k.xyy * map(p + k.xyy * E).x +
      k.yyx * map(p + k.yyx * E).x +
      k.yxy * map(p + k.yxy * E).x +
      k.xxx * map(p + k.xxx * E).x
  );
}

vec3 bg(vec2 uv) {
 return getTexture(texInerciaLogo2024, uv).rgb;  
}


vec3 tr(vec3 ro, vec3 rd, vec2 uv) {
  float td = .01;  
  vec2 h;
  
  vec3 c = vec3(0.);
  vec3 g = vec3(0.);

  
  for (int i = 0; i < 100; i++) {
       h = map(ro + rd * td);
       td += h.x * 0.6;
  
    
       if (h.x < 0.0005) {
        vec3 hp = ro + rd * td;
        vec3 hn = f_norm(hp);
         
         if (h.y == 0.) {
               return hn;  
            }
            else if (h.y == 1.) {
               return hn;
              }
         
       }
       
  }
  
  
  return vec3(c);  
}

void main(void)
{ 
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(0., 0., 3.);
  vec3 rd = normalize(vec3(uv, 0.) - ro);
  
	out_color = vec4(tr(ro, rd, uv), 1.);
}