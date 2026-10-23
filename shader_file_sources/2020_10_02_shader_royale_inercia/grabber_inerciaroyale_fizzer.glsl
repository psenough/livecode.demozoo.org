#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
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

float seg(vec2 p,vec2 a,vec2 b){
  return distance(p,mix(a,b,clamp(dot(p-a,normalize(b-a))/distance(a,b),0.,1.)));
  }

  vec2 path(float t){
  return vec2(cos(t*2.3),sin(t*2.2)+cos(t*4.112)*.4)*(2.+cos(t*1.7)*.5);
    }

vec3 trail(vec2 p,float tofs)
    {

      vec3 out_color;
  float d=1e4;
  vec2 q0,q1;
  int N=120;
  for(int i=0;i<40;++i)
  {
    q1=path((fGlobalTime+tofs)-float(i)*.1)+vec2(cos((fGlobalTime+tofs)*.02+float(i) * .1)*.1,
                            sin((fGlobalTime+tofs)*.025+float(i) * .771))*.1;
    // NOT raymarching!!! :)
    if(i>0)
    {
      d=min(d,seg(p,q0,q1)-(1.-float(i)/float(N)*40.)*.1);
    }
    q0=q1;
  }
  
  out_color.rgb=(.5+cos(vec3(1,2,3)*fGlobalTime)+tofs*4.5)/(max(1e-4,d)*10.+.01)*.5;
  
  out_color.rgb+=(.5+cos(vec3(1,2,3)*fGlobalTime))/(max(1e-4,d)*.1+1.)*.1;return out_color;
    }
    
    
    
    bool ddd(vec3 p)
    {
      //p+=10;
      //p=mod(p,20)-10;
      return length(p.xy)>60;
    }
    
vec4 trace(vec3 ro,vec3 rd)
    {
      vec3 cell=floor(ro);
      vec3 invrd=vec3(1)/rd;
      vec3 t=((cell+max(sign(rd),0.))-ro)*invrd;
      for(int i=0;i<250;++i)
      {
        vec3 pt=t;
        int face=(t.x<t.y&&t.x<t.z)?0:
        (t.y<t.x&&t.y<t.z)?1:2;
        
        cell[face]+=sign(rd[face]);
        t[face]+=abs(invrd[face]);
        
        if(ddd(cell))
        {
          vec3 n=vec3(0);
          n[face]=1;
          return vec4(n,min(pt.x,min(pt.y,pt.z)));
        }
        
      }
      return vec4(1e9);
    }
    
    
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
float t=fGlobalTime;//+cos(gl_FragCoord.x*100+gl_FragCoord.y*200)*.01;
  vec3 ro=vec3(cos(t)*2,sin(t*2)*2,-30),rd=normalize(vec3(uv,1.));
  vec4 res=trace(ro,rd);
  
  vec3 ld=normalize(vec3(1,1,-1));
  vec3 p=ro+rd*res.w;
  float sh=trace(p+ld*.001,ld).w<1e5?0.:1.;
  
    out_color.rgb=res.rgb*sh;
  return;
  
  out_color.rgb=vec3(.5+.5*dot(res.rgb,-ld))*sh;
  return;
  

  
  out_color.rgb=trail(uv*6.,0);

    out_color.rgb+=trail(uv*4.*vec2(-1,1),1);
  
  {
  vec2 q=path(fGlobalTime);
  vec2 p=uv*6.;
  out_color.rgb+=vec3(1)/distance(p,q) * .01*(.5+cos(10*atan(p.y-q.y,p.x-q.x)));
  }
  
  {
    vec2 q=path(fGlobalTime+1);
  vec2 p=uv*4.*vec2(-1,1);
  out_color.rgb+=vec3(1)/distance(p,q) * .01*(.5+cos(10*atan(p.y-q.y,p.x-q.x)));
  }
  
  //out_color.rgb/=(out_color.rgb+2.)/1.2;
  
  out_color.rgb=clamp(out_color.rgb*.5,0.,1.);
  out_color.a=1.;
  /*
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
*/
  }