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

float noise(vec2 p) 
{
    return fract(sin(p.x*12.9898 + p.y*78.233));
}

float star(vec2 p, float r, in int n, in float m, in float roundness) {
    float an = 3.141593 / float(n);
    float en = 3.141593 / m;
    vec2  acs = vec2(cos(an), sin(an));
    vec2  ecs = vec2(cos(en), sin(en));

    float bn = mod(atan(p.x, p.y),2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= r * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p) * sign(p.x) - roundness;
}

float line(vec2 p, vec2 a, vec2 b, float r) {
	p -= a;
	b -= a;
	float d = length (p - b * clamp (dot (p, b) / dot (b, b), 0.0, 1.0));
	return smoothstep (r + 0.01, r, d);
}

float n;

#define ITERS 10.0

void main(void)
{
  vec2 p = (2.0 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
  vec2 uv = (1.0 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
  float t = fGlobalTime*0.2;

	float ff = 1 / length(p) * .5;

  
	float f = texture( texFFT, ff ).r*1;
  vec4 pp = texture(texPreviousFrame, p);
  
  n = noise(p+t+f);

	vec4 outcol = vec4(30.0);
	
  for (float i = 0.0; i < ITERS; i+=1) 
  {
    float s = star(p*cos(i*t)+tan(t*10)*4.0+cos(t+i),0.8+0.1*cos(i*f)*0.1,2+int(i*0.1+pp.x*10.1)+int(mod(t,4)*1.3),0.5,abs(cos(cos(f-t*0.1)+uv.x*1*cos(t+uv.y))*0.50-i*0.01+n*cos(t*5+pp.z)-tan(t*0.1*f)));
    float ss = star(p,cos(t*0.5+i*0.01+ff*10.)+i*t*0.1+ff,8,cos(t*10+ff)*0.01+0.5,cos(t+ff));
    vec3 base = vec3(0.5*i*0.1+p.x-f*0,0.4+0.4*s,0.1+i*0.5);
    vec3 color = mix(vec3(4.0), base, 1.0 - smoothstep(0.0, 4.0 / v2Resolution.y, s))/ss;
    color-=pp.rgb*cos(t*0.1+f)*0.1;
    outcol.rgb-=color*1.5; 
  }
  
  outcol.rgb/=ITERS;
  
  outcol = clamp( outcol, 0.0, 1.0 );
  
	out_color = outcol;
}