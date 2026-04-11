#version 410 core

#define PI 3.1415

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// THANK YOU Inigo Quilez you are invalueable :pray:

float sdOrientedBox(in vec2 p, in vec2 a, in vec2 b, float th )
{
    float l = length(b-a);
    vec2  d = (b-a)/l;
    vec2  q = (p-(a+b)*0.5);
          q = mat2(d.x,-d.y,d.y,d.x)*q;
          q = abs(q)-vec2(l,th)*0.5;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);    
}

float sdSphere(in vec2 p, float r) {
  return length(p) - r;
}

vec2 repeated( vec2 p, float s )
{
    vec2 r = p - s*round(p/s);
    return r;
}

float smin( float a, float b, float k )
{
    k *= log(2.0);
    float x = b-a;
    return a + x/(1.0-exp2(x/k));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv_nn = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float contrib = 0.3;
  float zoom = texture(texFFTSmoothed, 0.01).r * 0.5;
  
  vec4 fft_color = texture(texFFT, uv.x / 4);
  //vec3 col = fft_color.xyz;
  vec3 col = texture(texPreviousFrame, uv_nn).rgb * 0.7;
  
  col += texture(texEvilbotTunnel, -uv_nn * 4 + fGlobalTime).rgb * 0.3;
  
  
  vec2 p = uv * (zoom + 1);
  for (int j = 0; j < 10; j++) {
    float jt = j / 4;
    float t = texture(texFFTIntegrated, 0.04 + jt * 0.04).r;
    float l = texture(texFFT, 0.02 + jt * 0.2).r * 0.5;
  vec2 p1 = vec2(cos(t + j) - sin(t * 2) * 0.2, sin(t) - cos(t * 2) * 0.2);
  vec2 p2 = vec2(cos(PI + t) - sin(t * 2) * 0.2, sin(PI + t + j) - cos(t * 2) * 0.2);
  float bg_melt = 2.;
  for (int i = 0; i < 10; i++) {
    float s = sdSphere(repeated(p + mod(vec2(fGlobalTime / 10), 1), 0.25) + j / 6, 0.1 * texture(texFFT, uv.x).x + i / 20);
    bg_melt = min(bg_melt, s);
  }
  float d = smin(
    sdOrientedBox(p, p1, p2, l),
    bg_melt, 0.05
  );

  bool hit = d < 0;
  
  float p = (j / 4);
  
  if (hit) {
    col.r += contrib*(0.5 + sin(p + t * 3) * 0.5);
    col.g += contrib*(0.5 + sin(p + t * 3 + (PI / 3)) * 0.5);
    col.b += contrib*(0.5 + sin(p + t * 3 + 2 * (PI / 3)) * 0.5);
  }
  }
	out_color = vec4(col, 0.);
}