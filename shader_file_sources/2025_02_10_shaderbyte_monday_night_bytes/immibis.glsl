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

vec3 getImage(ivec2 ic) {
  return vec3(imageLoad(computeTexBack[0],ic).r,imageLoad(computeTexBack[1],ic).r,imageLoad(computeTexBack[2],ic).r)/65536.0;
}
void putImage(ivec2 ic, vec3 val) {
  uvec3 ival = uvec3(val*65536.0);
  imageStore(computeTex[0], ic, uvec4(ival.x));
  imageStore(computeTex[1], ic, uvec4(ival.y));
  imageStore(computeTex[2], ic, uvec4(ival.z));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

const int NUM_SORT_OFFSETS = 24;
const int NUM_PHASES = 1+2*NUM_SORT_OFFSETS;
const int SORT_OFFSETS[NUM_SORT_OFFSETS] = {
  //1024,512,256,128,64,3,8,4,4,1,3,2, // stabilizes to a square pattern
  1024,512,256,128,64,3,8,4,96,23,467,23,
  512,64,96,12,55,72,465,236,25,1,67,63 // more chaotic
};
//const int SORT_OFFSETS[NUM_SORT_OFFSETS] = {1024,512,256,128,64,3,8,4,4,1,3,2};

float sortKey(vec4 col) {
  return col.r+col.g+col.b;
}

void main(void)
{
  uint phase, cycle;
  if(true) {
    phase = imageLoad(computeTexBack[0],ivec2(0,0)).r;
    if(texture(texFFTSmoothed, 0.01).r > 0.6) phase=0;
    cycle = imageLoad(computeTexBack[1],ivec2(0,0)).r;
    if(int(gl_FragCoord.x) == 0 && int(gl_FragCoord.y) == 0) {
      imageStore(computeTex[0],ivec2(0,0),uvec4((phase+1)%NUM_PHASES));
      imageStore(computeTex[1],ivec2(0,0),uvec4((phase == NUM_PHASES-1) ? cycle+1 : cycle));
    }
  } else {
    phase = int(fGlobalTime*NUM_PHASES*120.0/136.0)%NUM_PHASES;
    cycle = 0;
  }
  // TODO: advance frames at a maximum rate in real time
  //phase = min(phase, int(fGlobalTime*136.0)%60);
  
  
	if(phase == 0) {
    ivec2 iuv = ivec2(gl_FragCoord.xy);
    //iuv ^= 0x424;
    vec2 uv = vec2(vec2(iuv)+0.5) / v2Resolution;
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec2 m;
    m.x = atan(uv.x / uv.y) / 3.14;
    m.y = 1 / length(uv) * .2;
    float d = m.y;

    float f = 0;//texture( texFFT, d ).r * 100;
    m.x += sin( fGlobalTime ) * 0.1;
    m.y += fGlobalTime * 0.25;

    vec4 t = plas( m * 3.14, fGlobalTime ) / d;
    t = clamp( t, 0.0, 1.0 );
    out_color = f + t;
  } else {
    bool verticalSort;
    int phaseOffset, parity;
    
    if(false) {
      verticalSort = (((phase - 1) / NUM_SORT_OFFSETS ^ cycle) & 1) != 0;
      phaseOffset = SORT_OFFSETS[(phase-1)%NUM_SORT_OFFSETS];
    } else {
      verticalSort = (int(phase ^ cycle) & 1) != 0;
      phaseOffset = SORT_OFFSETS[((phase-1)/2+(verticalSort?NUM_SORT_OFFSETS/2:0))%NUM_SORT_OFFSETS];
    }
    
    parity = (int(verticalSort ? gl_FragCoord.y : gl_FragCoord.x) % (phaseOffset*2))>=phaseOffset?-1:1;
    phaseOffset *= parity;
    
    int beat = int(fGlobalTime*127.0/60.0) & 3;
    if(verticalSort) {
      if((beat & 1) != 0) parity = -parity;
    }
    if((beat & 2) != 0) parity = -parity;
    
    bool allMix = texture(texFFTSmoothed,0.001).r > 0.1;
    
    //int parity = ((phase ^ int(verticalSort ? gl_FragCoord.y : gl_FragCoord.x)) & 1) == 0 ? -1 : 1;
    //int phaseOffset = parity;
    
    vec4 a = texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution);
    //ivec2 bcoord = ivec2(gl_FragCoord.xy + (verticalSort ? vec2(0,phaseOffset) : vec2(phaseOffset, 0)));
    ivec2 bcoord = ivec2(gl_FragCoord.xy + (verticalSort ? vec2(phaseOffset/4+2,phaseOffset) : vec2(phaseOffset, phaseOffset/2)));
    if(float(bcoord.x) < v2Resolution.x && float(bcoord.y) < v2Resolution.y) {
      vec4 b = texture(texPreviousFrame, (vec2(bcoord)+0.5)/v2Resolution);
      if(allMix || sortKey(a)*parity < sortKey(b)*parity) {
        vec4 temp = a; a = b; b = temp;
      }
    }
    out_color = a;
  }
} 