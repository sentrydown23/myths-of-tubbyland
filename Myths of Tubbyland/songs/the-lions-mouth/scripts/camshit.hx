var swaying:Bool = false;
var swayDir:Int = 1;

var camSwing:Bool = false;
var swingTime:Float = 0;
var swingSpeed:Float = 1;
var swingAmount:Float = 2;

var gameTween:FlxTween;
var hudTween:FlxTween;

function postCreate()
{
    newHealthBarBG = new FunkinSprite(0, FlxG.height == 720 ? 612 : 655);
    newHealthBarBG.loadGraphic(Paths.image("game/tlmbar"));
    insert(members.indexOf(healthBar) + 1, newHealthBarBG).screenCenter(FlxAxes.X);
    newHealthBarBG.camera = camHUD;
    newHealthBarBG.antialiasing = Options.antialiasing;
    remove(healthBarBG.destroy());

    healthBar.scale.set(0.95, 0.95);
    healthBar.y -= 40;
    camGame.alpha = 0;
    camHUD.alpha = 0;
    healthBar.alpha = 0;
    newHealthBarBG.alpha = 0;
    scoreTxt.alpha = 0;
    accuracyTxt.alpha = 0;
    missesTxt.alpha = 0;
    iconP1.alpha = 0;
    iconP2.alpha = 0;
}

function beatHit(_)
{
    switch(_)
    {
        case 63: 
            tweenTo(camGame, {alpha: 1}, 0.5);
            tweenTo(camHUD, {alpha: 1}, 0.5);

        case 128:
            tweenTo(camHUD, {alpha: 0}, 1.0);

        case 135:
            healthBar.alpha = 1;
            newHealthBarBG.alpha = 1;
            scoreTxt.alpha = 1;
            iconP1.alpha = 1;
            iconP2.alpha = 1;
        
        case 136:
            tweenTo(camHUD, {alpha: 1}, 0.2);

        case 264:
            camswingon();

        case 327:
            camswingoff();

        case 360:
            swaying = true;
            swayDir = 1;
            swayCam();

        case 388:
            stopSway();

        // case 392: — removed, HUD is not hidden

        case 422:
            camGame.alpha = 0;

        case 424:
            camGame.alpha = 1;

        case 456: 
            camHUD.alpha = 0;

        case 464:
            var swingAmount = 3;
            var swingSpeed = 2;
            camswingon();
            camHUD.alpha = 1;

        case 528:
            tweenTo(iconP2, {alpha: 0}, 1.0);

        case 532:
            tweenTo(camGame, {alpha: 0}, 1);
            tweenTo(iconP1, {alpha: 0}, 1.0);

        case 536:
            tweenTo(healthBar, {alpha: 0}, 1.0);
            tweenTo(newHealthBarBG, {alpha: 0}, 1.0);
            tweenTo(scoreTxt, {alpha: 0}, 1.0);

        case 552: 
            camswingoff();

case 557: // UP NOTE (Index 2) - Natural vertical curve and smooth plunge
    var strum = playerStrums.members[2];
    var startY = strum.y;
    // Smooth, gradual transparency fade that finishes exactly with the movement
    FlxTween.tween(strum, {alpha: 0}, 0.8, {ease: FlxEase.sineOut});
    
    FlxTween.num(0, 1, 0.8, {ease: FlxEase.circIn}, function(v:Float) {
        // v creates an incredibly smooth parabolic arc (pops up 40px, then drops)
        strum.y = startY - (40 * Math.sin(v * Math.PI / 2)) + (900 * v * v);
        strum.angle = v * 35;
    });

case 558: // RIGHT NOTE (Index 3) - Smooth outward diagonal arc
    var strum = playerStrums.members[3];
    var startX = strum.x;
    var startY = strum.y;
    FlxTween.tween(strum, {alpha: 0}, 0.8, {ease: FlxEase.sineOut});
    
    FlxTween.num(0, 1, 0.8, {ease: FlxEase.circIn}, function(v:Float) {
        // Continuous outward movement blended smoothly with an accelerating downward drop
        strum.x = startX + (140 * FlxEase.quadOut(v)); 
        strum.y = startY + (900 * v * v);
        strum.angle = v * 40;
    });

case 560: // LEFT NOTE (Index 0) - Smooth outward diagonal arc
    var strum = playerStrums.members[0];
    var startX = strum.x;
    var startY = strum.y;
    FlxTween.tween(strum, {alpha: 0}, 0.8, {ease: FlxEase.sineOut});
    
    FlxTween.num(0, 1, 0.8, {ease: FlxEase.circIn}, function(v:Float) {
        strum.x = startX - (140 * FlxEase.quadOut(v)); 
        strum.y = startY + (900 * v * v);
        strum.angle = v * -40;
    });

case 564: // DOWN NOTE (Index 1) - Natural vertical curve and smooth plunge
    tweenTo(camHUD, {alpha: 0}, 1.0);
    var strum = playerStrums.members[1];
    var startY = strum.y;
    FlxTween.tween(strum, {alpha: 0}, 0.8, {ease: FlxEase.sineOut});
    
    FlxTween.num(0, 1, 0.8, {ease: FlxEase.circIn}, function(v:Float) {
        strum.y = startY - (40 * Math.sin(v * Math.PI / 2)) + (900 * v * v);
        strum.angle = v * -35;
    });

        case 567:
            tweenTo(camGame, {alpha: 1}, 1);

        case 580:
            tweenTo(camGame, {alpha: 0}, 1);
    }
}

// stepHit is now empty because all alpha control for the HUD has been removed
function stepHit(_)
{
    // Do nothing
}

function swayCam()
{
    if (!swaying) return;

    gameTween = FlxTween.tween(camGame, {angle: 3 * swayDir}, 1, {
        ease: FlxEase.sineInOut
    });

    hudTween = FlxTween.tween(camHUD, {angle: 3 * swayDir}, 1, {
        ease: FlxEase.sineInOut,
        onComplete: function(_)
        {
            if (!swaying) return;
            swayDir *= -1;
            swayCam();
        }
    });
}

function stopSway()
{
    swaying = false;

    if (gameTween != null)
        gameTween.cancel();

    if (hudTween != null)
        hudTween.cancel();

    FlxTween.tween(camGame, {angle: 0}, 0.25, {ease: FlxEase.quadOut});
    FlxTween.tween(camHUD, {angle: 0}, 0.25, {ease: FlxEase.quadOut});
}

function camswingon() {
    camSwing = true;
}

function camswingoff() {
    camSwing = false;
    camGame.angle = 0;
}

function update(elapsed:Float) {
    if (camSwing) {
        swingTime += elapsed * swingSpeed;
        camGame.angle = Math.sin(swingTime) * swingAmount;
    }
}

function tweenTo(object:Dynamic, values:Dynamic, duration:Float) {
    if (object != null) {
        FlxTween.globalManager.cancelTweensOf(object);
        return FlxTween.tween(object, values, duration);
    }
    return null;
}