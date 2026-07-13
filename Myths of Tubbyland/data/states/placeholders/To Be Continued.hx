import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import funkin.backend.MusicBeatTransition;

var bgSprite:FlxSprite;
var textDisplay:FlxText;

var targetString:String = "To be Continued ";
var currentString:String = "";

var isTyping:Bool = true;
var glitchChars:String = "X#%&@?$!01,./(){}";

var timeTracker:Float = 0;
var glitchFrequency:Float = 0.04; // How fast the letter distortion cycles
var glitchTimer:Float = 0;

// Track the persistent glitch background audio object
var glitchAudio:FlxSound;

function create() {
    FlxG.mouse.visible = false;

    // Force global background music volume to 0 immediately
    if (FlxG.sound.music != null) {
        FlxG.sound.music.volume = 0;
    }

    // Load and play the state audio
    glitchAudio = FlxG.sound.load(Paths.sound("comingsoon"));
    if (glitchAudio != null) {
        glitchAudio.looped = true;
        glitchAudio.volume = 1.0;
        glitchAudio.play();
    }

    // 1. Initialize the background asset container
    bgSprite = new FlxSprite(0, 0);
    bgSprite.loadGraphic(Paths.image("menus/story/promo"));
    bgSprite.setGraphicSize(FlxG.width, FlxG.height);
    bgSprite.updateHitbox();
    bgSprite.screenCenter();
    bgSprite.scrollFactor.set(0, 0);
    bgSprite.alpha = 0; // Start completely invisible
    add(bgSprite);

    // 2. Initialize text layers on top of the background
    textDisplay = new FlxText(0, 0, FlxG.width, "");
    textDisplay.setFormat(Paths.font("VCR Mono.ttf"), 64, 0xFFFFFFFF, "center");
    textDisplay.screenCenter();
    add(textDisplay);

    // Fade the background alpha in to 1.0 over exactly 5.0 seconds
    FlxTween.tween(bgSprite, {alpha: 1.0}, 5.0);

    // Timeline control: Type out the phrase step-by-step over exactly 5.0 seconds
    FlxTween.num(0, targetString.length, 5.0, {
        onUpdate: function(twn:FlxTween) {
            var charCount:Int = Math.floor(twn.value);
            currentString = targetString.substring(0, charCount);
        },
        onComplete: function(twn:FlxTween) {
            // Wait an additional 5 seconds while it keeps glitching out, then swap states
            new FlxTimer().start(5.0, function(tmr:FlxTimer) {
                // Abruptly cut the custom audio loop instantly before the transition
                if (glitchAudio != null) {
                    glitchAudio.stop();
                }

                // Restore music volume to 0.7 right before leaving
                if (FlxG.sound.music != null) {
                    FlxG.sound.music.volume = 0.7;
                }
                
                MusicBeatTransition.script = 'data/scripts/blackout';
                FlxG.switchState(new ModState("MyCustomMenu"));
            });
        }
    });
}

function update(elapsed:Float) {
    if (!isTyping) return;

    glitchTimer += elapsed;
    if (glitchTimer >= glitchFrequency) {
        glitchTimer = 0;
        
        var corruptedOutput:String = "";
        
        var displaySource:String = (currentString.length >= targetString.length) ? targetString : currentString;
        
        for (i in 0...displaySource.length) {
            var originalChar:String = displaySource.charAt(i);
            
            if (originalChar == " ") {
                corruptedOutput += " ";
                continue;
            }

            if (FlxG.random.bool(35)) {
                var randomGlitchIndex = FlxG.random.int(0, glitchChars.length - 1);
                corruptedOutput += glitchChars.charAt(randomGlitchIndex);
            } else {
                corruptedOutput += originalChar;
            }
        }
        
        textDisplay.text = corruptedOutput;
    }
}