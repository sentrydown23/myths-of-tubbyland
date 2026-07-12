import funkin.game.PlayState;

trace("Story Mode is: " + isCStoryMode);

function onSongEnd() 
{
    if (isCStoryMode)
    {
        trace("NP Complete in Story Mode, setting save to true");
        FlxG.save.data.npComplete = true;
        FlxG.save.flush();
        isCStoryMode = false;
    }
    else if (!isCStoryMode)
    {
        trace("NP Complete in Freeplay, nothing changes");
    }
}