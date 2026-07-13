import flixel.FlxG;
import flixel.util.FlxTimer;
import funkin.backend.scripting.ModState;
import funkin.backend.MusicBeatTransition;
import hxvlc.flixel.FlxVideoSprite;

// =====================================================================
// MANUAL CONFIGURATION
// =====================================================================
// Set this scale factor to match your project grid layout requirements.
// E.g., 0.6666 scales a native 1920x1080 file perfectly down to 1280x720.
var MANUAL_VIDEO_SCALE:Float = 0.6666; 
// =====================================================================

var cutsceneVideoSprite:FlxVideoSprite;
var isCutsceneStarted:Bool = false;
var targetDestination:String = "";

function create() {
    // 1. Lock camera coordinates flush to zero matrix
    FlxG.camera.scroll.set(0, 0);
    FlxG.mouse.visible = false;

    // 2. Fetch transmission parameters
    var videoAsset:String = FlxG.save.data.activeCutscenePath;
    targetDestination = FlxG.save.data.activeCutsceneTarget;

    FlxG.save.data.activeCutscenePath = null;
    FlxG.save.data.activeCutsceneTarget = null;

    if (videoAsset == null || videoAsset == "" || targetDestination == null || targetDestination == "") {
        abortAndSwitch("PreludeNPState"); 
        return;
    }

    // 3. Instantiate container asset
    cutsceneVideoSprite = new FlxVideoSprite(0, 0);
    cutsceneVideoSprite.antialiasing = true;
    cutsceneVideoSprite.scrollFactor.set(0, 0);

    // --- OFFICIAL DOCUMENTATION EVENT HOOKS ---
    cutsceneVideoSprite.bitmap.onFormatSetup.add(function():Void {
        if (cutsceneVideoSprite.bitmap != null && cutsceneVideoSprite.bitmap.bitmapData != null) {
            // Apply the manual configuration scale variable securely inside the format allocation frame
            cutsceneVideoSprite.setGraphicSize(
                cutsceneVideoSprite.bitmap.bitmapData.width * MANUAL_VIDEO_SCALE, 
                cutsceneVideoSprite.bitmap.bitmapData.height * MANUAL_VIDEO_SCALE
            );
            cutsceneVideoSprite.updateHitbox();
            cutsceneVideoSprite.screenCenter();
        }
    });

    // Handle automated state completion hooks using the engine signals
    cutsceneVideoSprite.bitmap.onEndReached.add(function():Void {
        abortAndSwitch(targetDestination);
    });

    add(cutsceneVideoSprite);

    var fullPath:String = Paths.video(videoAsset);
    if (!cutsceneVideoSprite.load(fullPath)) {
        abortAndSwitch(targetDestination);
    } else {
        // Essential micro-delay execution required by hxvlc to safely bind threads
        new FlxTimer().start(0.001, function(timer:FlxTimer) {
            if (cutsceneVideoSprite != null) {
                cutsceneVideoSprite.play();
                isCutsceneStarted = true;
            }
        });
    }
}

function update(elapsed:Float) {
    FlxG.camera.scroll.set(0, 0);
    
    // --- VIDEO SKIP LOGIC ---
    // Instantly skips the cutscene if ENTER or NUMPADENTER is pressed
    if (FlxG.keys.justPressed.ENTER) {
        abortAndSwitch(targetDestination);
    }
}

function abortAndSwitch(destination:String) {
    if (cutsceneVideoSprite != null) {
        // Clear references out so callbacks don't throw double-disposal bugs
        if (cutsceneVideoSprite.bitmap != null) {
            cutsceneVideoSprite.bitmap.onFormatSetup.removeAll();
            cutsceneVideoSprite.bitmap.onEndReached.removeAll();
        }
        cutsceneVideoSprite.stop();
        cutsceneVideoSprite.destroy();
        cutsceneVideoSprite = null;
    }
    MusicBeatTransition.script = 'data/scripts/blackout';
    FlxG.switchState(new ModState(destination));
}

function destroy() {
    if (cutsceneVideoSprite != null) {
        if (cutsceneVideoSprite.bitmap != null) {
            cutsceneVideoSprite.bitmap.onFormatSetup.removeAll();
            cutsceneVideoSprite.bitmap.onEndReached.removeAll();
        }
        cutsceneVideoSprite.stop();
        cutsceneVideoSprite.destroy();
    }
}
