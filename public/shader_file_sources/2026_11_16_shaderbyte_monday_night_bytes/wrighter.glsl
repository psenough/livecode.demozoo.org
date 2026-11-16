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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T ((fGlobalTime/60*174)/2)
#define pi acos(-1)

#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))


mat3 lookat(vec3 or, vec3 tar){
	vec3 dir = normalize(tar - or);
	vec3 right = normalize(cross(vec3(0,1,0),dir));
	vec3 up = normalize(cross(dir,right));
	return mat3(right,up,dir);
}

vec3 map(vec3 q){

	vec4 p = vec4(q,1);
	 
	vec3 d = vec3(0);
	
	for(float i = 0.; i < 8.; i++){
		//p = sin(p*1.4);
		
		//p = sin(p*1.);
		
		d += sin(cross(p.xyz,p.zxy)*5.2 + i*2.)*1.6/(1. + i*.6);
	
		p.xz *= rot(1.5);
		p.yz *= rot(1.5);
		
		
		if(mod(i,3) < 2)
		p = p/clamp(dot(p.xyz,p.xyz),0.2,4.8);
		//p = p/dot(p.xyz,p.xyz);
		
		//p = abs(p)- 0.9;
		p *= 0.6 + sin(T)*0.1;
	}
	
	return (d);
}
 
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


	
	vec3 col = vec3(0);
		
	vec3 ro = vec3(4,2,1);
	
	vec3 tar = vec3(0);
	
	ro = sin(ro + vec3(3,2,1) + T*0.1*sin(floor(T/2)) + floor(T/4));

	ro += sin(vec3(0.2,0.6,3)*T*.3)*0.2;
	
vec3 rd = normalize(vec3(uv,1));

	
	rd = lookat(tar,ro)*rd;
	
	vec3 p = ro;
	
	vec3 acc = vec3(0);
	
	for(float i = 0.; i < 300.; i++){
		vec3 d = map(p);
		
		p += 0.003*rd;
		
		acc += exp(-abs(d)*(40. + mod(T,4.)*1.));
	}
	
	col += acc*1;
	
	//col= col/(1.+col);
	
	
	
	vec2 nuv = gl_FragCoord.xy/v2Resolution.xy;
	
	vec2 del = vec2(0.04,0);
	vec2 dv = vec2(
		length(texture(texPreviousFrame, nuv + del.xy).rgb) - length(texture(texPreviousFrame, nuv - del.xy).rgb),
		length(texture(texPreviousFrame, nuv + del.yx).rgb) - length(texture(texPreviousFrame, nuv - del.yx).rgb)
	);
	
	dv = normalize(dv);
	vec3 prev = texture(texPreviousFrame, nuv + dv*0.002).rgb;
		
	
	
	float bt = fract(T/2);
	if(bt < 0.999999 || true){
		vec3 diff = col - prev;
		
		diff *= 1.5 ;
		
		vec3 curr = col;
		
		col = curr - diff;
		
		diff = sin(diff + vec3(3,2,0.2)*.9 + T*(1. + float(mod(T,3) < 1.)))*0.2*length(diff*1.);
		
		col += diff * (1. + 0);
		
		//col -= prev*10.9;
		float chill = sin(T/2*4);
		
		
		
		//if(chill){
			col = mix(col,prev,(1.-col)*chill +  - 20.*texture(texFFTSmoothed,0.2).x*1.);
		//}
		
		
		col = mix(col,prev,pow(1.-col,vec3(1)*abs(sin(T))));
	}
	
	col *= 0.8;
	
	col = col/(col+1);
	col *= col;
	col = pow(col,vec3(0.2,.3,.1));
	
	col = 0.5*sin(col) + 0.5;
	
	col = smoothstep(0.8,1.,col);
	
	col.rb += (col.r + col.b)*0.5;
	col *= vec3(1,0.4,1);
	col = pow(col,vec3(10.2,1.3,1.1));
	
	col += length(col)*0.2;
	col = col/(1.+col);
	//col = col/(1.+col);
	//col = smoothstep(0.,1.,col);
	
	//col *= 1.6;
	out_color = vec4(col,1);
}






