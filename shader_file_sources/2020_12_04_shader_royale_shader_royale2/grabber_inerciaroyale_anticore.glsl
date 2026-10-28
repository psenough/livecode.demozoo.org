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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sdSphere(vec3 p, vec3 pos, float r) {
  return length(p + pos) -r;
}

mat2 rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c,s,-s,c);
}

float sdBox(vec3 p, vec3 pos, vec3 b) {
    vec3 q = abs(p + pos) - b;
    return min(max(q.x, max(q.y, q.z)), 0);
}

float sdBoxes(vec3 p, vec3 pos, vec3 b) {
    float n = texture(texFFTSmoothed, 0.2).x;
    p.xy *= rot(sin(fGlobalTime * 3.));
    p.y += sin(fGlobalTime * 2 + p.x + n * 10.);
    p = vec3(p.x, mod(p.y, 0.4 + n * 2), p.z);
    vec3 q = abs(p + pos) - b;
    return min(max(q.x, max(q.y, q.z)), 0);
}

float opMin(float d1, float d2) {
    return max(-d1, d2);
}

float opSmooth(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0, 1);
  return mix(d2, d1, h) - k * h * (1-h);
}

float sdSpheres(vec3 p) {
    float n = texture(texFFTSmoothed, 0).x;
    p = p - mod(p, 0.16 + n - abs(cos(fGlobalTime)) / 5 );
    float t = fGlobalTime;
  
    float spheres = 999;
    for (int i = 0; i < 18; i++) {
        float p1 = t / 2 * i;
        float p2 = t /4 * (5 - i);
        float p3 = t + i * 2;
      
        spheres = opSmooth(spheres, sdSphere(p, vec3(sin(p1)*3, cos(p2)*3, sin(p3)+12), i * 0.05), 1);
    }
    
    return spheres;
}

vec2 map(vec3 p) {
    float n = texture(texFFT, 0.2).x;
    float s = sdSphere(p, vec3(0,0,10), 2 + n * 12);
    float b = sdBoxes(p, vec3(5,0,10), vec3(10,.2,5));
    float bms = opMin(b,s);
    float ss = sdSpheres(p);
    
    return vec2(opSmooth(bms, ss, 0.5), ss < bms ? 1 : 0);
}

vec3 tr(vec3 ro, vec3 rd){
    float td = 1;
    vec2 h;
  
    float n = texture(texFFTSmoothed, 0).x;
  
    vec3 c0 = vec3(0);
    vec3 glo0 = vec3(abs(sin(fGlobalTime)) * n * 0.5,abs(cos(fGlobalTime)) * n * 0.5,0.03);
    vec3 c1 = vec3(0);
    //vec3 glo1 = vec3(0.02, 0,0);
    vec3 glo1 = 0.02 * (0.5 + 0.5 * cos(fGlobalTime * 2 + rd.y*2 + vec3(4,1,0))) + 0.02 * (0.5 + 0.5 * cos(fGlobalTime * 3 + rd.y*5 + vec3(1,4,0)));
  
    for (int i = 0; i < 100; i++) {
        h = map(ro + rd * td);
        td += h.x;
      
        if (h.y == 0) c0 += glo0; else c1 += glo1;
      
        if (h.x < 0.01 || h.x > 20) break;
    }
    
    return c0 + c1;
}

void main(void)
{
  
    float n = texture(texFFTSmoothed, 0).x;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv = sin(fGlobalTime / 2) > 0 ? uv : abs(uv);
  
  vec3 ro= vec3(cos(fGlobalTime * 4) / 4 + 0.2,0,1.2 + n * 10);
  vec3 rd = normalize(vec3(uv, 0) - ro);

  out_color = vec4( tr(ro, rd), 1);
}