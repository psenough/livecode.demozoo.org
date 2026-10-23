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

const vec4 c = vec4(1.,0.,-1.,3.14159);
const float pi = 3.14159,
    PHI = 1.618,
    f = 1.e4;
mat3 R;

void hash33(in vec3 p3, out vec3 d)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    d = fract((p3.xxy + p3.yxx)*p3.zyx);
}

float hash12(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float lfnoise(in vec2 t)
{
    vec2 i = floor(t);
    t = fract(t);
    t = smoothstep(c.yy, c.xx, t);
    vec2 v1 = vec2(hash12(i), hash12(i+c.xy)), 
        v2 = vec2(hash12(i+c.yx), hash12(i+c.xx));
    v1 = c.zz+2.*mix(v1, v2, t.y);
    return mix(v1.x, v1.y, t.x);
}

float mfnoise(in vec2 x, in float d, in float b, in float e)
{
    float n = 0.;
    float a = 1., nf = 0., buf;
    for(float f = d; f<b; f *= 2.)
    {
        buf = lfnoise(f*x);
        n += a*buf;
        a *= e;
        nf += 1.;
    }
    return n * (1.-e)/(1.-pow(e, nf));
}

// Scene marching information
struct SceneData
{
    // Material for palette
    float material,
    
        // Distance
        dist,
    
        // Light accumulation for clouds
        accumulation,
    
        // Reflectivity
        reflectivity,
    
        // Transmittivity
        transmittivity,
    
        // Illumination
        specular,
    
        // Diffuse
        diffuse;
};

SceneData defaultMaterial(float d)
{
    return SceneData(.8, d, .0, .0, .0, .5, 1.);
}

SceneData add(SceneData a, SceneData b)
{
    if(a.dist < b.dist) return a;
    return b;
}

float dbox3(vec3 x, vec3 b)
{
  vec3 da = abs(x) - b;
  return length(max(da,0.))
         + min(max(da.x,max(da.y,da.z)),0.);
}

float m(vec2 x)
{
    return max(x.x,x.y);
}

float d210(vec2 x)
{
    return min(max(max(max(max(min(max(max(m(abs(vec2(abs(abs(x.x)-.25)-.25, x.y))-vec2(.2)), -m(abs(vec2(x.x+.5, abs(abs(x.y)-.05)-.05))-vec2(.12,.02))), -m(abs(vec2(abs(x.x+.5)-.1, x.y-.05*sign(x.x+.5)))-vec2(.02,.07))), m(abs(vec2(x.x+.5,x.y+.1))-vec2(.08,.04))), -m(abs(vec2(x.x, x.y-.04))-vec2(.02, .08))), -m(abs(vec2(x.x, x.y+.1))-vec2(.02))), -m(abs(vec2(x.x-.5, x.y))-vec2(.08,.12))), -m(abs(vec2(x.x-.5, x.y-.05))-vec2(.12, .07))), m(abs(vec2(x.x-.5, x.y))-vec2(.02, .08)));
}

float datz(vec2 uv)
{
    vec2 a = abs(uv)-.25;
    return max(max(min(max(min(abs(mod(uv.x-1./12.,1./6.)-1./12.)-1./30., abs(a.x+a.y)-.015),a.x+a.y), max(a.x+.1,a.y+.1)), -length(uv-vec2(0.,.04))+.045), -max(a.x+.225,a.y+.175));
}

void pR(inout vec2 p, float a)
{
	p = cos(a)*p+sin(a)*vec2(p.y, -p.x);
}

// iq's smooth minimum
float smoothmin(float a, float b, float k)
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1./6.);
}

float smoothmax(float a, float b, float k)
{
    return a + b - smoothmin(a,b,k);
}

float dlabyrinthsimplex(vec2 x)
{
    vec2 yc = floor(x),
        y = x - yc - .5;
    float d = f;
    
    for(float i=-1.; i<=1.; i+=1.)
        for(float j=-1.; j<=1.; j+=1.)
            d = min(d, abs(y.x+i+(-1.+2.*round(hash12(yc)))*(y.y+j))-.2);
    return d;
}

float dlabyrinth(vec2 x)
{
    return hash12(floor(x)-13.) < .5 
        ? max(
            dlabyrinthsimplex(x),
            dlabyrinthsimplex(x+133.)
        ) 
        : dlabyrinthsimplex(x);
}

float zextrude(float z, float d2d, float h)
{
    vec2 w = vec2(d2d, abs(z)-.5*h);
    return min(max(w.x,w.y),0.) + length(max(w,0.));
}

// Distance to hexagon pattern
void dhexagonpattern(in vec2 p, out float d, out vec2 ind) 
{
    vec2 q = vec2( p.x*1.2, p.y + p.x*0.6 );
    
    vec2 pi = floor(q);
    vec2 pf = fract(q);

    float v = mod(pi.x + pi.y, 3.0);

    float ca = step(1.,v);
    float cb = step(2.,v);
    vec2  ma = step(pf.xy,pf.yx);
    
    d = dot( ma, 1.0-pf.yx + ca*(pf.x+pf.y-1.0) + cb*(pf.yx-2.0*pf.xy) );
    ind = pi + ca - cb*ma;
    ind = vec2(ind.x/1.2, ind.y);
    ind = vec2(ind.x, ind.y-ind.x*.6);
}

SceneData scene(vec3 x)
{
  //x.xy = mod(x.xy, 2.*c.xx)-1.;
  
    //x.y += .3*fGlobalTime;
 
 /*
 SceneData sdf = add(
        SceneData(1., x.z, 0.,.5,0.,1.,1.),
        SceneData(.1, zextrude(x.z, , .6), 1.,0.,1.,1.,1.)
    );*/
    
    float na = mfnoise(x.xy-.3*fGlobalTime, 1., 1.e2, .45);
  
    const float zsize = .05;
    float dz = mod(x.z, zsize)-.5*zsize,
      zi = (x.z-dz)/zsize;
  
    float d2d = abs(length(x.xy-.2*c.yx)+.04*zi-2.5*na)-.01-texture(texFFTSmoothed, .003).r;
    
    SceneData sda = SceneData(1., x.z+1., 0., .6, 0., 1., 1.);
    //if(zi < 0.) 
      {
      sda = add(sda, SceneData(-3.*fract(.1*zi-texture(texFFTIntegrated, .03).r), zextrude(dz, d2d, .3*zsize)-.15*zsize, 0., .6, 0., 1., 1.));
    }
    
    //sda.dist = mod(sda.dist, .1)-.05;
    
    return sda;
  
    
  
  
    SceneData sdf = SceneData(0., x.z, 0.,.1,0.,1.,1.);
    
    if(x.z<.1||(dlabyrinth(2.*(x.xy+x.yx*c.xz))/2. < 0. && x.z < .3))
    {
        
    float s = .025,
            m = 0.;
        vec3 y = mod(x, s)-.5*s,
            yi = x-y,
            r;
        
        // Random material
        hash33(yi, r);
        r = 2.*r-1.;
        m += step(r.x+r.y+r.z,-1.);
        
        for(int i=0; i<5; ++i)
            if(r.y+r.z+r.x > 0.)
            {
                s *= .5; // Try .25
                vec3 a = mod(y, s)-.5*s,
                    yi = y-a;
                y = a;

                hash33(r +yi+.124*float(i), r);
                r = 2.*r-1.;
                m += step(r.x+r.y+r.z,-.9);
            }

        // Wall
        if(r.x > -.25+.5*sin(fGlobalTime))
        sdf = add(sdf, SceneData(m, dbox3(y, .39*s*c.xxx)-.1*s, 0., 0., 0., .5, .5+.5*m));
    }
    return sdf;
}

vec3 normal(vec3 x)
{
    float s = scene(x).dist,
        dx = 5.e-5;
    return normalize(vec3(
        scene(x+dx*c.xyy).dist, 
        scene(x+dx*c.yxy).dist, 
        scene(x+dx*c.yyx).dist
    )-s);
}

vec3 palette(float scale)
{
    const int N = 3;
    vec3 colors[N] = vec3[N](
        //vec3(0.21,0.21,0.21),
        //vec3(0.94,0.39,0.23),
        //vec3(0.94,0.39,0.23),
        c.xxx,
        vec3(0.41,0.72,1.00),
        vec3(0.03,0.02,0.36)
    );
    float i = floor(scale),
        ip1 = mod(i + 1., float(N));
    return mix(colors[int(i)], colors[int(ip1)], fract(scale));
}

// Analytical sphere distance.
// Use this by plugging o-x0 into x.
vec2 asphere(vec3 x, vec3 dir, float R)
{
    float a = dot(dir,dir),
        b = 2.*dot(x,dir),
        cc = dot(x,x)-R*R,
        dis = b*b-4.*a*cc;
    if(dis<0.) return vec2(f);
    vec2 dd = (c.xz*sqrt(dis)-b)/2./a;
    return vec2(min(dd.x, dd.y), max(dd.x, dd.y));
}

// Analytical box distance.
// Use this by plugging o-x0 into x.
vec2 abox3(vec3 x, vec3 dir, vec3 s)
{
    vec3 a = (s-x)/dir, 
        b = -(s+x)/dir,
        dn = min(a,b),
        df = max(a,b);
    return vec2(
        all(lessThan(abs(x + dn.y * dir).zx,s.zx)) 
            ? dn.y 
            : all(lessThan(abs(x + dn.x * dir).yz,s.yz)) 
                ? dn.x 
                : all(lessThan(abs(x + dn.z * dir).xy,s.xy)) 
                    ? dn.z
                    : f,
        all(lessThan(abs(x + df.y * dir).zx,s.zx)) 
            ? df.y 
            : all(lessThan(abs(x + df.x * dir).yz,s.yz)) 
                ? df.x 
                : all(lessThan(abs(x + df.z * dir).xy,s.xy)) 
                    ? df.z 
                    : f
    );
}

// Orthogonal projection for any vector d. Without the use of Gram-Schmidt for shorter code.
// This assumes, that you don't plug in the origin (which would be stupid, right?)
mat3 ortho(vec3 d)
{
    vec3 a = normalize(
        d.x != 0. 
            ? vec3(-d.y/d.x,1.,0.)
            : d.y != 0.
                ? vec3(1.,-d.x/d.y,0.)
                : vec3(1.,0.,-d.x/d.z)
    );
    return mat3(d, a, cross(d,a));
}


// Analytical infinite cylinder distance.
// Use this by plugging o-x0 into x.
vec2 apipe(vec3 x, vec3 dir, vec3 d, float R)
{
    //vec3 al = normalize(cross(d,dir));
    //mat3 m = transpose(mat3(al, cross(d, al), d));
    mat3 m = transpose(ortho(dir));
    x = m*x;
    dir = m*dir;
    
    return asphere(vec3(x.xy,0.), vec3(dir.xy,0.), R);
}

bool ray(out vec3 col, out vec3 x, inout float d, vec3 dir, out SceneData s, vec3 o, vec3 l, out vec3 n)
{
    for(int i=0; i<250; ++i)
    {
        x = o + d * dir;
        
      /*
        // Bounding box
        if(d>2.)
        {
            d = f;
            x = o + d * dir;
            return false;
        }
*/
        
        s = scene(x);
        
        if(s.dist < 1.e-4) 
        {
            // Blinn-Phong Illumination
            n = normal(x);
            col = palette(s.material);
            col = .2 * col
                + s.diffuse * col*max(dot(normalize(l-x),n),0.)
                + s.specular * col*pow(max(dot(reflect(normalize(l-x),n),dir),0.),2.);
                
            return true;
        }
        
        d += min(s.dist,s.dist>5.e-1?1.e-2:5.e-3);
        //d += s.dist;
        //d += min(s.dist, 1.e-3);
        
        //if(d > asphere(o-.5*R*c.yxy, dir, .24).y) d = abox3(o, dir, vec3(1.,1.,.911)).y;
    }
    return false;
}

mat3 rot3(vec3 p)
{
    return mat3(c.xyyy, cos(p.x), sin(p.x), 0., -sin(p.x), cos(p.x))
        *mat3(cos(p.y), 0., -sin(p.y), c.yxy, sin(p.y), 0., cos(p.y))
        *mat3(cos(p.z), -sin(p.z), 0., sin(p.z), cos(p.z), c.yyyx);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sm(in float d)
{
    return smoothstep(1.5/v2Resolution.y, -1.5/v2Resolution.y, d);
}

vec3 hsv2rgb(in vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(in vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main(void)
{
  /*
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;*/
  
  R = //mat3(1.);
  rot3(vec3(0.,0.,.7)*fGlobalTime);

    float d = 0.,
        d1 = 0.;
    vec2 uv = (gl_FragCoord.xy-.5*v2Resolution.xy)/v2Resolution.y;
    vec3 o = R*vec3(0., -.5, .5),
        col = c.yyy,
        c1,
        x,
        x1,
        n,
        n1,
        r = R*c.xyy,
        t = vec3(0.,0.,.4),
        dir = normalize(uv.x * r + uv.y * cross(r,normalize(t-o))-o),
        l = c.zxx+c.yyx;
    SceneData s, 
        s1;
        
    // Material ray
    //d = min(asphere(o-.5*R*c.yxy, dir, .24).x, abox3(o+.075*c.yyx, dir, vec3(1.,1.,.925)).y);
    
    d = -(o.z)/dir.z;
    
    if(ray(col, x, d, dir, s, o, l, n))
    {
        // Reflections
        //if(dbox3(x,vec3(1.)) < 0.) d1 = abox3(x+.075*c.yyx, re, vec3(1.,1.,.925)).y;
        //else d1 = min(abox3(x+.075*c.yyx, re, vec3(1.,1.,.925)).y, asphere(x-.5*R*c.yxy, re, .24).x);
        
        if(s.reflectivity != 0.)
        {
            vec3 re = reflect(dir,n);
            d1 = 2.e-2;
            if(ray(c1, x1, d1, re, s1, x, l, n1))
                col = mix(col, c1, s.reflectivity);
        }
        
        /*
        //d1 = asphere(o-.5*c.yxy, refract(dir,n, .99), .24).y;
        // Refractions
        d1 = 2.e-4;
        if(ray(c1, x1, d1, refract(dir,n, .99), s1, x, l, n1))
            col = mix(col, c1, s.transmittivity);
        */
        
        /*
        // Hard Shadow
        d1 = 1.e-2;
        if(ray(c1, x1, d1, normalize(l-x), s1, x, l, n1))
        {
            if(length(l-x1) < length(l-x))
                col *= .5;
        }
        */
        
        if(x.z < .3)
        {
        // Soft Shadow
        o = x;
        dir = normalize(l-x);
        d1 = 1.e-2;
        
        // if(d < 1.e2)
        {
            float res = 1.0;
            float ph = 1.e20;
            for(int i=0; i<1250; ++i)
            // for(d=1.e-2; x.z<.5; )
            {
                x = o + d1 * dir;
                s = scene(x);
                if(s.dist < 1.e-4) 
                {
                    res = 0.;
                    break;
                }
                if(x.z > .3) 
                {
                    res = 1.;
                    break;
                }
                float y = s.dist*s.dist/(2.0*ph)/12.;
                float da = sqrt(s.dist*s.dist-y*y);
                res = min( res, 100.0*da/max(0.0,d1-y) );
                ph = s.dist;
                d1 += min(s.dist,s.dist>5.e-1?1.e-2:5.e-3);
//                d1 += min(s.dist,s.dist>1.e-1?1.e-2:5.e-3);
            }
            col = mix(.5*col, col, res);
        }
        }
    }
    
    float d21a = d210(5.*(uv-.45*c.xz));
    col = mix(col, mix(col, c.xxx, .5), sm(d21a));
    
    vec3 ccol = rgb2hsv(col);
    ccol.r = 2.*sin(texture(texFFTIntegrated, .01).r);
    col = hsv2rgb(ccol);
    
    vec3 dcol = vec3(0.40,0.70,1.00);
    dcol.r = 2.*sin(texture(texFFTIntegrated, .01).r);
    dcol = hsv2rgb(dcol);
    
    col = mix(col, mix(dcol, .5*c.xxx, .8), smoothstep(0., 3., d));
    
    float dad;
    vec2 vi;
    dhexagonpattern(32.*uv, dad, vi);
    col = mix(col, mix(col, col+col*col+col*col*col, (.5+.5*lfnoise(vi-fGlobalTime*3.))), .5*abs(uv.y));
    
    col =mix(col, mix(col, .8*col, sm(abs(dad)-.1)), .5*abs(uv.y));
  
  out_color = vec4(mix(texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).rgb,col, .5).rgb,1.);
}