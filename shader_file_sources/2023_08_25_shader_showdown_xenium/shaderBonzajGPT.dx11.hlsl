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
  p = p*cos(a) + float2(p.y,-p.x)*sin(a);
}

float grid(float2 uv)
{
  float2 gp = uv*20;
  gp=cos(gp*2*3.141593);
  float g = max(gp.x,gp.y);
  g = saturate(g*10-9);

  float2 gs = uv;
  gs = abs(gs);
  if(max(gs.x,gs.y)>.405) g=0;
  return g;
}


float4 main( float4 position : SV_POSITION, float2 TexCoord : TEXCOORD ) : SV_TARGET
{
	float2 uv = (position.xy-v2Resolution/2)/v2Resolution.y/.8;
  float3 c = .6;

  float2 gp = uv*20;
  gp=cos(gp*2*3.141593);
  float g = max(gp.x,gp.y);
  g = saturate(g*10-9);

  float2 gs = uv;
  gs = abs(gs);
  if(max(gs.x,gs.y)>.405) g=0;
  
  c=lerp(c,float3(1,0,1),g);
  
  float3 rd = normalize(float3(uv,1));
  float3 ro = float3(0,0,-10);
  float t = (3 - ro.y)/rd.x;
  
  float2 fuv = (ro+rd*t).xz;
  //return float4(fuv.xy,0,0);
  g = grid(fuv);
  c=lerp(c,float3(1,0,1),g);
  
  
  
  float2 bp = frac(fGlobalTime/5)*2;
  if(bp.x>1) bp = 2-bp;
  bp.x = bp.x*2-1;
  bp.x *= .3;
  bp.y = .35-abs(sin(fGlobalTime))*.5;
  bp -= uv;
  bp /= 1.5;
  float2 bp2 = bp + .02;
  if(length(bp2)<.1)
     c *= .5;
  if(length(bp)<.1)
  {
    bp /= .1;
    R(bp,.3);
    
    //bp = pow(abs(bp),1.3)*sign(bp);
    bp = normalize(float3(bp,1)).xy;
    
    float ch = sin(bp.x*10+fGlobalTime*10);
    ch *= sin(bp.y*10);
    c = ch>0 ? float3(1,0,0) : 1;
  }
  
  
  
  
	return c.xyzz;
}