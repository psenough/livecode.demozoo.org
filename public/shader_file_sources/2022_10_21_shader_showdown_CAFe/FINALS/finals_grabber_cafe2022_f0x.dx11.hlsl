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
float4 main( float4 position : SV_POSITION, float2 TexCoord : TEXCOORD ) : SV_TARGET
{
	float2 uv = TexCoord;
	uv -= 0.5;
	uv /= float2(v2Resolution.y / v2Resolution.x, 1);
	float2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texFFT.Sample( smp, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	float4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = saturate( t );
  t=0;
  float3 ff;
  float2 r=float2(1.8,1);
  
  ff=texNoise.Sample(smp,uv*r+float2(0,-fGlobalTime*.7))*(1-uv.y*5)+saturate(uv.y-.5);
  ff*=texNoise.Sample(smp,uv*.4*r+float2(0,-fGlobalTime*.2))*(1-uv.y*5)+saturate(uv.y-.5);
  ff*=texNoise.Sample(smp,uv*4.4*r+float2(0,-fGlobalTime*.52))*(1-uv.y*5)*.4+saturate(uv.y-.5)*.01+.9; 
 
  ff*=float3(5,2,1);
  
  ff*=saturate(abs(uv.y-.5));
  
  ff=pow(ff,2)+.2*pow(ff,ff);
  
  
  
  float3 bb=float3(0,0,0);
  
float p= texFFTSmoothed.Sample(smp,.5);
  
  float2 uv3=uv;
  uv3*=texNoise.Sample(smp,uv);
  bb=saturate(1-5*length(uv3-4*float2(0,p)*4)+texFFTSmoothed.Sample(smp,abs(uv.x)));
  bb*=float3(0,.3,.7);
  //bb/=saturate(bb)+1;
  
//  bb=max(bb,texNoise.Sample(smp,uv*5)>.44); 
  
  
  
  
	return float4(ff+bb,1);
}