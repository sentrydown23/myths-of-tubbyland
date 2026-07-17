// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float glitchMultiplier; // Added to control the fade out / tween
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

/* License CC BY-NC-SA 4.0 Deed */
/* https://creativecommons.org/licenses/by-nc-sa/4.0/ */

float hash(vec2 p)
{
        return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p)
{
        float timeNoise = iTime * 8.0;
        vec2 offset = vec2(cos(timeNoise), sin(timeNoise)) * 10.0;
        return hash(p + offset);
}

// Controls the frequency and timing of random glitch bursts
float onOff(float a, float b, float c)
{
        return step(c, sin(iTime + a * cos(iTime * b)));
}

// Moved ramp definition up so stripes can see it
float ramp(float y, float start, float end)
{
        float inside = step(start, y) - step(end, y);
        float fact = (y - start) / (end - start) * inside;
        return (1.0 - fact) * inside;
}

// Creates the rolling scanline stripes
float stripes(vec2 uv)
{
        float noi = noise(uv * vec2(0.5, 1.0) + vec2(1.0, 3.0));

        // REDUCED FREQUENCY: Slower speed (iTime/4.0) and wider spacing (uv.y*2.0 instead of 4.0)
        float stripePattern = mod(uv.y * 2.0 + iTime / 4.0 + sin(iTime + sin(iTime * 0.4)), 1.0);
        return ramp(stripePattern, 0.5, 0.55) * noi * 0.7; // Slightly softened overall intensity
}

vec3 getVideo(vec2 uv)
{
        vec2 look = uv;

        // Highly localized horizontal shake "window"
        float window = 1.0 / (1.0 + 30.0 * (look.y - mod(iTime / 4.0, 1.0)) * (look.y - mod(iTime / 4.0, 1.0)));

        // GLITCH LESS: Raised threshold (0.5 and 0.95) so tracking errors occur less often, and cut displacement amount in half
        float horizontalOffset = sin(look.y * 10.0 + iTime) / 100.0 * onOff(4.0, 4.0, 0.5) * (1.0 + cos(iTime * 40.0)) * window;
        look.x = look.x + horizontalOffset * glitchMultiplier;

        // GLITCH LESS: Reduced vertical tracking jumps
        float vShift = 0.15 * onOff(1.5, 2.0, 0.95) * (sin(iTime) * sin(iTime * 10.0) + (0.5 + 0.1 * sin(iTime * 100.0) * cos(iTime)));
        look.y = mod(look.y + (vShift * glitchMultiplier), 1.0);

        vec3 video = vec3(texture(iChannel0, look));
        return video;
}

// BEND SCREEN EDGES (Spheroid CRT bulge effect)
vec2 screenDistort(vec2 uv)
{
        uv -= vec2(0.5, 0.5);

        // Calculate radial distance from screen center
        float r2 = uv.x * uv.x + uv.y * uv.y;

        // Apply barrel distortion curve
        // Tweak 0.12 and 0.18 to control how extreme the screen edge bend is
        uv *= 1.0 + (0.12 * r2 + 0.18 * r2 * r2) * glitchMultiplier;

        uv += vec2(0.5, 0.5);
        return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
        vec2 uv = fragCoord.xy / iResolution.xy;

        // Check original sprite state at this coordinate first
        vec4 originalCol = texture(iChannel0, uv);
        
        // FIX: If the sprite is completely transparent or pitch black, render absolute transparent black and stop.
        // This prevents the shader from drawing artificial scanlines/vignettes over nothing.
        if (originalCol.a < 0.005 || (originalCol.r == 0.0 && originalCol.g == 0.0 && originalCol.b == 0.0)) {
                fragColor = vec4(0.0, 0.0, 0.0, originalCol.a);
                return;
        }

        // Interpolate between clean coordinates and curved/bent coordinates
        vec2 distortedUV = screenDistort(uv);
        uv = mix(uv, distortedUV, glitchMultiplier);

        // Clamp uv coordinates to black outside boundaries to simulate distinct physical CRT bezel edges
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                fragColor = vec4(0.0, 0.0, 0.0, originalCol.a);
                return;
        }

        vec3 video = getVideo(uv);

        // Vignette (Simulates dark screen tube corners)
        float vigAmt = (3.0 + 0.3 * sin(iTime + 5.0 * cos(iTime * 5.0))) * glitchMultiplier;
        float vignette = (1.0 - vigAmt * (uv.y - 0.5) * (uv.y - 0.5)) * (1.0 - vigAmt * (uv.x - 0.5) * (uv.x - 0.5));

        // Blend scanline noise stripes
        video += stripes(uv) * glitchMultiplier;
        video *= vignette;

        // Less frequent scanline contrast overlay
        // Broadened spacing (uv.y*15.0 instead of 30.0)
        float scanlineStrength = (12.0 + mod(uv.y * 15.0 + iTime, 1.0)) / 13.0;
        video *= mix(1.0, scanlineStrength, glitchMultiplier);

        fragColor = vec4(video * originalCol.a, originalCol.a);
}

void main() {
        mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}