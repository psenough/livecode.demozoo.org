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
float time = fGlobalTime;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
vec3 cam(vec3 ro, vec3 rd, vec2 uv) {
    vec3 f = normalize(rd - ro);
    vec3 l = normalize(cross(vec3(0,1,0), f));
    vec3 u = normalize(cross(f,l));
    return normalize(f + l * uv.x + u * uv.y);
}

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}


vec4 bg(vec3 rd) {
  return rd.y * texture(texNoise, rd.xz + time * 0.1) * vec4(.3, .5, 1., 1.);
}

float sdBox(vec3 p, vec3 c) {
    vec3 q = abs(p) - c;
    return length(max(q, 0));
}
float ni(float a) { return texture(texFFTIntegrated, a).x; }
mat2 rot(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }

void mo(inout vec2 p, vec2 d){ p = abs(p) - d; if (p.y > p.x) p = p.yx; }

float sdThing(vec3 p) {
    mo(p.yz, vec2(.4));
    mo(p.xy, vec2(.4));
    p.xz *= rot(time + ni(0.2) * 2.);
    p.zy *= rot(time  + ni(0.) * 2.);
    mo(p.zx, vec2(.4));
    mo(p.yx, vec2(.4));
    return sdBox(p, vec3(.2, 1., .2));
}

vec3 rep(vec3 p, vec3 c) {
    return mod(p + .5 * c, c) - .5 * c;
}

vec2 map(vec3 p) {
    vec3 pp = p;
    p += vec3(0, 3 - sin(p.x * .2 + p.z * .3 + time + ni(0.) * 10.) * .2 - cos(-p.x * 2. + p.z * .3 + time) * .3 - length(p) * .1, 0);
    p = rep(p, vec3(.4, 0, .4));
    float s = sdSphere(p, .1);
    float b = sdThing(pp + vec3(sin(ni(0) * 3), 0, cos(ni(.15) * 3)));
  
    return vec2(min(s,b),s < b ? 1 : 2);
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

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.283 * (c * t + d));
}

vec4 tr(vec3 ro, vec3 rd, vec2 uv) {
    float td = 1;
    vec2 h;
  
    vec4 c = vec4(0);
  
    for (int i = 0; i < 400; i++) {
        vec3 ip = ro + rd * td;
        h = map(ip);
        td += h.x < 0.1 ? 0.01 : h.x;
        int bnc = 0;
        
        if (h.y == 2) {
            c += vec4(pal(time , vec3(.5),vec3(.5),vec3(1., 1., .2),vec3(.8, .6, .3) ), 1) * exp(-h.x * 5) * 0.01;
         }
      
        if (h.x < 0.01) {
            vec3 inorm = norm(ip);
          
            if (h.y == 1) {
              c += vec4(pal(ip.x * .1 + ip.z * .2 + time - ip.x * .2 + ip.z * .1 + time, vec3(.5),vec3(.5),vec3(1., 1., .2),vec3(.8, .6, .3) ), 1) * exp(-h.x * 20) * (exp(-td * .1) * .1);
            }
            if (h.y == 2) {
                ro = ip;
                rd = reflect(rd, inorm);
                td = 0.2;
                bnc += 1;
            }
        }
    }
    
    return bg(rd)  + c;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(-10 * sin(time), 1 + sin(time + ni(0) * .2), -5 * cos(time));
  vec3 rd = cam(ro, vec3(0,0,0), uv);
	out_color = pow(tr(ro, rd, uv), vec4(1/1.5));
}