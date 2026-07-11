import funkin.game.PlayState;

var drainAmount:Float = 0;
var gainAmount:Float = 0;
var minimumHealth:Float = 0.1;
var maximumHealth:Float = 2;

if(FlxG.save.data.notedrain)
{
function onNoteHit(event) {
    if (!event.player && health > minimumHealth && event.noteType != "sawnote")
        health -= drainAmount;

    if (event.player && health < maximumHealth && event.noteType != "sawnote")
        health += gainAmount;
}

function beatHit(_)
{
    switch(_)
    {
        case 136:
            drainAmount = 0.025;
            gainAmount = 0.005;
        
        case 166:
            drainAmount = 0;

        case 168:
            drainAmount = 0.025;

        case 184:
            if (health > 1)
            health = 1;

        case 200:
            drainAmount = 0;
            gainAmount = 0;

        case 264:
            drainAmount = 0.027;
            gainAmount = 0.008;

        case 328:
            drainAmount = 0.025;
            gainAmount = 0.005;

        case 392:
            drainAmount = 0;
            gainAmount = 0;
        
        case 460:
            health = 1;

        case 464:
            drainAmount = 0.01;
            gainAmount = 0.005; 
    }
}
}