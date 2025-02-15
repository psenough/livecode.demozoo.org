#version 410 core

#define NEAR_CLIPPING_PLANE 0.001
#define FAR_CLIPPING_PLANE 1000.0
#define NUMBER_OF_MARCH_STEPS 600
#define EPSILON 0.15
#define DISTANCE_BIAS 0.2

float time = 0.0;

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
uniform float fMid1;
uniform float fMid2;
uniform float fMid3;
uniform float fMid4;
uniform float fMid5;
uniform float fMid6;
uniform float fMid7;
uniform float fMid8;

vec4 pframe;

float sdSphere(vec3 p, float s)
{
	return length(p) - (s);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdPlane( vec3 p, vec4 n )
{
  return dot(p,n.xyz) + n.w;
}


float fmod(float a, float b)
{
    if(a<0.0)
    {
        return b - mod(abs(a), b);
    }
    return mod(a, b);
}

const float kHashScale1 = 443.8975;

float hash11(float p) {
  vec3 p3 = fract(vec3(p) * kHashScale1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}
 
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float fOpUnionRound(float a, float b, float r) {
	vec2 u = max(vec2(r - a,r - b), vec2(0));
	return max(r, min (a, b)) - length(u);
}


vec2 scene1(vec3 pos)
{
    vec3 translate = vec3(atan(pos.x*pos.y)*1.*cos(pframe.b*4.)*1.1, cos(pos.x*1.0+time*1.)*0.1, cos(cos(pos.z*0.1+pos.z*1.)+pos.x)*pos.y*cos(sin(time*0.1)*pos.z*0.05)*2.);

    vec3 tra2 = vec3(fract(pos.y)+cos(pos.y*1.+sin(time*1.))*0.1,sin(fract(pos.z*0.5)*1.)*0.5,cos(pos.y+fract(abs(cos(pos.z*0.5))*time*1.+pos.x*3.1+pos.y)*0.1)*1);
  
    vec3 opos = pos - translate + tra2;

    float finalDist = sdSphere(cos(opos*0.3*fract(pos.y*0.01)),1.2+sin(cos(time*1.+pos.z)+pos.z*0.1+cos(opos.z*0.5)*opos.z*0.001)*0.1)*5.91;
    	
    return vec2(finalDist, 0.0);
}


vec2 scene(vec3 pos) {
    float mat = 0.0;
	vec2 res1 = scene1(pos);
    mat = res1.y;
	return vec2(res1.x,mat);
}


float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

float err(float dist){ return min(EPSILON, pow(dist*0.02, 2.0)); }

vec3 discontinuity_reduction(vec3 origin, vec3 direction, vec3 position){ for(int i = 0; i < 3; i++)position = position + direction * (scene(position).x - err(distance(origin, position))); return position; }


vec3 raymarch(vec3 position, vec3 direction)
{
    float total_distance = NEAR_CLIPPING_PLANE;
    float acc = 0.0;
    for(int i = 0 ; i < NUMBER_OF_MARCH_STEPS ; ++i)
    {
        vec3 pos = position + direction * total_distance;
        //pos = discontinuity_reduction(position,direction,pos);
        vec2 result = scene(pos);

        if(result.x < EPSILON)
        {
            return vec3(total_distance, acc,result.y);
        }
        
        total_distance += result.x * DISTANCE_BIAS;
        
        
        if(total_distance > FAR_CLIPPING_PLANE)
            break;
    }
    return vec3(FAR_CLIPPING_PLANE, acc, 0.0);
}

vec3 normal( in vec3 pos )
{
	vec3 eps = vec3( 0.1, 0.0, 0.0 );
	vec3 nor = vec3(
	    scene(pos+eps.xyy).x - scene(pos-eps.xyy).x,
	    scene(pos+eps.yxy).x - scene(pos-eps.yxy).x,
	    scene(pos+eps.yyx).x - scene(pos-eps.yyx).x );
	return normalize(nor);
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
  float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

  float sigma2 = roughness * roughness;
  float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
  float B = 0.45 * sigma2 / (sigma2 + 0.09);

  return albedo * max(0.0, NdotL) * (A + B * s / t) / 3.14159;
}


layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  vec2 uv = (-v2Resolution.xy + 2.0*(gl_FragCoord.xy))/v2Resolution.y;

    pframe=texture(texPreviousFrame,uv/4.0);
  
    time = fmod(fGlobalTime,30.0);

    vec3 direction = normalize(vec3(uv, 0.0));
    float cx = 0.0;
    float cy = 0.0;
    float cz = time*6.9;
    
    vec3 camera_origin = vec3(cx, cy, cz);
    vec3 lookAt = vec3(cx,cy,cz+0.1);
    
    vec3 forward = normalize(lookAt-camera_origin);
    vec3 right = normalize(vec3(forward.z, 0.0, -forward.x ));
    vec3 up = normalize(cross(forward,right));

    float FOV = 1.;

    vec3 ro = camera_origin;
    vec3 rd = normalize(forward + FOV*uv.x*right + FOV*uv.y*up);

    vec3 result = raymarch(ro, rd);
            
    float fog = pow(1.0 / (1.0 + result.x), 0.2);
    
    vec3 materialColor = vec3(1.0-result.x*0.01, result.x*0.2*cos(uv.x*uv.y*3.), result.x*0.01);
		
    if (uv.y > 0.0) {
      materialColor.r -= 0.5;
      materialColor.g -= 0.5;
      materialColor.b -= 0.4;
    }

    vec3 intersection = ro + rd*result.x;
    
    vec3 nrml = normal(intersection);
    float occ = calcAO( intersection, nrml );
    vec3 light_dir = normalize(vec3(10.0,0.,-2));
    vec3 ref = reflect( rd, nrml );
    float dom = smoothstep( -0.1, 0.8, ref.y);
    float spe = pow(clamp( dot( ref, light_dir ), 0.0, 0.3 ),32.0);

    float diffuse = orenNayarDiffuse(light_dir,rd,nrml,0.4,0.9);
    
    vec3 light_color = vec3(pframe.r*2., pframe.b*2., 1.0);
    vec3 ambient_color = vec3(1.0,1.0, 1.0);
    vec3 diffuseLit = materialColor * (diffuse * light_color + ambient_color);
    vec3 outColor = diffuseLit*occ*fog+dom*0.3+spe*0.3;
    if (result.x >= FAR_CLIPPING_PLANE) outColor = vec3(1.0);
    
    out_color = vec4(1.3-outColor.r*0.8,0.8-outColor.b*0.8,1.7-outColor.g*0.4, 1.0);

}