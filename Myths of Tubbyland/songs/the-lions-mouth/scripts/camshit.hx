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
            FlxTween.tween(camGame, {alpha: 1}, 0.5);
            FlxTween.tween(camHUD, {alpha: 1}, 0.5);

        case 128:
            FlxTween.tween(camHUD, {alpha: 0}, 1.0);

        case 135:
            healthBar.alpha = 1;
            newHealthBarBG.alpha = 1;
            scoreTxt.alpha = 1;
            iconP1.alpha = 1;
            iconP2.alpha = 1;
        
        case 136:
            FlxTween.cancelTweensOf(camHUD);
            FlxTween.tween(camHUD, {alpha: 1}, 0.2);

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
            FlxTween.tween(iconP2, {alpha: 0}, 1.0);

        case 532:
            FlxTween.tween(camGame, {alpha: 0}, 1);
            FlxTween.tween(iconP1, {alpha: 0}, 1.0);

        case 536:
            FlxTween.tween(healthBar, {alpha: 0}, 1.0);
            FlxTween.tween(newHealthBarBG, {alpha: 0}, 1.0);
            FlxTween.tween(scoreTxt, {alpha: 0}, 1.0);

        case 552: 
            camswingoff();

        case 564:
            FlxTween.tween(camHUD, {alpha: 0}, 1.0);

        case 567:
            FlxTween.tween(camGame, {alpha: 1}, 1);

        case 580:
            FlxTween.tween(camGame, {alpha: 0}, 1);
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