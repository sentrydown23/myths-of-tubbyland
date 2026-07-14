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

function create() {
    FlxG.sound.playMusic(Paths.music("mainmenu"), 0.7, true);

    letterGroup = new FlxTypedGroup<FlxText>();
    add(letterGroup);

    var text:String = "MYTHS OF TUBBYLAND";
    var spacing:Int = 40;
    var startX:Float = (FlxG.width - (text.length * spacing)) / 2;

    for (i in 0...text.length) {
        var char = text.charAt(i);
        if (char == " ") continue;

        var letter = new FlxText(startX + (i * spacing), FlxG.height / 2, 0, char, 64);
        letter.setFormat(Paths.font("LD Slender Regular.ttf"), 64, 0xFFFFFFFF, "center");
        
        letter.borderStyle = FlxTextBorderStyle.OUTLINE;
        letter.borderColor = 0xFF000000;
        letter.borderSize = 3;
        
        letter.alpha = 0;
        letterGroup.add(letter);

        FlxTween.tween(letter, {alpha: 1}, 3.0, {startDelay: i * 0.2});
    }

    new FlxTimer().start(6.0, function(tmr) {
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
    
    letterGroup.forEach(function(letter) {
        letter.y = (FlxG.height / 2) + (Math.sin(timer * 2 + (letter.x * 0.05)) * 10);
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

    for (letter in letterGroup.members) {
        if (letter != null) {
            FlxTween.tween(letter, {alpha: 0}, 0.6);
        }
    }

    new FlxTimer().start(0.8, function(tmr) {
        MusicBeatTransition.script = 'data/scripts/whiteout';
        FlxG.switchState(new ModState("MyCustomMenu"));
    });
}