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
var HINT_FONT_SIZE:Int = 20; // Size for the upcoming song text

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

// Mandatory intro video path for starting a New Game
var NEW_GAME_CUTSCENE:String = "story/newgame";

// =====================================================================
// STORY PROGRESSION PIPELINE (Add new songs here in chronological order)
// =====================================================================
var storyPipeline:Array<{saveKey:String, targetState:String, displayName:String, cutscene:String}> = [
    {saveKey: "npComplete",  targetState: "PreludeNPState", displayName: "Nocturnal Protocol", cutscene: ""}, 
    {saveKey: "tlmComplete", targetState: "PreludeTLMState", displayName: "The Lions Mouth", cutscene: ""} // End game fallback
];
// =====================================================================

var bgSprite:FlxSprite;
var titleText:FlxText;
var videoSprite:FlxVideoSprite;    
var videoHitbox:FlxSprite;          

var options:Array<String> = ["NEW GAME", "CONTINUE"];
var textObjects:Array<FlxText> = [];
var hintText:FlxText; // Text object for the song preview hint
var curSelected:Int = 0;
var ambientAudio:FlxSound;

var camTimer:Float = 0;             
var isVideoPlaying:Bool = true;    
var hasSave:Bool = false;
var isClean:Bool = false;
isCStoryMode = false;

// Fullscreen video layer management for narrative cutscenes
var cutsceneVideoSprite:FlxVideoSprite;
var isPlayingCutscene:Bool = false;
var isCutsceneStarted:Bool = false;
var cutsceneTargetState:String = ""; // Track next destination safely

function create() {
    // Determine the save state routing before building the menu items
    var pipelineData = getContinueDestination();

    if (FlxG.save.data.npComplete == true)
    {
        hasSave = true;
    }
    else
    {
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
    
    var vlcOptions:Array<String> = [
        'input-repeat=99999', 
        'gain=' + VIDEO_AUDIO_BOOST
    ];

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
            // Dynamically scale text appearance depending on save history
            if (pipelineData.targetState == "") {
                menuText.color = 0xFF444444; // Grayed out if all are false
            } else {
                menuText.color = 0xFFFFFFFF; // Fully visible if a save state exists
            }
            menuText.text = "CONTINUE";
        }
        
        add(menuText);
        textObjects.push(menuText);
    }

    // Create Hint Text directly under the CONTINUE button position
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
        hintText.alpha = 0.3; // Matches idle unselected state alpha
    }
    add(hintText);

    // Initialize full-screen cutscene container over everything
    cutsceneVideoSprite = new FlxVideoSprite(0, 0);
    cutsceneVideoSprite.scrollFactor.set(0, 0); 
    cutsceneVideoSprite.visible = false;
    add(cutsceneVideoSprite);

    changeSelection(0, false); 
}

function update(elapsed:Float) {
    // Check if the cutscene is running and has finished playing
    if (isPlayingCutscene) {
        if (cutsceneVideoSprite != null) {
            // ONLY check bitmap parameters if the engine has fully finished instantiating it
            if (cutsceneVideoSprite.bitmap != null) {
                if (cutsceneVideoSprite.bitmap.isPlaying) {
                    // Fix scaling the exact frame the video kicks off
                    if (!isCutsceneStarted) {
                        isCutsceneStarted = true;
                        
                        // Scale the video perfectly back to Flixel's native display dimensions
                        cutsceneVideoSprite.setGraphicSize(FlxG.width, FlxG.height);
                        cutsceneVideoSprite.updateHitbox();
                        cutsceneVideoSprite.screenCenter();
                    }
                }
                
                // If it officially kicked off and has now finished, move on
                if (isCutsceneStarted && !cutsceneVideoSprite.bitmap.isPlaying && cutsceneTargetState != "") {
                    executeStateSwitch(cutsceneTargetState);
                }
            }
        }
        return; // Halt regular menu updates while cutscene plays
    }

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

    if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
        changeSelection(-1, true);
    }
    if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
        changeSelection(1, true);
    }

    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || FlxG.mouse.justPressedRight) {
        quitMenu();
    }

    if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
        selectOption();
    }
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

    if (playSound) {
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }

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
            playCutsceneThenSwitch(NEW_GAME_CUTSCENE, "PreludeNPState");
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
                playCutsceneThenSwitch(pipelineData.cutscene, pipelineData.targetState);
            } else {
                executeStateSwitch(pipelineData.targetState);
            }
        }
    }
}

function playCutsceneThenSwitch(cutscenePath:String, destinationState:String) {
    // Instantly snap the camera back to center coordinates and lock it.
    // This stops the camera matrix translation mid-frame before the video can sample positions.
    resetCamera();

    // 1. Immediately clean up and stop the background menu audio/video assets
    if (ambientAudio != null) {
        ambientAudio.stop();
    }
    if (videoSprite != null) {
        videoSprite.stop();
        videoSprite.destroy();
        videoSprite = null; 
    }
    if (videoHitbox != null) {
        videoHitbox.destroy();
    }

    // 2. Hide all remaining menu elements so nothing can flicker when the video ends
    if (bgSprite != null) bgSprite.visible = false;
    if (titleText != null) titleText.visible = false;
    if (hintText != null) hintText.visible = false;
    
    for (i in 0...textObjects.length) {
        if (textObjects[i] != null) {
            textObjects[i].visible = false;
        }
    }

    // 3. Arm the cutscene state tracker
    isPlayingCutscene = true;
    isCutsceneStarted = false;
    cutsceneTargetState = destinationState;
    FlxG.mouse.visible = false;

    // 4. Load and play the fullscreen cutscene
    var fullPath:String = Paths.video(cutscenePath);
    if (cutsceneVideoSprite.load(fullPath)) {
        cutsceneVideoSprite.visible = true;
        cutsceneVideoSprite.play();
    } else {
        // Fallback if video file is missing
        executeStateSwitch(destinationState);
    }
}

function executeStateSwitch(stateTarget:String) {
    cutsceneTargetState = ""; 
    isCutsceneStarted = false;
    
    // Clean up the cutscene player specifically
    if (cutsceneVideoSprite != null) {
        cutsceneVideoSprite.stop();
        cutsceneVideoSprite.destroy();
    }
    
    resetCamera();
    MusicBeatTransition.script = 'data/scripts/blackout';
    FlxG.switchState(new ModState(stateTarget));
}

function quitMenu() {
    resetCamera();
    cleanUpAssets();
    FlxG.sound.play(Paths.sound("cancelMenu"));
    FlxG.sound.music.volume = 0.7;
    FlxG.switchState(new ModState("MyCustomMenu"));
}

function resetCamera() {
    FlxG.camera.scroll.set(0, 0);
}

function cleanUpAssets() {
    isClean = true;
    if (ambientAudio != null) {
        ambientAudio.stop();
    }
    if (videoSprite != null) {
        videoSprite.stop();
        videoSprite.destroy();
    }
    if (videoHitbox != null) {
        videoHitbox.destroy();
    }
    if (cutsceneVideoSprite != null) {
        cutsceneVideoSprite.stop();
        cutsceneVideoSprite.destroy();
    }
}

function destroy() {
    resetCamera();
    cleanUpAssets();
}

// =====================================================================
// PIPELINE EVALUATION LOOPS
// =====================================================================
function getContinueDestination():{targetState:String, displayName:String, cutscene:String} {
    if (Reflect.field(FlxG.save.data, storyPipeline[0].saveKey) != true) {
        return {
            targetState: "", 
            displayName: "LOCKED",
            cutscene: ""
        };
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