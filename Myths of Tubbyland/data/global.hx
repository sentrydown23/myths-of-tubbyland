import funkin.backend.system.framerate.Framerate;
import flixel.FlxG;
import funkin.backend.scripting.Script;

// Load user settings from save data
var botplayValue:Bool = FlxG.save.data.botplayBox;
var devmodeValue:Bool = FlxG.save.data.devmodeBox;
var tinkymemeValue:Bool = FlxG.save.data.tinkymeme;
var forcefullscreenValue:Bool = FlxG.save.data.forcefullscreen;
var specialHitSoundsValue:Bool = FlxG.save.data.specialHitSounds;
var bordertoggleValue:String = FlxG.save.data.borderToggle;

function init() {
    // Initialize the whiteout script
    Script.create(Paths.script('data/scripts/whiteout'));
}

function new() {
    // Set default values for save data if they are null
    if (FlxG.save.data.botplayBox == null)
        FlxG.save.data.botplayBox = true;

    if (FlxG.save.data.devmodeBox == null)
        FlxG.save.data.devmodeBox = false;

    if (FlxG.save.data.tinkymeme == null)
        FlxG.save.data.tinkymeme = false;
    
    if (FlxG.save.data.forcefullscreen == null)
        FlxG.save.data.forcefullscreen = true;

    if (FlxG.save.data.borderToggle == null)
        FlxG.save.data.borderToggle = "on";

    if (FlxG.save.data.specialHitSounds == null)
        FlxG.save.data.specialHitSounds = true;
}

function preStateSwitch() {
    // Log current settings to the console if dev editing is enabled
    if(FlxG.save.data.devmodeBox) {
    trace("------------");
    trace("Botplay: " + botplayValue);
    trace("Devmode: " + devmodeValue);
    trace("Force Fullscreen: " + forcefullscreenValue);
    trace("Borders: " + bordertoggleValue);
    trace("Special Hit Sounds: " + specialHitSoundsValue);
    trace("Tinky Meme: " + tinkymemeValue);
    trace("------------");
    }

    // Hide the framerate overlay during state transitions
    if (Framerate.instance != null) {
        Framerate.instance.visible = false;
    }

    // Apply fullscreen setting
    if (FlxG.save.data.forcefullscreen == true) {
        FlxG.fullscreen = true;
    }
}