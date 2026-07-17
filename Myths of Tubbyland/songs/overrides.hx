import funkin.game.PlayState;

var gameoverState = GameOverSubstate;
var pauseState = PauseSubState;

function postCreate()
{
    switch(SONG.meta.name)
    {
        case "nocturnal-protocol":
            gameoverState.script = "data/scripts/gameovers/gameoverNP";
            pauseState.script = 'data/scripts/pause/pauseNP';

        case "the-lions-mouth":
            gameoverState.script = "data/scripts/gameovers/gameoverTLM";
            pauseState.script = 'data/scripts/pause/pauseTLM';
    }
}

function onPlayerHit(e)
{
    if (e.noteType == "custard")
        e.note.splash = "custard";
    
    if (e.noteType == "sawnote")
        e.note.splash = "spark";
}