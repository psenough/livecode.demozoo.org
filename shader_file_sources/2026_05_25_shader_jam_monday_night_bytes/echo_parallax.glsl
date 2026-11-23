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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

uint hash(uint x){
  x *= 0x9361ABC7u;
  x ^= 0x92807727u;
  x *= 0x07715593u;
  x ^= 0x67140661u;
  x *= 0x75926468u;
  return x;
}
float hashf(uint x) { return float(hash(x)) / float(0xFFFFFFFFu); }

uint s_rngState;
float rng()
{
  s_rngState = 11213 * s_rngState + 0x65729561u;
  return hashf(s_rngState);
}

// hi early Twitch chat!
//              .   
//   |\   /|   ||   
//   | \_/ '___/|   
//   | '^'      /   
//   |         |    
// \__""_____""___/ 
//   oo        oo   
//                  
// I've got some idea of what to do here, but haven't practiced it...
// let's see if it works!
//                  
// let's go!        
//                  

// that was fun!
// ok now for the thing I was actually going to go for

float g_attRadius = 5.;
float g_kickFreq = 5. / 1024.;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float scanlineGlitch()
{
  return 4096.0 * pow(texture(texFFTSmoothed, g_kickFreq).r, 6.0) * (2. * hashf(uint(gl_FragCoord.y / 16)) - 1);
}

vec4 backup()
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.x += scanlineGlitch();

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	vec4 oc = f + t;
  
  // s_rngState = uint(dot(floor(gl_FragCoord.yx/ 16), vec2(v2Resolution.x, 1.)));
  oc = oc * vec4(rng());
  return oc;
}

// you know what, we can do something more interesting than sin()
float linhash(float x)
{
  float lo = hashf(uint(x));
  float hi = hashf(uint(x)+1);
  float f = .5 * (1. -cos(3.1415926 * fract(x)));
  return 2. * mix(lo, hi, f) - 1.;
}

vec3 iter(vec3 p){
  float intKick = texture(texFFTIntegrated, g_kickFreq).r * .5;
  float a = 10.; // 30 * sin(.1 * intKick);
  float b = 30 * linhash(.1 * intKick);
  float c = 10. * linhash(.1 * 1.618 * 1.618 * intKick); // 8./3.;
  float d = linhash(.1 * 1.618 * intKick);
  d = sign(d) * pow(abs(d), 4.0);
  
  float xn = p.x + a * d * (p.y - p.x);
  float yn = p.y + d * (b * p.x - p.y - p.z * p.x);
  float zn = p.z + d * (p.x * p.y - c * p.z);
  vec3 res = vec3(xn, yn, zn);
  
  float l = length(res);
  if(l > g_attRadius)
  {
    res = g_attRadius * res / (l * l);
  }
  return res;
}

// thank u blackle
vec3 erot(vec3 p, vec3 ax, float ro) {
  ax = normalize(ax);
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

vec3 toWorld(vec3 p)
{
  float intKick = texture(texFFTIntegrated, g_kickFreq).r;
  return erot(p, vec3(0., 1., 0.), intKick * .1);
}

ivec2 projectToScreen(vec3 p)
{
  vec3 world = toWorld(p);
  return ivec2(v2Resolution.xy * 0.5 + (world.xy / g_attRadius) * v2Resolution.y);
}

void main(void)
{
  // background
  vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.y;
  out_color = dot(uv, uv) * backup();
  
  // strange attractor iteration
  s_rngState = uint(dot(gl_FragCoord.yx, vec2(v2Resolution.x, 1.)));
  vec3 p = 10. * (vec3(rng(), rng(), rng()) - vec3(.5));
  for(int i = 0; i < 100; i++)
  {
    vec3 pNew = iter(p);
    
    vec3 wOld = toWorld(p);
    vec3 wNew = toWorld(pNew);
    
    p = pNew;
    
    vec3 tg = wNew - wOld;
    
    vec3 v = vec3(1., 0., 0.);
    vec3 n = normalize(cross(tg, v));
    vec3 l = normalize(vec3(1.));
    vec3 h = normalize(v + l);
    
    float diff = dot(n, l);
    float spec = pow(abs(2.15 * dot(n, h)), 64.);
    float speedTint = pow(1.8 * length(tg), 2.) / g_attRadius;
    float lighting = fract(min(speedTint, 1.) + spec); // diff + spec; //0.2 * length(tg);
    imageStore(computeTex[0], projectToScreen(p), uvec4(exp2(32.) * min(lighting, .9999)));
  }
  
  // ok so imageLoad is the one!
  ivec2 readPos = ivec2(gl_FragCoord.xy + .03 * vec2(v2Resolution.x, 0) * scanlineGlitch());
  uint resolve = imageLoad(computeTexBack[0], readPos).r;
  if(resolve > 0)
  {
    float readLighting = float(resolve) * exp2(-32.);
    
    vec3 tint = plas(vec2(1.), fGlobalTime).rgb;
    
    //vec3 col = vec3(.5) + vec3(.5) * sin(vec3(1, 2, 3) * readLighting);
    //vec3 col = mix(.0 * vec3(0., 0., 1.), vec3(.5, 1., 1.), vec3(readLighting));
    vec3 col = 2. * sin((vec3(1.) + tint) * pow(readLighting, 1.5));
    
    out_color = vec4(col, 1.);
  }
  
  // out_color = mix(out_color, vec4(readLighting), vec4(.5));
}

// ok I think that's good enough for now!
// hope you've enjoyed these variants on the Lorentz strange attractor
// sorry for the blinking and for killing the encoder again!
// shout-out to Cmdr. Homer for the set!