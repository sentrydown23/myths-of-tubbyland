import funkin.game.PlayState;

trace("Story Mode is: " + isCStoryMode);

function onSongEnd(event) 
{
    if (isCStoryMode)
    {
        event.cancel(); 
        inst.stop();
        vocals.stop();
        trace("NP Complete in Story Mode, setting save to true");
        FlxG.save.data.npComplete = true;
        FlxG.save.flush();
        FlxG.save.data.activeCutscenePath = "story/tlm";
        FlxG.save.data.activeCutsceneTarget = "PreludeTLMState";
        FlxG.switchState(new ModState("StoryCutsceneState"));
    }
    else if (!isCStoryMode)
    {
        trace("NP Complete in Freeplay, nothing changes");
    }
}

function update(elapsed:Float) {
    // If the player presses the SPACEBAR key
    if (FlxG.keys.justPressed.SPACE) {
        // Instantly triggers the song's ending sequence
        PlayState.instance.endSong(); 
    }
}

