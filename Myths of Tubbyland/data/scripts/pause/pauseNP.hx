import funkin.options.OptionsMenu;
import funkin.backend.scripting.ModState;

var letterGroups:Array<FlxTypedGroup<FlxText>> = [];
var options:Array<String> = ["Resume", "Restart", "Options", "Exit"];
var curSelected:Int = 0;
var bg:FlxSprite;
var pauseCam:FlxCamera;
var flickerTimer:Float = 0;
var disc:FlxSprite;

function create(event) {
    event.cancel();

    // Initialize the pause camera
    pauseCam = new FlxCamera();
    pauseCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(pauseCam, false);

    // Create and add the background
    bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    bg.alpha = 0;
    bg.cameras = [pauseCam];
    add(bg);

    // Create the title text
    var title = new FlxText(0, 50, FlxG.width, "NOCTURNAL PROTOCOL", 72);
    title.setFormat(Paths.font("Slender.ttf"), 72, FlxColor.WHITE, "center");
    title.cameras = [pauseCam];
    add(title);

    // Initialize the disc sprite
    disc = new FlxSprite(FlxG.width + 900, FlxG.height / 2).loadGraphic(Paths.image("freeplay/vinyl_nocturnal-protocol"));
    disc.setGraphicSize(300, 300);
    disc.updateHitbox();
    disc.screenCenter(FlxAxes.Y);
    disc.cameras = [pauseCam];
    add(disc);

    // Setup the menu items group
    for (i in 0...options.length) {
        var group = new FlxTypedGroup<FlxText>();
        letterGroups.push(group);
        add(group);
        group.cameras = [pauseCam];

        var xPos = FlxG.width * 0.25;
        var yPos = (FlxG.height / 2) - 100 + (i * 80);
        var label = options[i];

        // Create individual letter sprites
        for (j in 0...label.length) {
            var letter = new FlxText(xPos + (j * 25), yPos, 0, label.charAt(j), 48);
            letter.setFormat(Paths.font("LD Slender Regular.ttf"), 48, FlxColor.WHITE, "left");
            letter.alpha = 0;
            group.add(letter);
        }
    }

    // Trigger opening animations
    FlxTween.tween(bg, {alpha: 0.8}, 0.5, {ease: FlxEase.quartOut});
    FlxTween.tween(disc, {x: FlxG.width * 0.6}, 1.2, {ease: FlxEase.backOut, startDelay: 0.2});

    // Staggered animation for menu buttons
    for (i in 0...letterGroups.length) {
        letterGroups[i].forEach(function(l) {
            FlxTween.tween(l, {alpha: 1}, 0.5, {
                startDelay: 0.3 + (i * 0.15),
                ease: FlxEase.expoOut
            });
            l.x -= 20;
            FlxTween.tween(l, {x: l.x + 20}, 0.5, {
                startDelay: 0.3 + (i * 0.15),
                ease: FlxEase.expoOut
            });
        });
    }
    
    // Initial selection visual
    changeSelection(0);
}

function update(elapsed) {
    disc.angle += elapsed * 45;

    // Keyboard navigation only
    if (FlxG.keys.justPressed.UP) changeSelection(-1);
    if (FlxG.keys.justPressed.DOWN) changeSelection(1);
    if (FlxG.keys.justPressed.ENTER) selectOption();

    // Trigger random letter flicker effect
    flickerTimer += elapsed;
    if (flickerTimer >= 3.0) {
        var group = letterGroups[FlxG.random.int(0, letterGroups.length - 1)];
        var letter = group.members[FlxG.random.int(0, group.members.length - 1)];
        flickerLetter(letter, 3);
        flickerTimer = 0;
    }
}

function selectOption() {
    switch(options[curSelected]) {
        case "Resume": close();
        case "Restart": FlxG.switchState(new PlayState());
        case "Options": FlxG.switchState(new OptionsMenu());
        case "Exit": 
        if (isCStoryMode)
        {
            FlxG.switchState(new ModState("CStoryModeState"));
        }
        else if (!isCStoryMode)
        {
            FlxG.switchState(new ModState("VinylFreeplayState"));
        }    
    }
}

function changeSelection(change:Int) {
    curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

    for (i in 0...letterGroups.length) {
        var group = letterGroups[i];
        var isSelected = (i == curSelected);

        group.forEach(function(l) {
            l.color = isSelected ? 0xFFFFFF00 : 0xFFFFFFFF;
            var targetScale = isSelected ? 1.2 : 1.0;
            FlxTween.cancelTweensOf(l.scale);
            FlxTween.tween(l.scale, {x: targetScale, y: targetScale}, 0.1);
        });
    }
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