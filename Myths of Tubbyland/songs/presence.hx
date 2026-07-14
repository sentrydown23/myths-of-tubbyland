import flixel.FlxG;
import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import funkin.backend.utils.DiscordUtil;

function create() {
    // Intercept the dynamic function instead of a blind override
    PlayState.instance.updateDiscordPresence = function() {
        if (PlayState.instance.paused) 
        {
            UpdatePresenceRevert();
        } 
        else 
        {
            UpdatePresence();
        }
    };
}

function postCreate()
{
    UpdatePresence();
}

function UpdatePresence()
{
    switch(SONG.meta.name)
    {
        case "nocturnal-protocol":
            var songDifficulty = "Difficulty: " + PlayState.instance.difficulty;
            var songName = "Playing: Nocturnal Protocol";
            var songData = FlxG.sound.music;
            DiscordUtil.config.logoKey = "coverart-1";

            DiscordUtil.changeSongPresence(
                songName,
                songDifficulty,
                songData,
                ""
            );

        case "the-lions-mouth":
            var songDifficulty = "Difficulty: " + PlayState.instance.difficulty;
            var songName = "Playing: The Lions Mouth";
            var songData = FlxG.sound.music;
            DiscordUtil.config.logoKey = "coverart-2";

            DiscordUtil.changeSongPresence(
                songName,
                songDifficulty,
                songData,
                ""
            );
    }    
}

function UpdatePresenceRevert()
{
    switch(SONG.meta.name)
    {
        case "nocturnal-protocol":
            var songDifficulty = "Difficulty: " + PlayState.instance.difficulty;
            var songName = "Paused: Nocturnal Protocol";

            DiscordUtil.changePresenceAdvanced({
                details: songName,
                state: songDifficulty,
                largeImageKey: "coverart-1",       
            });

        case "the-lions-mouth":
            var songDifficulty = "Difficulty: " + PlayState.instance.difficulty;
            var songName = "Paused: The Lions Mouth";

            DiscordUtil.changePresenceAdvanced({
                details: songName,
                state: songDifficulty,
                largeImageKey: "coverart-2",       
            });
    }    
}
