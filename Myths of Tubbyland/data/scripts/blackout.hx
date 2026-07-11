import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

function create(event) {
    // Prevent default transition animations
    event.cancel();

    // Handle fade-in when entering a new state
    if (!event.transOut) {
        // Create a white overlay matching the window dimensions
        var whiteSheet = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        whiteSheet.scrollFactor.set(0, 0);

        // Assign to the high-priority overlay camera
        if (transitionCamera != null) {
            whiteSheet.cameras = [transitionCamera];
        }
        add(whiteSheet);

        // Perform a slow fade-out of the white sheet
        FlxTween.tween(whiteSheet, {alpha: 0}, 3.0, {
            onComplete: function(_) {
                // Destroy the overlay once transparent
                finish();
            }
        });
    } else {
        // Skip transition when leaving a state
        finish();
    }
}