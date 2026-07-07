var damageAmount:Float = 0.1; 
var missDamageAmount:Float = 0.3; 
var minimumDamage:Float = 1; // maximum health is 2, so 1 would be 50%

function onPlayerHit(e)
{
    if(e.noteType == "sawnote")
    {
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