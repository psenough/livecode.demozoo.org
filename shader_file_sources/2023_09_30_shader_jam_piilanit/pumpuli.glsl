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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sdHex( in vec2 p, in float r )
{
	const vec3 k = vec3(-0.866025404,0.5,0.577350269);
	p = abs(p);
	p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
	p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
	return length(p)*sign(p.y);
}

float flog( in float a ) {
  return pow(2.71828,log2(a));
}

vec3 hsl2rgb( in vec3 c )
{
  vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
  return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

vec3 HueShift (in vec3 Color, in float Shift)
{
  vec3 P = vec3(0.55735)*dot(vec3(0.55735),Color);
  vec3 U = Color-P;
  vec3 V = cross(vec3(0.55735),U);    
  Color = U*cos(Shift*6.2832) + V*sin(Shift*6.2832) + P;
  return vec3(Color);
}

vec3 rgb2hsl( in vec3 c ){
  float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );
	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;     
        //s = l < .05 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) ); Original
		s = l < .0 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}
		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec3( h, s, l );
}

float sum( in vec2 a) {
  return a.x+a.y;
}
float sum( in vec3 a) {
  return a.x+a.y+a.z;
}
float sum( in vec4 a) {
  return a.x+a.y+a.z+a.w;
}
float sdEqTri( in vec2 p, in float r )
{
  const float k = sqrt(3.0);
  p.x = abs(p.x) - r;
  p.y = p.y + r/k;
  if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
  p.x -= clamp( p.x, -2.0*r, 0.0 );
  return -length(p)*sign(p.y);
}
 
float ang;
float zoa;
float ang2;

void main(void)
{
	vec2 uv = out_texcoord;
	vec2 uv_ = uv;
	uv_ *= -1;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv2 = out_texcoord;
	uv2 -= 0.5;
	uv2 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
	
  float fGt = mod(fGlobalTime/20,1)*2-1;
  
  uv *=3;
	
	vec2 m;
	m.x = atan(uv.y / uv.x) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  //m.x += fGt*0.1;
	//m.y += fGt*0.25;
  
  float fft = texture(texFFTSmoothed,flog(abs(uv.x)*.2)).r*40;
  
	float smf2 = texture(texFFTSmoothed,flog(abs(m.x)*.03+.1)).r*40;
	float smf = texture(texFFTSmoothed,d/20).r*40;
	float boom = smoothstep(0,1,texture(texFFTSmoothed,0.005).r*40);
	float tsak = smoothstep(0,1,texture(texFFTSmoothed,0.01).r*30);
	
  boom = smoothstep(1.0,20.0,boom*10);
  tsak = smoothstep(1,20,tsak*20);
  
	ang += -3.1415/2+fGt;//+smf;//(smf*1.1);//*4+boom*2-tsak*2;
  ang2+= -3.1415/2;
  
	vec2 rot = uv;
	
	rot.x=sin(ang)*uv.x+cos(ang)*uv.y;
	rot.y=sin(ang)*uv.y-cos(ang)*uv.x;
  
  zoa=0;//fGt*3.1415;
	
  float zoom = 1+tsak*.8-boom*.5;
  vec2 zoof = vec2(0+tsak*.2,0-boom*.4);
  vec2 zoor = zoof;
  zoor.x=sin(zoa)*zoof.x+cos(zoa)*zoof.y;
  zoor.y=sin(zoa)*zoof.y-cos(zoa)*zoof.x;
  
  uv2 *= zoom;
  vec2 rot2 = uv2;
	
	rot2.x=sin(ang2)*uv2.x+cos(ang2)*uv2.y;
	rot2.y=sin(ang2)*uv2.y-cos(ang2)*uv2.x;
  
  uv2 = rot2*1.1;
  
	uv2 *= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv2 += 0.5;
	
  vec4 prev= texture(texPreviousFrame,uv2);
  vec4 pnof= texture(texPreviousFrame,out_texcoord*vec2(1,-1));
	
	vec4 moi = vec4(900);
	vec4 nor = texture(texTex2,rot+vec2(0.5,0.5));
  
	vec2 moiu=-uv;
	
	float fy = texture(texFFT,flog(abs(m.y)*.8)+fGt*10-tsak).r*(1*(1+abs(m.y)*40));
	float fx = texture(texFFT,flog(abs(m.x)*.4)).r*(10*(1+abs(m.x)*40));
	float fys = texture(texFFTSmoothed,flog(abs(m.y)*.8)+fGt).r*(10*abs(m.y*40));
	float fxs = texture(texFFTSmoothed,flog(abs(m.x)*.4)).r*(100*(1+abs(m.x)*4));
	
  vec4 moi2= texture(texTex3,vec2(fGt,-fGt)*rot*4+vec2(0.5,0.5));
  vec4 nor2= texture(texTex4,vec2(fGt,-fGt)*rot*4+vec2(0.5,0.5));
  
  
  //vec4 moi2= texture(texTex3,(moiu)*(smf2*2+.5));

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	vec4 c = moi;
  c-=fy*40;
  c+=vec4(fx*abs(rot.y));
  c+=step(sdEqTri(rot,.2+tsak*.1),0+fx*0.01)*2;
  c/=step(sdEqTri(rot,.18+tsak*.1),0+fx*0.01)*3;
  
  c*=moi+vec4(fx,fy*5+fxs/2,fxs,0);
  c+=-400*step(sdHex(rot,0.4),m.y);
	c = clamp(c,-0.0,1.0);
	vec4 sub = vec4(1-m.y*0.5);
	vec4 add = vec4(fxs*.2,fxs*.01,fxs*.1,1);
  vec4 mul = vec4(8,0.8,.4,1);
	c *= mul;//*(nor.r);
  c += add+vec4(.1,.02,.05,1);
	c = clamp(c,-1.0,1.0);
  c -=sub;
  c *=4;
  c = vec4(HueShift(c.rgb,fGt*0.05+tsak*.1),1);
  
  vec4 hsl = vec4(rgb2hsl(c.rgb),1);
  hsl = vec4(hsl.x*0.8+boom*.01,hsl.y*.5,hsl.z,1);
  vec4 rgb = vec4(hsl2rgb(hsl.rgb),1);
  rgb = clamp(rgb,0,1);
  vec3 phsl = rgb2hsl(prev.rgb*.95);
  rgb += vec4(hsl2rgb(vec3(phsl.x+uv.x/20,phsl.y*.9,phsl.z*.99)),1);
  
  rgb*=(1-prev*.2)*clamp(boom,1.0,1.05);
  
  vec4 outside = vec4(abs(m.y)*fy*4);
  
  outside = clamp(outside,0.0,1.0);
  
  //outside*=step((100+sum(prev.rgb))*-sdEqTri(uv,1),0);
  //outside+=step(sum(rgb.rgb)*-sdEqTri(uv,1),0)*-4*fxs;
  //rgb    *=step(  sdHex(uv,.3*(1+fx*.4)),0);
  rgb    *=sdEqTri(uv,.5)*-4;
  
  rgb *=((1+clamp(fxs,0.0,1.0))*fx*.8)*(1-d);
  
  float kes = float(abs(uv.x)>.4)*.8+.2;
  
  vec4 comp = vec4(0);
  
  vec4 vari = vec4(hsl2rgb(vec3(.9-tsak*.4,1,.7)),1);

  comp = -fys*outside+rgb+(sum(rgb)/10*fx)*(rgb+prev*20);
  comp = clamp(comp,0.0,1.0);
  comp /= vec4(step(sdEqTri(rot,0.8+tsak*.2),0));
  comp += vec4(step(sdHex(rot,0.4+fx*0.01),0));
  comp -= vec4(step(sdHex(rot,0.38-fx*0.04),0));
  comp += (step(sdEqTri(uv,.8+fx*.1),0))*vari;
  comp -= (step(sdEqTri(uv,.74-fx*.01),0));
  comp *= 1+prev*.8;
  comp = clamp(comp,0.0,1.0);
  comp += vec4(hsl2rgb(vec3(phsl.x,phsl.y*.3,phsl.z*.1))*.8,1)*vec4(1,.8,1,1);
  comp *= 0.5+fys*.5;
  comp += pnof*.5;
  
  out_color = comp;
  //out_color +=moi2*abs(dot(nor2.xyz,vec3(cos(abs(fGt+2)*10)*8,sin(abs(fGt+2)*10)*8,-.5)));
  //out_color = vec4(step(sdHex(rot,1+fys*1),0));
  //out_color *= vec4(kes);//vec4(smf2);
  //out_color = vec4(float((uv.x+1)/2>fGt));
}