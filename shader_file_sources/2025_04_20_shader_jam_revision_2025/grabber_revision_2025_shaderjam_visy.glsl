#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texRevisionBW;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, s, -s, c);
	return m * v;
}

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate3(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
  if (uv.x < 0.0) { uv.x = 0.0-uv.x; }
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
  vec4 c = vec4(0.0);
  float t = fGlobalTime;
  
  for (float i=0.0; i < 16.0; i+=1.0)
  {
    c = c + texture(texAcorn2,length(uv*(4.0-i*0.01))+rotate(uv*length(uv+cos(t+i)*2.)*i*cos(t*0.1)*0.5,i*cos(i*0.1+t*0.1))+i*0.1+uv.x*0.1+t+uv.y)*cos(i)*0.5;
  }

  for (float i=0.0; i < 4.0; i+=1.0)
  {
    c = c + texture(texRevisionBW,rotate3(vec3(uv.x*10.5,uv.y*10.5,cos(t+i*0.1)*0.1)*i*1.1*cos(i+t*0.1)*0.1,vec3(sin(t*0.1+i),sin(t*0.1),i*cos(i*0.1+t*0.1)*0.1),t).xz)*abs(cos(i*0.05+t*2.))*0.05f;
  }

  

    for (float i=0.0; i < 4.0; i+=1.0)
  {
  c = c / vec4(0.5,0.6,0.7,0.0)*texture(texLynn,rotate3(vec3(t+uv.x+sin(t*0.01+i*10.1)+t*0.1,t*0.1+uv.y+sin(i*0.1+t*1.)*10.,cos(t+uv.y*1.5)),vec3(cos(t*0.001),sin(t*0.001)*0.1,atan(t*0.01+i*0.1)),cos(i*0.01+t*0.001)*0.1).xz)*cos(sin(t)+i)*2.-cos(i*0.4+t*0.1);
  }
 
  
	c = clamp( c, 0.0, 1.0 );

    for (float i=0.0; i < 4.0; i+=1.0)
  {
    c = c - texture(texAcorn2,length(uv*(4.0-i*0.01))+rotate(uv*length(uv*cos(t+i)+cos(t+i)*2.)*i*cos(t*0.1)*0.5,i*cos(i*0.1+t*0.1))+i*0.1+uv.x*0.1+t+uv.y)*0.05;
  }


	out_color = c;
}