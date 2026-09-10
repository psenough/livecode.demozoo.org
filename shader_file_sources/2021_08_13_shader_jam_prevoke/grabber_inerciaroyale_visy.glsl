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

float NEAR_CLIPPING_PLANE=0.00001;
float FAR_CLIPPING_PLANE=1000.;
const int NUMBER_OF_MARCH_STEPS=350;
float EPSILON=0.15;
float DISTANCE_BIAS=0.03;
float t = 0.;
vec3 pc;

float sdHexPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c) - 0.5 * c;
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

vec3 hit;

float mu;

vec2 scene(vec3 pos) {

    float offs = 1.0-mod(pos.z,0.2);
	float offs2 = 1.0-mod(pos.z,0.2);

    if (pos.z < 1.5) {
        offs = 1.0;
        offs2 = 1.0;
    }
    
    vec3 p = pos+vec3(0.0,0.0,-4.0);
    pR(p.xy,t*.1);
    p = opRep(p,vec3(2.1,1.25,0.));
	float d1 = sdHexPrism(p,vec2(0.45,abs(sin(mu*0.5+p.z))+offs));

    vec3 p2 = pos+vec3(0.0,0.0,-4.0);
    pR(p2.xy,t*.1);
    p2+=vec3(1.05,0.65,0.0);
    p2 = opRep(p2,vec3(2.1,1.25,0.));
	float d2 = sdHexPrism(p2+vec3(0.,0.0,0.),vec2(0.45,abs(cos(mu*0.6+p2.z))+offs2));

    float mate = 0.0;
    
    if (d1 < d2) mate = 1.0;
    
    return vec2(min(d1,d2),mate);
}

vec3 raymarch(vec3 position, vec3 direction)
{
    float total_distance = NEAR_CLIPPING_PLANE;
    float acc = 0.;
    float mate = 0.0;
    for(int i = 0 ; i < NUMBER_OF_MARCH_STEPS ; ++i)
    {
        vec3 pos = position + direction * total_distance;
        vec2 result = scene(pos);
        acc+=cos(result.x*1.)*.05;
        mate = result.y;
        if(result.x < EPSILON)
        {
            return vec3(total_distance, acc, mate);
        }
        
        total_distance += result.x * DISTANCE_BIAS;
        
        
        if(total_distance > FAR_CLIPPING_PLANE)
            break;
    }
    return vec3(FAR_CLIPPING_PLANE, acc, mate);
}

vec3 nr(vec3 n) {
	return normalize(n);
}

vec3 normal( in vec3 pos )
{
    vec3 eps = vec3(.3,0.,0.)*EPSILON;
	vec3 nor = vec3(
	    scene(pos+eps.xyy).x - scene(pos-eps.xyy).x,
	    scene(pos+eps.yxy).x - scene(pos-eps.yxy).x,
	    scene(pos+eps.yyx).x - scene(pos-eps.yyx).x );
	return nr(nor);
}

#define OBJECT_REFLECTIVITY 0.5

float fresnelApprox(float n1, float n2, vec3 normal, vec3 incident)
{
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal, incident);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (sinT2 > 1.0)
                return 1.0;
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = r0+(1.0-r0)*x*x*x*x*x;
 
        // adjust reflect multiplier for object reflectivity
        ret = (OBJECT_REFLECTIVITY + (1.0-OBJECT_REFLECTIVITY) * ret);
        return ret;
}

float orenNayarDiffuse(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float roughness,
  float albedo) {
  
  float LdotV = dot(lightDirection, viewDirection);
  float NdotL = dot(lightDirection, surfaceNormal);
  float NdotV = dot(surfaceNormal, viewDirection);

  float s = LdotV - NdotL * NdotV;
  float t = mix(1., max(NdotL, NdotV), step(0., s));

  float sigma2 = roughness * roughness;
  float A = 1. + sigma2 * (albedo / (sigma2 + .13) + .5 / (sigma2 + .33));
  float B = .45 * sigma2 / (sigma2 + .09);

  return albedo * max(0., NdotL) * (A + B * s / t) / 3.14159;
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    t=fGlobalTime*0.1;
  
  t = mod(t,16.0);

  //if (uv.x < 0.5) uv.x = 1.0-uv.x;

  
  float tt = 0.1*cos(t*uv.x*1.);

  //if (uv.y > 0.5 && pc.r < tt) uv.y = 1.0-uv.y;
  //else if (uv.y < 0.5 && pc.r >= tt) uv.y = 1.0-uv.y;


	uv -= 0.5+0.1*abs(cos(t*0.8));
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  

  
  mu = 20+cos(t*10.)*2.;
  
  uv*=0.5;

  //uv*=distance(uv,vec2(abs(cos(t*0.2+uv.x*2.1+uv.y*2.1)*0.25)))*15.0;
  
  vec3 direction = nr(vec3(uv, 0.));

  float FOV = 6.;
      
  float mo = t*0.8;
  
  vec3 camera_origin = vec3(mo,0.0,0.0);
  vec3 lookAt = vec3(mo,0.0,1.0+cos(t*0.1));
  
  vec3 forward = nr(lookAt-camera_origin);
  vec3 right = nr(vec3(forward.z, 0., -forward.x ));
  vec3 up = nr(cross(forward,right));
  
  vec3 ro = camera_origin;
  vec3 rd = nr(forward + FOV*uv.x*right + FOV*uv.y*up);

  vec3 result = raymarch(ro, rd);
  float sz = mu*1.;
  float tta = tan(cos(t*10.+uv.y*sz+uv.x*sz))+1.;
  float fog = pow(1.*tta / (1.*tta + result.x), .2);
  
  vec3 materialColor = vec3(1.1-result.x*.01*.5,1.2-cos(result.x*.1)*.5,2.9*.5)*0.05;

  if (result.z == 1.0) {
    materialColor = 0.5-vec3(abs(cos(mo+t*0.1+uv.y*10.+uv.x*10.0))-result.x*.1*1.,0.1-cos(result.x*.3)*.5,0.*.1);
  }
  
  vec3 intersection = ro + rd*result.x;
  
  vec3 nrml = normal(intersection);
  vec3 light_dir = nr(vec3(sin(result.x*.1),1.5*sin(t*0.4),-5.));
  vec3 ref = reflect( rd, nrml );

  float dom = smoothstep( 0.5, 1.9, ref.y);
  float spe = pow(clamp( dot( ref, light_dir ), 0., 1.0 ),32.);

  float diffuse = orenNayarDiffuse(light_dir,rd,nrml,0.3,2.5-result.x*0.5)-result.y*.1;
  
  float fresnel = fresnelApprox(result.x*0.05, 0.1, nrml, vec3(0.1,0.2,0.3))*1.5;
  
  vec3 light_color = vec3(1.0);
  vec3 ambient_color = light_color;
  vec3 diffuseLit = materialColor * (diffuse * light_color + ambient_color);
  vec3 c = fresnel*diffuseLit*fog+dom*.2+spe*.6;
  if (result.x >= FAR_CLIPPING_PLANE ) c=vec3(0.0);
  out_color = clamp(vec4(c,1.0)*vec4(0.9,0.8,1.1,1.0),vec4(0.0),vec4(1.0));
}