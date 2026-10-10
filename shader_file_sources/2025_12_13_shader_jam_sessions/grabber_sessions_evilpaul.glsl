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
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 getTexture(sampler2D sampler, vec2 uv) {
  vec2 size = textureSize(sampler, 0);
  float ratio = size.x / size.y;
  return texture(sampler, uv * vec2(1, -1 * ratio) - .5).rgb;
}


bool intersectPlane(vec3 normal, vec3 pos, vec3 rayOrigin, vec3 rayDir, inout float t, inout vec2 uv) { 
    float denom = dot(normal, rayDir);
    if (abs(denom) > 0.0001f) // abs gives front+back faces
    {
        t = dot(pos - rayOrigin, normal) / denom;
        if (t >= 0.) {
            vec3 uaxis = vec3(normal.z, normal.x, -normal.y);
            vec3 vaxis = vec3(normal.y, normal.z, -normal.x);
            vec3 hpos = rayOrigin + rayDir * t;
            uv = vec2(
                dot(hpos + pos, uaxis),
                dot(hpos + pos, vaxis)
            );
            return true;
        }
    }
    return false;
}


vec3 face1(vec2 uv, float time) {
  vec3 c = getTexture(texSessions, uv * 0.005 * vec2(1,1));
  if (uv.y < 0.33) {
    c = mix(vec3(0,0,0),vec3(0.86,.35,.27),1-c.r);
  } else {
    c = mix(vec3(.91,.85,.28),vec3(0.31,.68,.45),1-c.r);
  }    
  return c;
}

vec3 face2(vec2 uv, float time) {
  float a = atan(uv.x, uv.y);
  float d = length(uv);
//  vec3 c = getTexture(texSessions, uv * 0.005 * vec2(1,1));
 
  uv.x = a * .5 + time*.5;
  uv.y = d / radians(360)/20 + a;
  vec3 c = getTexture(texSessions, uv);
  c *= d/100;
  return c;
}

vec3 face3(vec2 uv, float time) {
  
  vec3 c = vec3(
  mod(getTexture(texNoise, uv * 0.001)  + time / 2.21, 1).r,
  mod(getTexture(texNoise, uv * 0.002)  + time / 2.33, 1).r,
  mod(getTexture(texNoise, uv * 0.003)  + time / 2.65, 1).r
);
  c *= getTexture(texShort, uv * 0.01);
  return c;
}

vec3 face4(vec2 uv, float time) {
  vec3 c1 = getTexture(texShort, uv * 0.01 + vec2(time, 0));
  c1 *= abs(sin(uv.y));
  vec3 c2 = getTexture(texShort, uv * 0.01 + vec2(-time, 0));
  c2 *= abs(cos(uv.y));
  
  return c1 + c2;
}


vec3 renderScene(float time, vec2 uv) {
  float t1 = floor(time);
  float t2 = t1 + 1;
  float a = pow(fract(time), .6);
  
  float r1 = getTexture(texNoise, vec2(t1 * 0.23, t1 * 0.32)).r;
  float r2 = getTexture(texNoise, vec2(t2 * 0.23, t2 * 0.32)).r;
 float rotY = mix(r1, r2, a) * 20;
//  float rotY = 0 + mix(r1, r2, a) * 1;
  
  float roll = 0;
  float height = 100;

  float d1 = getTexture(texNoise, vec2(t1 * 0.86, t1 * 0.54)).r;
  float d2 = getTexture(texNoise, vec2(t2 * 0.86, t2 * 0.54)).r;
  float dist = 250 + mix(d1, d2, a) * 1800;
  
  vec3 lookFrom = vec3(-sin(rotY) * dist, height, -cos(rotY) * dist);
  vec3 lookAt = vec3(0,0,0);
  vec3 fwd = normalize(lookAt - lookFrom);
  vec3 up = normalize(vec3(sin(roll), cos(roll), 0));
  vec3 right = cross(up, fwd);
  up = cross(fwd, right);
  vec3 ray = normalize(fwd + uv.x * right + uv.y * up);
  
  vec3 color = vec3(0,0,0);
  color = getTexture(texSessions, ray.yy * 5) * getTexture(texNoise, ray.xy * 10);
  
  
  float maxt = 999999;
  float t;
  vec2 tuv;
  if (intersectPlane(vec3(0, 0, -1), vec3(0, 0, 100), lookFrom, ray, t, tuv)) {
    if (t < maxt && abs(tuv.x) < 100 && abs(tuv.y) < 100) {
      maxt = t;
      color = face2(tuv, time);
    }
  }
  if (intersectPlane(vec3(0, 0, 1), vec3(0, 0, -100), lookFrom, ray, t, tuv)) {
    if (t < maxt && abs(tuv.x) < 100 && abs(tuv.y) < 100) {
      maxt = t;
      color = face1(tuv, time);
    }
  }
  if (intersectPlane(vec3(1, 0, 0), vec3(100, 0, 0), lookFrom, ray, t, tuv)) {
    if (t < maxt && abs(tuv.x) < 100 && abs(tuv.y) < 100) {
      maxt = t;
      color = face3(tuv, time);
    }
  }  
  if (intersectPlane(vec3(-1, 0, 0), vec3(-100, 0, 0), lookFrom, ray, t, tuv)) {
    if (t < maxt && abs(tuv.x) < 100 && abs(tuv.y) < 100) {
      maxt = t;
      color = face4(tuv, time);
    }
  }


  if (intersectPlane(vec3(0, 0, -1), vec3(0, 0, 0), lookFrom, ray, t, tuv)) {
    if (t < maxt) {
      float d = length (tuv);
      float a = atan(tuv.x, tuv.y);
      float spoke = mod(a + time*1, radians(30));
      if (d > 200 && d < 250 && spoke < radians(20)) {
        color += vec3(.6,1,1) * max(0, sin(gl_FragCoord.y/2));
      }
    }
  }
  if (intersectPlane(vec3(0, 0, -1), vec3(0, 0, 0), lookFrom, ray, t, tuv)) {
    if (t < maxt) {
      float d = length (tuv);
      float a = atan(tuv.x, tuv.y);
      float spoke = mod(a + time*-1, radians(10));
      if (d > 300 && d < 500 && spoke < radians(5)) {
        color += vec3(.4,1,1) * max(0, sin(gl_FragCoord.y/2));
      }
    }
  }

  
  return color;
}




void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 color = vec3(0,1,0);
  float time = fGlobalTime * 148 / 60 / 2;
  color.r = renderScene(time, uv - vec2(0.002, 0)).r;
  color.g = renderScene(time, uv + vec2(0.002, 0)).g;
  color.b = renderScene(time, uv).b;
  
  
  
	out_color.rgb = color;
}