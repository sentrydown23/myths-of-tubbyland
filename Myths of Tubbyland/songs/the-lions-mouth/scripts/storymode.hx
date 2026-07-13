import funkin.game.PlayState;

function onSongEnd(event) 
{
    if (isCStoryMode)
    {
        event.cancel(); 
        inst.stop();
        vocals.stop();
        trace("TLM Complete in Story Mode, setting save to true");
        FlxG.save.data.tlmComplete = true;
        FlxG.save.flush();
        // FlxG.save.data.activeCutscenePath = "story/";
        // FlxG.save.data.activeCutsceneTarget = "";
        isCStoryMode = false;
        FlxG.switchState(new ModState("placeholders/To Be Continued"));
    }
    else if (!isCStoryMode)
    {
        trace("TLM Complete in Freeplay, nothing changes");
    }
}


function update(elapsed:Float) {
    // If the player presses the SPACEBAR key
    if (FlxG.keys.justPressed.SPACE) {
        // Instantly triggers the song's ending sequence
        PlayState.instance.endSong(); 
    }
}

