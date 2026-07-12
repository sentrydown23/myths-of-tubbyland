import funkin.game.PlayState;

function onSongEnd() 
{
    if (isCStoryMode)
    {
        trace("TLM Complete in Story Mode, setting save to true");
        FlxG.save.data.tlmComplete = true;
        FlxG.save.flush();
        isCStoryMode = false;
    }
    else if (!isCStoryMode)
    {
        trace("TLM Complete in Freeplay, nothing changes");
    }
}