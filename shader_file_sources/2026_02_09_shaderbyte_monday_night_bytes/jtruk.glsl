#version 420 core
// JTRUK - ByteJam 2025-02-09
// Thanks: Havoc, Chaos
// Greets: Pumpuli, Boris, Canmom

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.1412
#define TAU (PI*2)

int ASEGS = 10;
int DSEGS = 10;
int NITEMS1 = 10;
int NITEMS2 = 10;
int NITEMS3 = 10;

void shuffle(float t) {
  float s = floor(t/3);
  ASEGS = 4+int(mod(pow(s+102,1.5),4))*2;
  DSEGS = 4+int(mod(pow(s+191,1.9),10))*2;
  NITEMS1 = 4+int(mod(pow(s+152,1.4),20));
  NITEMS2 = 4+int(mod(pow(s+172,1.2),20));
  NITEMS3 = 4+int(mod(pow(s+100,1.9),20));
}

vec2 rot1(vec2 p, float r) {
  return vec2(sin(r)*p[0] + cos(r)*p[1], cos(r)*p[0] - sin(r)*p[1]);
}

vec3 rot(vec3 p, vec3 r) {
  p.yz = rot1(p.yz, r.x);
  p.xz = rot1(p.xz, r.y);
  p.xy = rot1(p.xy, r.z);
  return p;
}

float col(float a, float d, float t) {
  float aunit = mod(a*ASEGS, TAU);
  float dunit = mod(d*DSEGS, 1);
  return (sin(aunit) + sin(dunit*.4+t*2)) * d;
}

float circ(vec2 p, vec2 pos, float r) {
  float d = length(pos - p);
  return d<=r ? d/r : 0;
}

float getItems(vec2 uv, float t, int nItems, vec3 rot2) {
  float v = 0;
  for(float i=0; i<nItems; i++) {
    vec3 p = vec3(.3, .3, 0);
    float aitem = (i/nItems) * TAU;
    p = rot(p, rot2);
    p = rot(p, vec3(t*.1,t*.2,aitem));
    float c = circ(vec2(p.x,p.y), uv, .4);
    if(mod(i,2)==0) {
      v += c;
    } else {
      v -= c;
    }
  }
  return v;
}

vec4 pal(float a) {
  return vec4(0.5 + 0.5 * sin(0),
  0.5 + 0.5 * sin(1+a),
  0.5 + 0.5 * sin(2+a),
  0);
}

void main(void)
{
  float t = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  shuffle(t);
  
  float a = atan(uv.x,uv.y);
  float d = length(uv);
  vec3 rot2 = vec3(t*.7,t*.2,t*.5);  
  
	out_color = vec4(1,0,0,0) * col(a,d,t-.7)
//    + (
    //+ vec4(sin(.5+a*2+t))
    + pal(col(a,d,t)+2+t) * .5
//  + vec4(0,0,1,0) * col(a,d,t-.7)
  //  ) * col(a,d,t-1)
    + pal(getItems(uv, t, NITEMS1, rot2)) * .3
    + pal(getItems(uv, t*0.6 + 1, NITEMS2, rot2)) * .3
    - smoothstep(.3,.6,pal(getItems(uv, t*0.8 + 2, NITEMS3, rot2))) * .3 * d*(5+sin(t)*5)
  ;
}