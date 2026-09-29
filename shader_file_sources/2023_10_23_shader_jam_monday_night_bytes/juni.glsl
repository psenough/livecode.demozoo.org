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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
vec2 hash2(vec2 uv){
    vec2 p = vec2(dot(uv,vec2(123.123,456.456)),dot(uv,vec2(1337.1337,0613.0713)));
    return fract(sin(p)*1234.1234);
}

vec4 voronoi(vec2 uv, float scale, float seed){
    vec2 tv= fract(uv) * scale;
    vec2 ti = floor(tv);
    vec2 tf = fract(tv);
    float m_dist = 2.;
    vec2 m_point;
    for(int x = -1; x <= 1; x++){
        for(int y = -1; y<=1; y++){
            vec2 off = vec2(float(x),float(y));
            vec2 p = hash2(mod(ti + off,scale)+seed);
            vec2 diff = off + p - tf;
            float dist = length(diff);
            if(dist < m_dist) {
            m_dist = dist;
            m_point = p;
            }
        }
    }
    return vec4(fract(m_point.r*seed));
}

vec3 getSkyGradient(vec2 uv){
    vec3 light = vec3(181,163,62)/256;
    vec3 mid = vec3(0,63,97)/256;
    vec3 dark = vec3(0,16,29)/256;
    
    mid.b += sin(fGlobalTime)/2;
    
    vec3 c = mid;
    float mixF = uv.y - .25;
    mixF*=2;
    if(mixF > 0) c=mix(c,dark,mixF);
    //if(mixF < 0) c=mix(c,light,abs(mixF));
    return c;
}

#define TEX_SCALE .01
vec4 sampleTex(vec2 uv){
   vec2 p = (uv+1.)*TEX_SCALE;
   p.y += texture(texFFTIntegrated, .05).r/10;
   return voronoi(p, 200, 1337.1337);
}

#define LAYERS 60.
#define DEPTH 1.
#define LOD 20.
vec3 baseColor = vec3(0.);
vec4 raymarchTex(vec3 ro, vec3 rd){
  if(ro.z > LOD) return vec4(0.);
  float layerH = DEPTH/LAYERS;
  float stepsize = length(rd * (layerH/rd.y));
  vec4 c =vec4(0.);
  for(float i=0.; i<LAYERS; i++){
    vec3 p = ro + rd*stepsize*i;
    vec4 s = sampleTex(p.xz);
    if(s.a < .3) s.a = 0.;
    float level = texture(texFFTSmoothed, s.a).r*150.;
    if(level * DEPTH < 1-layerH*i) s.a = 0.;
    s.a = smoothstep(.1,.2,s.a);
    s.rgb = mix(s.rgb, baseColor, layerH*i);
    c = mix(c,s,s.a);
    if(s.a > .95) break;
  }
  return c;
}

float sdfCircle(vec2 uv, float r){
  return length(uv) - r;
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.y-=.33/2;
  
  vec4 c = vec4(0.);
  
  vec3 camera = vec3(0., 1., 0.);
  
  vec3 ro = camera;
  vec3 rd = normalize(vec3(uv.x, uv.y, 1.));
  float flr = 0.;
  if(rd.y < -.045){
      vec3 hitP = abs((ro.y-flr)/rd.y)*rd;
      vec4 mid = vec4(0,63,97, 256)/256;
      mid.b += sin(fGlobalTime)/2;
      mid.rgb*=1.2;
      c = raymarchTex(hitP, rd)* mid;
      //c = sampleTex(hitP.xz);
  }else {
      c = vec4(getSkyGradient(uv+.75),1.);
      c += (1- smoothstep(.1,.12, vec4(sdfCircle(uv-vec2(0.,0.), .1))))*.75;
    
  }
  
	out_color = c;
}