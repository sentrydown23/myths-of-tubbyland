import flixel.FlxG;
import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import funkin.backend.shaders.CustomShader;
import openfl.filters.ShaderFilter;

// --- SHADER 1: VHS (VCR) ---
var vhsShader:CustomShader = null;
var vhsTime:Float = 0;
var gameFilter:ShaderFilter = null;
var hudFilter:ShaderFilter = null;

// --- SHADER 2: Interlaced Glitch ---
var glitchShader:CustomShader = null;
var glitchTime:Float = 0;
var glitchGameFilter:ShaderFilter = null;
var glitchHudFilter:ShaderFilter = null;

function update(elapsed:Float)
{
    // 1. Update VHS (VCR) Shader Time
    if (vhsShader != null)
    {
        vhsTime += elapsed;
        
        var timeParam = Reflect.field(vhsShader.data, "iTime");
        if (timeParam != null) {
            Reflect.setProperty(timeParam, "value", [vhsTime]);
        }
    }

    // 2. Update Interlaced Glitch Shader Time
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
    switch(_)
    {
        // --- VHS Shader Timeline ---
        case 152:
            shaderApply();

        case 184:
            shaderRemove();

        case 216:
            glitchShaderApply();

        case 248:
            glitchShaderRemove();
        
        case 280:
            shaderApply();

        case 312:
            shaderRemove();
    }
}

// ==========================================
// SHADER 1: VHS (VCR) METHODS
// ==========================================

function shaderApply()
{
    if (FlxG.save.data.shaderToggle)
    {
        // Safety clean in case it's somehow already running
        shaderRemove();

        vhsShader = new CustomShader("vcr");
        vhsTime = 0; // Reset runtime clock

        // Safely set "curvature" using reflection
        var curvatureParam = Reflect.field(vhsShader.data, "curvature");
        if (curvatureParam != null) {
            Reflect.setProperty(curvatureParam, "value", [3.5, 4.0]);
        }

        // Safely set "scanLineOpacity" using reflection
        var opacityParam = Reflect.field(vhsShader.data, "scanLineOpacity");
        if (opacityParam != null) {
            Reflect.setProperty(opacityParam, "value", [0.35, 0.35]);
        }

        gameFilter = new ShaderFilter(vhsShader);
        hudFilter = new ShaderFilter(vhsShader);

        // Apply to the Main Game Camera
        if (FlxG.camera.filters == null) {
            FlxG.camera.filters = [gameFilter];
        } else {
            FlxG.camera.filters.push(gameFilter);
        }

        // Apply directly to the HUD Camera
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
    // Remove from the Main Game Camera
    if (FlxG.camera.filters != null && gameFilter != null) {
        FlxG.camera.filters.remove(gameFilter);
        if (FlxG.camera.filters.length == 0) {
            FlxG.camera.filters = null;
        }
    }

    // Remove from the HUD Camera
    if (camHUD != null && camHUD.filters != null && hudFilter != null) {
        camHUD.filters.remove(hudFilter);
        if (camHUD.filters.length == 0) {
            camHUD.filters = null;
        }
    }

    // Reset the variables
    gameFilter = null;
    hudFilter = null;
    vhsShader = null;
}

// ==========================================
// SHADER 2: INTERLACED GLITCH METHODS
// ==========================================

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