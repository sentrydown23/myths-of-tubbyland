import funkin.options.OptionsMenu;

var menuItems:FlxTypedGroup<FlxText>;
var letterGroups:Array<FlxTypedGroup<FlxText>> = [];
var hitBoxes:Array<FlxSprite> = [];
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

    // Initialize the disc sprite off-screen
    disc = new FlxSprite(FlxG.width + 900, FlxG.height / 2).loadGraphic(Paths.image("freeplay/vinyl_nocturnal-protocol"));
    disc.setGraphicSize(300, 300);
    disc.updateHitbox();
    disc.screenCenter(FlxAxes.Y);
    disc.cameras = [pauseCam];
    add(disc);

    // Setup the menu items group
    menuItems = new FlxTypedGroup();
    menuItems.cameras = [pauseCam];
    add(menuItems);

    for (i in 0...options.length) {
        var group = new FlxTypedGroup<FlxText>();
        letterGroups.push(group);
        add(group);
        group.cameras = [pauseCam];

        var xPos = FlxG.width * 0.25;
        var yPos = (FlxG.height / 2) - 100 + (i * 80);
        var label = options[i];

        // Create individual letter sprites for the menu options
        for (j in 0...label.length) {
            var letter = new FlxText(xPos, yPos, 0, label.charAt(j), 48);
            letter.setFormat(Paths.font("LD Slender Regular.ttf"), 48, FlxColor.WHITE, "left");
            letter.x += (j * 25);
            letter.alpha = 0;
            group.add(letter);
        }

        // Add invisible hitboxes for mouse interaction
        var hitBox = new FlxSprite(xPos - 150, yPos + 50).makeGraphic(300, 60, FlxColor.TRANSPARENT);
        hitBox.ID = i;
        hitBox.cameras = [pauseCam];
        hitBoxes.push(hitBox);
        add(hitBox);
    }

    // Trigger opening animations
    FlxTween.tween(bg, {alpha: 0.8}, 0.5, {ease: FlxEase.quartOut});
    FlxTween.tween(disc, {x: FlxG.width * 0.6}, 1.2, {ease: FlxEase.backOut, startDelay: 0.2});

    // Staggered animation for menu buttons
    for (i in 0...letterGroups.length) {
        var group = letterGroups[i];
        group.forEach(function(l) {
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
}

function update(elapsed) {
    // Handle disc rotation
    disc.angle += elapsed * 45;

    // Keyboard navigation
    if (FlxG.keys.justPressed.UP) changeSelection(-1);
    if (FlxG.keys.justPressed.DOWN) changeSelection(1);

    // Mouse hover and click detection
    for (i in 0...hitBoxes.length) {
        var box = hitBoxes[i];
        if (FlxG.mouse.overlaps(box)) {
            if (curSelected != i) changeSelection(i - curSelected);
            if (FlxG.mouse.justPressed) selectOption();
        }
    }

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
    // Handle menu button selection
    switch(options[curSelected]) {
        case "Resume": close();
        case "Restart": FlxG.switchState(new PlayState());
        case "Options": FlxG.switchState(new OptionsMenu());
        case "Exit": FlxG.switchState(new ModState("VinylFreeplayState"));
    }
}

function changeSelection(change:Int) {
    // Update active selection and apply visual feedback
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
    // Perform a recursive flickering animation on a text character
    if (l == null) return;
    FlxTween.cancelTweensOf(l);
    l.alpha = (l.alpha >= 0.5) ? 0.1 : 1.0;
    if (count > 0) {
        new FlxTimer().start(0.06, function(tmr) { flickerLetter(l, count - 1); });
    } else {
        l.alpha = 1.0;
    }
}