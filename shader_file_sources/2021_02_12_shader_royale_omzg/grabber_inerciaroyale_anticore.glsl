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

float n(float x) {
    return texture(texFFT, x).x;
}

float ns(float x) {
    return texture(texFFTSmoothed, x).x;
}

float smin(float a, float b, float k) {
    float h = max(k - abs(a-b), 0.) / k;
    return min(a, b) - (h * h * k / 4);
}

mat2 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, s, -s, c);
}

float sdSphere (vec3 p, vec3 pos, float r) { return length(p + pos) - r; }

float sdBox(vec3 p, vec3 pos, vec3 b) {
    vec3 q = abs(p + pos) - b;
    return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

float sdTwist(vec3 p, vec3 pos) {
    p += pos;
    p.xz *= rot(p.y + fGlobalTime * 5);
    //p.x += sin(p.y / 10 + fGlobalTime) / 2;
  
    return sdBox(p, vec3(0,0,0), vec3(0.4, 999, 0.4)) - ns(0.4) * 50 * sin(p.z);
}

float sdTwists(vec3 p, vec3 pos) {
    p += pos;
    p.yz *= rot(3.1415 / 2);
    p.xz *= rot(p.y / 10);
    float d = 999;
    d = min(d, sdTwist(p, vec3(0,0,4 + sin (p.y / 2) * 0.5 )));
    d = min(d, sdTwist(p, vec3(0,0,-4  + sin (p.y / 2) * 0.5)));
    d = min(d, sdTwist(p, vec3(4  + sin (p.y / 2) * 0.5,0,0)));
    d = min(d, sdTwist(p, vec3(-4  + sin (p.y / 2) * 0.5,0,0)));
    return d;
}

float sdBlob (vec3 p, vec3 pos) {
     int scount = 8;
      float d = 999;
     for (int i = 0; i < scount; i++) {
         d = smin(d, sdSphere(p, pos + vec3(sin(i + fGlobalTime * 1.7),cos(i + fGlobalTime * 2.1),sin(i + fGlobalTime) / 2), 0.01), 0.5);
     }
     
     return d;
  
}

vec2 map(vec3 p) {
    float blob = sdBlob(p, vec3(sin(fGlobalTime) * 0.1, cos(fGlobalTime) * 0.1, sin(fGlobalTime) + 1));
    float tun = sdTwists(p, vec3(0, 0, 20));
  
    if (blob < tun) {
       return vec2(blob,0);
    } else { 
      return vec2(tun,1);
    }
}

vec3 norm (vec3 p) {
    const float E = 0.01;
    const vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * map( p + k.xyy * E).x +
        k.yyx * map( p + k.yyx * E).x +
        k.yxy * map( p + k.yxy * E).x +
        k.xxx * map( p + k.xxx * E).x
  );
}


vec3 bg(vec2 uv) {
    float ldiv = 6;
    float gain = 15;
    float sinmul = 5;
    float xmul = 0.01;
    float ymul = 0.02;
    float diff = 0.5;
    vec3 col = vec3(0.6, 0.4, 0.5);
    float cols = 6;
  
    vec3 bgc = col * cols * vec3(
      ns(length(uv / ldiv) + sin(uv.x * sinmul + fGlobalTime) * xmul + sin(uv.y * sinmul + fGlobalTime) * ymul),
      ns(length(uv / ldiv) + sin(uv.x * (sinmul - diff) + fGlobalTime) * xmul + sin(uv.y * (sinmul - diff) + fGlobalTime) * ymul),
      ns(length(uv / ldiv) + sin(uv.x * (sinmul - diff * 2) + fGlobalTime) * xmul + sin(uv.y * (sinmul - diff * 2) + fGlobalTime) * ymul)
  );
  
    return mix(vec3(0), bgc, length(uv * gain));
}

vec3 blobSub(vec3 p, vec3 n, float d, float td, vec2 uv) {
   return vec3(0.3, 0.3, 0.9) * exp(-abs(d)) * 0.04 * (0.4 + ns(0) * 10);
}

vec3 blobSurf(vec3 p, vec3 n, float d, float td, vec2 uv) {
   return n * 0.05;
}

vec3 fog(vec3 c, vec3 fc, float d, float md) {
    return mix(c, fc, min(md / d, 0));
}

vec3 dirlight(vec3 n, vec3 lc, vec3 ld) {
    return lc * dot(ld, n);
}

vec3 tunCol(vec3 p, vec3 n, float d, float td, vec2 uv) {
    vec3 c = vec3(1) * 0.2 + bg(n.xy / 2) * 1.4 + dirlight(n, vec3(1,0,0), vec3(1, 1, 0)) * 0.5 + + dirlight(n, vec3(1,1,0), vec3(-1, 1, 0)) * 0.5;
    return fog(c, bg(uv), td, 50);
}



vec3 tr(vec3 ro, vec3 rd, vec2 uv) {
    float td = 1;
    vec2 h;
    vec3 blobc = vec3(0);
    vec3 blobglo = vec3(0);
  
    for (int i = 0; i < 150; i++) {
        h = map(ro + rd * td);
        if (h.x < 1 && h.x > 0) {
            if (h.y == 0) {
               blobglo += vec3(0.7, 0.2, 0.6) * 0.02; 
            }
        }
      
        if (h.x > 0.01) {
          td += h.x;
        } else {
          td += 0.01;
        }
        
       
        
      
        if (h.x < 0.01) {
          
            vec3 ip = ro + rd * td;
            vec3 inorm = norm(ip);
          
            if (h.x > 0 && h.y == 0) {
              blobc += blobSurf(ip, inorm, h.x, td, uv);
            }
            
            if (h.y == 0) {
              blobc += blobSub(ip, inorm, h.x, td, uv);
            } else {
              return tunCol(ip, inorm, h.x, td, uv);
            }
        }
    }
    
    return bg(uv) + blobc + blobglo;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0,0,2);
  vec3 rd = normalize(vec3(uv, 0) - ro);

  out_color = vec4(tr(ro, rd, uv), 1);
}