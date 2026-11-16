#version 410 core

// pumpuli here :3
uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 orange[16] = vec3[](
vec3(26/255., 28/255., 44/255.),
vec3(47/255., 33/255., 60/255.),
vec3(70/255., 35/255., 80/255.),
vec3(93/255., 39/255., 93/255.),
vec3(120/255., 40/255., 89/255.),
vec3(150/255., 50/255., 86/255.),
vec3(177/255., 62/255., 83/255.),
vec3(199/255., 92/255., 84/255.),
vec3(215/255., 110/255., 86/255.),
vec3(239/255., 125/255., 87/255.),
vec3(243/255., 160/255., 97/255.),
vec3(250/255., 180/255., 105/255.),
vec3(255/255., 205/255., 117/255.),
vec3(255/255., 230/255., 180/255.),
vec3(255/255., 240/255., 200/255.),
vec3(255/255., 255/255., 255/255.)
);

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}

vec4 sharpen(in sampler2D tex, in vec2 coords, in vec2 renderSize) {
  float dx = 1.0 / renderSize.x;
  float dy = 1.0 / renderSize.y;
  vec4 sum = vec4(0.0);
  sum += -1. * texture(tex, coords + vec2( -1.0 * dx , 0.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 0.0 * dx , -1.0 * dy));
  sum += 5. * texture(tex, coords + vec2( 0.0 * dx , 0.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 0.0 * dx , 1.0 * dy));
  sum += -1. * texture(tex, coords + vec2( 1.0 * dx , 0.0 * dy));
  return sum;
}

vec4 plas( vec2 v, float time )
{
    float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
    return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 zom=uv;
  
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float BPM=164;
  float fGt=fGlobalTime/60*BPM;
  float frc=fract(fGt);
  float iGt=mix(floor(fGt),fGt,frc);
  float flGt=fract(iGt);
  
  zom-=.5;
  zom*=1-flGt*.02+frc*.01*-8*int(mod(1-floor(fGt),2));
  rot(zom,sin(uv.x*5+flGt*3)*flGt*.03*(.5+int(2-mod(fGt,5))));
  //zom+=vec2(sin(fGt*.2),cos(fGt*.21))*.002;
  zom+=.5;
  
  

  
  
    vec2 m;
    m.x = atan(uv.y / uv.x) / 3.14;
    m.y = 1 / length(uv) * .2;
  m=floor(m*100)/100;
  
  
    float d = exp(abs(m.x*.05));
  
  
    float fs = texture( texFFTSmoothed, d ).r * 10;
    float f  = texture( texFFT, d ).r * 10;

    vec4 t = texture(texPreviousFrame,zom).rrrr*.2;//plas( m*3.14*.2+uv.y, iGt+m.y*4+f*.02 ) / m.y;
    t = clamp( t, 0.0, 1.0 );
  
  vec4 prev = texture(texPreviousFrame,zom);
  vec4 sharp= sharpen(texPreviousFrame,zom,vec2(400-fs*200))-prev*.3;
  
  sharp=mix(vec4(vec3(sharp.r+sharp.g+sharp.b)/3,1),sharp,.9+f*.8);
  
  t=vec4(vec3(t.r+t.g+t.b)/3,0);
  
  float c = t.r*((1)/m.y-fs*.5);
  
  c=mod(c,1);
  
  int ci = 0;
  
  ci = int(mod(c*15+f,16));
  
  vec4 oc=vec4(.5);
  
  oc*=(fs+prev-(.7+m.y*fs)*sharp*((1-f)*2*(.5-mod(floor(fGt),2))));
  oc*=vec4(orange[ci],0);
  
  oc/=.4+step(length(uv)-.3-fs*.2,0.0);
  
  out_color = oc;
}
