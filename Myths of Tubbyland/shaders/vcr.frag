// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define S(a,b,t) smoothstep(a, b, t)

// High-quality procedural random number generator
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float xOffset(float y, float wave, float force) {
    float w = y*20. + iTime*50.;
    return (
        sin(w)
        + sin(w * 10.0) * 0.5
        + sin(w * 10.0) * 0.3
    ) * wave * 0.025 * force; // Slightly increased base offset multiplier (from 0.02 to 0.025)
}

float waveF(float y, float speed, float loop, float size) {
    float s = abs(mod(y + iTime * speed, loop) - 0.5);
    return S(1., 0., s*size);
}

vec2 screenDistort(vec2 uv)
{
    uv -= vec2(.5,.5);
    // Increased the CRT fish-eye curvature multiplier from 1.2 to 1.35
    uv = uv*1.35*(1./1.35+2.5*uv.x*uv.x*uv.y*uv.y);
    uv += vec2(.5,.5);
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    //Screen view (with increased fish-eye curvature)
    uv = screenDistort(uv);
    
    //Wave function
    float force0 = 0.05;
    // Increased force values slightly to make the horizontal wave tearing more aggressive
    float force1 = 0.55; // Up from 0.4
    float wave1 = waveF(uv.y,  0.4, 1.5, 15.);
    float force2 = 1.3;  // Up from 1.0
    float wave2 = waveF(uv.y,  0.7, 2.8, 20.);
    float force3 = 0.95; // Up from 0.7
    float wave3 = waveF(uv.y, 0.55, 2.8, 33.);
    
    //Offsets (Applying the horizontal coordinate shifts)
    uv.x += xOffset(uv.y, 1.5, 0.07); // Slightly boosted the constant baseline ripple
    uv.x += xOffset(uv.y, wave1, force1);
    uv.x += xOffset(uv.y, wave2, force2);
    uv.x += xOffset(uv.y, wave3, force3);
    
    //Texture
    fragColor = texture(iChannel0, uv);
    
    // 1. Generate crisp, moving procedural retro static (running at 24 frames per second)
    float timeSeed = floor(iTime * 24.0) * 19.13;
    float noiseVal = rand(gl_FragCoord.xy + vec2(timeSeed, -timeSeed));
    vec4 noise = vec4(vec3(noiseVal), 1.0);
    
    //Adds noise ONLY to the glitch tracking bands (with slightly higher opacity on the waves)
    fragColor = mix(fragColor, noise, wave1*0.25);   // Wave noise (Up from 0.2)
    fragColor = mix(fragColor, noise, wave2*0.25);
    fragColor = mix(fragColor, noise, wave3*0.25);
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}