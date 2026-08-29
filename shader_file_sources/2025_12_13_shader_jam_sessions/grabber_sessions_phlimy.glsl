#version 420 core

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
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

// Simplex 3D Noise by Ian McEwan, Stefan Gustavson (https://github.com/stegu/webgl-noise)
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);} vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;} float snoise(vec3 v){ const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);vec3 i  = floor(v + dot(v, C.yyy) );vec3 x0 =   v - i + dot(i, C.xxx) ;vec3 g = step(x0.yzx, x0.xyz);vec3 l = 1.0 - g;vec3 i1 = min( g.xyz, l.zxy );vec3 i2 = max( g.xyz, l.zxy );vec3 x1 = x0 - i1 + 1.0 * C.xxx;vec3 x2 = x0 - i2 + 2.0 * C.xxx;vec3 x3 = x0 - 1. + 3.0 * C.xxx;i = mod(i, 289.0 ); vec4 p = permute( permute( permute(   i.z + vec4(0.0, i1.z, i2.z, 1.0 ))+ i.y + vec4(0.0, i1.y, i2.y, 1.0 )) + i.x + vec4(0.0, i1.x, i2.x, 1.0 )); float n_ = 1.0/7.0; vec3  ns = n_ * D.wyz - D.xzx; vec4 j = p - 49.0 * floor(p * ns.z *ns.z); vec4 x_ = floor(j * ns.z); vec4 y_ = floor(j - 7.0 * x_ ); vec4 x = x_ *ns.x + ns.yyyy; vec4 y = y_ *ns.x + ns.yyyy; vec4 h = 1.0 - abs(x) - abs(y); vec4 b0 = vec4( x.xy, y.xy ); vec4 b1 = vec4( x.zw, y.zw ); vec4 s0 = floor(b0)*2.0 + 1.0; vec4 s1 = floor(b1)*2.0 + 1.0; vec4 sh = -step(h, vec4(0.0)); vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ; vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ; vec3 p0 = vec3(a0.xy,h.x); vec3 p1 = vec3(a0.zw,h.y); vec3 p2 = vec3(a1.xy,h.z); vec3 p3 = vec3(a1.zw,h.w); vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3))); p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w; vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0); m = m * m; return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );}

vec3 hsv(vec3 c) { vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); }

vec3 getTexture(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions, uv*vec2(1,-1*ratio)-.5).rgb;
}

float fft(float f, float smoothing) {
  return texture(texFFT, f).x*(1.0-smoothing) +
    texture(texFFTSmoothed, f).x*smoothing;
}
float ffti(float f) {
  return texture(texFFTIntegrated, f).x;
}
float hash11(uint q) { uvec2 n = q * uvec2(1597334673U, 3812015801U); q = (n.x ^ n.y) * 1597334673U; return float(q) * 2.328306437080797e-10; }
vec2 hash23(vec3 p) { uvec3 q = uvec3(ivec3(p)) * uvec3(1597334673U, 3812015801U, 2798796415U); uvec2 n = (q.x ^ q.y ^ q.z) * uvec2(1597334673U, 3812015801U); return vec2(n) * 2.328306437080797e-10; }
mat2 rotate2d(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

vec3 samplePrev(vec2 pos) {
    vec2 bounds = vec2(v2Resolution.x/v2Resolution.y, 1);
    if (pos == clamp(pos, vec2(-bounds), vec2(bounds))) {
        return texture(texPreviousFrame, pos*0.5*vec2(v2Resolution.y/v2Resolution.x, 1.0)+0.5).rgb;
    } else {
        return vec3(0.0);
    }
}

float time() {
  return fGlobalTime*148.0/60.0;
}

float pixels_bg(ivec2 c) {
  return step(0.7-fft(0.02, 0.3)*0.2, hash11(c.x^c.y^int(time())));
}

vec2 kaleido(vec2 pos, float offset) {
  pos = rotate2d(time()*0.05+1.54)*pos;
  pos = abs(pos);
  pos = rotate2d(time()*0.02+offset)*pos;
  return pos;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 pos = (gl_FragCoord.xy - v2Resolution.xy/2.0) / (v2Resolution.y/2.0);
  
  vec3 col = vec3(0);
  
  float pix_per_unit = 100.0;
 
  for (int i=0; i<4; i++) {
    float d = float(i)+1.0;
    
    vec2 pos = kaleido(pos, 0.0);
    
    pos = pos*d+(fGlobalTime*0.5+ffti(0.01)*0.4+d).x*0.1;
    
    ivec2 c = ivec2(pos*pix_per_unit);
    vec2 posf = vec2(c)/pix_per_unit;
    
    float pix = pixels_bg(c+int(time()*4.0));
    float logo = getTexture(posf*0.5).r;
    float noise = snoise(vec3(posf, time()*0.2));
    noise = float(noise>0.6-fft(0.01, 0.0));
    
    vec3 tone = hsv(vec3(float(i)*0.1+time()*0.02, 0.5, 1.0));
    col += vec3(pix*logo*noise)/d*tone*3.0;
  }
  
  //pos = kaleido(pos, 0.0);
  
  //vec2 wind = normalize(-pos)*0.02;
  vec2 pw = pos*2.0;
  vec2 wind = vec2(snoise(vec3(pw, 0.0)), snoise(vec3(pw, 10.0)))*0.01;
 
  col += samplePrev(pos + wind)*0.8;
  
  col = pow(col, vec3(1)-0.05*hsv(vec3(time()*0.02, 1.0, 1.0)));
  
	//col += 0.1*vec2(1, 0.865);
  //col += fft(0.02, 0.0)*0.5;
  //col *= hash23(vec3(gl_FragCoord.xy, time())).x*2.0;
  
  out_color = vec4(col, 1.0);
}