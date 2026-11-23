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
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float pi = acos(0) * 2.;
float tau = acos(0) * 4.;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec2 rotc(vec2 uv, float a, vec2 rcenter)
{
  float ar = .6;
  mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
  rcenter.x = (rcenter.x - .5) * (1. / ar) + .5;
  uv -= rcenter;
  uv *= rot;
  uv += rcenter;
  uv.x = (uv.x - .5) * ar + .5;
  return uv;
}

vec2 rotci(vec2 uv, float a, vec2 rcenter)
{
  mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
  uv -= rcenter;
  uv *= rot;
  uv += rcenter;
  return uv;
}

vec4 tex_rleg(vec2 uv, float a)
{
  uv = rotc(uv, a, vec2(-.03, -.04) + vec2(.5, .5));
  if (uv.x >= 0. && uv.y >= .42 && uv.x <= .5 && uv.y <= .56) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_rlleg(vec2 uv, float a1, float a2)
{
  uv = rotci(uv, a1, vec2(-.03, -.04) + vec2(.5, .5));
  uv = rotc(uv, a2, vec2(-.04, .06) + vec2(.5, .5));
  if (uv.x >= 0. && uv.y >= .56 && uv.x <= .5 && uv.y <= 1.) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_llleg(vec2 uv, float a1, float a2)
{
  uv = rotci(uv, a1, vec2(.03, -.04) + vec2(.5, .5));
  uv = rotc(uv, a2, vec2(.05, .06) + vec2(.5, .5));
  if (uv.x >= .5 && uv.y >= .56 && uv.x < 1. && uv.y < 1.) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_lleg(vec2 uv, float a)
{
  uv = rotc(uv, a, vec2(.03, -.04) + vec2(.5, .5));
  if (uv.x >= .5 && uv.y >= .42 && uv.x < 1. && uv.y < .56) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_larm(vec2 uv, float a)
{
  uv = rotc(uv, a, vec2(.06, -.23) + vec2(.5, .5));
  if (uv.x >= .56 && uv.y >= 0. && uv.x < 1. && uv.y <= .42) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_rarm(vec2 uv, float a)
{
  uv = rotc(uv, a, vec2(-.06, -.23) + vec2(.5, .5));
  if (uv.x >= 0. && uv.y >= 0. && uv.x < .44 && uv.y <= .42) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_body(vec2 uv)
{
  uv = rotc(uv, 0., vec2(.5, .3));
  if (uv.x >= .44 && uv.y >= .21 && uv.x < .56 && uv.y <= .42) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_head(vec2 uv, float a)
{
  uv = rotc(uv, a, vec2(.5, .22));
  if (uv.x >= .464 && uv.y >= 0. && uv.x < .535 && uv.y <= .23) {
    return texture(texEvilbotTunnel, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_head2(vec2 uv, float a, sampler2D texs)
{
  uv *= 8.;
  mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
  uv -= vec2(4.0, 1.4);
  uv *= rot;
  uv += vec2(.5, .5);
  if (uv.x >= 0. && uv.y >= 0. && uv.x < 1. && uv.y <= 1.) {
    return texture(texs, uv);
  } else {
    return vec4(0.);
  }
}

vec4 tex_vilbot(vec2 uv, float a_head, float a_larm, float a_rarm, float a_lleg, float a_rleg, float a_lknee, float a_rknee, int modhead)
{
  vec4 ret = vec4(0.);
  vec4 vilbot;
  uv = (uv * vec2(1., -1.) + vec2(1.)) * vec2(.5);
  vilbot = tex_rleg(uv, a_rleg);
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_rlleg(uv, a_rleg, a_rknee);
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_lleg(uv, a_lleg);
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_llleg(uv, a_lleg, a_lknee);
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_rarm(uv, a_rarm); 
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_larm(uv, a_larm);
	ret = mix(ret, vilbot, vilbot.a);
  vilbot = tex_body(uv);
	ret = mix(ret, vilbot, vilbot.a);
  if (modhead == 0) {
    vilbot = tex_head2(uv, a_head, texEwerk); 
  } else if (modhead == 1) {
    vilbot = tex_head2(uv, a_head, texC64); 
  } else if (modhead == 2) {
    vilbot = tex_head2(uv, a_head, texAmiga); 
  } else if (modhead == 3) {
    vilbot = tex_head2(uv, a_head, texZX); 
  } else if (modhead == 3) {
    vilbot = tex_head2(uv, a_head, texST); 
  } else {
    vilbot = tex_head(uv, a_head); 
  }
	ret = mix(ret, vilbot, vilbot.a);
  return ret;
}

vec3 rainbow(float v)
{
  v = floor(v * 7) / 7;
  v *= pi;
  float fc1 = max(0., sin(v-pi/3));
  float fc2 = max(0., sin(v));
  float fc3 = max(0., sin(v+pi/3));
  return vec3(fc1, fc2, fc3);
}

vec4 revilogo(vec2 uv, float a, float z)
{
  mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
  uv = uv / z * rot * 0.5 + 0.5;
  if (uv.x >= 0. && uv.y >= 0. && uv.x < 1. && uv.y <= 1.) {
    return texture(texRevisionBW, uv);
  } else {
    return vec4(0.);
  }
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv = uv * 2. - 1.;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  //mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
  //vec2 rotuv = uv * rot;
  vec4 vilbot; //texture(texEvilbotTunnel, uv);
  out_color.rgb = uv.xyy + vec3(.5);
  float ang = atan(uv.x, uv.y)/pi;
  float ap = ang + length(uv.xy) * 5. + fGlobalTime * -2.;
  
  float spika = 0.1;
  float spikl = -10. * texture(texFFT, 0.1).x * 2.;
  float spikr = texture(texFFTIntegrated, 0.2).x * .5 + .1;
  float tang = mod(ang + -spikr * .1, .125) / .125;
  if (tang >= 0. && tang < spika) ap += tang * spikl;
  else if (tang >= spika && tang < spika * 2.) ap += ((2 * spika) - tang) * spikl;
  
  out_color.rgb = rainbow(fract(ap)) * .5 + .5;

  vec4 revp = revilogo(uv, -fGlobalTime, 1.);
  //out_color = vec4(mix(out_color.rgb, vec3(0), revp.a*.5), 1.);

//out_color.rgb = vec3(sin(ap*tau));
  //out_color.rgb = vec3(length(uv.xy));
  //out_color.rgb = vec3(tang);
  float a;
  a = sin(fGlobalTime * 3.)*.5;
  mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
//  uv *= (a * .5 + 1);
  a = fGlobalTime * 2. + texture(texFFTIntegrated, 0.2).x;
  vilbot = tex_vilbot(uv, sin(a)*.5, sin(a), -sin(a), sin(a), sin(a), -sin(a), -sin(a), int(mod(fGlobalTime, 5)));
	out_color = vec4(mix(out_color.rgb, vilbot.rgb, vilbot.a), 1.);
  

  //out_color = texture(texFFT, uv.x) + 0.5;
}