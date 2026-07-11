import funkin.game.PlayState;
// Important game.playstate in case I need it later

// Substate Overrides
GameOverSubstate.script = "data/scripts/gameovers/gameoverNP";
PauseSubState.script = 'data/scripts/pause/pauseNP';

// Botplay option parsing
var isBotplayEnabled = FlxG.save.data.botplayBox;
trace("Botplay variable is currently: " + isBotplayEnabled);

function postCreate()
{
    if (isBotplayEnabled)
    {
        player.cpu = true;
        trace("Botplay is enabled!");
    }
    else if(!isBotplayEnabled) {
        trace("Botplay is disabled!");
    }
}

function onPlayerHit(e)
{
    if (e.noteType == "custard")
        e.note.splash = "custard";
}