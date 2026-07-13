import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import funkin.backend.scripting.ModState;
import funkin.backend.MusicBeatTransition;
import hxvlc.flixel.FlxVideoSprite;

// =====================================================================
// CONFIGURATION CONSTANTS
// =====================================================================
var TITLE_Y:Float = 150;
var TITLE_FONT_SIZE:Int = 45;

var NEW_GAME_X:Float = 150;
var CONTINUE_X:Float = 980;
var BUTTONS_Y:Float = 470;

var OPTIONS_FONT_SIZE:Int = 48;
var HINT_FONT_SIZE:Int = 20;

var VIDEO_PATH:String = "story/tv"; 
var VIDEO_SCALE:Float = 0.15;      

var VIDEO_AUDIO_BOOST:String = "100.0"; 

var AUTO_CENTER_X:Bool = false;     
var VIDEO_X:Float = -320;           
var VIDEO_Y:Float = -50;            

var HIDE_HITBOX_GUIDE:Bool = true;  
var HITBOX_WIDTH:Int = 340;         
var HITBOX_HEIGHT:Int = 240;        
var HITBOX_X:Float = 470;           
var HITBOX_Y:Float = 375;           

var SWAY_SPEED:Float = 1.5;         
var SWAY_X_REACH:Float = 15;        
var SWAY_Y_REACH:Float = 10;        

var NEW_GAME_CUTSCENE:String = "story/newgame";

// =====================================================================
// STORY PROGRESSION PIPELINE
// =====================================================================
var storyPipeline:Array<{saveKey:String, targetState:String, displayName:String, cutscene:String}> = [
    {saveKey: "npComplete",  targetState: "PreludeNPState", displayName: "Nocturnal Protocol", cutscene: ""}, 
    {saveKey: "tlmComplete", targetState: "PreludeTLMState", displayName: "The Lions Mouth", cutscene: "tlm"},
    {saveKey: "tbc", targetState: "placeholders/To Be Continued", displayName: "???", cutscene: ""}
];
// =====================================================================

var bgSprite:FlxSprite;
var titleText:FlxText;
var videoSprite:FlxVideoSprite;    
var videoHitbox:FlxSprite;          

var options:Array<String> = ["NEW GAME", "CONTINUE"];
var textObjects:Array<FlxText> = [];
var hintText:FlxText; 
var curSelected:Int = 0;
var ambientAudio:FlxSound;

var camTimer:Float = 0;             
var isVideoPlaying:Bool = true;    
var hasSave:Bool = false;
var isClean:Bool = false;
isCStoryMode = false;

function create() {
    if (FlxG.save.data.epilepsy == true)
        NEW_GAME_CUTSCENE = "story/newgamenoflash";
    var pipelineData = getContinueDestination();

    if (FlxG.save.data.npComplete == true) {
        hasSave = true;
    } else {
        hasSave = false;
    }   

    FlxG.mouse.visible = true;

    if (FlxG.sound.music != null) {
        FlxG.sound.music.volume = 0;
    }

    ambientAudio = FlxG.sound.load(Paths.music("story/storymode"));
    if (ambientAudio != null) {
        ambientAudio.looped = true;
        ambientAudio.volume = 0.6;
        ambientAudio.play();
    }

    bgSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/story/monitor"));
    bgSprite.antialiasing = true;
    bgSprite.scrollFactor.set(1, 1); 
    bgSprite.setGraphicSize(FlxG.width + (SWAY_X_REACH * 2), FlxG.height + (SWAY_Y_REACH * 2)); 
    bgSprite.updateHitbox();
    bgSprite.screenCenter();
    add(bgSprite);

    videoSprite = new FlxVideoSprite(0, 0); 
    videoSprite.scrollFactor.set(1, 1); 
    videoSprite.antialiasing = true;

    var nativePath:String = Paths.video(VIDEO_PATH);
    var vlcOptions:Array<String> = ['input-repeat=99999', 'gain=' + VIDEO_AUDIO_BOOST];

    if (videoSprite.load(nativePath, vlcOptions)) {
        videoSprite.play();
        videoSprite.scale.set(VIDEO_SCALE, VIDEO_SCALE);
        videoSprite.updateHitbox();
        videoSprite.y = VIDEO_Y;
        if (AUTO_CENTER_X) {
            videoSprite.x = (FlxG.width - videoSprite.width) / 2;
        } else {
            videoSprite.x = VIDEO_X;
        }
    }
    
    insert(members.indexOf(bgSprite) + 1, videoSprite);

    videoHitbox = new FlxSprite(HITBOX_X, HITBOX_Y);
    videoHitbox.makeGraphic(HITBOX_WIDTH, HITBOX_HEIGHT, 0xFF000000); 
    videoHitbox.scrollFactor.set(1, 1); 
    
    if (HIDE_HITBOX_GUIDE) {
        videoHitbox.alpha = 0.0001; 
    } else {
        videoHitbox.alpha = 0.6;    
    }
    add(videoHitbox);

    titleText = new FlxText(0, TITLE_Y, FlxG.width, "C A M P A I G N");
    titleText.setFormat(Paths.font("LD Slender Regular.ttf"), TITLE_FONT_SIZE, 0xFF888888, "center");
    titleText.letterSpacing = 4;
    titleText.scrollFactor.set(1, 1);
    add(titleText);

    for (i in 0...options.length) {
        var targetX:Float = (options[i] == "NEW GAME") ? NEW_GAME_X : CONTINUE_X;
        var displayWidth:Float = (options[i] == "NEW GAME") ? 400 : 500;

        var menuText:FlxText = new FlxText(targetX, BUTTONS_Y, displayWidth, options[i]);
        menuText.setFormat(Paths.font("LD Slender Regular.ttf"), OPTIONS_FONT_SIZE, 0xFFFFFFFF, "left");
        menuText.scrollFactor.set(1, 1);
        
        if (options[i] == "CONTINUE") {
            if (pipelineData.targetState == "") {
                menuText.color = 0xFF444444; 
            } else {
                menuText.color = 0xFFFFFFFF; 
            }
            menuText.text = "CONTINUE";
        }
        
        add(menuText);
        textObjects.push(menuText);
    }

    hintText = new FlxText(CONTINUE_X, BUTTONS_Y + OPTIONS_FONT_SIZE + 10, 500, "");
    hintText.setFormat(Paths.font("LD Slender Regular.ttf"), HINT_FONT_SIZE, 0xFFFFFFFF, "left");
    hintText.scrollFactor.set(1, 1);
    
    if (pipelineData.targetState == "") {
        hintText.text = "NEXT: LOCKED";
        hintText.color = 0xFF444444;
        hintText.alpha = 0.4;
    } else {
        hintText.text = "NEXT: " + pipelineData.displayName.toUpperCase();
        hintText.color = 0xFFFFFFFF;
        hintText.alpha = 0.3; 
    }
    add(hintText);

    changeSelection(0, false); 
}

function update(elapsed:Float) {
    camTimer += elapsed * SWAY_SPEED;
    FlxG.camera.scroll.x = Math.sin(camTimer) * SWAY_X_REACH;
    FlxG.camera.scroll.y = Math.cos(camTimer * 0.7) * SWAY_Y_REACH;

    if (!isClean && videoHitbox != null && FlxG.mouse.overlaps(videoHitbox)) {
        if (FlxG.mouse.justPressed) {
            toggleVideoState();
        }
    } else {
        for (i in 0...textObjects.length) {
            if (FlxG.mouse.overlaps(textObjects[i])) {
                if (curSelected != i) {
                    changeSelection(i - curSelected, true);
                }
                if (FlxG.mouse.justPressed) {
                    selectOption();
                }
            }
        }
    }

    if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) changeSelection(-1, true);
    if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) changeSelection(1, true);
    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || FlxG.mouse.justPressedRight) quitMenu();
    if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) selectOption();
}

function toggleVideoState() {
    if (videoSprite == null) return;

    if (isVideoPlaying) {
        FlxG.sound.play(Paths.sound("story/tv_off"), 3.0);
        videoSprite.pause();
        videoSprite.visible = false;
        isVideoPlaying = false;
    } else {
        FlxG.sound.play(Paths.sound("story/tv_on"), 3.0);
        videoSprite.visible = true;
        videoSprite.resume();
        isVideoPlaying = true;
    }
}

function changeSelection(change:Int, playSound:Bool) {
    curSelected += change;

    if (curSelected < 0) curSelected = options.length - 1;
    if (curSelected >= options.length) curSelected = 0;

    if (playSound) FlxG.sound.play(Paths.sound("scrollMenu"));

    var pipelineData = getContinueDestination();

    for (i in 0...textObjects.length) {
        var txt = textObjects[i];
        if (i == curSelected) {
            if (options[i] == "NEW GAME") {
                txt.color = 0xFFFFFFFF;
                txt.alpha = 1.0;
            } else {
                txt.color = 0xFF882222;
                txt.alpha = 1.0;
                if (pipelineData.targetState != "") {
                    hintText.color = 0xFF882222;
                    hintText.alpha = 1.0;
                }
            }
        } else {
            if (options[i] == "CONTINUE") {
                if (pipelineData.targetState == "") {
                    txt.color = 0xFF444444;
                    txt.alpha = 0.4;
                    hintText.color = 0xFF444444;
                    hintText.alpha = 0.4;
                } else {
                    txt.color = 0xFFFFFFFF;
                    txt.alpha = 0.4;
                    hintText.color = 0xFFFFFFFF;
                    hintText.alpha = 0.3;
                }
            } else {
                txt.color = 0xFFFFFFFF;
                txt.alpha = 0.3;
            }
        }
    }
}

function selectOption() {
    if (options[curSelected] == "NEW GAME") {
        FlxG.sound.play(Paths.sound("confirmMenu"));
        isNewGame = true;
        isCStoryMode = true;
        
        if (NEW_GAME_CUTSCENE != null && NEW_GAME_CUTSCENE != "") {
            switchWithCutscene(NEW_GAME_CUTSCENE, "PreludeNPState");
        } else {
            executeStateSwitch("PreludeNPState");
        }
    } 
    else if (options[curSelected] == "CONTINUE") {
        var pipelineData = getContinueDestination();

        if (pipelineData.targetState == "") {
            FlxG.sound.play(Paths.sound("story/locked"));
        } else {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            isCStoryMode = true; 
            
            if (pipelineData.cutscene != null && pipelineData.cutscene != "") {
                switchWithCutscene(pipelineData.cutscene, pipelineData.targetState);
            } else {
                executeStateSwitch(pipelineData.targetState);
            }
        }
    }
}

function switchWithCutscene(cutscenePath:String, destinationState:String) {
    resetCamera();
    cleanUpAssets();

    // Pass parameters safely into storage fields for the upcoming state to pick up
    FlxG.save.data.activeCutscenePath = cutscenePath;
    FlxG.save.data.activeCutsceneTarget = destinationState;

    MusicBeatTransition.script = 'data/scripts/blackout';
    FlxG.switchState(new ModState("StoryCutsceneState")); 
}

function executeStateSwitch(stateTarget:String) {
    resetCamera();
    cleanUpAssets();
    MusicBeatTransition.script = 'data/scripts/blackout';
    FlxG.switchState(new ModState(stateTarget));
}

function quitMenu() {
    resetCamera();
    cleanUpAssets();
    FlxG.sound.play(Paths.sound("cancelMenu"));
    if (FlxG.sound.music != null)
    FlxG.sound.music.volume = 0.7;
    FlxG.switchState(new ModState("MyCustomMenu"));
}

function resetCamera() {
    FlxG.camera.scroll.set(0, 0);
}

function cleanUpAssets() {
    isClean = true;
    if (ambientAudio != null) ambientAudio.stop();
    if (videoSprite != null) {
        videoSprite.stop();
        videoSprite.destroy();
    }
    if (videoHitbox != null) videoHitbox.destroy();
}

function destroy() {
    resetCamera();
    cleanUpAssets();
}

function getContinueDestination():{targetState:String, displayName:String, cutscene:String} {
    if (Reflect.field(FlxG.save.data, storyPipeline[0].saveKey) != true) {
        return { targetState: "", displayName: "LOCKED", cutscene: "" };
    }

    for (i in 0...storyPipeline.length - 1) {
        var currentBeaten = Reflect.field(FlxG.save.data, storyPipeline[i].saveKey) == true;
        var nextBeaten = Reflect.field(FlxG.save.data, storyPipeline[i + 1].saveKey) == true;

        if (currentBeaten && !nextBeaten) {
            return {
                targetState: storyPipeline[i + 1].targetState, 
                displayName: storyPipeline[i + 1].displayName,
                cutscene: (storyPipeline[i + 1].cutscene != null) ? storyPipeline[i + 1].cutscene : ""
            };
        }
    }

    var lastIndex = storyPipeline.length - 1;
    return {
        targetState: storyPipeline[lastIndex].targetState, 
        displayName: storyPipeline[lastIndex].displayName,
        cutscene: (storyPipeline[lastIndex].cutscene != null) ? storyPipeline[lastIndex].cutscene : ""
    };
}