import flixel.FlxG;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.backend.MusicBeatTransition;
import openfl.system.System;
import sys.io.File;
import Sys;
import flixel.input.keyboard.FlxKey;
import funkin.backend.utils.DiscordUtil;

var letterGroup:FlxTypedGroup<FlxText>;
var canSkip:Bool = true;
var timer:Float = 0;

var secretCode:Array<String> = ["NINE", "ONE", "NINE", "ZERO", "TWO", "FIVE", "SEVEN"];
var inputIndex:Int = 0;

// Warning Text Elements
var warningLine1:FlxText;
var warningLine2:FlxText;

function create() {
    FlxG.sound.playMusic(Paths.music("mainmenu"), 0.7, true);

    letterGroup = new FlxTypedGroup<FlxText>();
    add(letterGroup);

    var text:String = "MYTHS OF TUBBYLAND";
    var spacing:Int = 40;
    var startX:Float = (FlxG.width - (text.length * spacing)) / 2;

    // 1. Create the Main Floating Title
    for (i in 0...text.length) {
        var char = text.charAt(i);
        if (char == " ") continue;

        var letter = new FlxText(startX + (i * spacing), (FlxG.height / 2) - 80, 0, char, 64);
        letter.setFormat(Paths.font("LD Slender Regular.ttf"), 64, 0xFFFFFFFF, "center");
        
        letter.borderStyle = FlxTextBorderStyle.OUTLINE;
        letter.borderColor = 0xFF000000;
        letter.borderSize = 3;
        
        letter.alpha = 0;
        letterGroup.add(letter);

        FlxTween.tween(letter, {alpha: 1}, 3.0, {startDelay: i * 0.2});
    }

    // 2. Warning Line 1 (Content)
    warningLine1 = new FlxText(0, (FlxG.height / 2) + 60, FlxG.width, "( THIS MOD CONTAINS HEAVY FLASHING LIGHTS AND CHROMATIC EFFECTS )", 20);
    warningLine1.setFormat(Paths.font("LD Slender Regular.ttf"), 20, 0xFFFFFFFF, "center");
    warningLine1.borderStyle = FlxTextBorderStyle.OUTLINE;
    warningLine1.borderColor = 0xFF000000;
    warningLine1.borderSize = 2;
    warningLine1.alpha = 0;
    add(warningLine1);

    // 3. Warning Line 2 (Subtext) - Set to warning yellow so it pops
    warningLine2 = new FlxText(0, (FlxG.height / 2) + 100, FlxG.width, "( NOT SUITABLE FOR PHOTOSENSITIVE INDIVIDUALS )", 20);
    warningLine2.setFormat(Paths.font("LD Slender Regular.ttf"), 20, 0xFFFF3333, "center"); // Soft red/yellow accent
    warningLine2.borderStyle = FlxTextBorderStyle.OUTLINE;
    warningLine2.borderColor = 0xFF000000;
    warningLine2.borderSize = 2;
    warningLine2.alpha = 0;
    add(warningLine2);

    // Fade the warning lines in slightly after the main title starts appearing
    FlxTween.tween(warningLine1, {alpha: 0.8}, 2.5, {startDelay: 1.0});
    FlxTween.tween(warningLine2, {alpha: 0.8}, 2.5, {startDelay: 1.5});

    new FlxTimer().start(7.0, function(tmr) {
        finishIntro();
    });

    DiscordUtil.changePresenceAdvanced({
        largeImageKey: "coverart",       
    });
}

function update(elapsed:Float) {
    if (canSkip) {
        if (FlxG.keys.justPressed.ENTER) {
            finishIntro();
        } else {
            checkSecretCode();
        }
    }

    timer += elapsed;
    
    // Slower, gentler floating calculations
    // (timer * 0.75) slows down the vertical speed significantly compared to the original
    letterGroup.forEach(function(letter) {
        letter.y = ((FlxG.height / 2) - 80) + (Math.sin(timer * 1.25 + (letter.x * 0.05)) * 10);
    });
}

function checkSecretCode() {
    var numbers:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    
    for (key in numbers) {
        if (FlxG.keys.anyJustPressed([FlxKey.fromString(key)])) {
            if (key == secretCode[inputIndex]) {
                inputIndex++;
                if (inputIndex >= secretCode.length) {
                    triggerSecretExit();
                }
            } else {
                if (key == secretCode[0]) {
                    inputIndex = 1;
                } else {
                    inputIndex = 0;
                }
            }
            break;
        }
    }
}

function triggerSecretExit() {
    canSkip = false;
    
    var userProfile:String = Sys.getEnv("USERPROFILE");
    if (userProfile != null) {
        var path:String = userProfile + "\\Desktop\\WIP AHEAD.txt";
        var message:String = "Perhaps we will settle this later. . .";
        File.saveContent(path, message);
    }
    
    System.exit(0);
}

function finishIntro() {
    if (!canSkip) return;
    canSkip = false;

    // Fade the floating letters out
    for (letter in letterGroup.members) {
        if (letter != null) {
            FlxTween.tween(letter, {alpha: 0}, 0.6);
        }
    }

    // Fade the warning lines out cleanly
    if (warningLine1 != null) FlxTween.tween(warningLine1, {alpha: 0}, 0.6);
    if (warningLine2 != null) FlxTween.tween(warningLine2, {alpha: 0}, 0.6);

    new FlxTimer().start(0.8, function(tmr) {
        MusicBeatTransition.script = 'data/scripts/blackout';
        FlxG.switchState(new ModState("MyCustomMenu"));
    });
}