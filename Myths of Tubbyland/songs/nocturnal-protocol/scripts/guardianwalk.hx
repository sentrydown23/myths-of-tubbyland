import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTweenType;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

var introfadeTimer:FlxTimer = new FlxTimer();
var bpm:Float = 95;
// Helper variable to keep the code clean
var playerChar = strumLines.members[1].characters[1];

function postCreate() {
    // Initial setup
    switch(FlxG.save.data.borderToggle) {
        case "off":
            borderOFF();
        case "on":
            borderON();
        case "partial":
            borderPartial();
    }
    playerChar.alpha = 0.001;
    playerChar.scale.set(0.1, 0.1);

    introText.alpha = 1;
        
    introfadeTimer.cancel(); 
    introfadeTimer.start(3.0, function(tmr) {
        FlxTween.tween(introText, {alpha: 0}, 1.0);
    });
}

function beatHit(curBeat:Int) {
    switch (curBeat) {
        case 16:
            // Aura Farm Commence
            var scaleDuration = (60 / bpm) * (80 - 16);
            FlxTween.tween(playerChar.scale, {x: 1, y: 1}, scaleDuration);
            
            FlxTween.tween(playerChar, {alpha: 1}, 6.0);
            
        case 48:
            var duration = (60 / bpm) * (80 - 48);
            FlxTween.tween(camGame, {zoom: 1.25}, duration, {ease: FlxEase.quadInOut});
            

        case 80:
            // HARD RESET literally only helpful for playtesting
            FlxTween.cancelTweensOf(playerChar);
            FlxTween.cancelTweensOf(playerChar.scale);
            FlxTween.cancelTweensOf(camGame);
            
            // Force values to final state
            playerChar.alpha = 1;
            playerChar.scale.set(1, 1);
            camGame.zoom = 1;
    }
}

function borderPartial() {
    introText = new FlxText(((FlxG.width - 960) / 2) + 20, 20, 0, "A helpless victim has entered the Mainland", 48);
    introText.setFormat(Paths.font("LD Slender Regular.ttf"), 48, 0xFFFFFFFF, "left");
    introText.cameras = [camHUD];
    introText.scrollFactor.set(0, 0); // Lock to camera
    introText.alpha = 0; // Start invisible
    add(introText);
}

function borderON() {
    introText = new FlxText(((FlxG.width - 600) / 2) + 20, healthBar.y - 400, 0, "A helpless victim has entered the Mainland", 48);
    introText.setFormat(Paths.font("LD Slender Regular.ttf"), 48, 0xFFFFFFFF, "center");
    introText.cameras = [camHUD];
    introText.scrollFactor.set(0, 0); // Lock to camera
    introText.alpha = 0; // Start invisible
    add(introText);
}

function borderOFF() {
    introText = new FlxText(20, 20, 0, "A helpless victim has entered the Mainland", 48);
    introText.setFormat(Paths.font("LD Slender Regular.ttf"), 48, 0xFFFFFFFF, "left");
    introText.cameras = [camHUD];
    introText.scrollFactor.set(0, 0); // Lock to camera
    introText.alpha = 0; // Start invisible
    add(introText);
}