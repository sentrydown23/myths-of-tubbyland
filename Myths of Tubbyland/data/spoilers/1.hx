import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import openfl.system.System;
import sys.io.File;
import Sys;
import funkin.game.PlayState;

var bg:FlxSprite;
var mainText:FlxText;
var scatterBoxes:Array<FlxText> = [];

var isShaking:Bool = false;
var shakeIntensity:Float = 4.0;
var isViolentTeleporting:Bool = false;

var teleportTimer:Float = 0.0;
var teleportSpeed:Float = 0.15;

function create(event) {
    event.cancel();
    bg = new FlxSprite(0, 0);
    bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    bg.scrollFactor.set(0, 0);
    add(bg);

    mainText = new FlxText(0, 0, FlxG.width, "", 48);
    mainText.setFormat(Paths.font("VCR Mono.ttf"), 48, 0xFFFFFFFF, "center");
    mainText.scrollFactor.set(0, 0);
    mainText.visible = false;
    add(mainText);

    FlxG.sound.playMusic(Paths.music("secret/1"), 1.0, false);

    new FlxTimer().start(0.2, function(tmr:FlxTimer) {
        showText("What are you doing?", true);
        
        new FlxTimer().start(3.0, function(tmr:FlxTimer) {
            hideMainText();
            startScatterBoxes();
            
            new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                clearScatterBoxes();
                
                new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                    showText("Perhaps you think you were clever?", true);
                    
                    new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                        hideMainText();
                        
                        new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                            showText("If you want to dig, take this as a souvenir", true);
                            
                            new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                                hideMainText();
                                
                                new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                    showText("If it can't be helped. . .", true);
                                    
                                    new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                                        hideMainText();
                                        
                                        new FlxTimer().start(3.0, function(tmr:FlxTimer) {
                                            showText("Check your Desktop", false);
                                            dropSouvenir();
                                            
                                            new FlxTimer().start(5.0, function(tmr:FlxTimer) {
                                                FlxG.sound.play(Paths.sound("static"), 5.0); 
                                                
                                                new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                                    System.exit(0);
                                                });
                                            });
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
}

function update(elapsed:Float) {
    if (isShaking && mainText != null && mainText.visible) {
        mainText.x = FlxG.random.float(-shakeIntensity, shakeIntensity);
        mainText.y = ((FlxG.height / 2) - (mainText.height / 2)) + FlxG.random.float(-shakeIntensity, shakeIntensity);
    }

    if (isViolentTeleporting) {
        teleportTimer += elapsed;
        if (teleportTimer >= teleportSpeed) {
            teleportTimer = 0.0;
            for (box in scatterBoxes) {
                box.x = FlxG.random.float(50, FlxG.width - box.width - 50);
                box.y = FlxG.random.float(50, FlxG.height - box.height - 50);
            }
        }
    }
}

function showText(content:String, shake:Bool) {
    mainText.text = content;
    mainText.visible = true;
    isShaking = shake;
    if (!shake) {
        mainText.x = 0;
        mainText.y = (FlxG.height / 2) - (mainText.height / 2);
    }
}

function hideMainText() {
    mainText.visible = false;
    isShaking = false;
}

function startScatterBoxes() {
    isViolentTeleporting = true;
    teleportTimer = 0.0;
    for (i in 0...25) {
        var box = new FlxText(0, 0, 0, "You were supposed to collect them", 32);
        box.setFormat(Paths.font("VCR Mono.ttf"), 32, 0xFFFFFFFF, "left");
        box.scrollFactor.set(0, 0);
        add(box);
        scatterBoxes.push(box);
    }
}

function clearScatterBoxes() {
    isViolentTeleporting = false;
    for (box in scatterBoxes) {
        if (box != null) {
            box.destroy();
            remove(box);
        }
    }
    scatterBoxes = [];
}

function dropSouvenir() {
    // Pulls the "C:\Users\Username" path automatically
    var userProfile:String = Sys.getEnv("USERPROFILE"); 
    
    if (userProfile != null) {
        var path:String = userProfile + "\\Desktop\\souvenir.txt";
        var message:String = "9190257\n\nInTheBeginning, TypeTheseNumbers";
        File.saveContent(path, message);
    }
}