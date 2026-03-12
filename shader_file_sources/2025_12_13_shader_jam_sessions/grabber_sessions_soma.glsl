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

vec4 getTexture(vec2 uv, vec4 rect){
  vec2 st = (uv - rect.xy) / rect.zw;
  if(0. < st.x && st.x < 1.0 && 0. < st.y && st.y < 1.0) {
    st.y = 1. - st.y;
    return texture(texShort, st);
    }
    
    return vec4(0.);
  }

  vec2 toUv(vec2 uv) {
    vec2 st = uv * 2.0 - 1.0;
    st.x *= v2Resolution.y / v2Resolution.x;
    return st;
    }
  
vec2 reflectHp(vec2 p, vec4 hp) {
  vec2 n = normalize(hp.zw);
  float d = dot(n, p - hp.xy);
  return p.xy - 2 * n * d;
  }
  
float distHp(vec2 p, vec4 hp) {
  vec2 n = normalize(hp.zw);
  return dot(n, p - hp.xy);
  }
  
mat2 rot(float rad) {
  float c = cos(rad);
  float s = sin(rad);
  return mat2(c, s, -s, c);
  
  }
  
struct Motion {
  float index;
  float phase;
  };
  
Motion makeMotion(float pos, float s, float offset) {
  Motion m;
  float d = (pos - offset) / s;
  m.index = floor(d);
  m.phase = fract(d);
  return m;
  }
  
  float ease4(float t) {
    return t * t* t* t;
    }
    
float distCircle(vec2 p, vec3 c) {
  return distance(p, c.xy) - c.z;
  }
  
vec2 invCircle(vec2 p,  vec3 c) {
  p = p - c.xy;
  float r2 = c.z * c.z;
  //float d = distance(p, c);
  float R2 = dot(p, p);
  return c.xy + p * r2 / R2;
  }
 
 vec3 palette(float t) {
   vec3 a = vec3(0.3, 0.5, 0.2);
   vec3 b = vec3(0.8, 0.5, 0.6);
   vec3 c = vec3(1);
   vec3 d = vec3(0.3, 0.5, 0.4);
   
   return a + b * cos(2.0 * 3.14 * c * (t + d));
   }
    
void main(void)
{
    
  float BPM = 148.;
  float beatDur = 60. / BPM;
  float beatPos = fGlobalTime / beatDur;
  
  Motion scaleMotion = makeMotion(beatPos, 4, 0.);
  float scalePhase = ease4(scaleMotion.phase);
  
  

  
	vec2 pos = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y) * 2.0;
  pos.x *= v2Resolution.x / v2Resolution.y;
	pos -= vec2(2, 1);

  float scale = 3.;
  float scalebp = mod(beatPos, 12);
  float sv[6];
  for(int i= 0;i < 6; i++) {
    float grow = clamp(scalebp - float(i), 0., 1.);
    float shrink = clamp(scalebp - float(5 + i), 0., 1.);
    float level = grow * (1. - shrink);
    sv[i] = mix(0, 2, ease4(level)); 
  }
  scale = 1.0 + sv[0] + sv[1] + sv[2] + sv[3] + sv[4] + sv[5];
  

  pos *= scale;

  Motion rotMotion = makeMotion(beatPos, 4., 0.);
  float rotPhase= ease4(rotMotion.phase);
  float rotRad = (mod(rotMotion.index, 2.) == 0.) ? mix(0.,2. *  3.14, rotPhase) : mix(2. * 3.14, 0., rotPhase);
  pos = rot(rotRad) * pos; 
  
	vec2 uv =  pos / vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

    vec2 texSize = textureSize(texShort, 0) / 500.;
  vec4 texRect = vec4(-texSize / 2, texSize);
  
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  const int numLines = 4;
  vec4 lines[numLines];
  vec4 linesFromTo[numLines];
  lines[0] = vec4(texRect.x, 0, 1, 0);
  lines[1] = vec4(texRect.x + texRect.z, 0, -1, 0);
  lines[2] = vec4(0., texRect.y, 0, 1);
  lines[3] = vec4(0., texRect.y + texRect.z, 0, -1);

  for(int i = 0; i < numLines; i++) {
      linesFromTo[i] = vec4(lines[i].xy * 10, lines[i].xy);

    }

  float linebp = mod(beatPos, 12);
  for(int i= 0;i < numLines; i++) {
    float grow = clamp(linebp - float(i), 0., 1.);
    float shrink = clamp(linebp - float(8 + i), 0., 1.);
    float level = grow * (1. - shrink);
    lines[i].xy = mix(linesFromTo[i].xy, linesFromTo[i].zw, level); 
  }
  
  const int numCircles = 5;
  vec3 circles[numCircles];
  circles[0] = vec3(0, 2.2, 1);
  circles[1] = vec3(0, -2.2, 1);
  circles[2] = vec3(2.2, 0, 0);
  
  //circles[3] = vec3(-2.2, 0, 0);
  circles[4] = vec3(0, 0, 0);


    float circlebp = mod(beatPos, 8);
  for(int i= 0;i < numCircles; i++) {
    float grow = clamp(circlebp - float(i), 0., 1.);
    float shrink = clamp(circlebp - float(4 + i), 0., 1.);
    float level = grow * (1. - shrink);
    circles[i].z = mix(0, 1, ease4(level)); 
  }
    
  bool inFund = true;
  float loopNum = 0.;
  for(int i = 0; i < 100; i++) {
    inFund = true;
    for(int j = 0; j < numLines; j++) {
        inFund = false;
        if(distHp(pos, lines[j]) < 0.) {
 
          pos = reflectHp(pos,lines[j]);
          inFund = false;
          loopNum++;
    }
    
    for(int j = 0; j < numCircles; j++) {
        inFund = false;
        if(distCircle(pos, circles[j]) < 0.) {
 
          pos = invCircle(pos, circles[j]);
          inFund = false;
          loopNum++;
      }
    }
    
      }
      if(inFund) break;
  }
  
  vec4 col = vec4(palette(loopNum / 10.), 1.);
 
  vec4 tex = getTexture(pos, texRect);
  
	out_color = col + t  * tex;
}