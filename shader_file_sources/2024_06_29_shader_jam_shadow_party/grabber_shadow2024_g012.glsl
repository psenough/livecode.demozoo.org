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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


struct ray {
    vec3 pos;
    vec3 dir;
};
//Create the camera ray
ray create_camera_ray(vec2 uv, vec3 camPos, vec3 lookAt, float zoom){
    vec3 f = normalize(lookAt - camPos);
    vec3 r = cross(vec3(0.0,1.0,0.0),f);
    vec3 u = cross(f,r);
    vec3 c=camPos+f*zoom;
    vec3 i=c+uv.x*r+uv.y*u;
    vec3 dir=i-camPos;
    return ray(camPos,normalize(dir));
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

//Distance to scene at point
float distToScene(vec3 p){
//    return min(p.z,min(p.x,min(p.y,length(p-vec3(-0.3*sin(fGlobalTime),0.5,0.15))-0.3)));
    float s1 = sdRoundBox(p - vec3(-0.3, 0.2, 0.15), vec3(0.2, 0.2, 0.1), 0.02);
    float s2 = sdSphere(p - vec3(0.2, 0, 0.24), 0.3 - 0.1 * sin(fGlobalTime));
    return min(s1, s2);
}

//Estimate normal based on distToScene function
const float EPS=0.001;
vec3 estimateNormal(vec3 p){
    float xPl=distToScene(vec3(p.x+EPS,p.y,p.z));
    float xMi=distToScene(vec3(p.x-EPS,p.y,p.z));
    float yPl=distToScene(vec3(p.x,p.y+EPS,p.z));
    float yMi=distToScene(vec3(p.x,p.y-EPS,p.z));
    float zPl=distToScene(vec3(p.x,p.y,p.z+EPS));
    float zMi=distToScene(vec3(p.x,p.y,p.z-EPS));
    float xDiff=xPl-xMi;
    float yDiff=yPl-yMi;
    float zDiff=zPl-zMi;
    return normalize(vec3(xDiff,yDiff,zDiff));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec3 camPos=vec3(2.0,1.0,0.5);
    vec3 lookAt=vec3(0.0);
    float zoom=1.0;
    
    ray camRay=create_camera_ray(uv,camPos,lookAt,zoom);
    
    float totalDist=0.0;
    float finalDist=distToScene(camRay.pos);
    int iters=0;
    int maxIters=20;
    for (iters=0;iters<maxIters&&finalDist>0.01;iters++){
        camRay.pos+=finalDist*camRay.dir;
        totalDist+=finalDist;
        finalDist=distToScene(camRay.pos);
    }
    vec3 normal=estimateNormal(camRay.pos);
    
    vec3 lightPos=vec3(2.0,1.0,1.0);
    
    float dotSN=dot(normal,normalize(lightPos-camRay.pos));
    
    out_color = vec4(0.5+0.5*normal,1.0)*dotSN;
    return;

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	float turn = fGlobalTime * -0.5;
    m.x += turn;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}
