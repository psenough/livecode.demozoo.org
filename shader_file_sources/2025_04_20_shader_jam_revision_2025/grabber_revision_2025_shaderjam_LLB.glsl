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
uniform sampler2D texRevisionBW;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime

vec3 animationAmp = vec3(1.,.2, 1.);
vec3 animationSpeed = vec3(1.,1.,.5);
vec3 sheepPos = vec3(0);  
vec3 flowerPos = vec3(1e6);
vec3 panelPos = vec3(1e6);
vec3 panelWarningPos = vec3(1e6);
vec3 anvilPos = vec3(1e6);
vec3 sunDir = normalize(vec3(3.5,1.,-1.));
vec3 camPos = vec3(0.,2.5, -3.7);
vec3 camTa = vec3(0., 3., 0.);
vec3 eyeDir = vec3(0.,.45,1.);
vec2 headRot = vec2(0.);
vec2 excited = vec2(0);
float blink = 0.;
float camFocal = 2.;
float eyesSurprise = 0.;
float fishEyeFactor = 0.;
float noseSize = 1.;


//----------------------------------------------------------------------
// KodeLife Shadertoy mimic
//----------------------------------------------------------------------
// uniform float iTime;
float iTime = fGlobalTime;


//----------------------------------------------------------------------
// Maths function
//----------------------------------------------------------------------

const float PI = acos(-1.);
const float INFINITE = 9e7;

vec3 hash3(vec3 p);
float noise( in vec3 x );

mat3 lookat(vec3 ro, vec3 ta);
mat2 rot(float v);


// ---------------------------------------------
// Distance field toolbox
// ---------------------------------------------
float box( vec3 p, vec3 b );
float cappedCone( vec3 p, float h, float r1, float r2 );
float capsule( vec3 p, vec3 a, vec3 b, float r );
float torus( vec3 p, vec2 t );
float ellipsoid( vec3 p, vec3 r);
float smin( float d1, float d2, float k );
float smax( float a, float b, float k );
float triangle( vec3 p, vec2 h, float r );
float UnevenCapsule2d( vec2 p, float r1, float r2, float h );
float star2d(in vec2 p, in float r, in float rf);


// ---------------------------------------------
// Distance field 
// ---------------------------------------------
vec2 map(vec3 p);
float shadow( vec3 ro, vec3 rd);

// Materials
const float GROUND = 0.;
const float COTON = 1.;
const float SKIN = 2.;
const float EYE = 3.;
const float CLOGS = 4.;
const float METAL = 5.;
const float PANEL = 6.;
const float PANEL_FOOD = 7.;
const float PISTIL = 8.;
const float PETAL = 9.;
const float TIGE = 10.;
const float BLACK_METAL = 11.;
const float BLOOD = 12.;

vec2 dmin(vec2 a, vec2 b) {
    return a.x<b.x ? a : b;
}

vec2 flower(vec3 p) {
    p -= flowerPos;
    vec3 pr = p;
    pr.x += cos(3.1*.25+iTime)*3.1*.2;
    pr.y -= 2.8;
    pr.zy = rot(.7) * pr.zy;
    float pistil = ellipsoid(pr-vec3(0.,.3,0.), vec3(1.,.2+cos(pr.x*150.)*sin(pr.z*150.)*.05,1.)*.25);
    if (pistil < 5.) {
        vec2 dmat = vec2(pistil, PISTIL);
        
        vec3 pp = pr;
        
        //moda
        float per = PI*.2;
        float a = atan(pp.z,pp.x);
        float l = length(pp.xz);
        a = mod(a-per/2.,per)-per/2.;
        pp.xz = vec2 (cos(a),sin(a))*l;
        
        float petals = ellipsoid(pp-vec3(0.5,.2+sin(pp.x*2.)*.2,0.), vec3(2.,.1+sin(pp.z*40.)*.02,.75)*.25);
        if (petals < dmat.x) {
            dmat = vec2(petals, PETAL);
        }
        
        float tige = max(length(p.xz + vec2(cos(p.y*.25+iTime)*p.y*.2+0.02,-.1) )-smoothstep(3.1,0., p.y)*.05-0.02, p.y-3.1);
        if (tige < dmat.x) {
            dmat = vec2(tige, TIGE);
        }
        
        return dmat;
    }
    return vec2(INFINITE, GROUND);
}

// return [distance, material]
float headDist = 0.; // distance to head (for eyes AO)
vec2 sheep(vec3 p) {
    p -= sheepPos;
    float time = mod(iTime, 1.);
    time = smoothstep(0., 1., abs(time * 2. - 1.));

    p.y -= 1.;
    p.z -= -2.;

    // Body
    float tb = iTime*animationSpeed.x;
    vec3 bodyMove = vec3(cos(tb*PI),cos(tb*PI*2.)*.1,0.)*.025*animationAmp.x;
    float body = length(p*vec3(1.,1.,.825)-vec3(0.,1.5,2.55)-bodyMove)-2.;
    
    if (body < 3.) {
        float n = (pow(noise((p-bodyMove+vec3(.05,0.0,0.5))*2.)*.5+.5, .75)*2.-1.);
        body = body + .05 - n*.2;


        // Legs
        float t = mod(iTime*animationSpeed.x,2.);
        float l = smoothstep(0.,.5,t) * smoothstep(1.,.5,t);
        float a = smoothstep(0.,.5,t);
        float b = smoothstep(.5,1.,t);
        float c = smoothstep(1.,1.5,t);
        float d = smoothstep(1.5,2.,t);
        vec4 legsRot = vec4(b * (1.-b), d * (1.-d), a * (1.-a), c * (1.-c));
          
        vec4 legsPos = t*.5 - vec4(b, d, a, c);
        legsPos *= animationAmp.x;
        
        vec3 pl = p;
        pl.x -= .8;
        pl.z -= 2. + legsPos.x;
        pl.yz = rot(legsRot.x) * pl.yz;
        float legs = cappedCone(pl-vec3(0.,0.,0.), .7, .3, .2);
        float clogs = cappedCone(pl-vec3(0.,-0.8,0.), .2, .35, .3);

        pl = p;
        pl.x += 1.;
        pl.z -= 2. + legsPos.y;
        pl.yz = rot(legsRot.y) * pl.yz;
        legs = min(legs, cappedCone(pl-vec3(0.,0.,0.), .7, .3, .2));
        clogs = min(clogs, cappedCone(pl-vec3(0.,-0.8,0.), .2, .35, .3));

        pl = p;
        pl.x -= 1.;
        pl.z -= 4. + legsPos.z;
        pl.yz = rot(legsRot.z) * pl.yz;
        legs = min(legs, cappedCone(pl-vec3(0.,0.,0.), .7, .3, .2));
        clogs = min(clogs, cappedCone(pl-vec3(0.,-0.8,0.), .2, .35, .3));

        pl = p;
        pl.x += 1.;
        pl.z -= 4. + legsPos.w;
        pl.yz = rot(legsRot.w) * pl.yz;
        legs = min(legs, cappedCone(pl-vec3(0.,0.,0.), .7, .3, .2));
        clogs = min(clogs, cappedCone(pl-vec3(0.,-0.8,0.), .2, .35, .3));

        // Head
        vec3 ph = p + vec3(0., -2., -1.2);
        ph.xz = rot((time*animationSpeed.y - 0.5)*0.25*animationAmp.y+headRot.x) * ph.xz;
        ph.zy = rot(sin(iTime*animationSpeed.y)*0.25*animationAmp.y-headRot.y) * ph.zy;

        float head = length(ph-vec3(0.,-1.3,-1.2)) - 1.;
        head = smin(head, length(ph-vec3(0.,0.,0.)) - .5, 1.8);


        // hair 
        vec3 pp = ph;
        pp *= vec3(.7,1.,.7);
        float hair = length(ph-vec3(0.,0.35,-0.1))-.55;
        hair -= (cos(ph.z*8.+ph.y*4.5+ph.x*4.)+cos(ph.z*4.+ph.y*6.5+ph.x*8.))*.05;
        //hair -= (pow(noise(ph*3.+1.)*.5+.5, .75)*2.-1.)*.1;
        hair = smin(hair, body, 0.1);
        
        // ears
        pp = ph;
        pp.yz = rot(-.6) * pp.yz;
        pp.x = abs(p.x)-.8;
        pp *= vec3(.3,1.,.4);
        pp -= vec3(0.,-0.05 - pow(pp.x,2.)*5.,-.1);
        float ears = length(pp)-.15;
        ears = smax(ears, -(length(pp-vec3(0.,-.1,0.))-.12), .01);
        pp.y *= .3;
        pp.y -= -.11;
        float earsClip =  length(pp)-.16;
        
        //eyes
        pp = ph;
        pp.x = abs(ph.x)-.4;
        float eyes = length(pp*vec3(1.,1.,1.-eyesSurprise)-vec3(0.,0.,-1.)) - .3;
        
        float eyeCap = abs(eyes)-.01;
        //eyeCap = smax(eyeCap, -ph.z-1.1-smoothstep(0.95,0.96,blink)*.4, .01);
        eyeCap = smax(eyeCap, smin(-abs(ph.y+ph.z*(.025))+.25-smoothstep(0.95,0.96,blink)*.3+cos(iTime*1.)*.02, -ph.z-1.-eyesSurprise*1.8, .2), .01);
        eyeCap = smin(eyeCap, head, .02);
        head = min(head, eyeCap);

        // nostrils
        pp.x = abs(ph.x)-.2;
        pp.xz = rot(-.45) * pp.xz;
        head = smax(head, -length(pp-vec3(-0.7,-1.2,-2.05)) + .14*noseSize, .1);
        head = smin(head, torus(pp-vec3(-0.7,-1.2,-1.94), vec2(.14*noseSize,.05)), .05);

        // tail
        float tail =  capsule(p-vec3(0.,-.1,cos(p.y-.7)*.5),vec3(cos(iTime*animationSpeed.z)*animationAmp.z,.2,5.), vec3(0.,2.,4.9), .2);
        tail -= (cos(p.z*8.+p.y*4.5+p.x*4.)+cos(p.z*4.+p.y*6.5+p.x*3.))*.02;
        tail = smin(body, tail, .1);
        
        // Union
        vec2 dmat = vec2( body, COTON);
        dmat = dmin(dmat, vec2(tail, COTON));
        dmat = dmin(dmat, vec2(hair, COTON));
        dmat.x = smax(dmat.x, -earsClip, .15);
        dmat = dmin(dmat, vec2(legs, SKIN));
        dmat = dmin(dmat, vec2(head, SKIN));
        dmat = dmin(dmat, vec2(eyes, EYE));
        dmat = dmin(dmat, vec2(clogs, CLOGS));
        dmat = dmin(dmat, vec2(ears, SKIN));
        
        headDist = head;
        return dmat;
    } else {
        return vec2(body, COTON);
    }
}


vec2 map(vec3 p) {
    return 
    dmin(
      dmin(vec2(p.y, GROUND), sheep(p)),
      flower(p));
}

vec3 skyColor(vec3 rd, vec2 uv, float night) {
    // mon
    vec2 moonPos = vec2(cos(iTime*.7+2.), sin(iTime*.7+2.)*.75 );
    float moonCircle = smoothstep(0.151,0.15, length(uv-moonPos));
    float moon = moonCircle * smoothstep(0.13,0.2701, length(uv-moonPos-vec2(.05,0.05))+0.004*noise(100.*vec3(uv-moonPos, 0.)));

    // stars
    vec2 p = rot(iTime*0.0002)*uv*200.;
    vec2 fp = fract(p)-.5;
    vec2 ip = floor(p);
    vec3 rnd = hash3(vec3(abs(ip),abs(ip.x)));
    float s = rnd.z*.06;

    return  vec3(1., .9, .1) * moon*smoothstep(.5,-1., sunDir.y)
        + smoothstep(s,s*.01, length(fp+(rnd.xy-.5)) ) * (1.-moonCircle)
        + exp(-length(uv-moonPos)*2.)*.1 + pow(night,2.);
}

float fastAO( in vec3 pos, in vec3 nor, float maxDist, float falloff ) {
    float occ1 = .5*maxDist - map(pos + nor*maxDist *.5).x;
    float occ2 = .95*(maxDist - map(pos + nor*maxDist).x);
    return clamp(1. - falloff*1.5*(occ1 + occ2), 0., 1.);
}

float trace(vec3 ro, vec3 rd) {
    float t = 0.01;
    for(int i=0; i<128; i++) {
        float d = map(ro+rd*t).x;
        t += d;
        if (t > 100. || abs(d) < 0.001) break;
    }
    
    return t;
}

// Specular light effect for the eyes envmap.
float specular(vec3 v, vec3 l, float size)
{
    float spe = max(dot(v, normalize(l + v)), 0.);
    float a = 2000./size;
    float b = 3./size;
    return (pow(spe, a)*(a+2.) + pow(spe, b)*(b+2.)*2.)*0.008;
}




float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float p(vec2 uv, int i) {
    float ic = float(i);
	vec2 gr = 1.0 - abs(uv*7.-0.5 - vec2(mod(ic,7.), floor(ic/7.)));
	return smoothstep(0.25, 0.5, min(gr.x,gr.y));
}

float b(int n, int b) { return float(mod(floor(float(n) / exp2(floor(float(b)))), 2.0) != 0.0); }

float pa(vec2 uv, int g) {
	const ivec3 n[] = ivec3[](
		ivec3(0x9F00, 0x27C8, 0x0112),
        ivec3(0x8F00, 0x27C8, 0x00F2),
        ivec3(0x9F00, 0x2040, 0x01F0),
        ivec3(0x8F00, 0x2448, 0x00F2),
        ivec3(0x9F00, 0x27C0, 0x01F0),
        ivec3(0x9F00, 0x27C0, 0x0010),
        ivec3(0x9F00, 0x2340, 0x01F2),
        ivec3(0x9100, 0x27C8, 0x0112),
        ivec3(0x1F00, 0x8102, 0x01F0),
        ivec3(0x1F00, 0x2204, 0x00F1),
        ivec3(0x9100, 0x21C4, 0x0111),
        ivec3(0x8100, 0x2040, 0x01F0),
        ivec3(0x9100, 0x254D, 0x0112),
        ivec3(0x9100, 0x2549, 0x0113),
        ivec3(0x9F00, 0x2448, 0x01F2),
        ivec3(0x9F00, 0x27C8, 0x0010),
        ivec3(0x9F00, 0x2548, 0x0171),
        ivec3(0x9F00, 0xA7C8, 0x0190),
        ivec3(0x9F00, 0x07C0, 0x01F2),
        ivec3(0x1F00, 0x8102, 0x0040),
        ivec3(0x9100, 0x2448, 0x01F2),
        ivec3(0x9100, 0x4448, 0x0041),
        ivec3(0x9100, 0xA548, 0x00A2),
        ivec3(0x1100, 0x4105, 0x0111),
        ivec3(0x1100, 0x8105, 0x0040),
        ivec3(0x1F00, 0x4104, 0x01F0)	
	);
	
	float r = 0.0;
	for (int i = 0; i < 16; i++) {
		r = max(r, p(uv, i   )*b(n[g].x,i));
		r = max(r, p(uv, i+16)*b(n[g].y,i));
		r = max(r, p(uv, i+32)*b(n[g].z,i));
	}
	return r;
}

void main()
{
  iTime = texture(texFFTIntegrated, 0.09).r * 5.;
  camPos = vec3(6, 3, -8 + sin(time));
  headRot = vec2(0.2, 0.1 + sin(time)*.2);
  //animationSpeed *= 2.;
  animationSpeed = vec3(3.,1.5,8.);
  animationAmp = vec3(1.,1.,.5);
  blink = max(fract(iTime*.333), fract(iTime*.123+.1));
  eyeDir = vec3(-.1, 0.,1.);
  // camTa = 
  
    vec2 uv = (gl_FragCoord.xy) / v2Resolution;
    // uv = mod(vec2(uv.x, uv.y)*1.5 + vec2(time*.2,0.), 1.);
    vec2 v = uv*2.-1.;
    v.x *= v2Resolution.x / v2Resolution.y;
        
    // Setup ray
    vec3 ro = camPos;
    vec3 ta = camTa;
    vec3 rd = lookat(ro, ta) * normalize(vec3(v,camFocal - length(v)*fishEyeFactor));
        
    // Trace : intersection point + normal
    float t = trace(ro,rd);
    vec3 p = ro + rd * t;
    vec2 dmat = map(p);
    vec2 eps = vec2(0.0001,0.0);
    vec3 n = normalize(vec3(dmat.x - map(p - eps.xyy).x, dmat.x - map(p - eps.yxy).x, dmat.x - map(p - eps.yyx).x));
    
    
    // ----------------------------------------------------------------
    // Shade
    // ----------------------------------------------------------------
    float night = 1.; // smoothstep(0.,.3, sunDir.y)+.1;
    
    float ao = fastAO(p, n, .15, 1.) * fastAO(p, n, 1., .1)*.5;
    
    float shad = shadow(p, sunDir);
    float fre = 1.0+dot(rd,n);
    
    vec3 diff = vec3(1.,.8,.7) * max(dot(n,sunDir), 0.) * pow(vec3(shad), vec3(1.,1.2,1.5));
    vec3 bnc = vec3(1.,.8,.7)*.1 * max(dot(n,-sunDir), 0.) * ao;
    vec3 sss = vec3(.5) * mix(fastAO(p, rd, .3, .75), fastAO(p, sunDir, .3, .75), 0.5);
    vec3 spe = vec3(1.) * max(dot(reflect(rd,n), sunDir),0.);
    vec3 envm = vec3(0.);
    
    //sss = vec3(1.) * calcSSS(p,rd);
    vec3 amb = vec3(.4,.45,.5)*1. * ao;
    vec3 emi = vec3(0.);
    
    vec3 albedo = vec3(0.);
    if(dmat.y == GROUND || dmat.x > 50.) {
        albedo = vec3(3.);
        albedo = vec3(0.2);
        //albedo = skyColor(rd, v,  0.2);
        //albedo = texture(texRevisionBW, uv).rgb;
        
        int[] arr = int[](19, 7, 4, -1, 18, 7, 4, 4, 15, -1, 8, 18, -1, 1, 0, 2, 10);
        for (int i = 0; i < arr.length(); i++) {
            vec2 uv2 = 4.*uv - vec2(0.2, 0.1);
            //uv.y *= -1.;
            if (arr[i] >= 0)
              albedo += pa(uv2*5. - vec2(i-9, 0), arr[i]);
        }

        out_color.rgb = albedo;
        return;
        //return albedo;
        // smoothstep(90.,100.,t)
        sss *= 0.;
        spe *= 0.;
    } else if (dmat.y == COTON) {
        albedo = vec3(.4);
        sss *= fre*.5+.5;
        emi = vec3(.35);
        spe = pow(spe, vec3(4.))*fre*.25;
    } else if (dmat.y == CLOGS) {
        albedo = vec3(.025);
        sss *= 0.;
        spe = pow(spe, vec3(80.))*fre*10.;
    } else if (dmat.y == EYE) {
        sss *= .5;
        vec3 dir = normalize(eyeDir + (noise(vec3(iTime,iTime*.5,iTime*1.5))*2.-1.)*.01);
        
        // compute eye space -> mat3(eyeDir, t, b)
        vec3 t = cross(dir, vec3(0.,1.,0.));
        vec3 b = cross(dir,t);
        t = cross(b, dir);
        
        vec3 ne = n.z * dir + n.x * t + n.y * b;
        
        // parallax mapping
        vec3 v = rd.z * eyeDir + rd.x * t + rd.y * b;
        vec2 offset = v.xy / v.z * length(ne.xy) / length(ro-p) * .4;
        ne.xy -= offset * smoothstep(0.01,.0, dot(ne,rd));
        
        const float i_irisSize = .3;
        float pupilSize = .2 + eyesSurprise*.5;
        
        // polar coordinate
        float er = length(ne.xy);
        float theta = atan(ne.x, ne.y);
        
        // iris
        vec3 c = mix(vec3(.5,.3,.1) , vec3(.0,.8,1), smoothstep(0.16,i_irisSize,er)*.3+cos(theta*15.)*.04);
        float filaments = smoothstep(-.9,1.,noise(vec3(er*10.,theta*30.+cos(er*50.+noise(vec3(theta))*50.)*1.,0.)))
            + smoothstep(-.9,1.,noise(vec3(er*10.,theta*40.+cos(er*30.+noise(vec3(theta))*50.)*2.,0.)));
        float pupil = smoothstep(pupilSize,pupilSize+0.02, er);
        albedo = c * (filaments*.5+.5) * (smoothstep(i_irisSize,i_irisSize-.01, er)); // brown to green
        albedo *= vec3(1.,.8,.7) * pow(max(0.,dot(normalize(vec3(3.,1.,-1.)), ne)),8.)*300.+.5; // retro reflection
        albedo *= pupil; // pupil
        albedo += pow(spe,vec3(800.))*3; // specular light
        albedo = mix(albedo, vec3(.8), smoothstep(i_irisSize-0.01,i_irisSize, er)); // white eye
        albedo = mix(c*.3, albedo, smoothstep(0.0,0.05, abs(er-i_irisSize-0.0)+0.01)); // black edge
        
        // fake envmap reflection
        n = mix(normalize(n + (eyeDir + n)*4.), n, smoothstep(i_irisSize,i_irisSize+0.02, er));
        {
            vec3 v = reflect(rd, n);
            vec3 l1 = normalize(vec3(1., 1.5, -1.));
            vec3 l2 = vec3(-l1.x, l1.y*.5, l1.z);
            float spot =
                + specular(v, l1, .1)
                + specular(v, l2, 2.) * .1
                + specular(v, normalize(l1 + vec3(0.2, 0., 0.)), .3)
                + specular(v, normalize(l1 + vec3(0.2, 0., 0.2)), .5)
                + specular(v, normalize(l2 + vec3(0.1, 0., 0.2)), 8.) * .5;
    
            envm = (mix(
                mix(vec3(.3,.3,0.), vec3(.1), smoothstep(-.7, .2, v.y)),
                vec3(0.3, 0.65, 1.), smoothstep(-.0, 1., v.y)) + spot * vec3(1., 0.9, .8)) * mix(.15, .2, pupil) *sqrt(fre)*2.5;
        }
        
        // shadow on the edges of the eyes
        map(p);
        albedo *= smoothstep(0.,0.015, headDist)*.4+.6;
        
        // flower
        /*
        float shape = abs(sin(theta * 5.)) - smoothstep(.15, 0.7, er)*4.;
        shape = smoothstep(0.449, 0.45, shape);
        vec3 flower = mix(vec3(0.), vec3(.75,0.5,1.)*.5, shape);
        flower = mix(vec3(.7, .7, 0.), flower, smoothstep(.06, .1, er));
        flower *= smoothstep(135.2, 135.6, iTime);
        
        albedo += flower;
        */
        
        spe *= 0.;
    } else if (dmat.y == PISTIL) {
        vec3 pr = p - flowerPos;
        pr.x += cos(3.1*.25+iTime)*3.1*.2;
        pr.y -= 2.8;
        pr.zy = rot(.75) * pr.zy;
        albedo = mix(vec3(2.,.75,.0), vec3(2.,2.,.0), smoothstep(0.,.45, length(pr-vec3(0.,.3,0.))))*1.8;
        sss = vec3(0.01);
        spe *= 0.;
    } else if (dmat.y == TIGE) {
        albedo = vec3(0.,.05,.0);
        spe *= fre;
    } else if (dmat.y == PETAL) {
        vec3 pr = p - flowerPos;
        pr.x += cos(3.1*.25+iTime)*3.1*.2;
        pr.y -= 2.8;
        pr.zy = rot(.75) * pr.zy;
        albedo = mix(vec3(1.,1.,1.)+.5, vec3(.75,0.5,1.), smoothstep(0.5,1.1, length(pr-vec3(0.,.3,0.))))*2.;
       // albedo = vec3(1.,1.,1.)*3.;
        sss *= 0.;
        spe = pow(spe, vec3(4.))*fre*1.0;
    } else if(dmat.y == BLACK_METAL) {
        albedo = vec3(1.);
        diff *= vec3(.1)*fre;
        amb *= vec3(.1)*fre;
        bnc *= 0.;
        sss *= 0.;
        spe = pow(spe, vec3(100.))*fre*2.;
    }  else if(dmat.y == BLOOD) {
        albedo = vec3(1.,.01,.01)*.3;
        diff *= vec3(3.);
        amb *= vec3(2.)*fre*fre;
        sss *= 0.;
        spe = vec3(1.,.3,.3) * pow(spe, vec3(500.))*5.;
    } 
    else if (dmat.y == SKIN) {
        albedo = vec3(1.,.7,.5)*1.;
        amb *= vec3(1.,.75,.75);
        sss = pow(sss, vec3(.5,2.5,5.0)+2.)*2.;// * fre;// * pow(fre, 1.);
        spe = pow(spe, vec3(4.))*fre*.02;
    }

    // fog
    vec3 col = clamp(mix((albedo * (amb*1. + diff*.5 + bnc*2. + sss*2. ) + envm + spe*shad + emi) *  night, skyColor(rd,v, night), 0.), 0., 1.);


    // ----------------------------------------------------------------
    // Post processing pass
    // ----------------------------------------------------------------
    const float endTime = 146.;
    // gamma correction & color grading
    col = pow(pow(col, vec3(1./2.2)), vec3(1.0,1.05,1.1));
    
    // vignetting
    out_color = vec4(col / (1.+pow(length(uv*2.-1.),4.)*.04),1.);
    // out_color = vec4(0.5);
}





// ---------------------------------------------
// Raytracing toolbox
// ---------------------------------------------

// https://www.shadertoy.com/view/lsKcDD
float shadow( vec3 ro, vec3 rd)
{
    float res = 1.0;
    float t = 0.08;
    for( int i=0; i<64; i++ )
    {
        float h = map( ro + rd*t ).x;
        res = min( res, 30.0*h/t );
        t += h;
        
        if( res<0.0001 || t>50. ) break;
        
    }
    return clamp( res, 0.0, 1.0 );
}




// ---------------------------------------------
// Hash & Noise
// ---------------------------------------------
vec3 hash3(vec3 p) {
    uvec3 x = uvec3((p+100.)*10000.);
    const uint k = 1103515245U; 
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    
    return vec3(x)*(1.0/float(-1U));
}

float noise(vec3 x) {

    vec3 i = floor(x);
    vec3 f = fract(x);
    f = f*f*f*(f*(f*6.0-15.0)+10.0);
    return mix(mix(mix( hash3(i+vec3(0,0,0)).x, 
                        hash3(i+vec3(1,0,0)).x,f.x),
                   mix( hash3(i+vec3(0,1,0)).x, 
                        hash3(i+vec3(1,1,0)).x,f.x),f.y),
               mix(mix( hash3(i+vec3(0,0,1)).x, 
                        hash3(i+vec3(1,0,1)).x,f.x),
                   mix( hash3(i+vec3(0,1,1)).x, 
                        hash3(i+vec3(1,1,1)).x,f.x),f.y),f.z)*2.-1.;
}


// ---------------------------------------------
// Math
// ---------------------------------------------
mat3 lookat(vec3 ro, vec3 ta)
{
    const vec3 up = vec3(0.,1.,0.);
    vec3 fw = normalize(ta-ro);
    vec3 rt = normalize( cross(fw, normalize(up)) );
    return mat3( rt, cross(rt, fw), fw );
}

mat2 rot(float v) {
    float a = cos(v);
    float b = sin(v);
    return mat2(a,b,-b,a);
}


// ---------------------------------------------
// Distance field toolbox
// ---------------------------------------------
float box( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float cappedCone( vec3 p, float h, float r1, float r2 )
{
  vec2 q = vec2( length(p.xz), p.y );
  vec2 k1 = vec2(r2,h);
  vec2 k2 = vec2(r2-r1,2.0*h);
  vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
  vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
  float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
  return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}
float capsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  return length( pa - ba*clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 ) ) - r;
}
float torus( vec3 p, vec2 t )
{
  return length(vec2(length(p.xy)-t.x,p.z))-t.y;
}
float ellipsoid( vec3 p, vec3 r )
{
  float k0 = length(p/r);
  return k0*(k0-1.0)/length(p/(r*r));
}

float smin( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float smax( float a, float b, float k )
{
    k *= 1.4;
    float h = max(k-abs(a-b),0.0);
    return max(a, b) + h*h*h/(6.0*k*k);
}
float triangle( vec3 p, vec2 h, float r )
{
  return max(abs(p.z)-h.y,smax(smax(p.x*0.9+p.y*0.5, -p.x*0.9+p.y*0.5, r),-p.y,r)-h.x*0.5);
}

float UnevenCapsule2d( vec2 p, float r1, float r2, float h )
{
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,vec2(-b,a));
    if( k < 0.0 ) return length(p) - r1;
    if( k > a*h ) return length(p-vec2(0.0,h)) - r2;
    return dot(p, vec2(a,b) ) - r1;
}
