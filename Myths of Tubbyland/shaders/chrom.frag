// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float beatPulse; // Our game-synced beat!
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header


// ==========================================
// CONFIGURATION CONTROLS (Adjust here!)
// ==========================================
// 1.0 is normal. Make it 2.0 or 3.0 to go crazy, or 0.5 to make it super subtle!
#define SHAKE_STRENGTH 5.0
// ==========================================


// Simple mathematical random generator
float rand(float n) {
    return fract(sin(n * 12.9898) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // 1. BEAT-SYNCED JITTER (With Local Config Control)
    float timeStep = floor(iTime * 24.0); 
    vec2 shake = vec2(0.0);
    
    if (rand(timeStep) > (0.70 - beatPulse * 0.5)) {
        // Multiply the displacement by our SHAKE_STRENGTH define
        float maxShakeX = (0.003 + (beatPulse * 0.025)) * SHAKE_STRENGTH;
        float maxShakeY = (0.002 + (beatPulse * 0.012)) * SHAKE_STRENGTH;

        shake.x = (rand(timeStep + 1.0) - 0.5) * maxShakeX; 
        shake.y = (rand(timeStep + 2.0) - 0.5) * maxShakeY; 
    }
    
    // Apply the shake coordinates
    uv += shake;

    // 2. CHROMATIC ABERRATION (Fully Restored!)
    float glitchTimeStep = floor(iTime * 16.0);
    float blendTime = glitchTimeStep + (iTime * 0.25);
    
    float amount = 0.0;
    amount = (1.0 + sin(blendTime * 0.6)) * 0.5;
    amount *= 1.0 + sin(blendTime * 1.6) * 0.5;
    amount *= 1.0 + sin(blendTime * 2.7) * 0.5;
    amount = pow(amount, 3.0);

    float randomSpike = rand(glitchTimeStep + 4.2);
    if (randomSpike > 0.85) {
        amount *= 1.6; 
    } else if (randomSpike < 0.25) {
        amount *= 0.2; 
    }

    amount *= 0.035; 
    
    // Sample channels using our shaken base coordinates (uv) combined with the aberration offsets
    vec3 col;
    col.r = texture( iChannel0, vec2(uv.x + amount, uv.y) ).r;
    col.g = texture( iChannel0, uv ).g;
    col.b = texture( iChannel0, vec2(uv.x - amount, uv.y) ).b;

    col *= (1.0 - amount * 0.5);

    // Output final color
    fragColor = vec4(col, texture(iChannel0, uv).a);
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}