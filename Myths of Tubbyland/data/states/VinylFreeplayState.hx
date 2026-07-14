import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import funkin.backend.utils.DiscordUtil;

// Discord Presence details
var menuDetail:String = "Selecting a Song";
var menuState:String = "Freeplay";
var menuStateDEV:String = "Freeplay (DEV)";
var last = DiscordUtil.lastPresence;

var songs:Array<Dynamic> = [
    {displayName: "Nocturnal Protocol", folderName: "nocturnal-protocol", preludeState: "PreludeNPState", presence: "coverart-1f"},
    {displayName: "The Lions Mouth", folderName: "the-lions-mouth", preludeState: "PreludeTLMState", presence: "coverart-2f"}
];

var curSelected:Int = 0;
var canControl:Bool = true;
var diskOut:Bool = false;
var canInteract:Bool = true; 

var cover:FlxSprite;
var discNorm:FlxSprite;
var songText:FlxText;
var previewMusic:FlxSound;
var songBackground:FlxSprite;

function create()
{
    if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        FlxG.sound.playMusic(Paths.music("mainmenu"));

    if (FlxG.sound.music.volume >= 0.7) {
        FlxG.sound.music.fadeOut(1.0, 0.3);
    }
        
    FlxG.mouse.visible = true;
        
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    add(bg);

    songBackground = new FlxSprite(0, 0);
    songBackground.alpha = 0;
    add(songBackground);

    discNorm = new FlxSprite(0, 0);
    discNorm.scale.set(0.5, 0.5);
    add(discNorm);

    cover = new FlxSprite(0, 0);
    cover.scale.set(0.5, 0.5);
    add(cover);

    songText = new FlxText(750, 300, 400, "", 48);
    songText.setFormat(Paths.font("LD Slender Regular.ttf"), 62, 0xFFFFFFFF, "center");
    add(songText);

    changeSelection(0);
    UpdatePresence();
}

function update(elapsed:Float)
{
    if (!canControl) return;

    if (diskOut) {
        discNorm.angle += elapsed * 45;
    }

    // --- KEYBOARD NAVIGATION ---
    if (!diskOut && canInteract)
    {
        if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) changeSelection(-1);
        if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) changeSelection(1);
        if (FlxG.keys.justPressed.ENTER) simulateCoverClick();
        
        // EXIT TO MENU when disc is tucked
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
        {
            FlxG.switchState(new ModState("MyCustomMenu"));
        }
    }
    else if (diskOut && canInteract)
    {
        if (FlxG.keys.justPressed.ENTER) simulateDiscClick();
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) tuckDisc();
    }

    // --- MOUSE NAVIGATION ---
    if (FlxG.mouse.wheel != 0 && !diskOut && canInteract) changeSelection(-FlxG.mouse.wheel);
    
    if (FlxG.mouse.overlaps(cover) && FlxG.mouse.justPressed && !diskOut && canInteract) simulateCoverClick();
    if (FlxG.mouse.overlaps(discNorm) && FlxG.mouse.justPressed && diskOut && canInteract) simulateDiscClick();
    if (FlxG.mouse.justPressed && diskOut && !FlxG.mouse.overlaps(discNorm) && canInteract) tuckDisc();

    // Right click to go back to Menu
    if (FlxG.mouse.justPressedRight && canInteract)
    {
        if (diskOut) tuckDisc();
        else FlxG.switchState(new ModState("MyCustomMenu"));
    }
}

function simulateCoverClick()
{
    canInteract = false;
    FlxG.sound.music.fadeOut(0.5);
    
    FlxTween.tween(songBackground, {alpha: 0.4}, 1.8, {ease: FlxEase.expoOut});
    
    var songName:String = songs[curSelected].folderName;
    previewMusic = FlxG.sound.play(Paths.music("previews/" + songName), 0, true);
    previewMusic.fadeIn(0.5, 0, 0.3);

    FlxG.sound.play(Paths.sound("vinyl_eject"));
    
    var targetDiscX = cover.x + 200;
    FlxTween.tween(cover, {x: cover.x - 600, angle: -45, alpha: 0}, 1.2, {
        ease: FlxEase.backIn, 
        onComplete: function(_) { cover.visible = false; }
    });
    
    FlxTween.tween(discNorm, {x: targetDiscX, angle: 360}, 1.5, {ease: FlxEase.elasticOut});
    new FlxTimer().start(1.5, function(_) { canInteract = true; diskOut = true; });

    // Update the presence to use the song's custom presence art if it exists
    UpdatePresence(songs[curSelected].presence);
}

function simulateDiscClick()
{
    canControl = false;
    canInteract = false;
    
    FlxTween.tween(songBackground, {alpha: 0}, 1, {ease: FlxEase.expoOut});
    FlxTween.tween(songText, {alpha: 0}, 1, {ease: FlxEase.expoOut});
    if (previewMusic != null) previewMusic.fadeOut(0.5);
    FlxG.sound.music.stop();
    FlxG.sound.play(Paths.sound("confirmMenu"));
    
    FlxTween.tween(discNorm.scale, {x: 5, y: 5}, 1.2, {ease: FlxEase.cubeIn});
    FlxTween.tween(discNorm, {angle: discNorm.angle + 1440, alpha: 0}, 1.2, { 
        ease: FlxEase.cubeIn, 
        onComplete: function(_) {
            var stateName:String = songs[curSelected].preludeState;
            FlxG.switchState(new ModState(stateName));
        }
    });
}

function tuckDisc() {
    diskOut = false;
    canInteract = false;
    
    FlxTween.tween(songBackground, {alpha: 0}, 1.2, {ease: FlxEase.expoOut});
    FlxG.sound.play(Paths.sound("vinyl_back"));
    
    if (previewMusic != null) previewMusic.fadeOut(0.3, 0, function(_) { previewMusic.stop(); });
    FlxG.sound.music.fadeIn(0.5, 0, 0.3);

    cover.visible = true;
    FlxTween.tween(cover, {x: 200, angle: 0, alpha: 1}, 0.6, {ease: FlxEase.cubeOut});

    var tuckedDiscX = 200 + (cover.width - discNorm.width) / 2;
    FlxTween.tween(discNorm, {x: tuckedDiscX, angle: 0}, 0.6, {ease: FlxEase.cubeOut});

    new FlxTimer().start(0.6, function(_) { canInteract = true; });

    // Reset the presence back to the menu default image key
    UpdatePresence();
}

function changeSelection(change:Int)
{
    FlxG.sound.play(Paths.sound("scrollMenu"));
    curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

    songBackground.loadGraphic(Paths.image("freeplay/bg_" + songs[curSelected].folderName));
    songBackground.setGraphicSize(FlxG.width, FlxG.height);
    songBackground.updateHitbox();

    cover.scale.set(0.45, 0.45);
    FlxTween.tween(cover.scale, {x: 0.5, y: 0.5}, 0.3, {ease: FlxEase.expoOut});

    cover.loadGraphic(Paths.image("freeplay/cover_" + songs[curSelected].folderName));
    cover.updateHitbox();
    cover.x = 200;
    cover.y = (FlxG.height - cover.height) / 2;

    discNorm.loadGraphic(Paths.image("freeplay/vinyl_" + songs[curSelected].folderName));
    discNorm.updateHitbox();
    discNorm.x = cover.x + (cover.width - discNorm.width) / 2;
    discNorm.y = cover.y + (cover.height - discNorm.height) / 2;
    discNorm.angle = 0;

    songText.text = songs[curSelected].displayName;
}

function UpdatePresence(?customImage:String)
{
    // If no customImage is provided (or it's blank), use the default key
    var img:String = (customImage != null && customImage != "") ? customImage : "coverart-f";

    if (FlxG.save.data.devmodeBox)
    {
        DiscordUtil.changePresenceAdvanced({
            details: menuDetail,
            state: menuStateDEV,
            largeImageKey: img
        });
    }
    else 
    {
        DiscordUtil.changePresenceAdvanced({
            details: menuDetail,
            state: menuState,
            largeImageKey: img
        });
    }
}