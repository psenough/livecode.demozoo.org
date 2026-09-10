#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
    q= ((q>>16u)^q.yzx)*1111111111u;
      q= ((q>>16u)^q.yzx)*1111111111u;
    q= ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec3 stepNoise(float t,float n){
    float u = smoothstep(.5-n,.5+n,fract(t));
    return mix(hash3d(vec3(floor(t),-1U,1234657980)),hash3d(vec3(floor(t+1),-1U,1234657980)),u);
    
}
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}
float bpm = fGlobalTime * 128/60;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv *= 1+2*step(.3,abs(uv.y))*hash3d(vec3(uv,bpm)).x*.1;
vec3 col = vec3(0);
   vec3 ro = vec3(0.,0.,-5),rt=vec3(0.);
   vec3 z = normalize(rt-ro),x = vec3(z.z,0,-z.x);
  vec3 rnd = stepNoise(bpm/3,.2);
  
    vec3 rd = mat3(x,cross(z,x),z)*erot(normalize(vec3(uv,1.-rnd.x)),vec3(0,0,1),rnd.x*10+bpm*.5);
    float tbpm = floor(bpm)+smoothstep(.1,.9,fract(bpm));
  vec3 nrot = normalize(stepNoise(bpm,.5)-.5);
  float i=0.,e=0.,g=0;
  for(int cc=0;cc<3;cc++){
    for(;i++<60;){
            vec3 p= ro+rd*g;

      p.zxy += tbpm*5;
      vec3 id = floor(p/8);
       vec3 op=p;
      p = mod(p,6)-3;
      p = erot(p,nrot,bpm);
           
      p.x += cos(p.y+bpm)*.2;
          float h= sdCapsule(p,vec3(0,2,0),vec3(0,-2,0),.2+sqrt(texture(texFFTSmoothed,sin(atan(p.x,p.z)*30+bpm)).r*.5));;
          g+=e=max(.001,h);

          col+=(.95+.2*sin(atan(p.x,p.z)*3+bpm))*vec3(1.,.2,.3)*(.1525*exp(-5*fract(bpm+op.y*.1)))/exp(i*i*e);
    }
  }
    col = mix(col,vec3(1.0,1.0,1.0),1-exp(-.0001*g*g*g));
  vec3 rr = stepNoise(bpm,.2);
  col = mix(1-col,col,step(abs(uv.y)-.4,sqrt(texture(texFFTSmoothed,mix(rr.x,rr.y,uv.x)).r)));
	out_color = vec4(sqrt(col),1.);
}


/**


ON SCENE DANS UNE SAUCISSE !
GREETINGS TO NuSan, Peregrine, Callisto, Marex, Alkama xtrium 
                     
and all other coders all around the world !!


*/