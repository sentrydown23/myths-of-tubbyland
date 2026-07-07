import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

var flashSprite:FlxSprite;

function create() {
    new FlxTimer().start(0.1, function(tmr:FlxTimer) {
    flashSprite = new FlxSprite(0, 0);
    flashSprite.loadGraphic(Paths.image("stages/forest/dropimages/image3"));
    // Force the sprite to fill the entire screen
    flashSprite.setGraphicSize(FlxG.width, FlxG.height);
    flashSprite.updateHitbox(); 
    
    flashSprite.cameras = [camHUD]; 
    flashSprite.alpha = 0;
    add(flashSprite);
    });
}

function onNoteHit(event) {
    if (event.noteType == "Screamer" && !event.player) {
        // Cancel the existing tween so the alpha doesn't reset mid-fade
        FlxTween.cancelTweensOf(flashSprite);
        
        // Reset the sprite to full opacity immediately
        flashSprite.alpha = 1;
        
        // Start the new fade-out sequence
        FlxTween.tween(flashSprite, {alpha: 0}, 0.9, {
            startDelay: 0.05, 
            ease: FlxEase.expoOut
        });
    }
}