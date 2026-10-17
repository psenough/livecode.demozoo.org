#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = 3.14159265;
const float TORUS_R = 12.0;
const float TORUS_r = 3.0;

vec3 objPos;
float objAngle;
vec3 glow;

float b = texture(texFFT, 0.01).r * 10;

void rot(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float sdTorus(vec3 p, float R, float r) {
    vec2 q = vec2(length(p.xz) - R, p.y);
    return length(q) - r;
}

float sdCylinder(vec3 p, float r, float h) {
    vec2 d = vec2(length(p.xz) - r, abs(p.y) - h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float logo2D(vec2 p) {
    vec2 uv = p * 0.1 + 0.5;
    uv.y = 1.0 - uv.y;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
        return 1.0;
    float tex = texture(texRevisionBW, uv).r;
    return (0.1 - tex) * 0.5;
}

float logoSDF(vec3 p) {
    float cyl = sdCylinder(p, 5.0, 0.35);
    float cut = logo2D(p.xz);
    return max(cyl, cut);
}

vec2 opU(vec2 a, vec2 b) {
    return a.x < b.x ? a : b;
}

vec3 matColor(float id, vec3 p) {
    if (id < 0.5) { 
        float angle = atan(p.z, p.x);
        float seg = floor(angle / 0.4);
        float segId = mod(seg, 3.0);
        if (segId < 0.5) return vec3(0.961, 0.663, 0.722);
        if (segId < 1.5) return vec3(0.357, 0.808, 0.980);
        return vec3(b, b, b);
    }
    if (id < 1.5) return vec3(1.0, 0.9, 0.8); 
    return vec3(1.0);
}

vec2 sdf(vec3 p)
{
  float tun = -sdTorus(p, TORUS_R, TORUS_r);
  vec2 res = vec2(tun,0.0);
  
  vec3 T = vec3(-sin(objAngle),0.0,cos(objAngle));
  vec3 U = vec3(0.0,1.0,0.0);
  vec3 R = normalize(cross(U,T));
  
  vec3 pp = p - objPos;
  rot(pp.xy,fGlobalTime *0.5);
  
  float logo = logoSDF(pp*10.0)/10.0;
  glow += vec3(1.0, 0.7, 0.3) * 0.0004 / (0.01 + abs(logo));
  res = opU(res,vec2(logo,1.0));
  
  return res;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(
        sdf(p + e.xyy).x - sdf(p - e.xyy).x,
        sdf(p + e.yxy).x - sdf(p - e.yxy).x,
        sdf(p + e.yyx).x - sdf(p - e.yyx).x
    ));
}

void main(void)
{
  float spd = 4.0;
  float t = fGlobalTime;
  vec2 uv2 = gl_FragCoord.xy / v2Resolution.xy;
  vec2 q = (gl_FragCoord.xy - 0.5 * v2Resolution.xy) / v2Resolution.y;

  
  float cA = t *0.3 *spd;
  objAngle = cA + 0.15;
  
  vec3 cp = vec3(TORUS_R *cos(cA),0.0, TORUS_R *sin(cA));
  objPos = vec3(TORUS_R * cos(objAngle), 0.0, TORUS_R * sin(objAngle));
  objPos.y += sin(t*2.0)*0.3;
  
  vec3 cf = normalize(objPos - cp);
  vec3 cr = normalize(cross(vec3(0.0, 1.0, 0.0), cf));
  vec3 cu = cross(cf, cr);
  vec3 rd = normalize(q.x*cr + q.y*cu + 1.6*cf);
  
  float tr = 0.0;
  vec3 col = vec3(0.0);
  for (int i = 0; i < 120; i++) {
    vec3 p = cp+rd*tr;
    vec2 h = sdf(p);
    if (h.x < 0.005) {
      vec3 n = calcNormal(p);
      vec3 ld = normalize (cp-p);
      float diff = max(dot(n,ld),0.0);
      col = matColor(h.y,p)*(diff*0.7+0.2);
      break;
    }
    tr += h.x;
    if (tr > 50.0) break;
  }
  
  col += glow;
  
  vec2 cUV = uv2 - 0.5;
  
  float abr = 0.003 + b * 0.004;
  vec2 caDir = cUV * abr;
  col.r = mix(col.r, texture(texPreviousFrame, uv2 + caDir).r, 0.5);
  col.b = mix(col.b, texture(texPreviousFrame, uv2 - caDir).b, 0.5);
  
  float fbz= 0.97-b*0.01;
  vec2 fbuv= cUV*fbz;
  rot(fbuv,0.005);
  fbuv+=0.5;
  vec3 fb=texture(texPreviousFrame,fbuv).rgb;
  col=mix(col,fb,0.3+b*0.1);
  
  float vig = 1.0 - dot(cUV, cUV) * 0.3;
  col *= clamp(vig, 0.0, 1.0);
  
  col = smoothstep(0.0, 1.0, col);
  
	out_color = vec4(col, 1.0);
}