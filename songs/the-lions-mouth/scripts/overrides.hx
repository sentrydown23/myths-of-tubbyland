import funkin.game.PlayState;
// Important game.playstate in case I need it later

// Substate Overrides
GameOverSubstate.script = "data/scripts/gameovers/gameoverTLM";
PauseSubState.script = 'data/scripts/pause/pauseTLM';

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