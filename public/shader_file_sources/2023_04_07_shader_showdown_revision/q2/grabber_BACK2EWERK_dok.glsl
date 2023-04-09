#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
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

float p2(vec2 p, vec2 uv, float r) {
    
    return 1.0-step(r, length(uv -p));
}
mat2 rot2(float a){return mat2(cos(a), sin(a), -sin(a), cos(a));}
void main(void)
{
	vec2 uv = gl_FragCoord.xy / v2Resolution.y;
  vec2 UV = gl_FragCoord.xy -  0.5 * v2Resolution / v2Resolution.y;
  vec3 col = vec3(0);
  uv *= mix(1.0,2., texture(texFFT,0.01).r);
  UV=uv * rot2(fGlobalTime*00.1) + vec2(0.5,0) * sin(fGlobalTime) + vec2(0.0,0.2) * sin(fGlobalTime);
  switch(int(fract(fGlobalTime*175.0/120.0)*8)) {
    case 4:
      case 5:
        case 6:
          case 7:
    case 1:
  for (float i = 0.0; i < 4.0; i+=0.1) {
  vec2 r = v2Resolution / v2Resolution.y;
  vec2 d = vec2(0.4, 0.7);
  vec2 p = d * (fGlobalTime - i*mix(0.8,1.2,sin(fGlobalTime)));
  vec2 s = (0.5 - fract(p/r))*r;
  col.r += p2(2 * sign(s) * s, uv, mix(0.1,0.8, texture(texFFT, mix(0.01, 0.1, i)).r));
  }
  case 2:
  uv *= rot2(sin(fGlobalTime));
  uv *= 3;
  uv = fract(uv);
  for (float i = 0.0; i < 1.0; i+=0.1) {
  vec2 r = v2Resolution / v2Resolution.y;
  vec2 d = vec2(0.8, -0.3);
  vec2 p = d * (fGlobalTime - i*mix(0.8,1.2,sin(fGlobalTime)));
  vec2 s = (0.5 - fract(p/r))*r;
  col.r += p2(2 * sign(s) * s, uv, mix(0.05,0.2, texture(texFFT, mix(0.01, 0.1, i)).r));
  }
  case 3:
  uv *= rot2(sin(fGlobalTime));
    uv = fract(uv);
  for (float i = 0.0; i < 1.0; i+=0.1) {
  vec2 r = v2Resolution / v2Resolution.y;
  vec2 d = vec2(0.4, 0.2);
  vec2 p = d * (fGlobalTime - i*mix(1.8,2.0,sin(fGlobalTime)));
  vec2 s = (0.5 - fract(p/r))*r;
  col.b += p2(2 * sign(s) * s, uv, mix(0.02,0.2, texture(texFFT, mix(0.01, 0.1, i)).r));
  }
}
  if (col.b > 0)
    col.r = 1.0 - col.r;
 
   if (texture(texFFT, 0.02).r > 0.2)
  col.r = 1.0 - col.r;
   if(texture(texRevision, UV).r  > 0.5)
     col.r = 1.0 - col.r;
  col.rgb = col.rrr;
	out_color = vec4(col, 1.0);
}