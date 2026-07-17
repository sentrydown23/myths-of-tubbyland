import funkin.game.PlayState;
import funkin.backend.shaders.CustomShader; 
import openfl.filters.ShaderFilter;

var glitchShader:CustomShader;
var cameraFilter:ShaderFilter;
var shaderActive:Bool = false;
var shaderTime:Float = 0;

// Dynamic controller variable we can tween
var shaderStrength:Float = 1.0; 

var border:FlxSprite;
var barLeft:FlxSprite;
var barRight:FlxSprite;
var barTop:FlxSprite;
var barBottom:FlxSprite;

var borderCam:FlxCamera;
var introImage1:FlxSprite;
var introImage2:FlxSprite;
var introImage3:FlxSprite;

function create() {
    glitchShader = new CustomShader("vhs"); 
    glitchShader.iTime = 0.0;
    
    // Set our starting strength to 1 (Fully glitched)
    var multParam = Reflect.field(glitchShader.data, "glitchMultiplier");
    if (multParam != null) {
        Reflect.setProperty(multParam, "value", [shaderStrength]);
    }

    switch (FlxG.save.data.borderToggle) {
        case "on":
            borderON();
        case "partial":
            borderPartial();
        case "off":
            borderOFF();
        default:
            borderOFF();
    }
}

function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 15:
            // Instantly make the shader active with 100% strength
            shaderStrength = 1.0;
            applyShaderToBorderCam();
        case 16:
            if (introImage1 != null) {
                introImage1.scale.set(1.0, 1.0);
                FlxTween.tween(introImage1, {alpha: 1}, 1.0);
                FlxTween.tween(introImage1.scale, {x: introImage1.scale.x + 0.1, y: introImage1.scale.y + 0.1}, 7.0, {ease: FlxEase.linear});
            }
        case 30:
            if (introImage1 != null) FlxTween.tween(introImage1, {alpha: 0}, 1.0);
        case 32:
            if (introImage2 != null) {
                introImage2.scale.set(1.0, 1.0);
                FlxTween.tween(introImage2, {alpha: 1}, 1.0);
                FlxTween.tween(introImage2.scale, {x: introImage2.scale.x + 0.1, y: introImage2.scale.y + 0.1}, 7.0, {ease: FlxEase.linear});
            }
        case 46:
            if (introImage2 != null) FlxTween.tween(introImage2, {alpha: 0}, 1.0);
        case 48:
            if (introImage3 != null) {
                introImage3.scale.set(1.0, 1.0);
                FlxTween.tween(introImage3, {alpha: 1}, 1.0);
                FlxTween.tween(introImage3.scale, {x: introImage3.scale.x + 0.1, y: introImage3.scale.y + 0.1}, 7.0, {ease: FlxEase.linear});
            }
        case 62:
            // --- SYNCED FADE OUT ---
            // We fade BOTH the image's alpha and the shader's strength together over 1.0 second.
            FlxTween.num(1.0, 0.0, 1.0, {
                ease: FlxEase.linear,
                onUpdate: function(tween:FlxTween) {
                    shaderStrength = tween.value; // Fades the shader strength
                    if (introImage3 != null) {
                        introImage3.alpha = tween.value; // Fades the image alpha at the exact same rate
                    }
                }
            });
        case 64:
            // I would love to fade them out naturally but the game
            removeShaderFromBorderCam();
            FlxTween.globalManager.cancelTweensOf(introImage1);
            FlxTween.globalManager.cancelTweensOf(introImage2);
            FlxTween.globalManager.cancelTweensOf(introImage3);
            introImage1.visible = false;
            introImage2.visible = false;
            introImage3.visible = false;
    }
}

function update(elapsed:Float)
{
    if (glitchShader != null)
    {
        shaderTime += elapsed;
        
        // 1. Update Time
        var timeParam = Reflect.field(glitchShader.data, "iTime");
        if (timeParam != null) {
            Reflect.setProperty(timeParam, "value", [shaderTime]);
        }

        // 2. Feed the active tween value into our new glitchMultiplier uniform
        var multParam = Reflect.field(glitchShader.data, "glitchMultiplier");
        if (multParam != null) {
            Reflect.setProperty(multParam, "value", [shaderStrength]);
        }
    }
}


function borderOFF() {
    borderCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    borderCam.bgColor = 0x00000000; // Transparent background
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;

    FlxG.cameras.add(borderCam, false);
    
    introImage1 = new FlxSprite(0, 0).loadGraphic(Paths.image("stages/satstat/intro1"));
    introImage1.setGraphicSize(FlxG.width, FlxG.height);
    introImage1.updateHitbox();
    introImage1.scrollFactor.set(0, 0);
    introImage1.cameras = [borderCam];
    introImage1.alpha = 0;
    add(introImage1);

    introImage2 = new FlxSprite(0, 0).loadGraphic(Paths.image("stages/satstat/intro2"));
    introImage2.setGraphicSize(FlxG.width, FlxG.height);
    introImage2.updateHitbox();
    introImage2.scrollFactor.set(0, 0);
    introImage2.cameras = [borderCam];
    introImage2.alpha = 0;
    add(introImage2);
    
    introImage3 = new FlxSprite(0, 0).loadGraphic(Paths.image("stages/satstat/intro3"));
    introImage3.setGraphicSize(FlxG.width, FlxG.height);
    introImage3.updateHitbox();
    introImage3.scrollFactor.set(0, 0);
    introImage3.cameras = [borderCam];
    introImage3.alpha = 0;
    add(introImage3);
}

function borderON() {
    // Screen dimensions
    var screenW:Int = FlxG.width;   // 1280
    var screenH:Int = FlxG.height;  // 720
    
    // Dimensions for 4:3 (height 720, width 960)
    var gameW:Int = 960;
    var gameH:Int = 720;
    var offsetX:Int = (screenW - gameW) / 2; // 160 pixels of black bars on the sides
    
    // ---- CREATE CAMERA FOR THE BORDER ----
    borderCam = new FlxCamera(0, 0, screenW, screenH);
    borderCam.bgColor = 0x00000000; // Transparent background
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;
    
    // Add camera to the camera list (above all others)
    FlxG.cameras.add(borderCam, false);

    // ---- ADD IMAGES ----
    introImage1 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro1"));
    introImage1.setGraphicSize(gameW, gameH);
    introImage1.updateHitbox();
    introImage1.scrollFactor.set(0, 0);
    introImage1.cameras = [borderCam];
    introImage1.alpha = 0;
    add(introImage1);

    introImage2 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro2"));
    introImage2.setGraphicSize(gameW, gameH);
    introImage2.updateHitbox();
    introImage2.scrollFactor.set(0, 0);
    introImage2.cameras = [borderCam];
    introImage2.alpha = 0;
    add(introImage2);
    
    introImage3 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro3"));
    introImage3.setGraphicSize(gameW, gameH);
    introImage3.updateHitbox();
    introImage3.scrollFactor.set(0, 0);
    introImage3.cameras = [borderCam];
    introImage3.alpha = 0;
    add(introImage3);
    
    // ---- CREATE BLACK BARS ----
    
    // Left bar
    barLeft = new FlxSprite(0, 0);
    barLeft.makeGraphic(offsetX, screenH, 0xFF000000);
    barLeft.scrollFactor.set(0, 0);
    barLeft.cameras = [borderCam]; // Assign to the new camera
    add(barLeft);
    
    // Right bar
    barRight = new FlxSprite(screenW - offsetX, 0);
    barRight.makeGraphic(offsetX, screenH, 0xFF000000);
    barRight.scrollFactor.set(0, 0);
    barRight.cameras = [borderCam]; // Assign to the new camera
    add(barRight);
    
    // ---- CREATE STROKE INSIDE 4:3 ----
    
    border = new FlxSprite(offsetX, 0);
    border.loadGraphic(Paths.image("stages/satstat/obv"));
    
    if (border.graphic == null)
    {
        trace("❌ Image not found!");
        border.makeGraphic(gameW, gameH, 0xFFFF0000);
    }
    
    // Stretch to 4:3 size
    border.setGraphicSize(gameW, gameH);
    border.updateHitbox();
    border.scrollFactor.set(0, 0);
    border.cameras = [borderCam]; // Assign to the new camera
    add(border);
}

function borderPartial() {
    // Screen dimensions
    var screenW:Int = FlxG.width;   // 1280
    var screenH:Int = FlxG.height;  // 720
    
    // Dimensions for 4:3 (height 720, width 960)
    var gameW:Int = 960;
    var gameH:Int = 720;
    var offsetX:Int = (screenW - gameW) / 2; // 160 pixels of black bars on the sides
    
    // ---- CREATE CAMERA FOR THE BORDER ----
    borderCam = new FlxCamera(0, 0, screenW, screenH);
    borderCam.bgColor = 0x00000000; // Transparent background
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;
    
    // Add camera to the camera list (above all others)
    FlxG.cameras.add(borderCam, false);

    // ---- ADD IMAGES ----
    introImage1 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro1"));
    introImage1.setGraphicSize(gameW, gameH);
    introImage1.updateHitbox();
    introImage1.scrollFactor.set(0, 0);
    introImage1.cameras = [borderCam];
    introImage1.alpha = 0;
    add(introImage1);

    introImage2 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro2"));
    introImage2.setGraphicSize(gameW, gameH);
    introImage2.updateHitbox();
    introImage2.scrollFactor.set(0, 0);
    introImage2.cameras = [borderCam];
    introImage2.alpha = 0;
    add(introImage2);
    
    introImage3 = new FlxSprite(offsetX, 0).loadGraphic(Paths.image("stages/satstat/intro3"));
    introImage3.setGraphicSize(gameW, gameH);
    introImage3.updateHitbox();
    introImage3.scrollFactor.set(0, 0);
    introImage3.cameras = [borderCam];
    introImage3.alpha = 0;
    add(introImage3);
    
    // ---- CREATE BLACK BARS ----
    
    // Left bar
    barLeft = new FlxSprite(0, 0);
    barLeft.makeGraphic(offsetX, screenH, 0xFF000000);
    barLeft.scrollFactor.set(0, 0);
    barLeft.cameras = [borderCam]; // Assign to the new camera
    add(barLeft);
    
    // Right bar
    barRight = new FlxSprite(screenW - offsetX, 0);
    barRight.makeGraphic(offsetX, screenH, 0xFF000000);
    barRight.scrollFactor.set(0, 0);
    barRight.cameras = [borderCam]; // Assign to the new camera
    add(barRight);
}

function applyShaderToBorderCam() {
    if (glitchShader == null || borderCam == null) return;

    // Create the filter wrapper for the camera
    cameraFilter = new ShaderFilter(glitchShader);
    
    // Assign the filter to the camera's filters array
    borderCam.filters = [cameraFilter];
    
    shaderActive = true;
}

function removeShaderFromBorderCam() {
    borderCam.filters.remove(cameraFilter);
        if (borderCam.filters.length == 0) {
            borderCam.filters = null;
        }
    shaderActive = false;
}