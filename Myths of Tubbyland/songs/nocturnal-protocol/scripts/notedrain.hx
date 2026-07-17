import funkin.game.PlayState;

var drainAmount:Float = 0.025;
var screamerDrainAmount:Float = 0.1;
var gainAmount:Float = 0.02;
var minimumHealth:Float = 0.1;
var maximumHealth:Float = 2;

if (FlxG.save.data.notedrain && !FlxG.save.data.botplayBox) {
function onNoteHit(event) {
    if (!event.player && health > minimumHealth && event.noteType != "Screamer")
    {
        health -= drainAmount;
    }
    else if (!event.player && health > minimumHealth && event.noteType == "Screamer")
    {
        health -= screamerDrainAmount;
    }

    if (event.player && event.noteType != "custard" && health < maximumHealth)
    health += gainAmount;
}

function beatHit(e)
{
    switch(e)
    {
        case 152:
            drainAmount = 0;
            gainAmount = 0.001;

        case 184:
            drainAmount = 0.025;
            gainAmount = 0.02;

        case 216:
            drainAmount = 0.015;
            gainAmount = 0;
            health = 1;

        case 248:
            drainAmount = 0;
            gainAmount = 0; 
    }
}
}