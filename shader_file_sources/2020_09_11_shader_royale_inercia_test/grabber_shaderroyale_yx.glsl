#version 410 core

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

#define iTime (fGlobalTime*.3)

#define pi uintBitsToFloat(0x40490FDB)

mat2 rotate(float a)
{
	float c=cos(a),s=sin(a);
	return mat2(c,s,-s,c);
}

float tick(float t)
{
	t = fract(t);
	t = smoothstep(0,1,t);
	t = smoothstep(0,1,t);
	return t;
}

float square(vec2 p, float r)
{
	p=abs(p)-r;
	return max(p.x,p.y);
}

float squircle(vec2 p, float r)
{
	float c = length(p)-r;
	float b = square(p,r);
	return mix(c,b,tick(sin(iTime)*.5+.5));
}

float sdf(vec2 p, float i)
{
	float l = length(p);
	
	p=-abs(p);
	p -= tick(iTime+l*.1);
	
	//p = sin(p*pi+iTime*10.)*.5;
	
	p = fract(p+.5)-.5;
	
	float T = iTime*6.+i*pi/3.+l*2.;
	
	float r = tick(sin(T)*.5+.5)*.2+.1;
	float d = 1e9;
	d = min(d,length(p.x)+sin(T)*.05);
	d = min(d,length(p.y)+sin(T)*.05);
	p *= rotate(T*.5);
	d = min(d,abs(squircle(p,r))-.02);
	return d;
	//return abs(length(p)-1.)-.1;
}

void main(void)
{
	const float speed = 2.;
	
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	uv *= 2;

	uv *= rotate(atan(uv.x,uv.y)*0.25);
	uv += uv;
	uv = abs(uv);
	uv = vec2(max(uv.x,uv.y),min(uv.x,uv.y));
	//uv *= rotate(atan(uv.x,uv.y)*2);
	
	vec3 cam = vec3(0,0,-10);
	vec3 dir = normalize(vec3(uv,5));
	
	cam.yz *= rotate(sin(iTime*.3));
	dir.yz *= rotate(sin(iTime*.3));
	cam.xz *= rotate(iTime*.1);
	dir.xz *= rotate(iTime*.1);
	
	float t1 = (cam.y/-dir.y);
	float t2 = (cam.z/-dir.z);
	float t3 = (cam.x/-dir.x);
	t1=t1>0?t1:10000;
	t2=t2>0?t2:10000;
	t3=t3>0?t3:10000;
	
	vec2 uv1 = cam.xz+dir.xz*t1;
	vec2 uv2 = cam.xy+dir.xy*t2;
	vec2 uv3 = cam.yz+dir.yz*t3;
	
	//uv1 = fract(uv1+.5)-.5;
	//uv2 = fract(uv2+.5)-.5;
	//uv3 = fract(uv3+.5)-.5;
	
	float d1 = sdf(uv1,0);
	float d2 = sdf(uv2,1);
	float d3 = sdf(uv3,2);
	
	float f1 = pow(.9,t1);
	float f2 = pow(.9,t2);
	float f3 = pow(.9,t3);
	
	vec3 color = vec3(0);
	color += vec3(smoothstep(0,abs(length(fwidth(uv1))*5),-d1)) * f1 * vec3(1,0,0);
	color += vec3(smoothstep(0,abs(length(fwidth(uv2))*5),-d2)) * f2 * vec3(0,1,0);
	color += vec3(smoothstep(0,abs(length(fwidth(uv3))*5),-d3)) * f3 * vec3(0,0,1);
	
	color += vec3(3,1,1)*.005/abs(d1) * f1;
	color += vec3(1,3,1)*.005/abs(d2) * f2;
	color += vec3(1,1,3)*.005/abs(d3) * f3;

	color.r += (sin(max(uv1.x,uv1.y))*.2+.2) * f1;
	color.g += (sin(max(uv2.x,uv2.y))*.2+.2) * f2;
	color.b += (sin(max(uv3.x,uv3.y))*.2+.2) * f3;

	color = pow(color,vec3(2.));
	
	//color.xy = (color.xy-.5)*rotate(iTime)+.5;
	
	color /= 1.-dot(uv,uv)*.06;
	//color = clamp(color,0,1);
	//color *= 1.-dot(uv,uv)*.05;
	
	out_color = vec4(1.-color, 1);
}