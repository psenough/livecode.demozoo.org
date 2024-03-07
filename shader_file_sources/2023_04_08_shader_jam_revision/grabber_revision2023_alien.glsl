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

#define _t fGlobalTime
#define bpm 80.
#define one_bpm 60./bpm
#define beat(a) fract(_t/(one_bpm*a))
#define cumbeat(a) _t+beat(a)
#define FAR 30.
#define PI acos(-1)

mat2 rot(float a) {return mat2(cos(a), -sin(a), sin(a), cos(a));}
float smin(float a, float b, float k){
	float h = max(k-abs(a-b), 0.0 ) / k;
	return min(a,b) - h*h*k*(1.0/4.0);
}

float box3(vec3 p, vec3 b){
	vec3 d = abs(p)-b;
	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float distort(vec3 p){
  vec3 spp = p;
	p.y += 2.5;  
    p.x = abs(p.x);
  
    p.x *= atan(p.y, p.z);
	float final = 0.0;
	float y = p.y;
	p.z -= 10.0;
  float off = 1.0;
  if(beat(2) < 0.5) {
    off = 20;
  }
	p.xz *= vec2(0.1, 0.5);
	for(int i = 0; i <4; i++){
		final += box3(p, vec3(5*i));
		p.z -= 10.0 + off;
		p.x *= 2.0;
		p.xz *= rot(0.2*float(i)*y);
		p.x = abs(p.x) + 0.0001*cumbeat(2);
		p.z = cos(p.x * 2.0+sin(p.z * 2.0));
		p.z -= 5.0;
		p.xz *= rot(0.8 - p.y);
		p.x -= 5.0;
	}
	return final  / 12.0;
}

float scene(vec3 p) {
 
  if(beat(4) < 0.2) {
    p = abs(p);
    p -= 1.0;
  }
  
  
  
  float d = distort(p);
  p = abs(p);
  
  p -= vec3(0, 1, 40 - beat(2));
  float bb = beat(4);
  if(bb < 0.2) {
    p.xz *= rot(0.3);
  }
  else if(bb < 0.4) {
    p.yz *= rot(0.387);
  }
  else if(bb < 0.6) {
    p.xy *= rot(2.3);
    p.y -= 10;
  }
  else if(bb < 0.8) {
     p.xy *= rot(2.3);
     p.yz *= rot(2.3);
    //p.z += 3;
  }
  else if(bb < 1.0) {
  }
  float b = box3(p, vec3(0.2));
  float aa = 3;
  if (beat(4) < 0.5) {
    aa = 6;
  }
  else if (beat(4) < 0.8) {
    aa = 10;
  }
  return smin(d, b, aa);
}

float march(vec3 ro, vec3 rd, out vec3 p) {
  float a = 0.01;
    int i = 0;
    int steps = int(40. );
    for(i = 0; i < steps; i++){
        p = ro + rd*a;
        float b = scene(p);
        a += b;
        if(a>FAR){
            return 1.;
        }
        else if(abs(b) < 0.00001) {
            float f = (float(i)) /float(steps);
            return f;
        }
    }
    return FAR;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  if(beat(8) < 0.3) {
    uv = abs(uv);
    uv = fract(uv*3);
    uv -= 0.5;
    
  }
  
  vec3 ro = vec3(0, 1, -55);
  vec3 rd = vec3(uv, 1.0/tan(70.0 * 0.5 * PI /180));
  rd.yz *= rot(0.2);     
  
 
if(beat(4) < 0.4) {
  //rd.xz *= rot(beat(2));
  ro.z += beat(4)*40;
}  
  
 
  
  
  
  vec3 p;
  
  float t = march(ro, rd, p);
  
  
  vec3 color = vec3(t);
  vec3 a = vec3(0.1,0.1,0.2);
  vec3 b = vec3(0.05, 0.8, 0.3);
  
  a = vec3(0.99, 0.29, 0.3);
  b = vec3(0.23, 0., 0.23);
  
  float ab = 0;
  if(beat(8) < 0.4){
    ab = 0.8;
  }  
  
  color = mix(a, b, vec3(t));
  vec4 prev = texture(texPreviousFrame, uv*4);
  color = mix(color, prev.xyz, ab);

  if(beat(16) < 0.5) {
    color = 1-color;
  }
  
  color = pow(color, vec3(0.88));
  
  if(beat(8) < 0.5) {
    color *= 0.3+uv.y;
  }
  
  color = mix(color, vec3(0.2, 0.4, 0.3), 2.0+fract(p.z+_t));;
    
  uv = abs(uv);
  uv.x-= p.x;
  uv.x -= beat(4);
  uv.y += sin(p.x)*0.1;
  if(length(uv) < 0.5 && beat(4)< 0.5) {
    color *= color;
  }
  
  if(uv.x > 0.4) {
    color *= 0.4;
  }
  
  uv.y += 0.2*_t+beat(8);
  uv = fract(uv*2);
  if(uv.y < 0.5){
    color = 1-color;
  }
  if(beat(8) < 0.2) {
    color *= uv.y; 
  }
  
	out_color = vec4(color,1);
}