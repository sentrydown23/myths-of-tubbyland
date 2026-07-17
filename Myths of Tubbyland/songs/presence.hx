import flixel.FlxG;
import funkin.game.PlayState;
import funkin.backend.scripting.ModState;
import funkin.backend.utils.DiscordUtil;

// Timer to throttle Discord updates to prevent rate-limiting (Discord updates roughly every 5 seconds)
var discordUpdateTimer:Float = 0.0;

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

// This function runs every frame of the game
function update(elapsed:Float)
{
    if (PlayState.instance != null && !PlayState.instance.paused)
    {
        discordUpdateTimer += elapsed;
        
        // Only push to Discord once every 5 seconds so the API doesn't ignore us
        if (discordUpdateTimer >= 5.0)
        {
            UpdatePresence();
            discordUpdateTimer = 0.0;
        }
    }
}

function UpdatePresence()
{
    var diffUpper = PlayState.instance.difficulty.toUpperCase();
    
    // Safely format the accuracy string or display N/A if no notes are hit yet
    var accString = "N/A";
    if (PlayState.instance.accuracy >= 0)
    {
        var rawAccuracy:Float = PlayState.instance.accuracy * 100;
        var formattedAccuracy:Float = Math.floor(rawAccuracy * 100) / 100;
        accString = formattedAccuracy + "%";
    }

    var liveMisses:Int = PlayState.instance.misses;
    var liveScore:Int = PlayState.instance.songScore;

    // Default gameplay stats string
    var statsString = "Accuracy: " + accString + " - Misses: " + liveMisses + " - Score: " + liveScore;

    // If botplay is active, replace the stats line with "(BOTPLAY)"
    if (FlxG.save.data.botplayBox)
    {
        statsString = "(BOTPLAY)";
    }

    switch(SONG.meta.name)
    {
        case "nocturnal-protocol":
            var songName = "Playing: Nocturnal Protocol (" + diffUpper + ")";
            var songData = FlxG.sound.music;
            
            DiscordUtil.config.logoKey = "coverart-1";

            DiscordUtil.changeSongPresence(
                songName,
                statsString,
                songData,
                ""
            );

        case "the-lions-mouth":
            var songName = "Playing: The Lions Mouth (" + diffUpper + ")";
            var songData = FlxG.sound.music;
            
            DiscordUtil.config.logoKey = "coverart-2";

            DiscordUtil.changeSongPresence(
                songName,
                statsString,
                songData,
                ""
            );
    }    
}

function UpdatePresenceRevert()
{
    var diffUpper = PlayState.instance.difficulty.toUpperCase();
    
    var accString = "N/A";
    if (PlayState.instance.accuracy >= 0)
    {
        var rawAccuracy:Float = PlayState.instance.accuracy * 100;
        var formattedAccuracy:Float = Math.floor(rawAccuracy * 100) / 100;
        accString = formattedAccuracy + "%";
    }

    var liveMisses:Int = PlayState.instance.misses;
    var liveScore:Int = PlayState.instance.songScore;

    var statsString = "Accuracy: " + accString + " - Misses: " + liveMisses + " - Score: " + liveScore;

    if (FlxG.save.data.botplayBox)
    {
        statsString = "(BOTPLAY)";
    }

    switch(SONG.meta.name)
    {
        case "nocturnal-protocol":
            var songName = "Paused: Nocturnal Protocol (" + diffUpper + ")";

            DiscordUtil.changePresenceAdvanced({
                details: songName,
                state: statsString,
                largeImageKey: "coverart-1"       
            });

        case "the-lions-mouth":
            var songName = "Paused: The Lions Mouth (" + diffUpper + ")";

            DiscordUtil.changePresenceAdvanced({
                details: songName,
                state: statsString,
                largeImageKey: "coverart-2"       
            });
    }    
}