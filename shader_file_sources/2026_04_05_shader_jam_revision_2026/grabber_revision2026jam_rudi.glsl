#version 420 core

uniform float fGlobalTime;
uniform vec2 v2Resolution;

layout(location = 0) out vec4 out_color;

// Simulated PRNG matching your 8086 implementation
float hash(float n) {
    return fract(sin(n * 25173.0) * 13849.0);
}

// Mocking 'speech.bin' data
// vec3 = vec3(m1 (F1), m2 (F2), amplitude/voicing)
vec3 getPhoneme(int frame) {
    int step = frame % 120;
    if (step < 10) return vec3(255.0, 0.0, 0.0); // Pause
    if (step < 40) return vec3(9.0,  15.0, 1.0); // Vowel "A" (Voiced)
    if (step < 70) return vec3(4.0,  25.0, 1.0); // Vowel "E" (Voiced)
    if (step < 100) return vec3(255.0, 0.0, 1.0); // Consonant Hiss (Unvoiced)
    return vec3(255.0, 0.0, 0.0); // Pause
}

// The core 8086 PC Speaker algorithm translated to GLSL math
float synthesizeSpeech(float time) {
    // 10ms frames
    int frameIndex = int(time * 100.0);
    vec3 phoneme = getPhoneme(frameIndex);
    
    float m1 = phoneme.x;
    float m2 = phoneme.y;
    float amp = phoneme.z;

    if (amp == 0.0) return 0.0; // is_pause (Speaker Gate closed)

    float wave = 0.0;

    if (m1 == 255.0) {
        // --- UNVOICED FRAME (Consonant/Hiss) ---
        // You used divider 398 (~3000 Hz hiss) and a PRNG
        float prng = hash(floor(time * 8000.0)); // Sampled at 8000Hz
        wave = prng > 0.5 ? 1.0 : -1.0;
    } else {
        // --- VOICED FRAME (Vowels) ---
        
        // 1. Calculate Dividers exactly like your 'div bx' logic
        float f1_div = max(14914.0 / max(m1, 1.0), 1.0);
        float f2_div = m2 == 0.0 ? f1_div : max(14914.0 / max(m2, 1.0), 1.0);

        // 2. AM GLOTTAL EXCITATION
        // 8000Hz timer, 145 ticks per cycle = ~55Hz Demonic Pulse
        float timer8000 = time * 8000.0;
        float glottal_phase = mod(timer8000, 145.0);
        
        // 25% Duty Cycle (cmp glottal_phase, 36)
        bool speaker_gate_open = glottal_phase < 36.0;

        if (speaker_gate_open) {
            // 3. HARDWARE MULTIPLEXING
            // Swap F1 and F2 on the PIT (test al, 1)
            bool load_f1 = mod(timer8000, 2.0) < 1.0;
            float active_div = load_f1 ? f1_div : f2_div;

            // 4. PIT Mode 3 Square Wave Generation
            // freq = 1.19318 MHz / divider
            float freq = 1193180.0 / active_div;
            wave = sign(sin(time * 3.14159265 * 2.0 * freq));
        }
    }

    return wave;
}

void main(void) {
    // Normalize UV coordinates
    vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
    
    // Map the X axis to a short time window (0.05 seconds) to view the wave scrolling
    float window = 0.15;
    float t = fGlobalTime + uv.x * window;
    
    // Fetch the waveform amplitude at this exact microsecond
    float wave = synthesizeSpeech(t);
    
    // Scale wave to fit the screen vertically
    float y = uv.y * 2.0 - 1.0;
    float dist = abs(y - (wave * 0.5));
    
    // Oscilloscope glow effect
    float intensity = 0.015 / (dist + 0.001);
    vec3 col = vec3(0.2, 0.9, 0.4) * intensity;
    
    // CRT Grid and Scanlines
    col *= 0.8 + 0.2 * sin(uv.y * 800.0); 
    col += vec3(0.0, 0.1, 0.0) * step(fract(uv.x * 20.0), 0.02);
    col += vec3(0.0, 0.1, 0.0) * step(fract(uv.y * 20.0), 0.02);
    
    // Frame Vignette (darkens the corners)
    col *= 1.0 - pow(abs(uv.x - 0.5) * 2.0, 4.0);
    col *= 1.0 - pow(abs(uv.y - 0.5) * 2.0, 4.0);

    out_color = vec4(col, 1.0);
}