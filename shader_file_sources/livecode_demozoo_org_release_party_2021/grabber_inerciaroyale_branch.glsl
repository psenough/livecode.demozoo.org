	#version 410 core

	uniform float fGlobalTime; // in seconds
	uniform vec2 v2Resolution; // viewport resolution (in pixels)
	uniform float fFrameTime; // duration of the last frame, in seconds

	uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
	uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
	uniform sampler1D texFFTIntegrated; // this is continually increasing
	uniform sampler2D texPreviousFrame; // screenshot of the previous frame
	uniform sampler2D texChecsampleser;
	uniform sampler2D texNoise;
	uniform sampler2D texTex1;
	uniform sampler2D texTex2;
	uniform sampler2D texTex3;
	uniform sampler2D texTex4;

	layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

	#define iTime fGlobalTime
	#define iResolution v2Resolution
	#define iTimeDelta fFrameTime
	#define iFrame int(fGlobalTime*60.0f)
	#define iChannel0 texPreviousFrame


	#define EPSILON 0.01
	#define MAX_DISTANCE 140.

	#define RAY_STEPS 122
	#define MAX_SAMPLES 4.

	const float PI = 3.14159269;
	const float TWOPI = PI * 2.0;
	float syncTime;
	struct Ray {
	    vec3 position;
	    vec3 direction;
	    
	    vec4 carriedLight; // how much light the ray allows to pass at this point
	    
	    vec3 light; // how much light has passed through the ray
	};

	struct Material {
	    vec4 carriedLight; // surface color and transparency
	    vec3 emit; // emited light
	    float scatter;
	};

	// iq's integer hash https://www.shadertoy.com/view/XlXcW4
	const uint samples = 1103515245U;
	vec3 hash( uvec3 x ) {
	    x = ((x>>8U)^x.yzx)*samples;
	    x = ((x>>8U)^x.yzx)*samples;
	    x = ((x>>8U)^x.yzx)*samples;
	    return vec3(x)*(1.0/float(0xffffffffU));
	}
	vec2 hash2( float n ) {
	    return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123));
	}
	// iq's rotation iirc
	mat3 rotationMatrix(vec3 axis, float angle) {
	    axis = normalize(axis);
	    float s = sin(angle);
	    float c = cos(angle);
	    float oc = 1.0 - c;
	    
	    return mat3(oc * axis.x * axis.x + c,
	                oc * axis.x * axis.y - axis.z * s,
	                oc * axis.z * axis.x + axis.y * s,
	                oc * axis.x * axis.y + axis.z * s,  
	                oc * axis.y * axis.y + c,
	                oc * axis.y * axis.z - axis.x * s,
	                oc * axis.z * axis.x - axis.y * s,
	                oc * axis.y * axis.z + axis.x * s,
	                oc * axis.z * axis.z + c);
	}
	float sdSphere( vec3 position, float size ) {
	  return length(position) - size;
	}
	float sdBox( in vec3 p, in vec3 b ) {
	    vec3 d = abs(p) - b;
	    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
	}
	vec2 hash( vec2 p )
	{
	    p = vec2( dot(p,vec2(127.1,311.7)),
	              dot(p,vec2(269.5,183.3)) );

	    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
	}
	float fOpUnionRound(float a, float b, float r) {
	    vec2 u = max(vec2(r - a,r - b), vec2(0));
	    return max(r, min (a, b)) - length(u);
	}

	float sdCapsule( vec3 p, vec3 a, vec3 b, float r ) {
	    vec3 pa = p - a, ba = b - a;
	    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	    return length( pa - ba*h ) - r;
	}
	float getRing(float l) {
	    return 1.0-min(pow(l,12.),1.);
	}
  float sdHexPrism( vec3 p, vec2 h) {
    vec3 q = abs(p.zxy);
    return max(q.z-h.y, max((q.x*0.866+q.y*0.5), q.y) - h.x);
  }
  float sdCylinder(vec3 p, vec2 h){
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
  }
	float getDistance( in vec3 position, out Material material) {
	    float finalDistance = 1e10;
    position.y+=6.0;
    position *= rotationMatrix(vec3(0.0,0.0,1.0),sin(iTime+position.z*0.06)/2.);
    vec3 boardPosition = position;
	    float boardDistance = sdBox(boardPosition-vec3(0.0,-5.0,0.0), vec3(27.0,2.0,644.0));
      float bounceTimer = iTime*3.;
      float bouncePosY = abs(sin(bounceTimer));
      float bouncePosY2 = pow(abs(cos(bounceTimer)),3.);
      vec3 chessPiecePosition = position - vec3(0.0,-1.2+bouncePosY*1.4,0.0);
    //chessPiecePosition *= rotationMatrix(vec3(0.0,1.0,0.0),sin(iTime/4.));
    chessPiecePosition *= rotationMatrix(vec3(1.0,0.0,0.0),sin(bounceTimer*PI/2.)/12.);
      chessPiecePosition.y *= 1.0 + bouncePosY2/5.;
    if(position.z<1.0){
      float pieceDistance = sdHexPrism( chessPiecePosition, vec2(1.2+0.6*sin(-chessPiecePosition.y),2.1));
    pieceDistance = min(pieceDistance, sdCylinder(chessPiecePosition,vec2(1.6-chessPiecePosition.y/3.,0.3)));
    pieceDistance = min(pieceDistance, sdCylinder(chessPiecePosition-vec3(0.0,-1.8,0.0),vec2(2.1,0.3)));
      chessPiecePosition.y -= 3.0;
      pieceDistance = min(pieceDistance, sdSphere(chessPiecePosition,1.2));
      pieceDistance = min(pieceDistance, sdHexPrism(chessPiecePosition,vec2(1.1,0.6)));
	    finalDistance = min(finalDistance, pieceDistance);
    }
	    finalDistance = min(finalDistance, boardDistance);
	    
      if(finalDistance==boardDistance) {
      vec3 boardPosition = position*0.25 - vec3(0.5);
        boardPosition.z-=iTime;
	     material.carriedLight = vec4(vec3(0.1+0.9*floor(mod(boardPosition.x+floor(mod(boardPosition.z,2.0)),2.0))),0.8); 
	     material.emit = material.carriedLight.rgb*0.5; // emited light
	     material.scatter = 0.4;
      } else {
	     material.carriedLight = vec4(1.1,1.1,1.1,1.0);
	     material.emit = vec3(0.2,0.1,0.0); // emited light
	     material.scatter = 3.0;
      }
	    
	    return finalDistance;
	}
	vec3 getLightDirection(float time) {
	    return vec3(
	        0.0,
	        0.0,
	        1.0);
	}
	vec3 getLightColor(float time) {
	    return vec3( 24.0);
	}
	vec3 cameraPosition(float time) {
	  return vec3(12.0*sin(iTime),-1.0,-12.0+sin(iTime/3.)*4.0);
	}
	vec3 cameraRotation(vec3 dir, float time, float signer) {
	    vec2 roti = vec2(0.5,sin(iTime)/12.);
	    
	    if(signer > 0.) { 
	        dir *= rotationMatrix(vec3(1.0,0.0,0.0), roti.x );
	        dir *= rotationMatrix(vec3(0.0,1.0,0.0), roti.y );
	    } else {
	        dir *= rotationMatrix(vec3(0.0,1.0,0.0), -roti.y);
	        dir *= rotationMatrix(vec3(1.0,0.0,0.0), -roti.x);
	    }
	    return dir;
	}
	float shade(inout Ray ray, vec3 dir, float d, Material material)
	{
	    ray.carriedLight *= material.carriedLight;
	    ray.light += material.emit * ray.carriedLight.rgb;
	    return material.scatter;
	}
  //hemispherical sampling
	void sampleSkybox(inout vec3 dir, float samples, float count, float diffuse) {
	    vec3  uu  = normalize( cross( dir, vec3(0.01,1.0,1.0) ) );
	    vec2  aa = hash2( count );
	    float ra = sqrt(aa.y);
	    float ry = ra*sin(6.2831*aa.x);
	    float rx = ra*cos(6.2831*aa.x);
	    float rz = sqrt( sqrt(samples)*(1.0-aa.y) );
	    dir = normalize(mix(dir, vec3( rx*uu + ry*normalize( cross( uu, dir ) ) + rz*dir ), diffuse));
	}
	vec3 shadeBackground(vec3 dir) {
	    vec3 lightDirection = getLightDirection(syncTime);
	    lightDirection = normalize( lightDirection);
	    vec3 lightColor = getLightColor(syncTime);
	    
	    float bacsamplesgroundDiff = dot( dir, vec3( 0.0, 1.0, 0.0));
	    float lightPower = dot( dir, lightDirection);
	    vec3 bacsamplesgroundColor =  0.1 * lightColor * vec3(1.0,0.5,0.2) * pow( max( lightPower, 0.0), 6.0); 
	    bacsamplesgroundColor += lightPower * pow( max( lightPower, 0.0), abs( lightDirection.y)) * 0.2;
	    
	    return max(vec3(0.0), bacsamplesgroundColor);
	}

	vec3 normal(Ray ray, float d) {
	    Material material;
	    float dx = getDistance(vec3(EPSILON, 0.0, 0.0) + ray.position, material) - d;
	    float dy = getDistance(vec3(0.0, EPSILON, 0.0) + ray.position, material) - d;
	    float dz = getDistance(vec3(0.0, 0.0, EPSILON) + ray.position, material) - d;
	    return normalize(vec3(dx, dy, dz));
	}
	Ray initialize(vec2 uv, vec2 suffle) {
	    Ray r;
	    r.light = vec3(0.0);
	    r.carriedLight = vec4(1.0);
	    r.position = cameraPosition(syncTime);
	    r.direction = normalize(vec3(uv+suffle, 1.0));
	    r.direction = cameraRotation(r.direction, syncTime, 1.0);
	    return r;
	}
	float firstHit = 0.;
	#define maxPixelSamples 1
	vec4 smpl(vec2 uv, vec2 uvD, out vec3 position, int sampleCount, Ray ray, out float temporalSampling) {
	    int hit = 0;
	    float depth = 0.0;
	    float maxDiffuseSum = 0.0;
	    vec4 color = vec4( 0.0);
	    float minDistance = 10e8;
	    float totalDistance = 0.0;
	    float count = 0.0;
	    float diffuseSum = 0.0;
	    float samples = 1.0;
	    vec3 total = vec3(0.0);
	    vec3 startPosition = ray.position;
	    vec3 startDirection = ray.direction;
	    for( int i = 0; i < RAY_STEPS; i++) {
	        Material material;
	        float dist = getDistance( ray.position, material);
	        minDistance = min( minDistance, dist);
	        ray.position += dist * ray.direction ;
	        totalDistance += dist;
	        if(dist < EPSILON) { 
	          { 
	            
	                if(firstHit == 0.) {
	                    position = ray.position;
	                    temporalSampling = material.carriedLight.a;
	                }
	                ray.position -= dist * ray.direction;
	                vec3 norm = normal( ray, dist);
	                ray.position -= 2.0 * dist * ray.direction;
	                firstHit ++;
	                float diffuse = shade( ray, norm, dist, material);
	                diffuseSum += diffuse;

	                sampleSkybox(
	                    ray.direction, 
	                    samples, 
	                    samples + 12.12312 * dot( norm, ray.direction) + syncTime + float(sampleCount), 
	                    diffuse * 0.5);

	                ray.position += 1.0 * EPSILON * norm;
	                ray.direction = reflect(ray.direction, norm);
	                ray.position += 1.0 * EPSILON * ray.direction;
	                
	                
	                count ++;
	                hit = 1;
	                if(count > MAX_SAMPLES * material.scatter + 1.0 ) {
	                    break;
	                }
	                else if(sampleCount > 1 && material.scatter < 0.5) {
	                    break;
	                }
	            }
	        } else if (totalDistance > MAX_DISTANCE) {
	            vec3 bg = shadeBackground( ray.direction)*12.;
	            if (minDistance > EPSILON*1.5) {
	                ray.light = bg;
	                break;
	            }
	            total += ray.light + ray.carriedLight.rgb * bg;
	            samples++;        
	            maxDiffuseSum = max( diffuseSum, maxDiffuseSum);
	            diffuseSum = 0.0;
	            break;
	        }
	    }
	    total += ray.light;
	    color += vec4( total / samples, 1.0);

	    return color;
	}
	vec4 trace(vec2 uv, vec2 uvD, out vec3 position) {
	    vec4 color = vec4(0.0);
	    float temporalSampling = 0.0;
	    for( int sampleCount = 0; sampleCount < maxPixelSamples; sampleCount++) {
	        uvec3 seed = uvec3(gl_FragCoord.xy, iFrame*maxPixelSamples + sampleCount);
	        vec3 rand = hash(seed);
	        vec2 suffle = rand.xy - 0.5;
	        suffle /= iResolution.xy;
	        Ray ray = initialize(uv, suffle);
	        color += smpl( uv,  uvD, position, sampleCount, ray, temporalSampling);
	    }
	    return vec4( color.rgb / color.a, temporalSampling);
	}
	vec4 reproject( vec3 worldPos) {
	    vec3 prevCameraPosition = cameraPosition( syncTime - iTimeDelta);
	    vec3 curCameraPosition = cameraPosition( syncTime);
	    vec3 dir = normalize(worldPos - prevCameraPosition);
	    dir = cameraRotation(dir, syncTime - iTimeDelta, -1.0);
	    dir /= dir.z;
	    
	    vec2 aspect = vec2(iResolution.x/iResolution.y, 1.0);
	    vec2 uv = dir.xy;
	    uv /= aspect;
	    uv += vec2(1.0);
	    uv /= 2.0;
	    if(uv.x>0.0 && uv.x<1.0 && uv.y>0.0 && uv.y<1.0) {
	        vec4 tex = texture(iChannel0, uv);
	        tex.a = mod(tex.a, 1.0);
	        return tex;
	    }
	    return vec4(0.0);
	}

	void mainImage( out vec4 fragColor, in vec2 fragCoord )
	{
    
	    syncTime = iTime - 1.0;
		vec2 aspect = vec2(iResolution.x/iResolution.y, 1.0);
		vec2 uv = fragCoord.xy / iResolution.xy;
		uv = (2.0 * uv - 1.0) * aspect;
    if(abs(uv.y)<0.777){
		vec2 uvD = ((2.0 * ((fragCoord.xy+vec2(1.0, 1.0)) / iResolution.xy) - 1.0) * aspect) - uv;
		vec3 position = vec3(0.0);
		vec4 light = trace(uv, uvD, position);
		fragColor = vec4( light.rgb, 1.0/127.0 );

		fragColor.rgb = pow( fragColor.rgb, vec3(1.0/2.1) );
		if(length(position)>0.){
			vec4 reprojectionColor = reproject( position) * 0.85 * light.a;
			fragColor += vec4(reprojectionColor.rgb*1.15,1.0/127.0) * (reprojectionColor.a * 127.0);
		}
		fragColor.rgb /= fragColor.a * 127.0;
		fragColor.a = mod(fragColor.a,1.0);
		fragColor.rgb = min(max(fragColor.rgb,vec3(0.0)),vec3(1.0));
    }
	}
	void main(void)
	{
		vec2 fragCoord = gl_FragCoord.xy;
	  	vec4 fragColor;
		mainImage(  fragColor,  fragCoord );
		out_color = fragColor;
	}
