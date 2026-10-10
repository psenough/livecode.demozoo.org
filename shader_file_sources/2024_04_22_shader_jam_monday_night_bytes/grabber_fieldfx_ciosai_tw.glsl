#version 410 core

#define PI  3.14159265359
// SQuareroot
#define SQ3 1.73205080757
#define SQ2 1.41421356237

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

mat2 rot(in float angle){
    return mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
}

float polygon(in vec2 st, in float sides){
  float accum = 0.;
  for(float i=0.;i<32.;i++){
    accum = max(accum, (st*rot(i*PI/sides)).x);
    if(i-1.>sides) break;
  }
  return accum;
}

vec3 mul3( in mat3 m, in vec3 v ){return vec3(dot(v,m[0]),dot(v,m[1]),dot(v,m[2]));}

//luminance saturation hue
vec3 oklch_to_srgb( in vec3 c ) {
    c = vec3(c.x, c.y*cos(c.z), c.y*sin(c.z));
    mat3 m1 = mat3(
        1,0.4,0.2,
        1,-0.1,-0.06,
        1,-0.1,-1.3
    );

    vec3 lms = mul3(m1,c);

    lms = pow(lms,vec3(3.0));

    
    mat3 m2 = mat3(
        4, -3.3,0.2,
        -1.3,2.6,-0.34,
        0.0,-0.7, 1.7
    );
    return mul3(m2,lms);
}

void main(void)
{
  vec2 uncentered = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float volume = texture(texFFT,uncentered.x*.3).r;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float t = fGlobalTime*.2+volume;

	float px=1.5/v2Resolution.y;
  float level = 0.;
  for(float i=0.;i<24.;i++){
      float t_f = t+texture(texNoise, vec2(i*.282, .0)).r*8.;
      float t_i = floor(t_f);
      float size = mod(t_f,1.)*.1;
      vec2 shift = uv;
      shift *= rot(
          texture(texNoise, vec2(i*.755, t_i*.246)).r
          *PI*8.);
      float dorto_pos = -pow(mod(t_f,1.),1.8)*1.2;
      float sides = texture(texNoise, vec2(i*9.582, .0)).r*4.;
      sides = 2.+floor(sides);
      level+=1.-smoothstep(size, size+px, polygon(shift-vec2(dorto_pos,0.), sides));
  }
  level = mix(0., 1., level-floor(level*2.)/2.);
  vec3 col = oklch_to_srgb(vec3(1.,1.,mod(t*3.,2.*PI)));
  
  out_color.r = texture(texPreviousFrame, uncentered+vec2(-SQ2,SQ2)*px).b*0.98;
  out_color.g = texture(texPreviousFrame, uncentered+vec2(SQ2,SQ2)*px).r*0.98;
  out_color.b = texture(texPreviousFrame, uncentered+vec2(0.,1.)*px).g*0.98;
	out_color.rgb = mix(out_color.rgb, col, level);
}