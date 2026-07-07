import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;
import openfl.system.System;
import funkin.options.OptionsMenu;
import funkin.backend.MusicBeatTransition;

var letterGroups:Array<FlxTypedGroup<FlxText>> = [];
var hitBoxes:Array<FlxSprite> = [];
var titleGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
var menuItems:Array<String> = ["Select Chapter", "Options", "Credits", "Exit"];
var flickerTimer:Float = 0;
var titleFlickerTimer:Float = 0;
var canFlicker:Bool = false;
var isSelecting:Bool = false;
var mainFont:String = "LD Slender Regular.ttf"; 
var titleFont:String = "Slender.ttf";

var bg:FlxSprite;
var bgTimer:Float = 0;

function create() {
    FlxG.mouse.visible = true;
    
    // Smooth audio transition
    if (FlxG.sound.music.volume < 0.7) {
        FlxG.sound.music.fadeIn(1.0, FlxG.sound.music.volume, 0.7);
    } else if (FlxG.sound.music.volume > 0.7) {
        FlxG.sound.music.fadeOut(1.0, 0.7);
    }
    
    bg = new FlxSprite(-20, -20).loadGraphic(Paths.image("menus/menuBG"));
    bg.setGraphicSize(FlxG.width + 40, FlxG.height + 40);
    bg.updateHitbox();
    add(bg);
    
    add(titleGroup);
    var titleText = "Myths of Tubbyland";
    var titleStartX = (FlxG.width - (titleText.length * 45)) / 2;
    for (j in 0...titleText.length) {
        var letter = new FlxText(titleStartX + (j * 45), 50, 0, titleText.charAt(j), 72);
        letter.setFormat(Paths.font(titleFont), 72, 0xFFFFFFFF, "center");
        titleGroup.add(letter);
    }
    
    for (i in 0...menuItems.length) {
        var group = new FlxTypedGroup<FlxText>();
        add(group);
        letterGroups.push(group);
        
        var label = menuItems[i];
        var startX = (FlxG.width - (label.length * 20)) / 2;
        var yPos = 200 + (i * 80);
        
        var hitBox = new FlxSprite(startX, yPos).makeGraphic(label.length * 20, 60, 0xFF000000);
        hitBox.alpha = 0;
        hitBoxes.push(hitBox);
        add(hitBox);
        
        for (j in 0...label.length) {
            var letter = new FlxText(startX + (j * 20), yPos, 0, label.charAt(j), 48);
            letter.setFormat(Paths.font(mainFont), 48, 0xFFFFFFFF, "left");
            letter.alpha = 0;
            letter.origin.set(0, 0); 
            group.add(letter);
            FlxTween.tween(letter, {alpha: 1}, 0.5, {startDelay: (i * 0.1) + (j * 0.02)});
        }
    }
    new FlxTimer().start(2.0, function(tmr) { canFlicker = true; });
}

function update(elapsed:Float) {
    if(FlxG.keys.justPressed.TAB) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = !(persistentDraw = true);
    }

    if(FlxG.keys.justPressed.SEVEN && FlxG.save.data.devmodeBox == true) {
        openSubState(new EditorPicker());
        persistentUpdate = !(persistentDraw = true);
    }

    // Parallax background effect
    bgTimer += elapsed;
    bg.x = -20 + (Math.sin(bgTimer * 0.2) * 7);
    bg.y = -20 + (Math.cos(bgTimer * 0.15) * 8);

    if (canFlicker && !isSelecting) {
        flickerTimer += elapsed;
        if (flickerTimer >= 2.5) {
            if (FlxG.random.bool(60)) triggerNeonBurst();
            flickerTimer = 0;
        }
        titleFlickerTimer += elapsed;
        if (titleFlickerTimer >= 5.0) {
            if (FlxG.random.bool(30)) triggerTitleFlicker();
            titleFlickerTimer = 0;
        }
    }

    for (i in 0...hitBoxes.length) {
        var box = hitBoxes[i];
        var group = letterGroups[i];
        
        if (FlxG.mouse.overlaps(box) && !isSelecting) {
            group.forEach(function(l) { 
                if (l.scale.x < 1.1) {
                    FlxTween.cancelTweensOf(l.scale);
                    FlxTween.tween(l.scale, {x: 1.1, y: 1.1}, 0.2, {ease: FlxEase.expoOut});
                }
                l.color = 0xFFFF4444; 
            });
            if (FlxG.mouse.justPressed) flashAndSelect(i);
        } else if (!isSelecting) {
            group.forEach(function(l) { 
                if (l.scale.x > 1.0) {
                    FlxTween.cancelTweensOf(l.scale);
                    FlxTween.tween(l.scale, {x: 1.0, y: 1.0}, 0.2, {ease: FlxEase.expoOut});
                }
                l.color = 0xFFFFFFFF; 
            });
        }
    }
}

function flashAndSelect(index:Int) {
    isSelecting = true;
    canFlicker = false;
    FlxG.sound.play(Paths.sound("menuSelection"), 2.0);

    var group = letterGroups[index];
    
    // Rapid opacity flash effect
    for (i in 0...6) {
        new FlxTimer().start(0.1 * i, function(tmr) {
            group.forEach(function(l) { l.alpha = (i % 2 == 0) ? 0 : 1; });
        });
    }
    
    new FlxTimer().start(0.7, function(tmr) {
        handleSelection(menuItems[index]);
    });
}

function triggerNeonBurst() {
    var group = letterGroups[FlxG.random.int(0, letterGroups.length - 1)];
    var list = [];
    group.forEach(function(l) { list.push(l); });
    FlxG.random.shuffle(list);
    for (i in 0...Math.min(3, list.length)) flickerLetter(list[i], 3);
}

function triggerTitleFlicker() {
    var l = titleGroup.members[FlxG.random.int(0, titleGroup.length - 1)];
    if (l != null) flickerLetter(l, 1);
}

function flickerLetter(l:FlxText, count:Int) {
    if (l == null) return;
    FlxTween.cancelTweensOf(l);
    l.alpha = (l.alpha >= 0.5) ? 0.1 : 1.0;
    if (count > 0) {
        new FlxTimer().start(0.06, function(tmr) { flickerLetter(l, count - 1); });
    } else {
        l.alpha = 1.0;
    }
}

function handleSelection(name:String) {
    MusicBeatTransition.script = null;
    switch (name) {
        case "Select Chapter": FlxG.switchState(new ModState("VinylFreeplayState"));
        case "Options": FlxG.switchState(new OptionsMenu());
        case "Credits": FlxG.switchState(new ModState("CreditsState"));
        case "Exit": performExitSequence();
    }
}

function performExitSequence() {
    FlxG.sound.play(Paths.sound("cancelMenu"));
    FlxG.sound.music.fadeOut(0.5, 0);
    FlxTimer.globalManager.clear();
    for (g in letterGroups) g.forEach(function(l) { FlxTween.tween(l, {alpha: 0}, 0.5); });
    titleGroup.forEach(function(l) { FlxTween.tween(l, {alpha: 0}, 0.5); });
    new FlxTimer().start(0.6, function(tmr) { System.exit(0); });
}