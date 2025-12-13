Texture2D texChecker;
Texture2D texNoise;
Texture2D texTex1;
Texture2D texTex2;
Texture2D texTex3;
Texture2D texTex4;
Texture1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
Texture1D texFFTSmoothed; // this one has longer falloff and less harsh transients
Texture1D texFFTIntegrated; // this is continually increasing
Texture2D texPreviousFrame; // screenshot of the previous frame
SamplerState smp;

cbuffer constants
{
	float fGlobalTime; // in seconds
	float2 v2Resolution; // viewport resolution (in pixels)
	float fFrameTime; // duration of the last frame, in seconds
}

float4 plas( float2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return float4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


void R(inout float2 p,float a)
{
  a*=2*.3141593;
  p = p*cos(a) + float2(p.y,-p.x)*sin(a);
}

float M(float x,float r)
{
    return (x/r-floor(x/r)-.5)*r;
}

float cu(float3 q)
{
  q=abs(q);
  return max(max(q.x,max(q.y,q.z))-1,1.3-length(q));
}
float cube(float3 q,float3 r)
{
  q=abs(q)-r;
  return max(q.x,max(q.y,q.z));
}


float sdf(float3 p)
{
  float t = fGlobalTime*5;
  float d = length(p)-1;
  
  float3 q = p;
  //q.y -= sin(t);
  //q.x = (q.x/5-floor(q.x/5)-.5)*5;
  R(q.xz,t);
  R(q.xy,t/3);
  //d = cu(q);
  d = max(length(p.xy)-4,abs(p.z)-9);
  
  q=p;
  q.z -= 10;
  q.y -= 3;
  d = min(d,cube(q,5));
  q.z = M(q.z,30);
  float b = max(cube(q,float3(5,5,10)),8-p.z);
  
  q = p;
  q.z=M(q,5);
  q=abs(q);
//  b = max(b,2-max(q.y,q.z));
//  b = max(q.y,q.z)-2;
  d = min(d,b);
  
  q = p;
  q.y += 2.5;
  q.z = M(q.z,6);
  //q.z = (q.x/8-floor(q.z/8))*8-4;
  d = min(d,max(max(length(q.yz)-2,abs(abs(q.x)-4)-.5),-7.5-p.z));
  
  
  
  q = p;
  //q.y -= sin(t);
  q.z -= t*12;
  q.z = (q.z/5-floor(q.z/5)-.5)*5;
  q.y += 10;
  //R(q.xz,t);
  //R(q.xy,t/3);
  d = min(cu(q/5)*5-.5,d);
  
  d = min(d,p.y+13+.5*sin(p.x)*cos(p.z+sin(p.x+t*3)));
  
  return d*.5;
}


float4 main( float4 position : SV_POSITION, float2 TexCoord : TEXCOORD ) : SV_TARGET
{
  float gt = fGlobalTime*5;
	float2 uv = TexCoord;
	uv -= 0.5;
	uv /= float2(v2Resolution.y / v2Resolution.x, 1);

  float3 ro = float3(0,0,-50);
  R(ro.xz,sin(gt/7));
  R(ro.zy,cos(gt/3)*.05+.1);


  float3 rf = normalize(-ro);//float3(0,0,1);
  float3 ru = float3(0,1,0);
  ru = normalize(ru-rf*dot(ru,rf));
  float3 rs = cross(rf,ru);
  
  //float3 rd = normalize(float3(uv,1));
  float3 rd = normalize(uv.x*rs+uv.y*ru+rf);
  float t=0, d;
  float3 p;
  
  for(int i=0;i<200;i++)
  {
      d = sdf(p=ro+rd*t);
      if(d<0.01) break;
      t += d;
  }
  
  if(d<0.01)
  {
    float2 e = float2(0.01,0);
    float3 n = normalize(float3(sdf(p+e.xyy),sdf(p+e.yxy),sdf(p+e.yyx)) - d);
    float3 ld = normalize(float3(2,1,-3));
    float3 f = dot(ld,n)*float3(1,1,.5);
  
    ro = p + n*.02;
    rd = ld;
    float s=0;
    for(int i=0;i<50;i++)
    {
      d = sdf(p=ro+rd*s);
      if(d<0.01) break;
      s += d;
    }
    if(d<.01) f=0;
    
    f += (n.y*.5+.5)*float3(.5,.7,.7)/2;
    f *= .5;
    f /= 1+f;
    f = pow(f,1/2.2);
    
    
    return f.xyzz/pow(1.01,t);
  }
  
  
	return 1/t;
}