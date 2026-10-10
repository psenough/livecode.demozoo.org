#version 410 core

uniform float        fGlobalTime;          
uniform vec2         v2Resolution;         
uniform sampler1D    texFFT;               
uniform sampler1D    texFFTSmoothed;       

layout(location = 0) out vec4 out_color;

void main() {
    vec2 uv = gl_FragCoord.xy / v2Resolution;
    uv = uv * 1.8 - 1.0;
    uv.x *= v2Resolution.x / v2Resolution.y;

    float bass = texture(texFFTSmoothed, 0.1).r;

    float phase = fGlobalTime * 4.0;
    vec2 osc = vec2(
        sin(fGlobalTime * 1.2 + bass * 10.0),
        cos(fGlobalTime * 0.9 - bass * 4.0)
    );
    float h = fract(sin(phase * 12.9898) * 271827);

    vec2 noise = vec2((h * 3.0 - 1.0) * 0.02);

    vec2 jitter = osc * 0.05 + noise;

    uv -= jitter;
  
    float radius = 0.44 + bass * 0.20;
    float blur   = 0.05 + bass * 0.05;

    float cr = smoothstep(radius, radius - blur, h/.3*length(uv + vec2( blur, blur/2)));
    float cg = smoothstep(radius, radius - blur, h/.2*length(uv));
    float cb = smoothstep(radius, radius - blur, h/.2*length(uv + vec2(-blur/2, -blur)));

    out_color = vec4(cr, cg, cb, 1.0);
}
