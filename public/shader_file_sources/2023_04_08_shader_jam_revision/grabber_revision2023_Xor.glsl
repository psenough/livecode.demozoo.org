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

float hash(float p)
{
    return fract(cos(p*.7)*4e3);
}
float hash(vec2 p)
{
    return fract(cos(dot(p,vec2(.7,.51)))*4e3);
}

vec4 hash4(vec2 p)
{
    return fract(cos(dot(p,vec2(.7,.51)))*vec4(.7,.8,.9,1)*4e3);
}
mat2 rotate2D(float a)
{
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= texture(texFFT,.1).r*.5+2.;
  uv += cos(ceil(length(uv)/.1)-texture(texFFTIntegrated,.1).r*1e2)*uv*length(uv)*texture(texFFT,.1).r;

	vec3 d = normalize(vec3(uv,0.5));

  d.yz *= rotate2D(.1);
  d.xy *= rotate2D(cos(fGlobalTime*.2)*.5);
  d.yz *= rotate2D(.6);

  vec3 p = vec3(0,2,fGlobalTime/.1+hash(gl_FragCoord.xy+fract(fGlobalTime))*.2+texture(texFFT,.1).r*1e0)*.1;
  vec3 c = p;
  vec3 v;

  float m;
  float shade = 0.0;
  for(int i = 0;i<100;i++)
  {
    v = p;
    m = max(p.y-abs(tan(ceil(fGlobalTime))),abs(cos(ceil(fGlobalTime)))+.5-max(abs(p.x),p.y-2.));
    float h = .4+.2*hash(floor(fGlobalTime/vec2(4,5)));
    if (i==50)
    {
        d=normalize(hash4(gl_FragCoord.xy-fract(fGlobalTime)).xyz);
        //p+=(c-p)/1e4;
        shade = 0.0;
    }

    for(float s = 1e1; s>.01; s*=h)
    {
        float r = s*h*(cos(h*h*1e3)*.1+1.);
        v = r-abs(mod(v,s*2.)-s);
        m = max(m,cos(ceil(fGlobalTime)/.4)>.2?r-length(r+v): min(v.x,min(v.y,v.z)));
        v.xz *= rotate2D(s*tan(h*h*1e3));
    }
    if (i>50) m += 5e-5;
    p += d*m;
    shade += max(16e-3-m*m,0.);
  }

  uv /= abs(sin(ceil(fGlobalTime)/.9+cos(fGlobalTime)));
  uv *= rotate2D(sin(ceil(fGlobalTime)/.13));
  uv += sin(ceil(fGlobalTime)*vec2(7.4,5.3));
  uv = mod(uv+3.,6.)-3.;
  vec2 X = uv+vec2(1,0);
  X *= rotate2D(.8);
  vec2 R = uv-vec2(1,0);
  float rd = (.1-length(clamp(R,-vec2(0,.4),vec2(0,.4))-R));
  R *= rotate2D(-.3);
  rd = max(rd,(.1-length(clamp(R,-vec2(-.15,-.2),vec2(.6,-.2))-R)));


  float s = sign(sin(ceil(fGlobalTime)/.7));
  if (cos(fGlobalTime)>.5) shade = s*min(shade*s,s*max(max((.1-length(clamp(X,-vec2(.6,0),vec2(.6,0))-X)),(.1-length(clamp(X,-vec2(0,.6),vec2(0,.6))-X))),max((.1-abs(length(uv)-.4)),rd))*v2Resolution.y);
  vec4 prev = texture2D(texPreviousFrame,gl_FragCoord.xy / v2Resolution);

  
  //shade *= 2.;
  vec2 M = v2Resolution.yy*.2;
  for(int i = 0;i<8;i++)
  {
    vec2 P = gl_FragCoord.xy*rotate2D(float(i)*.1-7.+cos(texture(texFFTIntegrated,.2).r)*.5)+fGlobalTime*length(M)*2.;
    float h = (hash(ceil(P/M/2.)+vec2(i,i*9))*.4-.2);
    h *= cos(h*h*1e3+fGlobalTime+texture(texFFT,.2).r*7e1);
    shade -= sqrt(1./length(max(abs(mod(P,M*2.)-M)-M*h,0.)));
    M*=.9;
  }
	out_color = vec4(1.-shade,prev)*pow(hash4(ceil(fGlobalTime/vec2(4,5))),vec4(.4,.1,.1,1));
  }
