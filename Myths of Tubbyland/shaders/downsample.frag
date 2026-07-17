// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

// Resolution Downsampling Configuration
// Lower values = heavier retro/low-quality look.
const float targetHeight = 480.0; 

float rand(float seed){
    return fract(sin(dot(vec2(seed) ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 interlace(vec2 co, vec4 col) {
    if (mod(floor(co.y), 3.0) < 0.001) {
        // REMOVED: Took out the '+ (rand(iTime) * 0.03)' white noise addition
        return col * ((sin(iTime * 5.) * 0.05) + 0.88);
    }
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Pixelation / Downsampling
    float aspect = iResolution.x / iResolution.y;
    vec2 targetRes = vec2(targetHeight * aspect, targetHeight);
    vec2 uv = (floor((fragCoord / iResolution.xy) * targetRes) + 0.5) / targetRes;

    // --- PROMINENT ANALOG JITTER ---
    float tapeWave = sin(uv.y * 12.0 - iTime * 2.5) * 0.0035;
    float lineNoise = 0.0038 * (0.5 - rand(iTime * 24.0 * uv.y));
    
    // Combine them into a strong, cohesive horizontal wiggle
    vec2 finalDisplace = vec2(tapeWave + lineNoise, 0.0);

    // Sample the screen texture with our prominent tape distortion
    vec4 texColor = texture(iChannel0, uv.xy + finalDisplace);

    // Apply the interlaced TV scanlines
    fragColor = interlace(fragCoord, texColor);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}