#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex3;
uniform sampler2D texTex2;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

float rect1(vec2 p, float sizeX, float sizeY, float r) {
  p = pow(max(abs(p) + r - sizeX, 0.), vec2(4));
  float v = p.x+p.y - pow(r,4.);
  return smoothstep(-1., 1., v/fwidth(v));
}

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float rect(vec2 uv, vec2 size, float blur) {
    vec2 d = abs(uv) - size;
    return smoothstep(blur, 0.0, max(d.x, d.y));
}

vec4 getFront(vec2 uv) {
  float r = 1.;//rect(uv - vec2(0.5, 0.5), vec2(0.4, 0.4), 0.01);
  float x = rand(vec2(floor(fGlobalTime*1.)));
  x = mix(abs(sin(fGlobalTime)), x, 0.5);
  r -= rect(uv - vec2(x, 0.5), vec2(0.07, 0.5), 0.01);
  r -= rect(uv - vec2(1.-x, 0.5), vec2(0.1, 0.5), 0.01);
  return vec4(0,0,0,r);
}

void main(void) {
    float time = fGlobalTime;
      time *= 5.;
  // time = texture(texFFTIntegrated, 1).x;
    vec2 fragCoord = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  	vec2 uv = fragCoord;
    uv -= 0.5;
  	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    // vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    // Normalized pixel coordinates (from -1 to 1)
    // vec2 uv = (fragCoord * 2.0 - v2Resolution.xy) / v2Resolution.y;
    // vec2 uv = (fragCoord * 2.0 - v2Resolution.xy) / v2Resolution.y;
    // uv = fragCoord;

        float angle = fGlobalTime*0.1;
        float s = sin(angle), c = cos(angle);
        uv *= mat2(c, -s, s, c);

    vec2 uv0 = uv; // Store initial uv for global glow
    vec3 finalColor = vec3(0.0);

    for (float i = 0.0; i < 6.0; i++) {
        // Fractional repetition (Domain Folding)
        uv = fract(uv * (1.6+sin(time*0.1)*0.6) ) - 0.5;
        // uv = fract(uv * 1.1) - 0.5;
   
        float d = length(uv) * exp(-length(uv0));
        // d = length(uv) * length(uv0);
        // d = length(uv) / 10.;
        //float d = pow(length(uv), length(uv0)); // * exp(-length(uv0));

        float pat = time*0.01 + i * 0.1;
        vec3 col; // palette(pat, vec3(0.5), vec3(0.9), vec3(2,1,1), vec3(0, 0.3, 0.6));
        col = palette(uv0.x, vec3(0.9), vec3(0.3), vec3(.2), vec3(0.5, 0.3, 0.6));

        d = sin(d * 8.0 + time*.5) / 8.0;
        d = abs(d);

        finalColor += col * d;
    }

   vec4 front = getFront(fragCoord);
   finalColor = mix(finalColor, front.rgb, front.a);

    out_color = vec4(finalColor, 1.0);
  }

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main2(void)
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

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}