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

#define T fGlobalTime

float sid=0;
vec3 c0=vec3(0);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float t){
  float c,s;
  c=cos(t);
  s=sin(t);
  return mat2(c,s,-s,c);
}

mat2 m0;

float dfo(vec3 p, float id){
  p.xy*=rot(p.z*sin(T/4+id)*(.01+id*0.1));
  p.z+=T;
  float s = 1.0/id/id;
  vec3 p2 = mod(p, s+s)-s;
  p+=sin(p.yzx+T);
  return length(p2)-s*0.5;
}

float df(vec3 p){
  float d=dfo(p,0);
  for (float i=.0; i<4; i+=1.)
  {
    d=max(d-.2, min(d, dfo(p, i)));
  }
  return d;
}

vec3 nf(vec3 pos){
  vec2 e=vec2(0,1e-3);
  return normalize(vec3(
    df(pos+e.yxx) - df(pos-e.yxx),
    df(pos+e.xyx) - df(pos-e.xyx),
    df(pos+e.xxy) - df(pos-e.xxy)
  ));
}

vec3 surf(vec3 pos){
  vec3 norm = nf(pos);
  vec3 emc = c0;
  vec3 shr = vec3(0);
  float pat = 0;
  float q = 0;
  q += smoothstep(0.9,0.98,sin((pos.z*0.5+T*3.14159)));
  pat += smoothstep(0.97-q,0.98,sin(94*df(pos*1.0+1.0)));
  pat += smoothstep(0.92,0.98,sin(94*df(pos*4.0+1.0)))*0.2;
  shr=emc * pat * (1.0+q*2.0);
  return shr;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 quv = uv-mod(uv,vec2(0.1));
  float q=fract(dot(quv, vec2(2.412,95.313))*31.3513);
  sid = T*0.3+q*0.25;
  sid -= fract(sid);
  sid = sin(sid*4123);
  
  c0 = mix(vec3(0.9,9,1.1), vec3(9,0.9,1.1), abs(sin(sid*4.04+uv.y*0.5)));
  c0 = mix(c0, vec3(1.5,.9,6), abs(sin(sid*9.53+uv.y*0.5)));

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d*d + T ).r * 80;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;
  
  vec3 pos = vec3(sin(sid)*0.35,cos(sid*4)*0.35,-4);
  vec3 dir = normalize(vec3(uv.xy, +1));
  float dt=0.01;
  float dist;
  
  dir.xy*=rot(sid);
  dir.xz*=rot(sin(sid*53)/4);
  dir.yz*=rot(sin(sid*9)/4);
  
  for (int i=0; i<150; i+=1){
    dist = df(pos+dir*dt);
    dt += dist;
  }
  
  vec3 pos2 = pos+dir*dt;

  vec3 col = vec3(0);
  if (dist < 1e-3)
  {
    col = surf(pos2);
  }
  col=mix(c0*4,col,1.0/(1.0+dt*dt*1e-3));
  
  vec3 dir2 = reflect(nf(pos2), dir);

	vec4 t1 = plas( m * 1, T + texture(texFFTIntegrated, 0.05).r*1 ) / d;
	vec4 t2 = plas( m * 2, T + texture(texFFTIntegrated, 0.05).r*1 ) / d;
	vec4 t3 = plas( m * 3, T + texture(texFFTIntegrated, 0.05).r*1 ) / d;
  
  vec4 t = t1*vec4(3,0.1,1,0)+t2*vec4(1,0,1,0)+t3*vec4(1,0.1,3,0);
	t *= 0.1;

  vec3 outc = (f*.1 + t*.5).xyz*0.1;
  outc += col*0.9;
  
  vec3 prev;
  prev  = texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).xyz;
  outc = mix(outc, prev, 0.4);
  
  outc *= smoothstep(0.5, 0.55, abs(mod((uv.xy*rot(T*0.1)).x + T*.1 - texture(texFFTIntegrated, 0.02).r*0.05, 0.025)-0.0125)*80.0)*.2+.8;
  
  
  outc *= 1.0-pow(length(uv),2.0);
  
  outc = vec3(1.4, 1.4, 1.4)*outc / (1.0 + outc);
  
	out_color = vec4(outc, 0.5);
}