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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


 float ffti = texture(texFFTIntegrated, 1.).r * 1.;
 float ffts = texture(texFFTSmoothed, 0.).r * 3.;
  float fftr = texture(texFFTSmoothed, 1.).r * 10.;

 float blendColorBurn(float base, float blend) {
	return (blend==0.0)?blend:max((1.0-((1.0-base)/blend)),0.0);
}

vec3 blendColorBurn(vec3 base, vec3 blend) {
	return vec3(blendColorBurn(base.r,blend.r),blendColorBurn(base.g,blend.g),blendColorBurn(base.b,blend.b));
}

vec3 blendColorBurn(vec3 base, vec3 blend, float opacity) {
	return (blendColorBurn(base, blend) * opacity + base * (1.0 - opacity));
}

float sphere(vec3 p, float r) {
    return length(p) - r;
}

float box(vec2 p, vec2 b) {
    vec2 vv = abs(p)-b;
    return max(vv.x, vv.y);
}

float cylinder(vec3 p, float r, float h) {
    float d = length(p.xz)-r;
    d = max(d, abs(p.y) - h);
    return d;
}

float plane(vec3 p, vec3 n, float d) {
    return dot(p,n)+d;
}

void pR(inout vec2 p, float a) {
    p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

float modpolar(inout vec2 p, float n) {
    float ng = 2. * 3.14159 / n;
    float a = atan(p.y, p.x) + ng / 2.;
    float r = length(p);
    float c = floor(a / ng);
    a = mod(a, ng) - ng / 2.;
    p = vec2(cos(a), sin(a)) * r;
    if (abs(c) >= (n / 2.))
        c = abs(c);
    return c;
}


vec2 map(vec3 p) {
    float dist = 999.;
   float id = 0.;
  
  
    vec3 sphP = p + vec3(
    sin(fGlobalTime * 1.) * 1.,
  
    sin(fGlobalTime * 2.) * 0.3,
  
    sin(ffti * 2.) * 1.
  );
  float sph = sphere(sphP, .3);
  
  vec3 cylP = sphP;
  pR(cylP.xz, fGlobalTime);
  pR(cylP.xy, cos(length(cylP.xy) * 0.5) + fGlobalTime);
  pR(cylP.xz, sin(length(cylP.xz) * 0.5) + ffti);
  modpolar(cylP.yz, 6.);
  modpolar(cylP.yx, 6.);
  float cyl = cylinder(cylP, 0.03 * ffts, 10.);
  
  if (cyl < dist) {
      dist = cyl;
    id = 0.;
  }
  
  if (sph < dist){
      dist = sph;
     id = 1.;
   }
   
   
   float walls = -box(p.xy, vec2(3., 1.));
   if (walls < dist){
      dist = walls;
     id = 1.;
   }
   
   float wall = plane(p, vec3(0., 0., 1.), 2.);
   if (wall < dist) {
     dist = wall;
      id = 2.;     
    }
   
   return vec2(dist, id);
}


vec3 norm(vec3 p) {
    float E = 0.0001;
    vec2 k = vec2(1., -1.);
   return normalize(
      k.xyy * map(p + k.xyy * E).x +
      k.yyx * map(p + k.yyx * E).x +
      k.yxy * map(p + k.yxy * E).x +
      k.xxx * map(p + k.xxx * E).x
  );
}

float ao(vec3 p, vec3 n, float d) {
    return clamp(map(p + n * d).x / d, 0., 1.);
}


vec4 tr(vec3 ro, vec3 rd, vec2 uv) {
    float td = .1;
    vec2 h;
  
  vec3 c = vec3(0.);
  vec3 g = vec3(0.);
  vec3 gcol = vec3(1.);
  
  int bnc = 0;
  float en = 1.;
  
  for (int i = 0; i < 256; i++) {
      vec3 ip = ro + rd * td;
      h = map(ip);
     td += h.x * 0.5;
    
      if (h.y == 0.) {
          g += gcol * exp(-h.x * 10.) * (0.04);
      }
    
      if (h.x < 0.001) {
          vec3 inorm = norm(ip);
        
         if (h.y  == 0.) {
            c = gcol;
            break;
         } else if (h.y == 1.) {
            float nz = texture(texNoise, ip.xz).r / 2. + texture(texNoise, ip.zy).r / 2.;
           
            c += vec3(nz * .3) * en * ao(ip, inorm, .1);
            ro = ip;
            rd = reflect(rd, inorm + (nz * .2 - .1));
            td = .1;
            bnc += 1;
            en -= .7;
         } else {
           vec3 tp = ip;
           
      pR(tp.xy, ffts * 2. + 0.5);
            c += texture(texSessions, tp.xy * vec2(-.5, -1.) + vec2(fGlobalTime*0.2, ffti)).rgb * vec3(1., ffts * 10., 0.) * en; 
           break;
         }
      }
      
      if (h.x > 100. || bnc > 3 || en < 0.) {
          break;
      }
  }
  
  return vec4(c + g, 1.);
}


vec3 cam(vec3 pos, vec3 dir, vec2 uv) {
    vec3 f = normalize(dir - pos);
    vec3 l = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = normalize(cross(f, l));
    return normalize(f + l * uv.x + u * uv.y);
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 ro = vec3(smoothstep(0.,1.,sin(fGlobalTime)) * 2., 0., 5.);
  vec3 rd = cam(ro, vec3(0.), uv);
 
  
  vec3 rc = tr(ro, rd, uv).rgb;
  vec3 fc = blendColorBurn(tr(ro, rd, uv).rgb, texture(texSessionsShort, uv * vec2(1., -1.) * 1. + fGlobalTime * 0.1  + (ffts * 4. *  texture(texNoise, uv).r)).rgb * vec3(1.,abs(sin(ffti * 0.2)), 0.));
  
	out_color = vec4(mix(rc, fc, ffts * 3.), 1.);
}