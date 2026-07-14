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
import funkin.backend.utils.DiscordUtil;

var letterGroups:Array<FlxTypedGroup<FlxText>> = [];
var hitBoxes:Array<FlxSprite> = [];
var titleGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
var menuItems:Array<String> = ["Story Mode", "Select Chapter", "Options", "Credits", "Extras", "Exit"];
var curSelected:Int = 0; 
var flickerTimer:Float = 0;
var canFlicker:Bool = false;
var isSelecting:Bool = false;
var mainFont:String = "LD Slender Regular.ttf"; 
var titleFont:String = "Typedeer Mono.ttf";

// --- PANORAMA CONFIGURATION ---
var panoramaImages:Array<String> = ["menus/menuBG", "menus/menuBG2", "menus/menuBG3", "menus/menuBG4"];
var panoramaGroup:FlxTypedGroup<FlxSprite>;
var curBgIndex:Int = 0;
var panoramaInterval:Float = 10.0; // Interval duration in seconds
var panoramaSwitchTimer:Float = 0;

var bgTimer:Float = 0;
var selectionLine:FlxSprite;
var menuShade:FlxSprite;

function create() {
    FlxG.mouse.visible = true;
    
    UpdatePresence();

    // Check if music object exists before running volume operations
    if (FlxG.sound.music != null) {
        if (FlxG.sound.music.volume < 0.7) {
            FlxG.sound.music.fadeIn(1.0, FlxG.sound.music.volume, 0.7);
        } else if (FlxG.sound.music.volume > 0.7) {
            FlxG.sound.music.fadeOut(1.0, 0.7);
        }
    }
    else if (FlxG.sound.music == null)
    {
        FlxG.sound.playMusic(Paths.music("mainmenu"), 0.7, true);
    }
    
    // Initialize panorama setup group
    panoramaGroup = new FlxTypedGroup<FlxSprite>();
    add(panoramaGroup);

    for (i in 0...panoramaImages.length) {
        var bgSprite = new FlxSprite(-40, -40).loadGraphic(Paths.image(panoramaImages[i]));
        bgSprite.setGraphicSize(FlxG.width + 80, FlxG.height + 80);
        bgSprite.updateHitbox();
        bgSprite.alpha = (i == 0) ? 1.0 : 0.0; // Only show the first image initially
        panoramaGroup.add(bgSprite);
    }

    menuShade = new FlxSprite(0, 0).makeGraphic(420, FlxG.height, 0x99000000);
    menuShade.alpha = 0;
    add(menuShade);
    FlxTween.tween(menuShade, {alpha: 1}, 0.5, {ease: FlxEase.quintOut});
    
    add(titleGroup);
    var titleText = "Myths of Tubbyland";
    
    var titleStartX = 20; 
    for (j in 0...titleText.length) {
        var letter = new FlxText(titleStartX + (j * 21), 45, 0, titleText.charAt(j), 34);
        letter.setFormat(Paths.font(titleFont), 34, 0xFFFFFFFF, "left");
        letter.alpha = 0;
        titleGroup.add(letter);
        
        FlxTween.tween(letter, {alpha: 1}, 0.55, {startDelay: 0.45 + (j * 0.02), ease: FlxEase.quintOut});
    }

    selectionLine = new FlxSprite(45, 185).makeGraphic(4, 38, 0xFFFF4444);
    add(selectionLine);
    
    for (i in 0...menuItems.length) {
        var group = new FlxTypedGroup<FlxText>();
        add(group);
        letterGroups.push(group);
        
        var label = menuItems[i];
        var startX = 65; 
        var yPos = 185 + (i * 65); 
        
        var hitBox = new FlxSprite(startX - 25, yPos).makeGraphic(290, 45, 0xFF000000);
        hitBox.alpha = 0;
        hitBoxes.push(hitBox);
        add(hitBox);
        
        for (j in 0...label.length) {
            var letter = new FlxText(startX + (j * 16), yPos, 0, label.charAt(j), 36);
            letter.setFormat(Paths.font(mainFont), 36, 0xFFFFFFFF, "left");
            letter.alpha = 0;
            letter.origin.set(0, 0); 
            group.add(letter);
            
            letter.ID = j;
            FlxTween.tween(letter, {alpha: 1}, 0.4, {startDelay: (i * 0.06) + (j * 0.012)});
        }
    }
    new FlxTimer().start(1.8, function(tmr) { canFlicker = true; });
    
    changeSelection(0); 
}

function postCreate()
{
    new FlxTimer().start(0.2, function(tmr) { MusicBeatTransition.script = null; }); 
}

function update(elapsed:Float) {
    if(FlxG.keys.justPressed.TAB) openSubState(new ModSwitchMenu());
    if(FlxG.keys.justPressed.SEVEN && FlxG.save.data.devmodeBox) openSubState(new EditorPicker());

    if (!isSelecting) {
        if (FlxG.keys.justPressed.UP) changeSelection(-1);
        if (FlxG.keys.justPressed.DOWN) changeSelection(1);
        if (FlxG.keys.justPressed.ENTER) flashAndSelect(curSelected);
    }

    for (i in 0...hitBoxes.length) {
        if (FlxG.mouse.overlaps(hitBoxes[i]) && curSelected != i && !isSelecting) {
            changeSelection(i - curSelected);
        }
        if (FlxG.mouse.overlaps(hitBoxes[i]) && FlxG.mouse.justPressed && !isSelecting) {
            flashAndSelect(i);
        }
    }

    // Dynamic drifting math running uniformly on every background asset
bgTimer += elapsed;
    var calcX = -40 + (Math.sin(bgTimer * 0.45) * 22);
    var calcY = -40 + (Math.cos(bgTimer * 0.35) * 24);
    
    // Added explicit safety null check wrapper
    if (panoramaGroup != null) {
        panoramaGroup.forEach(function(bg:FlxSprite) {
            bg.x = calcX;
            bg.y = calcY;
        });
    }

    // Handle background interval cross-fades
    if (panoramaImages.length > 1) {
        panoramaSwitchTimer += elapsed;
        if (panoramaSwitchTimer >= panoramaInterval) {
            panoramaSwitchTimer = 0;
            switchBackground();
        }
    }

    if (canFlicker && !isSelecting) {
        flickerTimer += elapsed;
        if (flickerTimer >= 1.5) { if (FlxG.random.bool(70)) triggerNeonBurst(); flickerTimer = 0; }
    }
}

function switchBackground() {
    var oldBg = panoramaGroup.members[curBgIndex];
    curBgIndex = FlxMath.wrap(curBgIndex + 1, 0, panoramaImages.length - 1);
    var newBg = panoramaGroup.members[curBgIndex];

    // Smooth 1.2s alpha cross-fade between old and new backgrounds
    FlxTween.tween(oldBg, {alpha: 0}, 1.2, {ease: FlxEase.linear});
    FlxTween.tween(newBg, {alpha: 1}, 1.2, {ease: FlxEase.linear});
}

function changeSelection(change:Int) {
    curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
    
    FlxTween.cancelTweensOf(selectionLine);
    FlxTween.tween(selectionLine, {y: 185 + (curSelected * 65)}, 0.2, {ease: FlxEase.quintOut});

    for (i in 0...letterGroups.length) {
        var isSelected = (i == curSelected);
        var baseStartX = 65;
        var targetX = isSelected ? 85 : baseStartX; 

        letterGroups[i].forEach(function(l) {
            var isIntroRunning:Bool = (l.alpha < 1 && !canFlicker);
            
            if (!isIntroRunning) {
                FlxTween.cancelTweensOf(l);
                FlxTween.tween(l, {x: targetX + (l.ID * 16), alpha: isSelected ? 1 : 0.65}, 0.25, {ease: FlxEase.quintOut});
            } else {
                FlxTween.tween(l, {x: targetX + (l.ID * 16)}, 0.25, {ease: FlxEase.quintOut});
            }
            
            if (isSelected) {
                l.color = 0xFFFF4444; 
            } else {
                l.color = (menuItems[i] == "Select Chapter") ? 0xFFFFFFFF : 0xFFCCD4DC;
            }
        });
    }
}

function flashAndSelect(index:Int) {
    isSelecting = true;
    canFlicker = false;
    FlxG.sound.play(Paths.sound("menuSelection"), 2.0);

    FlxTween.tween(selectionLine, {alpha: 0}, 0.15);
    FlxTween.tween(menuShade, {alpha: 0}, 0.45);

    var group = letterGroups[index];
    for (i in 0...6) {
        new FlxTimer().start(0.06 * i, function(tmr) {
            group.forEach(function(l) { 
                l.alpha = (i % 2 == 0) ? 0 : 1; 
                l.color = 0xFFFFFFFF; 
            });
        });
    }
    
    new FlxTimer().start(0.5, function(tmr) { handleSelection(menuItems[index]); });
}

function triggerNeonBurst() {
    var groupIndex = FlxG.random.int(0, letterGroups.length - 1);
    var group = letterGroups[groupIndex];
    var list = [];
    group.forEach(function(l) { list.push(l); });
    FlxG.random.shuffle(list);
    for (i in 0...Math.min(3, list.length)) jitterLetter(list[i], 3, groupIndex);
}

function jitterLetter(l:FlxText, count:Int, groupIndex:Int) {
    if (l == null) return;
    FlxTween.cancelTweensOf(l);
    
    if (count > 0) {
        var baseStartX = (groupIndex == curSelected) ? 85 : 65;
        var originalY = 185 + (groupIndex * 65);
        
        l.x = (baseStartX + (l.ID * 16)) + FlxG.random.float(-5, 5);
        l.y = originalY + FlxG.random.float(-4, 4);
        l.alpha = FlxG.random.float(0.3, 0.9);
        
        if (groupIndex == curSelected) l.color = 0xFFFF4444;
        else l.color = (menuItems[groupIndex] == "Select Chapter") ? 0xFFFFFFFF : 0xFFCCD4DC;

        new FlxTimer().start(0.04, function(tmr) { jitterLetter(l, count - 1, groupIndex); });
    } else {
        l.alpha = (groupIndex == curSelected) ? 1.0 : 0.65;
        var endX = (groupIndex == curSelected) ? 85 : 65;
        l.x = endX + (l.ID * 16);
        l.y = 185 + (groupIndex * 65);
    }
}

function handleSelection(name:String) {
    switch (name) {
        case "Story Mode": FlxG.switchState(new ModState("CStoryModeState"));
        case "Select Chapter": FlxG.switchState(new ModState("VinylFreeplayState"));
        case "Options": FlxG.switchState(new OptionsMenu()); // separately hooked from import - Vanilla game menu, so no ModState
        case "Credits": FlxG.switchState(new ModState("placeholders/ComingSoon"));
        case "Extras": FlxG.switchState(new ModState("Extra"));
        case "Exit": performExitSequence();
    }
}

function performExitSequence() {
    FlxG.sound.play(Paths.sound("cancelMenu"));
    FlxG.sound.music.fadeOut(0.5, 0);
    FlxTimer.globalManager.clear();
    FlxTween.tween(selectionLine, {alpha: 0}, 0.3);
    FlxTween.tween(menuShade, {alpha: 0}, 0.3);
    for (g in letterGroups) g.forEach(function(l) { FlxTween.tween(l, {alpha: 0}, 0.5); });
    titleGroup.forEach(function(l) { FlxTween.tween(l, {alpha: 0}, 0.5); });
    panoramaGroup.forEach(function(bg:FlxSprite) { FlxTween.tween(bg, {alpha: 0}, 0.5); });
    new FlxTimer().start(0.6, function(tmr) { System.exit(0); });
}

function UpdatePresence()
{
    if (FlxG.save.data.devmodeBox)
    {
        DiscordUtil.changePresenceAdvanced({
            details: "In the Main Menu",
            state: "Development Mode",
            largeImageKey: "coverart",       
        });
    }
    else 
    {
        DiscordUtil.changePresenceAdvanced({
            details: "In the Main Menu",
            state: "",
            largeImageKey: "coverart",       
        });
    }
}