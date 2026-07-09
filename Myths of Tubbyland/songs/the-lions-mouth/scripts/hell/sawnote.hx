import funkin.game.PlayState;

var damageAmount:Float = 0.8; // do 40% on hit
var missDamageAmount:Float = 0.4; // do 20% on miss to compensate for such a low minimum damage 
var minimumDamage:Float = 0.5; // maximum health is 2, so 0.5 would be 25%
var soundVolume:Float = 4.0; // default volume 

function onPlayerHit(e)
{
    if(e.noteType == "sawnote")
    {
        if(FlxG.save.data.specialHitSounds == true) 
        FlxG.sound.play(Paths.sound("sawhit"), soundVolume);


        var potentialHealth = health - damageAmount; // potentialHealth is current players health - damageAmount

        // Calculate if potentialHealth is greater than or equal to minimumDamage, then run code if it is
        if (potentialHealth >= minimumDamage) {
            health = potentialHealth; // Apply the damage
        } 
    }
}

function onPlayerMiss(e)
{
    if(e.noteType == "sawnote")
    {
        if(FlxG.save.data.specialHitSounds == true) 
        FlxG.sound.play(Paths.sound("sawmiss"), 3.0);
        e.cancel(true);
        e.note.strumLine.deleteNote(e.note);
        
        FlxG.camera.shake(0.05, 0.2);
        FlxG.camera.flash(0xFFFF0000, 0.3);
        
        // Calculate the result of the health deduction
        var newHealth = health - missDamageAmount;
        
        // Check if the result is 0 or less
        if (newHealth <= 0)
        {
            GameOverSubstate.script = "data/scripts/gameovers/gameoverTLMSawnote";
        }
        
        // Apply the damage
        health = newHealth;
    }
}

function beatHit(_) 
{
    switch(_) 
    {
        case 199:
        soundVolume = 1.0;

        case 263:
        soundVolume = 4.0;

        case 391:
        soundVolume = 1.0;

        case 463:
        soundVolume = 4.0;
    }
}