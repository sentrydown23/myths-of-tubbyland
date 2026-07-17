import funkin.game.PlayState;
var song = SONG.meta.name;


function postCreate()
{
    song = SONG.meta.name;
}



function onSongEnd(event) 
{
    if (isCStoryMode)
    {
        event.cancel(); 
        inst.stop();
        vocals.stop();

        switch(song)
        {
            case "nocturnal-protocol":
                FlxG.save.data.npComplete = true;
                FlxG.save.flush();
                FlxG.save.data.activeCutscenePath = "story/tlm";
                FlxG.save.data.activeCutsceneTarget = "PreludeTLMState";
                FlxG.switchState(new ModState("StoryCutsceneState"));

            case "the-lions-mouth":
                FlxG.save.data.tlmComplete = true;
                FlxG.save.flush();
                isCStoryMode = false;
                FlxG.switchState(new ModState("placeholders/To Be Continued"));

        }
    }
}