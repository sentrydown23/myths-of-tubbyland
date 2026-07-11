import hxvlc.flixel.FlxVideoSprite;

var camSwing:Bool = false;
var swingTime:Float = 0;
var swingSpeed:Float = 0.8;
var swingAmount:Float = 1;

var swingEnabled:Bool = false;
var progress:Float = 1;
var duration:Float = 0;

var swingEnabled:Bool = false;
var currentAngle:Float = 0;
var targetAngle:Float = 0;
public var newHealthBarBG:FunkinSprite;

function postCreate()
{
    newHealthBarBG = new FunkinSprite(0, FlxG.height == 720 ? 612 : 655);
    newHealthBarBG.loadGraphic(Paths.image("game/healthbar"));
    insert(members.indexOf(healthBar) + 1, newHealthBarBG).screenCenter(FlxAxes.X);
    newHealthBarBG.camera = camHUD;
    newHealthBarBG.antialiasing = Options.antialiasing;
    remove(healthBarBG.destroy());
    healthBar.scale.set(0.95, 0.95);
    healthBar.y -= 40;

    newHealthBarBG.alpha = 0;
    healthBar.alpha = 0;
    scoreTxt.alpha = 0;
    accuracyTxt.alpha = 0;
    missesTxt.alpha = 0;
    iconP1.alpha = 0;
    iconP2.alpha = 0;
    defaultDisplayRating = false;
    defaultDisplayCombo = false;
    minDigitDisplay = -1;
    cpuStrums.visible = false;
    playerStrums.visible = false;
    

    if (FlxG.save.data.tinkymeme == true){
            // Initialize Video using FlxVideoSprite
    video = new FlxVideoSprite(0, 0);
    video.antialiasing = true;
    video.cameras = [camHUD]; 
    video.visible = false;
    
    // Set up scaling to fill the screen
    video.bitmap.onFormatSetup.add(function():Void
    {
        if (video.bitmap != null && video.bitmap.bitmapData != null)
        {
            // Forces the video to stretch to the screen dimensions
            video.setGraphicSize(FlxG.width, FlxG.height);
            video.updateHitbox();
            video.screenCenter();
        }
    });

    insert(0, video);
    }
}


function beatHit(_)
{
    switch(_)
    {
        case 5:
            playerStrums.visible = true;
            snapStrums(0);
        case 15:
            fadeStrums(1, 0.5);
        case 48:
            camswingon();
            tweenTo(healthBar, {alpha: 1.0}, 2);
            tweenTo(newHealthBarBG, {alpha: 1.0}, 2);
            tweenTo(iconP1, {alpha: 1.0}, 2);
        case 78:
            fadeStrums(0, 0.5);
            tweenTo(healthBar, {alpha: 0}, 0.5);
            tweenTo(newHealthBarBG, {alpha: 0}, 0.5);
            tweenTo(iconP1, {alpha: 0}, 0.5);
        case 80:
            camswingoff();
        case 84:
            tweenTo(healthBar, {alpha: 1.0}, 2);
            tweenTo(newHealthBarBG, {alpha: 1.0}, 2);
            tweenTo(iconP1, {alpha: 1.0}, 2);
            tweenTo(iconP2, {alpha: 1.0}, 2);
            tweenTo(scoreTxt, {alpha: 1.0}, 2);
            tweenTo(missesTxt, {alpha: 1.0}, 2);
            fadeStrums(1.0, 0.5);
        case 151:
            tweenTo(healthBar, {alpha: 0}, 1);
            tweenTo(newHealthBarBG, {alpha: 0}, 1);
            tweenTo(iconP1, {alpha: 0}, 1);
            tweenTo(iconP2, {alpha: 0}, 1);
            tweenTo(scoreTxt, {alpha: 0}, 1);
            tweenTo(missesTxt, {alpha: 0}, 1);
        case 152: 
            fadeStrums(0, 0.01);
        case 166:
            fadeStrums(1.0, 0.5);
        case 184:
            tweenTo(healthBar, {alpha: 1.0}, 2);
            tweenTo(newHealthBarBG, {alpha: 1.0}, 2);
            tweenTo(iconP1, {alpha: 1.0}, 2);
            tweenTo(iconP2, {alpha: 1.0}, 2);
            tweenTo(scoreTxt, {alpha: 1.0}, 2);
            tweenTo(missesTxt, {alpha: 1.0}, 2);
        case 213:
            tweenTo(healthBar, {alpha: 0}, 1);
            tweenTo(newHealthBarBG, {alpha: 0}, 1);
            tweenTo(iconP1, {alpha: 0}, 1);
            tweenTo(iconP2, {alpha: 0}, 1);
            tweenTo(scoreTxt, {alpha: 0}, 1);
            tweenTo(missesTxt, {alpha: 0}, 1);
        case 216:
            charswingon();
            fadeStrums(0, 0.01);
            if (FlxG.save.data.tinkymeme == true && video != null) {
                video.visible = true;
                if (video.load(Paths.video("tinkybustingafuckingmove"))) {
                    new FlxTimer().start(0.001, (_) -> {
                        video.play();
                        video.volume = 0;
                    });
                }
            }
        case 224:
            fadeStrums(1.0, 0.01);
            healthBar.alpha = 1;
            newHealthBarBG.alpha = 1;
            iconP2.alpha = 1;
            iconP1.alpha = 1;
        case 232:
            fadeStrums(0, 0.01);
            healthBar.alpha = 0;
            newHealthBarBG.alpha = 0;
            iconP2.alpha = 0;
            iconP1.alpha = 0;
        case 238:
            fadeStrums(1.0, 1);
            healthBar.alpha = 1;
            newHealthBarBG.alpha = 1;
            iconP2.alpha = 1;
            iconP1.alpha = 1;
        case 246:
            tweenTo(iconP2, {alpha: 0}, 2);
        case 248:
            charswingoff();
            camswingon();
            if (FlxG.save.data.tinkymeme == true && video != null) {
                video.visible = false;
                video.stop();
            }
        case 278:
            fadeStrums(0, 0.5);
        case 280:
            camswingoff();
            healthBar.alpha = 0;
            newHealthBarBG.alpha = 0;
            iconP2.alpha = 0;
            iconP1.alpha = 0;
        case 294:
            fadeStrums(1.0, 1);
        case 312:
            fadeStrums(0, 0.01);
    }
    
    if (swingEnabled) {
        targetAngle = (targetAngle == 18) ? -18 : 18;
        currentAngle = targetAngle;
    }
}

function stepHit(_) {
    switch(_) {
        case 605:
        curCameraTarget = -1; 
    }
}

function charswingon() {
    swingEnabled = true;
}

function charswingoff() { 
    swingEnabled = false; 
    currentAngle = 0;
    camGame.angle = 0;
}

function camswingon() {
    camSwing = true;
}

function camswingoff() {
    camSwing = false;
    camGame.angle = 0;
}

function lockCamera() {
    camGame.follow(null); 
}

function fadeStrums(targetAlpha:Float, duration:Float) {
    playerStrums.forEach(function(strum) {
        FlxTween.globalManager.completeTweensOf(strum);
        FlxTween.tween(strum, {alpha: targetAlpha}, duration);
    });
}

function snapStrums(targetAlpha:Float) {
    playerStrums.forEach(function(strum)
        strum.alpha = targetAlpha
);
}

function update(elapsed:Float) {
    if (camSwing) {
        swingTime += elapsed * swingSpeed;
        camGame.angle = Math.sin(swingTime) * swingAmount;
    }

if (swingEnabled) {
        currentAngle *= 0.95; 
        camGame.angle = currentAngle;
    }
}

function tweenTo(object:Dynamic, values:Dynamic, duration:Float) {
    if (object != null) {
        // Automatically wipes out any active tweens on this object engine-wide
        FlxTween.globalManager.cancelTweensOf(object);
        return FlxTween.tween(object, values, duration);
    }
    return null;
}