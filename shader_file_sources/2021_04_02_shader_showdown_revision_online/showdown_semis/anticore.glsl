#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texRevision;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float time = fGlobalTime;
float rnd(float a) { a = fract(a * .123); a *= a + 12.23; a*=a+a; return fract(a);}
vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 cam(vec3 ro, vec3 rd, vec2 uv) {
    vec3 f = normalize(rd-ro);
    vec3 l = normalize(cross(vec3(0,1,0), f));
    vec3 u = normalize(cross(f,l));
    return normalize(f + l * uv.x + u * uv.y);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0));
}

vec3 rep(vec3 p, vec3 c) {
    return mod(p + .5 * c, c)-.5 * c;
}
float ni(float a) { return texture(texFFTIntegrated, a).x; }


float cid = 0;

vec2 map(vec3 p) {
 
  cid = rnd(round(p.x) * 120. + round(p.z) * 152.);
    
  
    vec3 pp = p;
    pp = rep(pp, vec3(5, 0, 0));
    float t = sdBox(pp, vec3(1, 1, 1));
  
    p += vec3(0.5,2 - abs(sin(time) * 3.) * 0.1 - abs(round(p.z)) * 0.2,0.);
    p = rep(p, vec3(1,0,1));
    float c = sdBox(p, vec3(.4)) - .05;
 
    return vec2(min(c, t), c < t ?  1 : 2);
}

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.283 * (c * t + d));
}


vec3 norm(vec3 p) {
    float E = 0.001; vec2 k = vec2(1, -1);
    return normalize(
      k.xyy * map(p + k.xyy * E).x + 
  
      k.yyx * map(p + k.yyx * E).x + 
      k.yxy * map(p + k.yxy * E).x + 
      k.xxx * map(p + k.xxx * E).x
  );
}

vec4 tr(vec3 ro, vec3 rd, vec2 uv) {
    float td = 1;
    vec2 h;
  
    vec4 c = vec4(0);
  
    for (int i = 0; i < 600; i++) {
        vec3 ip = ro + rd * td;
        h = map(ip);
      
        td += h.x < 0.1 ? 0.01: h.x * 0.5;
      
        if (h.x < 0.01) {
            vec3 inorm = norm(ip);
            if (h.y == 1) {
          
            c += vec4(pal(cid * 2 + time ,vec3(.5),vec3(.5),vec3(1., 1., .2),vec3(.9, .5, .9)) * max(dot(inorm, vec3(-10, 10, -10)), 0) * 0.1, 1);
              break;
            } 
            
            if (h.y == 2 && (1-texture(texRevision, (ip.zy + 1) / 2).r > 0.5)) {
                c += vec4(pal(ip.y + time ,vec3(.5),vec3(.5),vec3(1., 1., .2),vec3(.9, .5, .9)), 1.) * exp(-h.x * 70) * 0.01;
            }
        }
    }
    
    return c;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(-5 + time * 2,0,0);
  vec3 rd = cam(ro, vec3(sin(ni(0) * 3) + time,0,sin(time)), uv);
  
  out_color = tr(ro, rd, uv);
}