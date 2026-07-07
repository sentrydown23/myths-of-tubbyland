import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import funkin.game.PlayState;

var custardCounter:FlxText;
var deathChanceText:FlxText; // New text object
var custardsCollected:Int = 0;
var deathChance:Float = 1.0; 

var fadeTimer:FlxTimer = new FlxTimer();
var gameoverCustard:String = "data/scripts/gameovers/gameoverNPnoCustard";

function postCreate() {
    switch(FlxG.save.data.borderToggle) {
        case "off":
            borderOFF();
        case "on":
            borderON();
        case "partial":
            borderPartial();
    }

    // 2. Death Chance Text
    // Y: healthBar.y - 100 (Moves it higher)
    // X: Centering math: (healthBar X + half of healthBar width) - (half of text width)
    deathChanceText = new FlxText(0, healthBar.y - 100, 0, "Chances of death: 100%", 48);
    setupText(deathChanceText);
    
    // Calculate center relative to health bar
    // We do this after setting the text so the width is accurate
    deathChanceText.x = healthBar.x + (healthBar.width / 2) - (deathChanceText.width / 2);
    
    add(deathChanceText);
}

// Helper to keep formatting identical
function setupText(txt:FlxText) {
    txt.setFormat(Paths.font("LD Slender Regular.ttf"), 48, 0xFFFFFFFF, "left");
    txt.cameras = [camHUD];
    txt.scrollFactor.set(0, 0);
    txt.alpha = 0;
}

function onNoteHit(e) {
    if(e.noteType == "custard") {
        custardsCollected += 1;
        deathChance -= 0.1;
        if (deathChance < 0) deathChance = 0;
        
        // Update both texts
        custardCounter.text = "Custards Collected: " + custardsCollected + "/10";
        // Convert deathChance (e.g., 0.9) to percent (e.g., 90)
        deathChanceText.text = "Chances of death: " + Math.round(deathChance * 100) + "%";
        
        // Show both
        custardCounter.alpha = 1;
        deathChanceText.alpha = 1;
        
        // Reset timer
        fadeTimer.cancel(); 
        fadeTimer.start(3.0, function(tmr) {
            FlxTween.tween(custardCounter, {alpha: 0}, 1.0);
            FlxTween.tween(deathChanceText, {alpha: 0}, 1.0);
        });
    }
}

function onPlayerMiss(e) {
    if(e.noteType == "custard") {
        e.cancel(true);
        FlxG.camera.flash(0xFFFF0000, 0.3);
        e.note.kill();
        e.note.destroy();
    }
}

function beatHit(curBeat:Int) {
    if (curBeat == 312) {
        // Roll the dice based on the current accumulated deathChance
        var roll = FlxG.random.float(0, 1);
        
        trace("Current Death Chance: " + (deathChance * 100) + "% | Roll: " + (roll * 100) + "%");
        
        if (roll < deathChance) {
            trace("Death event triggered!");
            GameOverSubstate.script = gameoverCustard;
            health = 0;
        }
    }
}

function borderOFF() {
    custardCounter = new FlxText(20, 20, 0, "Custards Collected: 0/10", 48);
    setupText(custardCounter);
    add(custardCounter);
}

function borderPartial() {
    custardCounter = new FlxText(((FlxG.width - 960) / 2) + 20, 20, 0, "Custards Collected: 0/10", 48);
    setupText(custardCounter);
    add(custardCounter);
}

function borderON() {
    custardCounter = new FlxText(((FlxG.width - 390) / 2) + 20, healthBar.y - 150, 0, "Custards Collected: 0/10", 48);
    setupText(custardCounter);
    add(custardCounter);
}