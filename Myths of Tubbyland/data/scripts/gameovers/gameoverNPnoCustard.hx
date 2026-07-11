import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import funkin.game.PlayState;

var deathImg:FlxSprite;
var deathMusic:FlxSound;
var titleText:FlxText;
var infoText:FlxText;
var hintText:FlxText; // Added hint text object
var canRestart:Bool = false;
var fontName:String = "LD Slender Regular.ttf";

function create(event) {
    event.cancel();

    // Play the death sound effect
    var deathSound:FlxSound = FlxG.sound.play(Paths.sound("gameover/deathNP"));

    // Set up the background image
    deathImg = new FlxSprite(0, 0).loadGraphic(Paths.image("gameover/deathNP"));
    deathImg.setGraphicSize(FlxG.width, FlxG.height);
    deathImg.updateHitbox();
    deathImg.scrollFactor.set(0, 0);
    deathImg.setPosition(0, 0);
    deathImg.alpha = 0;
    add(deathImg);

    // Set up the death title text
    titleText = new FlxText(0, FlxG.height * 0.2, FlxG.width, "YOU FAILED TO:", 72);
    titleText.setFormat(Paths.font(fontName), 72, 0xFFFFFFFF, "center");
    titleText.scrollFactor.set(0, 0);
    titleText.alpha = 0;
    add(titleText);

    // Set up the death info text
    infoText = new FlxText(0, FlxG.height * 0.45, FlxG.width, "COLLECT ALL THE CUSTARDS", 48);
    infoText.setFormat(Paths.font(fontName), 48, 0xFFFF46A2, "center");
    infoText.scrollFactor.set(0, 0);
    infoText.alpha = 0;
    add(infoText);

    // Set up the hint text below the info text
    hintText = new FlxText(0, FlxG.height - 50, FlxG.width, "Every collected Custard will reduce your chances of death by 10%!", 24);
    hintText.setFormat(Paths.font(fontName), 24, 0xFFCCCCCC, "center");
    hintText.scrollFactor.set(0, 0);
    hintText.alpha = 0;
    add(hintText);

    // Handle sequence after initial death sound completion
    deathSound.onComplete = function() {
        // Fade in UI elements
        FlxTween.tween(deathImg, {alpha: 1}, 1.5);
        FlxTween.tween(titleText, {alpha: 1}, 1.5);
        FlxTween.tween(infoText, {alpha: 1}, 1.5);
        FlxTween.tween(hintText, {alpha: 1}, 1.5);

        deathMusic = FlxG.sound.play(Paths.music("gameover/death"), 0);
        deathMusic.fadeIn(1.5, 0, 1);

        new FlxTimer().start(1.5, function(tmr) {
            canRestart = true;
            startBreathing();
        });
    };
}

function startBreaking() { // Maintained existing naming structure
    startBreathing();
}

function startBreathing() {
    // Apply pulsing effect to UI elements
    var tweenOptions = {type: FlxTween.PINGPONG, ease: FlxEase.sineInOut};

    FlxTween.tween(deathImg, {alpha: 0.7}, 2.0, tweenOptions);
    FlxTween.tween(titleText, {alpha: 0.7}, 2.0, tweenOptions);
    FlxTween.tween(infoText, {alpha: 0.7}, 2.0, tweenOptions);
    FlxTween.tween(hintText, {alpha: 0.7}, 2.0, tweenOptions);
}

function update(elapsed:Float) {
    // Restart level on Enter key
    if (canRestart && FlxG.keys.justPressed.ENTER) {
        canRestart = false;

        // Stop animations and transition to PlayState
        FlxTween.cancelTweensOf(deathImg);
        FlxTween.cancelTweensOf(titleText);
        FlxTween.cancelTweensOf(infoText);
        FlxTween.cancelTweensOf(hintText);

        FlxTween.tween(deathImg, {alpha: 0}, 0.5);
        FlxTween.tween(titleText, {alpha: 0}, 0.5);
        FlxTween.tween(infoText, {alpha: 0}, 0.5);
        FlxTween.tween(hintText, {alpha: 0}, 0.5);

        deathMusic.fadeOut(0.5, 0, function(t) {
            FlxG.switchState(new PlayState());
        });
    }
    // Return to freeplay menu on Escape key
    else if (canRestart && FlxG.keys.justPressed.ESCAPE) {
        canRestart = false;

        // Stop animations and transition to VinylFreeplayState
        FlxTween.cancelTweensOf(deathImg);
        FlxTween.cancelTweensOf(titleText);
        FlxTween.cancelTweensOf(infoText);
        FlxTween.cancelTweensOf(hintText);

        FlxTween.tween(deathImg, {alpha: 0}, 0.5);
        FlxTween.tween(titleText, {alpha: 0}, 0.5);
        FlxTween.tween(infoText, {alpha: 0}, 0.5);
        FlxTween.tween(hintText, {alpha: 0}, 0.5);

        deathMusic.fadeOut(0.5, 0, function(t) {
            FlxG.switchState(new ModState("VinylFreeplayState"));
        });
    }
}