import flixel.FlxG;
import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import funkin.backend.shaders.CustomShader;
import openfl.filters.ShaderFilter;

// --- SHADER 1: Chromatic Glitch ---
var glitchShader:CustomShader = null;
var shaderTime:Float = 0;
var gameFilter:ShaderFilter = null;
var hudFilter:ShaderFilter = null;

// --- SHADER 2: Scary Lion ---
var lionShader:CustomShader = null;
var lionTime:Float = 0;
var lionGameFilter:ShaderFilter = null;
var lionHudFilter:ShaderFilter = null;

// --- SHADER 3: Interlaced Glitch ---
var glitchShader:CustomShader = null;
var glitchTime:Float = 0;
var glitchGameFilter:ShaderFilter = null;
var glitchHudFilter:ShaderFilter = null;

// --- Screen Tear Intensity Tracker ---
var tearIntensity:Float = 0.0;

function update(elapsed:Float)
{
    // 1. Keep feeding the running time (iTime) to the Chromatic shader
    if (glitchShader != null)
    {
        shaderTime += elapsed;
        var timeParam = Reflect.field(glitchShader.data, "iTime");
        if (timeParam != null) {
            Reflect.setProperty(timeParam, "value", [shaderTime]);
        }
    }

    // 2. Keep feeding running variables to the Scary Lion shader
    if (lionShader != null)
    {
        lionTime += elapsed;
        
        // Handle decaying the aggressive tear back to 0 over 0.5 seconds
        if (tearIntensity > 0) {
            // Subtracting 2.0 per second means a value of 1.0 reaches 0.0 in exactly 0.5s!
            tearIntensity -= elapsed * 2.0; 
            if (tearIntensity < 0) tearIntensity = 0;
        }

        var timeParam = Reflect.field(lionShader.data, "iTime");
        if (timeParam != null) {
            Reflect.setProperty(timeParam, "value", [lionTime]);
        }

        // Pass the live tearing intensity variable to the shader
        var tearParam = Reflect.field(lionShader.data, "extraTear");
        if (tearParam != null) {
            Reflect.setProperty(tearParam, "value", [tearIntensity]);
        }

        // Initialize dummy mouse values
        var mouseParam = Reflect.field(lionShader.data, "iMouse");
        if (mouseParam != null) {
            Reflect.setProperty(mouseParam, "value", [FlxG.mouse.x, FlxG.mouse.y, 0, 0]);
        }
    }

    if (glitchShader != null)
    {
        glitchTime += elapsed;
        
        var timeParam = Reflect.field(glitchShader.data, "iTime");
        if (timeParam != null) {
            Reflect.setProperty(timeParam, "value", [glitchTime]);
        }
    }
}

function beatHit(_)
{
    // Toggle effects on and off at specific beats
    switch(_)
    {
        case 200:
            shaderApply();

        case 208:
            shaderRemove();
        
        case 216:
            shaderApply();

        case 224:
            shaderRemove();

        case 232:
            shaderApply();

        case 240:
            shaderRemove();

        case 248:
            shaderApply();

        case 256:
            shaderRemove();

        case 264:
            glitchShaderApply();

        case 328:
            glitchShaderRemove();

        case 392:
            shaderApply();

        case 422:
            shaderRemove();

        case 424:
            shaderApply();

        case 456:
            shaderRemove();
            lionShaderApply();

        case 459:
            triggerAggressiveTear();

        case 464:
            lionShaderRemove();
            glitchShaderApply();

        case 528:
            glitchShaderRemove();
    }
}

/**
 * Call this function from anywhere in your song script to trigger 
 * a sudden, aggressive screen-tear burst that decays over 0.5 seconds.
 */
function triggerAggressiveTear()
{
    if (lionShader != null) {
        tearIntensity = 1.0;
    }
}

// ==========================================
// CHROMATIC SHADER METHODS
// ==========================================

function shaderApply()
{
    if (FlxG.save.data.shaderToggle)
    {
        shaderRemove();

        glitchShader = new CustomShader("chrom");

        gameFilter = new ShaderFilter(glitchShader);
        hudFilter = new ShaderFilter(glitchShader);

        if (FlxG.camera.filters == null) {
            FlxG.camera.filters = [gameFilter];
        } else {
            FlxG.camera.filters.push(gameFilter);
        }

        if (camHUD != null) {
            if (camHUD.filters == null) {
                camHUD.filters = [hudFilter];
            } else {
                camHUD.filters.push(hudFilter);
            }
        }
    }
}

function shaderRemove()
{
    if (FlxG.camera.filters != null && gameFilter != null) {
        FlxG.camera.filters.remove(gameFilter);
        if (FlxG.camera.filters.length == 0) {
            FlxG.camera.filters = null;
        }
    }

    if (camHUD != null && camHUD.filters != null && hudFilter != null) {
        camHUD.filters.remove(hudFilter);
        if (camHUD.filters.length == 0) {
            camHUD.filters = null;
        }
    }

    gameFilter = null;
    hudFilter = null;
    glitchShader = null;
}

// ==========================================
// SCARY LION SHADER METHODS
// ==========================================

function lionShaderApply()
{
    if (FlxG.save.data.shaderToggle)
    {
        lionShaderRemove();

        lionShader = new CustomShader("scarylion");
        lionTime = 0;
        tearIntensity = 0.0; // Start at normal level

        var resParam = Reflect.field(lionShader.data, "iResolution");
        if (resParam != null) {
            Reflect.setProperty(resParam, "value", [FlxG.width, FlxG.height, 0]);
        }

        lionGameFilter = new ShaderFilter(lionShader);
        lionHudFilter = new ShaderFilter(lionShader);

        if (FlxG.camera.filters == null) {
            FlxG.camera.filters = [lionGameFilter];
        } else {
            FlxG.camera.filters.push(lionGameFilter);
        }

        if (camHUD != null) {
            if (camHUD.filters == null) {
                camHUD.filters = [lionHudFilter];
            } else {
                camHUD.filters.push(lionHudFilter);
            }
        }
    }
}

function lionShaderRemove()
{
    if (FlxG.camera.filters != null && lionGameFilter != null) {
        FlxG.camera.filters.remove(lionGameFilter);
        if (FlxG.camera.filters.length == 0) {
            FlxG.camera.filters = null;
        }
    }

    if (camHUD != null && camHUD.filters != null && lionHudFilter != null) {
        camHUD.filters.remove(lionHudFilter);
        if (camHUD.filters.length == 0) {
            camHUD.filters = null;
        }
    }

    lionGameFilter = null;
    lionHudFilter = null;
    lionShader = null;
    tearIntensity = 0.0;
}

function glitchShaderApply()
{
    if (FlxG.save.data.shaderToggle)
    {
        // Safety clean
        glitchShaderRemove();

        glitchShader = new CustomShader("downsample");
        glitchTime = 0; // Reset runtime clock

        glitchGameFilter = new ShaderFilter(glitchShader);
        glitchHudFilter = new ShaderFilter(glitchShader);

        // Apply to the Main Game Camera
        if (FlxG.camera.filters == null) {
            FlxG.camera.filters = [glitchGameFilter];
        } else {
            FlxG.camera.filters.push(glitchGameFilter);
        }

        // Apply to the HUD Camera
        if (camHUD != null) {
            if (camHUD.filters == null) {
                camHUD.filters = [glitchHudFilter];
            } else {
                camHUD.filters.push(glitchHudFilter);
            }
        }
    }
}

function glitchShaderRemove()
{
    // Remove from the Main Game Camera
    if (FlxG.camera.filters != null && glitchGameFilter != null) {
        FlxG.camera.filters.remove(glitchGameFilter);
        if (FlxG.camera.filters.length == 0) {
            FlxG.camera.filters = null;
        }
    }

    // Remove from the HUD Camera
    if (camHUD != null && camHUD.filters != null && glitchHudFilter != null) {
        camHUD.filters.remove(glitchHudFilter);
        if (camHUD.filters.length == 0) {
            camHUD.filters = null;
        }
    }

    // Reset the variables
    glitchGameFilter = null;
    glitchHudFilter = null;
    glitchShader = null;
}