import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import funkin.game.PlayState;

var custardCounter:FlxText;
var deathChanceText:FlxText;
var custardsCollected:Int = 0;
var deathChance:Float = 1.0; 
var permanentDeathChance:Float = 0.0;

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
    deathChanceText = new FlxText(0, healthBar.y - 100, 0, "Chances of death: 100%", 48);
    setupText(deathChanceText);
    
    // Calculate center relative to health bar
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
        if(FlxG.save.data.specialHitSounds == true) 
        FlxG.sound.play(Paths.sound("custardhit"), 5.0);
        custardsCollected += 1;
        
        // Each hit reduces the risk by 20% (0.2) instead of 10%
        deathChance -= 0.2;
        if (deathChance < 0) deathChance = 0;
        
        custardCounter.color = 0xFFFFFFFF;
        deathChanceText.color = 0xFFFFFFFF;
        custardCounter.text = "Custards Collected: " + custardsCollected + "/5"; // Scaled to /5
        
        // Show current chance. Only show (+X) if penalty exists
        var displayPercent = Math.round(deathChance * 100);
        var penaltyPercent = Math.round(permanentDeathChance * 100);
        
        deathChanceText.text = "Chances of death: " + displayPercent + "%" + 
                               (permanentDeathChance > 0 ? " (+" + penaltyPercent + ")" : "");
        
        custardCounter.alpha = 1;
        deathChanceText.alpha = 1;
        
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
        if(FlxG.save.data.specialHitSounds == true) 
        FlxG.sound.play(Paths.sound("custardmiss"), 7.0);
        FlxG.camera.flash(0xFFFF0000, 0.3);
        e.note.kill();
        e.note.destroy();

        // Each miss locks away 20% (0.2) permanently 
        permanentDeathChance += 0.2;
        deathChance -= 0.2;
        if (deathChance < 0) deathChance = 0;
        
        // Visual feedback
        custardCounter.alpha = 1;
        deathChanceText.alpha = 1;
        custardCounter.color = 0xFFFF0000;
        deathChanceText.color = 0xFFFF0000;

        // Display current total chance + the penalty
        var displayPercent = Math.round(deathChance * 100);
        var penaltyPercent = Math.round(permanentDeathChance * 100);
        deathChanceText.text = "Chances of death: " + displayPercent + "% (+" + penaltyPercent + ")";

        fadeTimer.cancel();
        fadeTimer.start(1.0, function(tmr) {
            FlxTween.color(custardCounter, 0.5, 0xFFFF0000, 0xFFFFFFFF);
            FlxTween.color(deathChanceText, 0.5, 0xFFFF0000, 0xFFFFFFFF);
            FlxTween.tween(custardCounter, {alpha: 0}, 1.0);
            FlxTween.tween(deathChanceText, {alpha: 0}, 1.0);
        });
    }
}

function beatHit(curBeat:Int) {
    if (curBeat == 312) {
        var roll = FlxG.random.float(0, 1);
        var totalRisk = deathChance + permanentDeathChance;
        
        if (roll < totalRisk) {
            GameOverSubstate.script = gameoverCustard;
            health = 0;
        }
    }
}

function borderOFF() {
    custardCounter = new FlxText(20, 20, 0, "Custards Collected: 0/5", 48); // Scaled to /5
    setupText(custardCounter);
    add(custardCounter);
}

function borderPartial() {
    custardCounter = new FlxText(((FlxG.width - 960) / 2) + 20, 20, 0, "Custards Collected: 0/5", 48); // Scaled to /5
    setupText(custardCounter);
    add(custardCounter);
}

function borderON() {
    custardCounter = new FlxText(((FlxG.width - 390) / 2) + 20, healthBar.y - 150, 0, "Custards Collected: 0/5", 48); // Scaled to /5
    setupText(custardCounter);
    add(custardCounter);
}