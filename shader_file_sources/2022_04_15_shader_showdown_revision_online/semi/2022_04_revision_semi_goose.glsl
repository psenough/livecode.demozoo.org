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


mat2 Rot(float r) {
  float c = cos(r), s = sin(r);
  return mat2(c,s,-s,c);
}
float cir(vec2 p, float radius) {
  return length(p)-radius;
}
float ls(in vec2 p, in float ra, in float rb, in float h){
  p.x = abs(p.x);
  float b = (ra-rb)/h;
  vec2 c = vec2(sqrt(1.-b*b),b);
  float k = c.x*p.y - c.y*p.x, m = dot(c,p), n = dot(p,p);
  if(k < 0.){
    return sqrt(n)-ra;
  } else if (k > c.x*h) {
    return sqrt(n+h*h-2.*h*p.y) -rb;
  }
  return m - ra;
}

void draw (float dist, vec4 mc, inout vec4 fc) {
  float dtc = fwidth(dist) *.5;
  fc = mix(fc, vec4(0,0,0,1), smoothstep(dtc, -dtc, dist-0.01));
  fc = mix(fc, mc, smoothstep(dtc,-dtc, dist));
}

void sd (vec2 p, inout vec4 fc) {
  p.x += .5;
  p *= Rot(.1*sin(fGlobalTime*3.));
  vec2 po = p;
  float face = cir(p-vec2(0,0.01), 0.3);
  draw(face, vec4(.5, .5, .5,1.), fc);
  p = po;
  vec2 np = p;
  np.x = abs(np.x);
  //float c1 = cir(np-vec2(.15,0.05), 0.075);
  draw(cir(np-vec2(.15,0.05), 0.075), vec4(1), fc);
  draw(cir(np-vec2(.15, 0.05), 0.03), vec4(0.),fc);
  draw(cir(np-vec2(.13, 0.05), 0.01), vec4(1.), fc);
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float r = length(uv);
  vec3 bg = mix(vec3(0.93,0.91,0.62), vec3(0.9, 0.44, 0.44), r);
  vec2 pos = 10.*uv*Rot(1.55);
  pos -= vec2(-4.75,0.);
  vec2 rep = fract(pos);
  float dist = 2.0*min(min(rep.x, 1.-rep.x), min(rep.y, 1.-rep.y));
  float sqd = length((floor(pos)+vec2(0.5))-vec2(5.0));
  float edge = sin(fGlobalTime-sqd*.5)*.5+.5;
  edge = (fGlobalTime-sqd*.5)*.5;
  edge = 2.0*fract(edge*.5);
  float value;
  value = fract(dist*2.);
  value = mix(value, 1.0-value, step(1.,edge));
  edge = pow(abs(1.-edge),2.);
  value = smoothstep(edge-0.05, edge, .95*value);
  value += sqd*.21;
  out_color = mix(vec4(1.,1.,1.,1.), vec4(bg,1.), value);
  //out_color = vec4(bg, 1);
   sd(uv, out_color);
  
  
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	//out_color = f + t;
}