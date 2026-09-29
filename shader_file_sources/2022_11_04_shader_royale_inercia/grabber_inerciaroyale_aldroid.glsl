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

// first shader royale please ignore
// here we goooooo! glhf!

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( 0, c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 pla2(vec2 uv) {
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = floor(m.y*20)/20;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y = fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return (t).xyz;
}

mat2 rot(float a) {
  return mat2(cos(a), -sin(a),sin(a), cos(a));
}

float wing2(vec2 uv) {
  uv.x = abs(uv.x);
  return length(uv + sin(uv.y)*2)-1;
}

float wing(vec3 p) {
  p.x = abs(p.x);
  p.xz *= rot(sin(fGlobalTime*20)/5);
  return max(abs(p.z)-0.01,wing2(p.xy));
}

float sdBox(vec3 p, vec3 s) {
  vec3 q = abs(p) - s;
  return max(q.x,max(q.y,q.z));
}

float flh = 3.5;

float flutter(vec3 p) {
    p.y += sin(fGlobalTime);
  p.x += sin(fGlobalTime*2)*2;
  p.yz *= rot (1.2+sin(fGlobalTime*2)*0.2);
  p.xy *= rot(sin(fGlobalTime*2+0.5));
  float bod=length(p/vec3(0.3,1,0.3)+vec3(0.,0,0.3))-1;
  bod /= 3;
  float hed = length(p-vec3(0,1,0)) -0.2;
  float flutter = min(min(wing(p/3),bod),hed);
  return flutter;
}

float twgl = 100;

float twimst(vec3 p) {
  p.yz *= rot(fGlobalTime+p.x/10);
  p.y += texture(texFFT,p.x/1000+0.02).r*10;
  
  float twgls = max(abs(p.y)-0.4,abs(p.z)-0.4);
  twgl = min(twgl,twgls);
  return twgls;
}

float flugl = 100;

float map(vec3 p) {

  float flut = flutter(p/(texture(texFFTSmoothed,0.01).r+1));
  flugl = min(flugl,flut);
  float flo = p.y+flh;
  
  float muun = length(p - vec3(19,12,25))-1;
  
  float twi=twimst(p-vec3(0,0,20));
  
  return min(min(min(flut, flo), muun),twi);
}

vec3 skydome(vec3 rd) {
  return vec3(vec2(-rd.y),rd.y)+texture(texFFT,0.01).r*5;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p) - vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)));
}

vec3 wh = vec3(1);

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-15), rd=normalize(vec3(uv,1));
  
  rd.x += max(0,sin(uv.y*4))*0.003;
  rd.y += max(0,cos(uv.x*4))*0.003;
  
  float d,t=0;
  
  for(int i=0; i < 1000; ++i ) {
    d = map(ro+rd*t);
    t+=d;
    if (d < 0.01) {
      vec3 p = ro + rd * t;
        
      if (p.y > 0.3-flh)
        break;
      else {
        wh = vec3(0.5,0.5,1);
        vec3 n = gn(p);
        n.x += sin(fGlobalTime*4+30*p.z)/50;
        n.y += cos(fGlobalTime*4+30*p.z)/50;
        rd = reflect(rd,n);
        ro = p;
        t = 0.2;
      }
    }
  }
  
  
  vec3 col = skydome(rd);
  
  vec3 ld = normalize(vec3(3,4,-10));
  
  vec3 p = ro + rd * t;
  
  if (d < 0.01) {
    vec3 n = gn(ro+rd*t);
    if (p.y > 3) {
      col = vec3(1);
    } else {
      if (p.z > 3) {
        col = vec3(0,0.4,0);
      } else {
        col = vec3(0.3,0,0);
      }
      col += pow(max(dot(reflect(-ld,n),rd),0),30);
      col += dot(n,ld);
    }
  } else {
    
    col += vec3(0.3,0.3,0)* 0.1/pow(twgl,2);
    col += vec3(0.6,0.,0.4)* 0.1/pow(flugl,2)*texture(texFFT,0.01).r;
 }
  
  col += exp(-0.0001*t*t);
  col *= wh;
  
  out_color = vec4(col,1);
}