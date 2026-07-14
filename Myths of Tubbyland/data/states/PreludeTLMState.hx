import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import openfl.utils.Assets;
import flixel.util.FlxTimer;
import funkin.backend.utils.DiscordUtil;

// State configuration variables
var targetSongFolder:String = "the-lions-mouth"; 
var textPages:Array<String> = [
    "data/preludeinfo/prelude-the-lions-mouth-0.txt",
    "data/preludeinfo/prelude-the-lions-mouth-1.txt"
];
var difficulties:Array<String> = ["easy", "normal", "hard", "hell"];
var curDifficulty:Int = 2; 

var hasMechPage:Bool = true;
var mechTextPath:String = "data/preludeinfo/prelude-the-lions-mouth-mech.txt";
var mechImgPath:String = "preludeinfo/prelude-the-lions-mouth-mech";

var curPage:Int = 0;
var onMechPage:Bool = false;
var isTransitioning:Bool = false;

var firstLineText:FlxText;
var restLinesText:FlxText;
var npText:FlxText;
var mechSpr:FlxSprite;

var typingTween:FlxTween;
var currentFullFirstLine:String = ""; // Needed for skipping

var diffTitleText:FlxText;
var diffDisplayText:FlxText;
var diffHintText:FlxText;

function create()
{
    UpdatePresence();
    FlxG.mouse.visible = true;
    if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        FlxG.sound.playMusic(Paths.music("ambience"));

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    add(bg);

    firstLineText = new FlxText(50, 80, FlxG.width - 100, "", 28);
    firstLineText.setFormat(Paths.font("LD Slender Regular.ttf"), 40, 0xFFFFFFFF, "left");
    firstLineText.borderStyle = FlxTextBorderStyle.OUTLINE;
    firstLineText.borderSize = 2;
    add(firstLineText);

    restLinesText = new FlxText(50, 140, FlxG.width - 100, "", 28);
    restLinesText.setFormat(Paths.font("LD Slender Regular.ttf"), 40, 0xFFFFFFFF, "left");
    restLinesText.borderStyle = FlxTextBorderStyle.OUTLINE;
    restLinesText.borderSize = 2;
    restLinesText.alpha = 0;
    add(restLinesText);

    mechSpr = new FlxSprite(0, FlxG.height + 50);
    mechSpr.alpha = 0;
    add(mechSpr);

    npText = new FlxText(0, FlxG.height - 140, FlxG.width, "", 24);
    npText.setFormat(Paths.font("LD Slender Regular.ttf"), 44, 0xFFFFFFFF, "center");
    npText.alpha = 0;
    add(npText);

    diffTitleText = new FlxText(0, FlxG.height - 100, FlxG.width, "Difficulty:", 24);
    diffTitleText.setFormat(Paths.font("LD Slender Regular.ttf"), 32, 0xFFFFFFFF, "center");
    diffTitleText.alpha = 0.6;
    add(diffTitleText);

    diffDisplayText = new FlxText(0, FlxG.height - 70, FlxG.width, difficulties[curDifficulty].toUpperCase(), 32);
    diffDisplayText.setFormat(Paths.font("LD Slender Regular.ttf"), 44, 0xFF9DD744, "center");
    add(diffDisplayText);

    diffHintText = new FlxText(0, FlxG.height - 30, FlxG.width, "Press F to change Difficulty", 18);
    diffHintText.setFormat(Paths.font("LD Slender Regular.ttf"), 24, 0xFFFFFFFF, "center");
    diffHintText.alpha = 0.5;
    add(diffHintText);

    loadPreludePage(0);
}

function skipAnimations() {
    if (typingTween != null) typingTween.cancel();
    FlxTween.cancelTweensOf(firstLineText);
    FlxTween.cancelTweensOf(restLinesText);
    
    firstLineText.text = currentFullFirstLine;
    firstLineText.alpha = 1;
    restLinesText.alpha = 1;
    isTransitioning = false;
}

function update(elapsed:Float)
{
    var skipPressed:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || 
                           FlxG.keys.justPressed.A || FlxG.keys.justPressed.D || FlxG.mouse.justPressed;

    if (isTransitioning && skipPressed) {
        skipAnimations();
        return; 
    }

    if (isTransitioning) return;

    var hitNext:Bool = FlxG.keys.justPressed.D || (FlxG.mouse.justPressed && FlxG.mouse.x >= FlxG.width / 2);
    var hitBack:Bool = FlxG.keys.justPressed.A || (FlxG.mouse.justPressed && FlxG.mouse.x < FlxG.width / 2);

    if (hitNext)
    {
        if (onMechPage) startSongGameplay();
        else if (curPage + 1 < textPages.length) loadPreludePage(curPage + 1);
        else if (hasMechPage && Assets.exists(Paths.file(mechTextPath))) loadMechanicsPage();
        else startSongGameplay();
    }
    else if (hitBack)
    {
        if (onMechPage) {
            onMechPage = false;
            hideMechanicImage();
            loadPreludePage(curPage);
        } else if (curPage > 0) loadPreludePage(curPage - 1);
        else exitToFreeplayState();
    }
    
    if (FlxG.keys.justPressed.F)
    {
        curDifficulty++;
        if (curDifficulty >= difficulties.length) curDifficulty = 0;
        diffDisplayText.text = difficulties[curDifficulty].toUpperCase();
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }
}

function loadPreludePage(targetPage:Int)
{
    isTransitioning = true;
    if (typingTween != null) typingTween.cancel();
    FlxTween.cancelTweensOf(firstLineText);
    FlxTween.cancelTweensOf(restLinesText);

    firstLineText.alpha = 0;
    restLinesText.alpha = 0;
    
    curPage = targetPage;
    var textContent:String = Assets.getText(Paths.file(textPages[curPage]));
    
    if (curPage == 0) npText.text = "A / CLICK LEFT: CANCEL   |   D / CLICK RIGHT: NEXT PAGE";
    else npText.text = "A / CLICK LEFT: PREV PAGE   |   D / CLICK RIGHT: NEXT PAGE";

    npText.alpha = 0.6;
    formatAndTypewriter(textContent);
}

function loadMechanicsPage()
{
    isTransitioning = true;
    if (typingTween != null) typingTween.cancel();
    
    firstLineText.alpha = 0;
    restLinesText.alpha = 0;

    onMechPage = true;
    var textContent:String = Assets.getText(Paths.file(mechTextPath));
    npText.text = "A / CLICK LEFT: PREV PAGE   |   D / CLICK RIGHT: START GAME";
    
    formatAndTypewriter(textContent);
    showMechanicImage();
}

function formatAndTypewriter(rawText:String)
{
    rawText = StringTools.replace(rawText, "\r\n", "\n");
    var lines:Array<String> = rawText.split("\n");
    currentFullFirstLine = lines[0]; // Store for skip function
    
    var bodyText:String = (lines.length > 1) ? lines.slice(1).join("\n") : "";

    firstLineText.text = "";
    firstLineText.alpha = 1;
    restLinesText.text = bodyText;
    restLinesText.alpha = 0;

    firstLineText.updateHitbox();
    restLinesText.y = firstLineText.y + firstLineText.height + 25;

    typingTween = FlxTween.num(0, currentFullFirstLine.length, currentFullFirstLine.length * 0.04, {
        onUpdate: function(t:FlxTween) {
            firstLineText.text = currentFullFirstLine.substring(0, Std.int(t.value));
        },
        onComplete: function(_) {
            firstLineText.text = currentFullFirstLine;
            FlxTween.tween(restLinesText, {alpha: 1}, 0.5, {
                startDelay: 0.8, 
                onComplete: function(_) { isTransitioning = false; }
            });
        }
    });
}

function showMechanicImage()
{
    if (Assets.exists(Paths.image(mechImgPath))) {
        mechSpr.loadGraphic(Paths.image(mechImgPath));
        mechSpr.updateHitbox();
        mechSpr.screenCenter(0x10);
        mechSpr.x = FlxG.width - mechSpr.width - 300; 
        mechSpr.y = FlxG.height + 50;
        mechSpr.alpha = 0;
        FlxTween.tween(mechSpr, {alpha: 1, y: (FlxG.height - mechSpr.height) / 2}, 0.6, {ease: FlxEase.backOut});
    }
}

function hideMechanicImage()
{
    if (mechSpr.alpha > 0) FlxTween.tween(mechSpr, {alpha: 0, y: FlxG.height + 50}, 0.25, {ease: FlxEase.cubeIn});
}

function startSongGameplay()
{
    isTransitioning = true;
    hideMechanicImage();
    FlxTween.tween(firstLineText, {alpha: 0}, 0.4);
    FlxTween.tween(restLinesText, {alpha: 0}, 0.4);
    FlxTween.tween(npText, {alpha: 0}, 0.4, {
        onComplete: function(_) {
            new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                PlayState.loadSong(targetSongFolder, difficulties[curDifficulty]);
                FlxG.switchState(new PlayState());
            });
        }
    });
}

function exitToFreeplayState()
{
    isTransitioning = true;
    FlxG.sound.music.fadeOut(0.3, 0);
    FlxTween.tween(firstLineText, {alpha: 0}, 0.3);
    FlxTween.tween(restLinesText, {alpha: 0}, 0.3);
    FlxTween.tween(npText, {alpha: 0}, 0.3, {
        onComplete: function(_) {
            FlxG.sound.music.stop();
            if (isCStoryMode)
            {
                FlxG.switchState(new ModState("CStoryModeState"));
            }
            else if (!isCStoryMode)
            {
            FlxG.switchState(new ModState("VinylFreeplayState"));
            }
        }
    });
}

function UpdatePresence()
{
    if (FlxG.save.data.devmodeBox)
    {
        DiscordUtil.changePresenceAdvanced({
            details: "The Lions Mouth",
            state: "Prelude (DEV)",
            largeImageKey: "coverart-2",       
        });
    }
    else 
    {
        DiscordUtil.changePresenceAdvanced({
            details: "The Lions Mouth",
            state: "Prelude",
            largeImageKey: "coverart-2",       
        });
    }
}