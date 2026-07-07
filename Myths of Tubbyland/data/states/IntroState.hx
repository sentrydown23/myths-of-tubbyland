import flixel.FlxG;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.backend.MusicBeatTransition;

var letterGroup:FlxTypedGroup<FlxText>;
var canSkip:Bool = true;
var timer:Float = 0;

function create() {
    // Start music
    FlxG.sound.playMusic(Paths.music("mainmenu"), 0.7, true);

    letterGroup = new FlxTypedGroup<FlxText>();
    add(letterGroup);

    var text:String = "MYTHS OF TUBBYLAND";
    // Adjust spacing dynamically based on character count
    var spacing:Int = 40;
    var startX:Float = (FlxG.width - (text.length * spacing)) / 2;

    for (i in 0...text.length) {
        var char = text.charAt(i);
        // Skip rendering spaces, but maintain horizontal offset
        if (char == " ") continue;

        var letter = new FlxText(startX + (i * spacing), FlxG.height / 2, 0, char, 64);
        letter.setFormat(Paths.font("LD Slender Regular.ttf"), 64, 0xFFFFFFFF, "center");
        
        // Add thick outline for bolder effect
        letter.borderStyle = FlxTextBorderStyle.OUTLINE;
        letter.borderColor = 0xFF000000;
        letter.borderSize = 3;
        
        letter.alpha = 0;
        letterGroup.add(letter);

        // Staggered fade-in effect
        FlxTween.tween(letter, {alpha: 1}, 3.0, {startDelay: i * 0.2});
    }

    // Auto-transition timer
    new FlxTimer().start(6.0, function(tmr) {
        finishIntro();
    });
}

function update(elapsed:Float) {
    // Skip intro logic
    if (canSkip && FlxG.keys.justPressed.ENTER) {
        finishIntro();
    }

    timer += elapsed;
    
    // Animate each letter with a wave motion
    letterGroup.forEach(function(letter) {
        // Sine wave offset based on time and position
        letter.y = (FlxG.height / 2) + (Math.sin(timer * 2 + (letter.x * 0.05)) * 10);
    });
}

function finishIntro() {
    if (!canSkip) return;
    canSkip = false;

    // Fade out all letters
    for (letter in letterGroup.members) {
        if (letter != null) {
            FlxTween.tween(letter, {alpha: 0}, 0.6);
        }
    }

    // Switch state after fade completes
    new FlxTimer().start(0.8, function(tmr) {
        MusicBeatTransition.script = 'data/scripts/whiteout';
        FlxG.switchState(new ModState("MyCustomMenu"));
    });
}