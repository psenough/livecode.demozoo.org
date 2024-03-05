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

const float E=0.001;
const float FAR=100;
const int STEPS=128;

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d,0.0))+min(max(d.x, max(d.y, d.z)), 0.0);
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float scene(vec3 p, vec3 ro, vec3 rd){
  vec3 pp= p;
  
  for(int i = 0; i < 40; ++i){
    
    pp = abs(pp)-vec3(10,10,10);
    
  }
  
  float sp = box(pp,vec3(2));
  return sp;
}

void rot(inout vec2 p, float a){
  p = cos(a)*p +sin(a)*vec2(-p.y,p.x);
}


float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p,ro,rd);
    t += d;
    p = ro+rd*t;
    if(d <= E || d >= FAR) {
      break;
    }
  }
  return t;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	uv += 0.5;
  
  float fft = texture(texFFTIntegrated,.5).r *1;
  
  uv=floor(uv*(80*fft))/(80*fft);  
  
  float time = fGlobalTime;
  vec2 q = uv-.5;
  
  
  vec3 ro= vec3(0,4,10);
  ro+=vec3(10,0,10)+vec3(sin(fft*.02)*100,4,2);
  rot(ro.xz,time*fft*.002);
  ro-=vec3(10,0,10);
  vec3 rt= vec3(0,0,0);

  
  vec3 z = normalize(ro-rt);
  vec3 x = normalize(cross(z,vec3(0,1,0)));
  vec3 y = normalize(cross(x,z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, 1/radians(90.0)));

  float t = march(ro,rd);
  vec3 p = ro+rd*t;
  
  
	float f = texture( texFFT, 0.05 ).r * 100;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  zom-=vec2(.5);
  zom*=vec2(.999)-f*.1;
  zom+=vec2(.5);
  
  vec4 prev = texture(texPreviousFrame,zom)*.99;

  
  
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 col = vec4(1-length(p)/FAR)/vec4(abs(p),1);//plas( m * 3.14, fGlobalTime ) / d;
  if(t>=FAR-1){
     col=vec4(1)-prev*vec4(.4*sin(time*f),.8*cos(time*.2),.4,1);
  }

	col = clamp( col, 0.0, 1.0 );
  col *=vec4(10.4,-10.2*sin(time*4),.5,1);
	out_color = col+prev*.5;
}