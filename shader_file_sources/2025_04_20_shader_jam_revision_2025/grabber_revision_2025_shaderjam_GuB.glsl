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

float hash21(vec2 p) {
    p = fract(p * vec2(233.34, 851.74));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}

float fwig(float x, float t, float freq, float amp)
{
//    return amp * 16. * (x*x*(x-1.)*(x-1.)) * sin(freq*x + t);
    float v = x * x - 1.;
    return -amp * v * v * v * sin(freq*x + t);
}

float fwigd(float x, float t, float freq, float amp)
{
// -B (x - 1)^2 (x + 1)^2 (A x^2 cos(A x + 1) + 6 x sin(A x + 1) - A cos(A x + 1))
    float a = amp * (x - 1.) * (x - 1.) * (x + 1.) * (x + 1.);
    float b = freq * (x * x - 1.) * cos(freq*x + t) + 6. * x * sin(freq*x + t);
    return a * b;
        
//    return 16. * amp * x * (x - 1.) * 
//        (freq * x * (x - 1.) * cos(freq*x + t) + 
//         (4.*x - 2.) * sin(freq*x + t));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 hash3(float n) { 
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

vec3 hash33(vec3 v) { 
    return fract(sin(cross(v, vec3(12.5, 71.5, 44.6)))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float smin2( float a, float b, float k )
{
    float abd = abs(a - b);
    if (abs(a - b) < k) return (a + b / 2.0);
    return min(a, b);
}

float bfield_old(vec3 p, vec3 ofs, float time)
{
    vec3 pmod = mod(p + ofs, 4.0) - 2.0;
    vec3 cell = floor((p + ofs) / 4.0) - ofs;
    vec3 dr = normalize(hash33(cell) - 0.5);
    vec4 rot = vec4(cos(time), sin(time), -sin(time), 0.0);
    dr = vec3(dot(dr, rot.xzw), dot(dr, rot.yxw), dr.z);
    rot = vec4(cos(time * 1.5), sin(time * 1.5), -sin(time * 1.5), 0.0);
    dr = vec3(dr.x, dot(dr, rot.wxz), dot(dr, rot.wyx));
    vec3 cro = abs(cross(pmod, dr));
    float ddist = cro.x + cro.y + cro.z;
    return min(1.0, max(ddist - 0.25, length(pmod) - 1.0));
}

vec2 bfield_old2(vec3 p, vec3 ofs, float igt)
{
    vec3 pmod = mod(p + ofs, 4.0) - 2.0;
    vec3 cell = floor((p + ofs) / 4.0) - ofs;
    vec3 dr = normalize(hash33(cell) - 0.5);
    float rotval = (igt*dr.x)*5.0;
    vec4 rot = vec4(cos(rotval), sin(rotval), -sin(rotval), 0.0);
    pmod = vec3(dot(pmod, rot.xzw), dot(pmod, rot.yxw), pmod.z);
    rotval = (igt*dr.y)*5.0;
    rot = vec4(cos(rotval), sin(rotval), -sin(rotval), 0.0);
    pmod = vec3(pmod.x, dot(pmod, rot.wxz), dot(pmod, rot.wyx));
    vec3 d = abs(pmod) - vec3(0.15, 0.15, 1.0);
    float dist = min(1.0, min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)));
    float mat = floor(mod(dr.z * 54654.0, 3.0));
    //dist = length(pmod) - 1.0;
    return vec2(dist, mat + 1.0);
}

vec2 bfield(vec3 p, float igt)
{
    vec3 cell = floor(p / 4.0);
    vec3 dr = normalize(hash33(cell) - 0.5);
    vec3 pmod = mod(p, 4.0) - 2.0;
    
    float rotval = (igt*dr.x)*5.0;
    vec4 rot = vec4(cos(rotval), sin(rotval), -sin(rotval), 0.0);
    pmod = vec3(dot(pmod, rot.xzw), dot(pmod, rot.yxw), pmod.z);
    rotval = (igt*dr.y)*5.0;
    rot = vec4(cos(rotval), sin(rotval), -sin(rotval), 0.0);
    pmod = vec3(pmod.x, dot(pmod, rot.wxz), dot(pmod, rot.wyx));
    
    vec3 d = abs(pmod) - vec3(0.15, 0.15, 1.0);
    float dist = min(1.0, min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)));
    float mat = floor(mod(dr.z * 54654.0, 3.0));
    return vec2(dist, mat + 1.0);
}

vec2 barmap(vec3 p, float m)
{
    vec3 cell = floor(p / 4.0);
    vec3 dr = normalize(hash33(cell) - 0.5);
    vec3 pmod = mod(p, 4.0) - 2.0;
    
    vec3 d = abs(pmod) - vec3(m, m, clamp(m, 1.0, 2.0));
    float dist = min(1.0, min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)));
    float mat = floor(mod(dr.z * 54654.0, 3.0));
    return vec2(dist, mat + 1.0);
}

float bigmap(vec3 p) 
{
    vec3 pmod = mod(p + 10.0, 20.0) - 10.0;
    //pmod.x = pmod.x + pmod.x*0.1*sin(iTime * 1.0);
    //pmod.y = pmod.y + pmod.y*0.1*sin(iTime * 2.0);
    //pmod.z = pmod.z + pmod.z*0.1*sin(iTime * 3.0);
    float dsph = length(pmod) - 7.5;
    float dm1 = length(pmod.xy) - 4.0;
    float dm2 = length(pmod.xz) - 4.0;
    float dm3 = length(pmod.yz) - 4.0;
    float dmx = min(dsph, min(dm1, min(dm2, dm3)));
    //float dmx = smin(dm1, smin(dm2, dm3,0.5),0.5);;
    return -dmx;
}

vec2 smallmap(vec3 p, float time)
{
    float mosin = sin(time * 0.5) * 1.85;
    if (mosin > 0.0) {
        return barmap(p, 0.15 + mosin);
    } else {
        return bfield(p, -mosin);
    }
}

vec2 map(vec3 p, float time)
{
    vec2 ret = smallmap(p, time);
    float bm = bigmap(p);
    if (bm > ret.x) 
        ret.x = bm;
    //return vec2(bm, 1.0);
    return ret;
}

vec3 norm(vec3 p, float time)
{
    vec2 c = vec2(0.01, 0.0);
    return normalize(vec3(map(p+c.xyy, time).x - map(p-c.xyy, time).x,
                          map(p+c.yxy, time).x - map(p-c.yxy, time).x,
                          map(p+c.yyx, time).x - map(p-c.yyx, time).x));
}

vec4 m3(vec2 uv, out vec4 fragColor, in vec2 fragCoord, float time)
{
    vec3 ray = normalize(vec3(fragCoord - 0.5 * v2Resolution.xy, v2Resolution.x*0.5));
    vec3 c = vec3(uv,0.5+0.5*sin(time));
    //c = vec3(0.0, 0.0, 0.0);
    vec3 cbg = c;
    float movt = time * 10.0;
    float movs = 3.14159*movt/20.0;
    vec3 p0 = vec3(sin(movs)*10.0 + 10.0, 0.0, movt);
    if (mod(movt+10.0, 80.0) < 0.0) {
    	float rangl = -cos(movs);
    	vec4 rot = vec4(cos(rangl), sin(rangl), -sin(rangl), 0.0);
    	ray = vec3(dot(ray, rot.xzw), dot(ray, rot.yxw), ray.z);
    } else {
	    p0.x = 0.0;
    }
    float t = 1.0;
    for (int i = 0; i < 64; ++i) {
        vec3 p = p0 + ray * t;
        vec2 dm = map(p, time);
        if (dm.x < 0.001) {
            vec3 n = norm(p, time);
            c = 0.5 * n + 0.5;
            vec3 albed = vec3(0.0, 0.0, 0.0);
            if (dm.y == 1.0) {
            	albed = vec3(1.0, 0.0, 0.0);
            } else if (dm.y == 2.0) {
            	albed = vec3(0.0, 1.0, 0.0);
            } else {
            	albed = vec3(0.0, 0.0, 1.0);
            }
            albed = mix(albed, vec3(1.0), clamp(sin(time * 0.5), 0.0, 1.0));
            vec3 specc = vec3(1.0, 1.0, 1.0);
            vec3 lvec = normalize(vec3(-0.5, 0.5, -1.0));
            float difv = dot(n, lvec);
            vec3 rvec = 2.0 * dot(lvec, n) * n - lvec;
            float specv = pow(clamp(dot(rvec, -ray), 0.0, 1.0), 5.0);
            c = albed * difv * 0.5 + specv * specc * 1.0 + albed * 0.2;
            float iflo = 0.4 - float(i) / 64.0;
            c *= vec3(iflo+1.0);
            c = pow(c, vec3(2.2));
            c = mix(c, cbg, clamp(t*.02, 0.0, 1.0));
            break;
        }
        t += dm.x;
    }
    return vec4(c, 1.0);
}

vec4 m2(vec2 uv, float time) {
    float persp = 1. / (-uv.y + 1.5);
    uv.x *= persp;
    uv.y *= persp;
    uv.y += fGlobalTime * .05;
    uv *= mat2(1., 1., -1., 1.);
  
    
    float scale = 3.;
    //vec2 osq = floor(uv * scale);
    //float parity = fract(dot(osq, vec2(1.)) * .5);
    float rh = hash21(floor(uv * scale));
    float rh2 = hash21(vec2(rh,rh));
    //vec3 col2 = 1.*vec3(osq.xy, rh2);
    uv = fract(uv * scale) * 2.0 - 1.0;
    if (rh2 > 0.5) uv *= mat2(1., 0., 0., -1.);
    //col2 = vec3(parity);
    //if (parity > 0.) uv *= mat2(-1., 0., 0., 1.);
    //if (parity > 0.) col2 = vec3(0.5);
    uv *= mat2(1., -1., 1., 1.);
    uv.y = fract(uv.y * 0.5) * 2.0 - 1.0;
    float x = fract(uv.x * .5 + .5) * 2. - 1.;
    float t = time*2.*sin(rh*23.)+rh*78.;
    float freq = 7.0*rh+sin(time*1.2+7.*rh);
    float amp = sqrt(rh)*.2*sin(time+5.*rh);
    float fx = fwig(x, t, freq, amp);
    float fdx = fwigd(x, t, freq, amp);
    float d = (uv.y - fx) / length(vec2(1., 1.*fdx));
    float cval = sin(x * 3.14159 * 2. + time * 2. - d * fdx*8.) + .4;
    vec3 cbase = vec3(1.0, 0.5, 0.0);
    vec3 col = max(cbase, vec3(cval) + cbase) * smoothstep(0.1+persp*.04, 0.1-persp*.04, abs(d)) +
        0. * vec3(0.,0.,1.) * smoothstep(0.03, 0.0, abs(uv.y)) +
        0. * vec3(1.,0.,0.) * smoothstep(0.03, 0.0, abs(uv.y-.1*fdx)) + 
        0. * vec3(0.,1.,0.) * smoothstep(0.03, 0.0, abs(uv.y-fx));
    //fragColor = vec4(col+col2,1.0);
    return vec4(col,1.0);
  }

 vec4 m1(vec2 uv, float time) {
     float resxy = max(v2Resolution.x, v2Resolution.y);
    vec2 p = ((gl_FragCoord.xy - v2Resolution.xy * .5) / vec2(resxy, resxy)) * 2.;
    vec3 c = vec3(uv,0.5+0.5*sin(fGlobalTime*2.));
    float pi=atan(-1.);
    float t = -fGlobalTime*5.-texture(texFFT,.1).x*3.;
    c = vec3(0.);

    vec2 pp = p*16.+t*.1;
    for (int i = 0; i < 5; ++i) {
        pp *= .5;
        p = mod(pp*2.+vec2(t,-t),4.)-2.0;
        float l = max(0.,min(1.-dot(.5*p,.5*p), 1.));
        float ap = atan(p.x-.2,p.y+.3)*8. + sin(l*10.+fGlobalTime*5.+texture(texFFT,.1).x*1.);
        if (ap > -8. && ap < -2. && p.y > 0.) {
            float ts = fGlobalTime;
            float fc1 = max(0., sin(ap-sin(ts)));
            float fc2 = max(0., sin(ap));
            float fc3 = max(0., sin(ap+sin(ts)));
            c += vec3(fc1, fc2, fc3)*l*4.;
        }
        if (length(p)+texture(texFFT,.1).x < .05*(5.+sin(atan(p.x,p.y)*5.+t*2.))) c = vec3(1., 1., 0.);
        if (texture(texFFT,.1).x > 0.5 && length(p) < .02*(5.+sin(atan(p.x,p.y)*5.+t*2.))) c = vec3(1., 0., 0.);
    }
	return vec4(c, 1.0);
}
  
void main(void)
{
  //float t2 = texFFTIntegrated;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  out_color = 1.*m1(uv, fGlobalTime) + 0.*m2(uv, fGlobalTime);

}