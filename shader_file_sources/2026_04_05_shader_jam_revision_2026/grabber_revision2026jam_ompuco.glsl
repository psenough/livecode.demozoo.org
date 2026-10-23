#version 420 core
 precision highp float;
precision highp sampler2D;

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}











vec2 rot(vec2 p, float a) {
	return vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}




    //random function
			 float nrand(float x, float y)
    {
        return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
    }


    
    
    
                    vec3 SphereRand(uint seed)
            {
                float a = (float((seed * 0x73493U) & 0xfffffU) / float(0x100000)) * 2. - 1.;
                float b = 6.283 * (float((seed * 0xAF71fU) & 0xfffffU) / float(0x100000));
                float cosa = sqrt(1. - a * a);
                return vec3(cosa * cos(b), a, cosa * sin(b));
            }



vec3 applyHue(vec3 aColor, float aHue) {
	float angle = radians(aHue);
	vec3 k = vec3(0.57735, 0.57735, 0.57735);
	float cosAngle = cos(angle);
	//Rodrigues' rotation formula
	return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1. - cosAngle);
}


            
            
            
            

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d,.0));
  
}
float sdCross( in vec3 p )
{
  float inf = 100000000.0;
  float da = sdBox(p.xyz,vec3(inf,1.0,1.0));
  float db = sdBox(p.yzx,vec3(1.0,inf,1.0));
  float dc = sdBox(p.zxy,vec3(1.0,1.0,inf));
  return min(da,min(db,dc));
}



vec3 frctl( vec3 p )
{
   float d = sdBox(p,vec3(1.0));
   vec3 res = vec3( d, 1.0, 0.0);

   float s = 1.0;
   for( int m=0; m<3; m++ )
   {
      vec3 a = mod( p*s, 2.0 )-1.0;
      s *= 3.0;
      vec3 r = abs(1.0 - 3.0*abs(a));

      float da = max(r.x,r.y);
      float db = max(r.y,r.z);
      float dc = max(r.z,r.x);
      float c = (min(da,min(db,dc))-1.0)/s;

      if( c>d )
      {
          d = c;
          res = vec3( d, 0.2*da*db*dc, (1.0+float(m))/4.0 );
       }
   }

   return res;
}






float map(vec3 p, float fft1, float fft2)
{
  float d = 1.0;
  
  //if(length(p)<2.0)
  //p = mod(p+vec3(0.0,fft1,fft2), vec3(1.0));
  
  
  d = min(d, sdBox(p, vec3(.5)));
  
    d = max(d, sdCross(p));
  
  
  vec3 frct = frctl(p);
  d = frct.y-.0 - pow(fft2,.5)*.01;
  return d;
}

vec3 raymarch(vec3 ro, vec3 rd, float n, float fft0, float fft1, float fft2)
{
  int steps = 64;
  
  
  
  
  
  
  
  vec3 pos = ro + rd*1.0;
  
  float d = 1.0;
  
  for(int i = 0; i < steps; i++)
  {
    n = nrand(n,i);

    d = map(pos/4., fft1, fft2);
    if(d<.0) break;
    rd = mix(rd, SphereRand(uint(n*10000.0)),.0421*fft0);
            pos = pos + rd*d*(.5+n*(.2+fft0));

  }
  
  
  return pos;
}


void main(void)
{
  
      vec4 prevClock = texture( texPreviousFrame, vec2(3.0) / v2Resolution);

  
  float fft0 = texture( texFFTSmoothed, .05 ).r*10.;
  float fft1 = texture( texFFTIntegrated, .2 ).r*3.;
  float fft2 = texture( texFFTIntegrated, .5 ).r*3.;
  
  
  
  if(round(gl_FragCoord.x/8.)==0.0 && round(gl_FragCoord.y/8.)==0.0){
    
  
    out_color=vec4(mod(prevClock.r + prevClock.g*.05,1.), max(prevClock.g*.8,mix(max(fft0*.2,prevClock.g),fft0,.025)), 1.0,1.0);
    return;
  }
  
  out_color = vec4(.0);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	//uv -= 0.5;
  
  vec2 uvOriginal = uv;
  
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  
  float n = nrand(uv.y, nrand(uv.x,nrand(uv.y,fGlobalTime)));
  
  
    vec4 prev = texture( texPreviousFrame, uvOriginal);

      float musicTime = fGlobalTime*.0 + prevClock.r*3.141592653*4.;
  
  
  
  for(int i = 0; i < 4; i++)
  {
    n = nrand(n,i);
  
  
  
  
  vec3 ro = vec3(.0,0.0,0.0);
  
  ro.xy += vec2(
    sin(musicTime*.3)*3.0,
    cos(musicTime*.3)*3.0
  );
  
  
  vec3 rd = (vec3(uv - vec2(.5), 1.));
  
  	rd.z -= length(rd)*.5;
    
    rd.z*=.5;
    
    //rd.z/=length(rd);
    
    
    
    

  
  
  
    rd.yz = rot(rd.yz,cos(musicTime*.3)*1.5);
    rd.xz = rot(rd.xz,sin(musicTime*.3)*1.5);



  
  vec3 rm = raymarch(ro, rd, n, fft0, fft1, fft2);
  
  


	float f = texture( texFFTSmoothed, pow(length(rm*.1),1.5) ).r*10.;
  
  
  
  
  vec4 newCol = vec4(sin(f));
  
  newCol.xyz = applyHue(vec3(.5,1.0,.0), newCol.x*320.0+fft1*20.)*newCol.xyz*5.;

  
	out_color += mix(prev, newCol, .5-step(5.5,length(rm))*.4) /4.0;
}
}