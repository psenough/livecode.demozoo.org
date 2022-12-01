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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float t = fGlobalTime;
vec3 cam(vec3 ro, vec3 rd, vec2 uv) {
  vec3 f = normalize(rd - ro);
  vec3 l = normalize(cross(vec3(0,1,0), f));
  vec3 u = normalize(cross(f, l));
  
  return normalize(f + l * uv.x + u * uv.y);
}

float ni(float a){
    return texture(texFFTIntegrated, a).x;
}


void mo(inout vec2 p,vec2 d){p = abs(p)-d;if(p.y>p.x)p=p.yx;}
vec3 rep(vec3 p, vec3 c) { return mod(p + .5 * c, c) - .5 * c; }
vec3 repl(vec3 p,vec3 c,vec3 l){return p-c*clamp(round(p/c),-l,l);}
mat2 rot(float t) { return mat2(cos(t), sin(t), -sin(t), cos(t)); }
float sdBox(vec3 p, vec3 b) { vec3 q = abs(p) - b; return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0); }
float sdSphere(vec3 p, float r) { return length(p) - r; }
float sdPlane(vec3 p, vec3 n, float h) { return dot(p,n) + h; }
float rnd(float p) { p = fract(p * .131); p *= p + 333.33; return fract(2 * p * p); }
float dirlight(vec3 n, vec3 ld) {
  ld = normalize(ld);
  return clamp(max(dot(n, ld), 0), 0, 1);
 }
float spec(vec3 p, vec3 n, vec3 ld, float k) {
    ld = normalize(ld);
    vec3 r = reflect(-ld, n);
    vec3 v = normalize(-p);
    return pow(max(dot(r,n), 0), k);
}
vec3 palette(float t) {
    vec3 a= vec3(1);
    vec3 b= vec3(1);
    vec3 c = vec3(2);
    vec3 d = vec3(0,.1, .2);
    return a + b * cos(6.28318 * (c * t + d));
}

vec2 ground(vec3 p) {
    float plane = sdPlane(p, vec3(0,1,0), 0);
    float cracks = texture2D(texNoise, p.xz * 0.05).r;
    float crack = 0.28;
  
    return vec2(
    plane + texture2D(texTex2, p.xz * .7).r * 0.03
      + texture2D(texNoise, p.zx * 0.1).r * 1
      + texture2D(texNoise, p.xz * 0.01).r * 10,
      
       cracks > crack && cracks < crack + 0.01 ? 4 : 0
    );
}


float bid;
float tunnel(vec3 p) {
    vec3 bp = p;
    bp.xy *= rot(bp.z * 0.1);
    mo(bp.xy, vec2(0.5));
    mo(bp.zy, vec2(0.5));
    bid = rnd(round(p.z + 0.5) * 120);
    float b = sdBox(rep(bp + vec3(-1.5, 0, 0), vec3(0, 0, 2)), vec3(0.1, 1.5, 0.1));
    return b;
}


float sid;
vec2 sphrs(vec3 p) {
  p = p + vec3(0,0,-t - 7 + texture(texFFTSmoothed, 0.1) * 20);
  p.xz *= rot(t);
  p.yz *= rot(t);
  sid = rnd(round(p.x - 0.75) * 10 + round(p.y - 0.75) * 20 +  round(p.z - 0.75) * 10);
  p = repl(p, vec3(.5), vec3(2));
  float s = sdSphere(p + vec3(sin(t * 10 + p.x / 10) * 0.05), .2 - abs(sin(sid * 60 + t)) * .15);
  return vec2(s, fract(sid + t) < 0.9 ? 2 : 3);
}

vec2 map(vec3 p) {
    float m = 999;
    float mm = 0;
    
    vec2 g = ground(p);
    if (g.x < m) { m = g.x; mm = g.y; }
    
    float t = tunnel(p);
    if (t < m) { m = t; mm = 1; }
    
    vec2 s = sphrs(p);
    if (s.x < m) { m = s.x; mm = s.y; }
    
    return vec2(m, mm);
}
vec3 norm(vec3 p) {
    float E = 0.01; vec2 k = vec2(1, -1);
    
    return normalize(
      k.xyy * map(p + k.xyy * E).x +
      k.yyx * map(p + k.yyx * E).x +
      k.yxy * map(p + k.yxy * E).x +
      k.xxx * map(p + k.xxx * E).x 
    );
}

vec3 bg(vec2 uv) {
    float h = uv.y;
    float n = texture2D(texNoise, vec2(uv.x, uv.y - t * 0.05)).x;
    float s = texture2D(texNoise, uv * 6 + vec2(sin(t) + t, cos(t))).x > 0.45 ? 1 : 0;
  
    return vec3(n * h*2 * palette(uv.y / 2.1));
}


vec3 ld = vec3(0, 30, 10);
vec4 tr(vec3 ro, vec3 rd, vec2 uv) {
    float td = 1;
    vec2 h;
    vec4 c = vec4(0);
    vec4 g = vec4(0);
    int bnc = 0;
    float en = 1.;
  
    for (int i = 0; i < 1000; i++) {
        vec3 ip = ro + rd * td;
        h = map(ip);
        td += h.x * 0.7;
      
        if (h.y == 1) {
            g += vec4(palette(bid * (ni(0.15) * 1 + t / 2)) * exp(-h.x * 10) * .07, 1.);
        }
        
        if (h.y == 3) {
          g += vec4(palette(sid / 10) * exp(-h.x * 10) * .07, 1.);
        }
        if (h.y == 4) {
          g += vec4(palette(0.63 + sin(ip.x / 10 + t * 0.2)) * exp(-h.x * 10) * (.5 + abs(sin(ip.x + ip.z + t)) * .5), 1.);
        }
       
      
        if (h.x < 0.01) {
          vec3 inorm = norm(ip);
          
          if (h.y == 0) {
              c += vec4(dirlight(inorm, ld) * palette(ip.y * 0.2 + 0.45) * en * 0.7 + spec(ip, inorm, ld, 20), 1) * en;
           }
           
           if (h.y == 1) {
                c += vec4(palette(bid * (ni(0.15) * 1 + t / 2)) * en, 1.);
           }
           
           if (h.y == 2) {
             c += vec4(0.2) * en;
             ro = ip;
             rd = reflect(rd, inorm);
             td = .1;
             bnc += 1;
             en = max(en - .7, 0);
           }
           
           if (h.y == 3) {
               c += vec4(palette(sid / 10) * en, 1.);
            }
            
            if (h.y == 4) {
                c += vec4(0.9);
            }
        }
        
        if (td > 200) {
            return vec4(bg(uv) + vec3(g) * exp(-td * 0.05), td/1000);
        }
      
        if (c.a >= 1 || bnc > 1 || en < 0 || td > 1000) break;
    }
    
    return vec4((vec3(c) + vec3(g)) * exp(-td * 0.05), td/1000);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 ro = vec3(fract(t / 10) > 0.5 ? 10 : 0, 0, t);
  vec3 rd = cam(ro, vec3(0,0,t + 10), uv);
  out_color = tr(ro, rd, uv);
}