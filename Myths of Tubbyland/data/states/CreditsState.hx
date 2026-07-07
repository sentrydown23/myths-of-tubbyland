import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

var creditsData:Array<Dynamic> = [
    {
        name: "Scrally", 
        desc: "Did all of the coding, and ported Niro's Nocturnal Protocol to Codename Engine", 
        url: "https://www.youtube.com/@scrally-lull"
    },
    {
        name: "AstroDev", 
        desc: "Made all the sprites for The Lions Mouth", 
        url: "https://www.youtube.com/@astronomicaldeveloper"
    },
    {
        name: "Niro", 
        desc: "Made all sprites and icons for Nocturnal Protocol", 
        url: "https://www.youtube.com/@nirogammamon"
    },
    {
        name: "Redus", 
        desc: "Made the icons, ending screen, and disc for The Lions Mouth", 
        url: "https://www.youtube.com/@redustheimpo"
    },
    {
        name: "SancoTheFox", 
        desc: "Composer of Nocturnal Protocol and The Lions Mouth", 
        url: "https://www.youtube.com/@sancothefox2816"
    }
];

var grpNames:FlxTypedGroup<FlxText>;
var descText:FlxText;
var titleText:FlxText;
var hintText:FlxText;

var curSelected:Int = 0;
var canInteract:Bool = false;

function create() {
    // Show mouse cursor
    FlxG.mouse.visible = true;

    // Title setup
    titleText = new FlxText(0, 40, FlxG.width, "The Lions Mouth Credits", 64);
    titleText.alignment = "center";
    titleText.font = Paths.font("LD Slender Regular.ttf");
    titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
    titleText.borderColor = 0xFF000000;
    titleText.borderSize = 4;
    titleText.color = 0xFFFFD700;
    add(titleText);

    // Names list setup
    grpNames = new FlxTypedGroup();
    add(grpNames);

    for (i in 0...creditsData.length) {
        var nameTxt = new FlxText(0, 200 + (i * 80), FlxG.width, creditsData[i].name, 54);
        nameTxt.alignment = "center";
        nameTxt.font = Paths.font("LD Slender Regular.ttf");
        nameTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
        nameTxt.borderColor = 0xFF000000;
        nameTxt.borderSize = 4;
        nameTxt.ID = i;
        grpNames.add(nameTxt);
    }

    // Description text
    descText = new FlxText(50, FlxG.height - 120, FlxG.width - 100, "", 36);
    descText.alignment = "center";
    descText.font = Paths.font("LD Slender Regular.ttf");
    descText.borderStyle = FlxTextBorderStyle.OUTLINE;
    descText.borderColor = 0xFF000000;
    descText.borderSize = 3;
    add(descText);

    // Hint text
    hintText = new FlxText(5, FlxG.height - 30, FlxG.width, "Click / ENTER to open YouTube | Right-Click / Click Hint / ESC to go back", 20);
    hintText.alignment = "center";
    hintText.font = Paths.font("LD Slender Regular.ttf");
    add(hintText);

    // Entrance animations
    for (i in 0...grpNames.members.length) {
        var item = grpNames.members[i];
        item.x -= 800;
        FlxTween.tween(item, {x: 0}, 1, {ease: FlxEase.expoOut, startDelay: i * 0.1});
    }

    FlxTween.tween(titleText, {y: titleText.y + 10}, 1, {
        ease: FlxEase.expoOut, 
        onComplete: function(_) {
            canInteract = true;
            changeSelection(0, true);
        }
    });
}

function update(elapsed:Float) {
    if (!canInteract) return;

    // Mouse input
    for (item in grpNames.members) {
        if (FlxG.mouse.overlaps(item)) {
            if (curSelected != item.ID) {
                changeSelection(item.ID, true);
            }
            
            if (FlxG.mouse.justPressed) {
                FlxG.openURL(creditsData[curSelected].url);
            }
        }
    }

    // Keyboard input
    if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
        changeSelection(-1, false);
    
    if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
        changeSelection(1, false);

    if (FlxG.keys.justPressed.ENTER) {
        FlxG.openURL(creditsData[curSelected].url);
    }

    // Exit menu
    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || FlxG.mouse.justPressedRight || (FlxG.mouse.overlaps(hintText) && FlxG.mouse.justPressed)) {
        exitMenu();
    }
}

function changeSelection(change:Int, absolute:Bool = false) {
    FlxG.sound.play(Paths.sound('scrollMenu'));

    if (absolute)
        curSelected = change;
    else
        curSelected += change;

    // Wrap selection
    if (curSelected < 0) curSelected = creditsData.length - 1;
    if (curSelected >= creditsData.length) curSelected = 0;

    // Update description with fade animation
    descText.alpha = 0;
    descText.text = creditsData[curSelected].desc;
    descText.y = FlxG.height - 100;
    FlxTween.tween(descText, {alpha: 1, y: FlxG.height - 120}, 0.3, {ease: FlxEase.cubeOut});

    // Update UI items
    for (item in grpNames.members) {
        var isSelected = (item.ID == curSelected);
        item.alpha = isSelected ? 1 : 0.5;
        item.color = isSelected ? 0xFFFFFF00 : 0xFFFFFFFF;
        
        FlxTween.cancelTweensOf(item.scale);
        FlxTween.tween(item.scale, {x: isSelected ? 1.2 : 1.0, y: isSelected ? 1.2 : 1.0}, 0.2, {ease: isSelected ? FlxEase.backOut : FlxEase.cubeOut});
    }
}

function exitMenu() {
    canInteract = false;
    FlxG.mouse.visible = false;
    FlxG.sound.play(Paths.sound('cancelMenu'));
    
    for (item in grpNames.members) {
        FlxTween.tween(item, {x: 800, alpha: 0}, 0.5, {ease: FlxEase.backIn});
    }
    FlxTween.tween(descText, {alpha: 0}, 0.5);
    FlxTween.tween(titleText, {y: -100, alpha: 0}, 0.5, {
        ease: FlxEase.backIn, 
        onComplete: function(_) {
            FlxG.switchState(new ModState("MyCustomMenu"));
        }
    });
}