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

mat2 Rot(float a) {
  float s=sin(a),c=cos(a);
  return mat2(c,-s,s,c);
}

vec2 hash(vec2 p) {
   vec2 ml;
  ml.x =atan(p.x,p.y)/3.14;
  ml.y = 1/length(p)*.2;
  float d = ml.y;
  float f = texture( texFFTSmoothed, d ).r * .001;
  mat2 m = mat2(15.32,83.43,117.38,289.59);
  return fract(sin(m*p)*45678.789*f);

}

float vor(vec2 p) {
  vec2 g = floor(p);
  vec2 f = fract(p);
  float dfp = 1.;
  for(int y=-1;y<=1;y++){
    for(int x=-1;x<=1;x++){
      vec2 lp = vec2(x,y);
      float h = distance(lp+hash(g+lp),f);
      dfp=min(dfp,h);
    }
  }
  return sin(dfp);
}

float text(vec2 uv) {
  float t =vor(uv*8.+vec2(fGlobalTime));
  t*=1.-length(uv*2.);
  return t;
}

float fbm(vec2 uv) {  
  float s = 0.;
  float a = 1.;
  
  for(int i=0;i<4;i++){
    s+=text(uv)*a;
    uv+=uv;
    a*=.8;
  }
  return s;
}

vec4 cols(vec2 uv) {
  float t = pow(fbm(uv*.3),2.);
  return vec4(vec3(t*8.,t*3.,t*8.),1.);
}

vec2 uvs(vec3 p) {
    p = normalize(p);
    float x = atan(p.x,p.y)/6.283;
  float y = asin(p.y) / 3.141;
  return vec2(0.5)+vec2(x,y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv = (2.0 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  vec3 col = vec3(1.);
  vec3 cam = vec3(0,0,-5);
  vec3 dir = normalize(vec3(uv,1));
  float t = 0.;
  for (int i=0;i<100;i++){
    vec3 hp = cam+dir*t;
    float d = length(hp)- 2.5;
    t+=d;
    if(d<0.0001 || t>100) {
      break;
    }
  }
  
  col = (1.-cols(uv)).rgb;
  
  if (t < 100){
    vec3 p = cam + dir *t;
    vec2 uv2 = uvs(p);
    col = cols(uv2).rgb;
    //col = vec3(1);
  }
  
	out_color = vec4(col,1);//f + t;
}