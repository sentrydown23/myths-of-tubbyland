import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.system.FlxSound;

var bg:FlxSprite;
var sidebarBg:FlxSprite; 

var categories:Array<String> = ["Subjects", "Mechanics", "Locations"];
var categoryGroup:FlxTypedGroup<FlxText>;
var categoryArray:Array<FlxText> = []; 
var currentCategory:Int = 0;
var inSubMenu:Bool = false;

var subMenuData:Dynamic;
var subGroup:FlxTypedGroup<FlxText>;
var subArray:Array<FlxText> = []; 
var currentSub:Int = 0;

var displayImage:FlxSprite;
var displayDesc:FlxText;
var fontName:String = "LD Slender Regular.ttf";

var imgTween:FlxTween;
var imgMoveTween:FlxTween;
var descTween:FlxTween;
var descMoveTween:FlxTween;
var sidebarTween:FlxTween;
var menuLoop:FlxSound;
var bgTimer:Float = 0;

function create() {
    if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;

    menuLoop = new FlxSound();
    menuLoop.loadEmbedded(Paths.music("extras"), true); 
    menuLoop.volume = 0;
    menuLoop.play();
    menuLoop.fadeIn(1.5, 0, 0.6);
    FlxG.sound.list.add(menuLoop); 

    subMenuData = {
        Subjects: [
            {name: "Tinky Winky", desc: "The first to become infected.", image: "menus/extras/char/tinky", sound: "extras/tinky"},
            {name: "Dipsy", desc: "The first to be killed. No one knows where he got the lion head.", image: "menus/extras/char/dipsy", sound: "extras/dipsy"},
            {name: "???", desc: "???", image: "menus/extras/char/prev1", sound: "extras/laalaa"},
            {name: "???", desc: "???", image: "menus/extras/char/prev2", sound: "extras/po"}
        ],
        Mechanics: [
            {name: "Custards", desc: "Each collected Custard reduces your chance of dying by the end of the song. The percent reduced is difficulty dependant.", image: "menus/extras/mech/custard"},
            {name: "Saw Notes", desc: "Hitting a Saw note will damage you down to a certain point. Missing a Saw Note will damage you heavily. Damage and Minimum Health is difficulty dependant.", image: "menus/extras/mech/saw"}
        ],
        Locations: [
            {name: "Main Land", desc: "Sweet home", image: "menus/extras/loc/mainland"},
            {name: "Sattellite Station", desc: "The only means of global communcation", image: "menus/extras/loc/station"},
            {name: "???", desc: "???", image: "menus/extras/loc/prev1"},
            {name: "???", desc: "???", image: "menus/extras/loc/prev2"}
        ]
    };

    bg = new FlxSprite(-20, -20).loadGraphic(Paths.image("menus/extras/bg"));
    bg.setGraphicSize(FlxG.width + 40, FlxG.height + 40); 
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    sidebarBg = new FlxSprite(0, 0).makeGraphic(340, FlxG.height, 0x99000000);
    add(sidebarBg);

    categoryGroup = new FlxTypedGroup<FlxText>();
    add(categoryGroup);

    for (i in 0...categories.length) {
        var catText:FlxText = new FlxText(60, 220 + (i * 100), 0, categories[i], 52);
        catText.setFormat(Paths.font(fontName), 52, 0xFF94A3B8, "left"); 
        catText.ID = i;
        categoryGroup.add(catText);
        categoryArray.push(catText); 
    }

    subGroup = new FlxTypedGroup<FlxText>();
    add(subGroup);

    displayImage = new FlxSprite(660, 90);
    displayImage.makeGraphic(580, 440, 0x00000000); 
    displayImage.alpha = 0;
    add(displayImage);

    displayDesc = new FlxText(660, 560, 560, "", 24);
    displayDesc.setFormat(Paths.font(fontName), 24, 0xFFE2E8F0, "left");
    displayDesc.alpha = 0;
    add(displayDesc);

    updateSelection();
}

function getSubItems():Array<Dynamic> {
    var catName:String = categories[currentCategory];
    return Reflect.field(subMenuData, catName);
}

function update(elapsed:Float) {
    // Subtle background drift math
    bgTimer += elapsed;
    bg.x = -20 + (Math.sin(bgTimer * 1.2) * 7);
    bg.y = -20 + (Math.cos(bgTimer * 1.0) * 8);

    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || FlxG.mouse.justPressedRight) {
        if (inSubMenu) {
            clearSubMenu();
        } else {
            if (menuLoop != null && menuLoop.playing) {
                menuLoop.fadeOut(0.4, 0, function(twn:FlxTween) {
                    menuLoop.stop();
                });
            }
            FlxG.sound.music.volume = 0.7;
            FlxG.switchState(new ModState("MyCustomMenu"));
        }
        return;
    }

    // Process interaction loops based on deep navigation menu layer state
    if (!inSubMenu) {
        for (txt in categoryArray) {
            if (txt != null && FlxG.mouse.overlaps(txt)) {
                if (currentCategory != txt.ID) {
                    currentCategory = txt.ID;
                    FlxG.sound.play(Paths.sound("extras/extrascroll"), 0.1);
                    updateSelection();
                }
                if (FlxG.mouse.justPressed) {
                    selectCategory();
                    return;
                }
            }
        }

        if (FlxG.keys.justPressed.UP) { changeSelection(-1); }
        if (FlxG.keys.justPressed.DOWN) { changeSelection(1); }
        if (FlxG.keys.justPressed.ENTER) { selectCategory(); }

    } else {
        for (txt in subArray) {
            if (txt != null && FlxG.mouse.overlaps(txt)) {
                if (currentSub != txt.ID) {
                    currentSub = txt.ID;
                    FlxG.sound.play(Paths.sound("extras/extrascroll"), 0.1);
                    updateSubSelection();
                }
                if (FlxG.mouse.justPressed) {
                    selectSubOption();
                }
            }
        }

        if (FlxG.keys.justPressed.UP) { changeSubSelection(-1); }
        if (FlxG.keys.justPressed.DOWN) { changeSubSelection(1); }
        if (FlxG.keys.justPressed.ENTER) { selectSubOption(); }
    }
}

function changeSelection(change:Int) {
    FlxG.sound.play(Paths.sound("extras/extrascroll"), 0.1);
    currentCategory = FlxMath.wrap(currentCategory + change, 0, categories.length - 1);
    updateSelection();
}

function updateSelection() {
    for (txt in categoryArray) {
        if (txt != null) {
            if (txt.ID == currentCategory) {
                txt.color = 0xFFA855F7; 
                FlxTween.cancelTweensOf(txt.scale);
                FlxTween.tween(txt.scale, {x: 1.05, y: 1.05}, 0.25, {ease: FlxEase.backOut});
            } else {
                txt.color = 0xFF94A3B8; 
                FlxTween.cancelTweensOf(txt.scale);
                FlxTween.tween(txt.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.sineOut});
            }
        }
    }
}

function selectCategory() {
    FlxG.sound.play(Paths.sound("extras/extraselect"), 0.35);
    inSubMenu = true;
    currentSub = 0;
    
    subGroup.clear();
    subArray = [];

    // Expand sidebar graphic box using numerical interpolation
    if (sidebarTween != null) sidebarTween.cancel();
    sidebarTween = FlxTween.num(sidebarBg.width, 560, 0.4, {ease: FlxEase.backOut}, function(v:Float) {
        sidebarBg.setGraphicSize(Std.int(v), FlxG.height);
        sidebarBg.updateHitbox();
        sidebarBg.x = 0; 
    });

    var items = getSubItems();
    if (items == null) return;
    
    // Iteratively build subcategory list elements with staggered fade animations
    for (i in 0...items.length) {
        var subText:FlxText = new FlxText(365, 230 + (i * 75), 180, items[i].name, 30);
        subText.setFormat(Paths.font(fontName), 30, 0xFF64748B, "left");
        subText.ID = i;
        subText.alpha = 0;
        
        subText.x -= 15;
        subGroup.add(subText);
        subArray.push(subText); 
        
        FlxTween.tween(subText, {alpha: 1, x: 365}, 0.45 + (i * 0.08), {ease: FlxEase.elasticOut});
    }

    updateSubSelection();
}

function changeSubSelection(change:Int) {
    var items = getSubItems();
    if (items == null || items.length == 0) return;
    
    FlxG.sound.play(Paths.sound("extras/extrascroll"), 0.1);
    currentSub = FlxMath.wrap(currentSub + change, 0, items.length - 1);
    updateSubSelection();
}

function selectSubOption() {
    var items = getSubItems();
    if (items == null || items.length == 0) return;

    var currentData = items[currentSub];
    
    if (currentData.sound != null && currentData.sound != "") {
        FlxG.sound.play(Paths.sound(currentData.sound), 3);
    } else {
        FlxG.sound.play(Paths.sound("extras/extrascroll"), 0.2);
    }
}

function updateSubSelection() {
    var items = getSubItems();
    if (items == null || items.length == 0) return;

    for (txt in subArray) {
        if (txt != null) {
            FlxTween.cancelTweensOf(txt);
            if (txt.ID == currentSub) {
                txt.color = 0xFF22D3EE; 
                FlxTween.tween(txt, {x: 380, alpha: 1}, 0.2, {ease: FlxEase.circOut});
            } else {
                txt.color = 0xFFE2E8F0;
                FlxTween.tween(txt, {x: 365, alpha: 0.6}, 0.2, {ease: FlxEase.sineOut});
            }
        }
    }

    var currentData = items[currentSub];
    
    if (imgTween != null) imgTween.cancel();
    if (imgMoveTween != null) imgMoveTween.cancel();
    if (descTween != null) descTween.cancel();
    if (descMoveTween != null) descMoveTween.cancel();

    // Dynamically load new graphic assets and recalculate layout aspect bounding rules
    displayImage.loadGraphic(Paths.image(currentData.image));
    displayImage.setGraphicSize(580, 0); 
    displayImage.updateHitbox();
    
    if (displayImage.height > 440) {
        displayImage.setGraphicSize(0, 440);
        displayImage.updateHitbox();
    }

    var targetX:Float = 660;
    var targetImgY:Float = 90;
    
    displayImage.x = targetX + 60; 
    displayImage.y = targetImgY; 
    displayImage.alpha = 0; 
    
    displayDesc.text = currentData.desc;
    displayDesc.fieldWidth = 560; 
    displayDesc.alpha = 0; 
    
    var targetDescY:Float = targetImgY + displayImage.height + 30;
    displayDesc.x = targetX + 60; 
    displayDesc.y = targetDescY; 

    imgTween = FlxTween.tween(displayImage, {alpha: 1}, 0.4, {ease: FlxEase.sineOut});
    imgMoveTween = FlxTween.tween(displayImage, {x: targetX}, 0.4, {ease: FlxEase.backOut});
    
    descTween = FlxTween.tween(displayDesc, {alpha: 1}, 0.4, {ease: FlxEase.sineOut});
    descMoveTween = FlxTween.tween(displayDesc, {x: targetX}, 0.4, {ease: FlxEase.backOut});
}

function clearSubMenu() {
    inSubMenu = false;
    subGroup.clear();
    subArray = [];
    
    if (sidebarTween != null) sidebarTween.cancel();
    sidebarTween = FlxTween.num(sidebarBg.width, 340, 0.35, {ease: FlxEase.backOut}, function(v:Float) {
        sidebarBg.setGraphicSize(Std.int(v), FlxG.height);
        sidebarBg.updateHitbox();
        sidebarBg.x = 0;
    });

    if (imgTween != null) imgTween.cancel();
    if (imgMoveTween != null) imgMoveTween.cancel();
    if (descTween != null) descTween.cancel();
    if (descMoveTween != null) descMoveTween.cancel();

    FlxTween.tween(displayImage, {alpha: 0, x: FlxG.width + 40}, 0.25, {ease: FlxEase.sineIn});
    FlxTween.tween(displayDesc, {alpha: 0, x: FlxG.width + 40}, 0.25, {ease: FlxEase.sineIn});
    FlxG.sound.play(Paths.sound("extras/extraback"), 0.35);
}