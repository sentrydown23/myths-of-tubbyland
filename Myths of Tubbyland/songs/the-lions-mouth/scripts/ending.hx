var endingSprites:Array<String> = [
    "stages/satstat/ending/goodend",
    "stages/satstat/ending/goodend2"
];

var endingSpr:FunkinSprite;
var sawNoteMisses:Int = 0; // Create a miss counter specifically for sawnote

// Track misses
function onPlayerMiss(e)
{
    // If the player missed a sawnote, increment our counter
    if(e.noteType == "sawnote")
    {
        sawNoteMisses++;
    }
}

function beatHit(curBeat:Int)
{
    switch(curBeat)
    {
        case 568:
            chooseEnding();
    }
}

function chooseEnding()
{
    endingSpr = new FunkinSprite();
    
    // Load the image based on our new sawNoteMisses counter
    endingSpr.loadGraphic(Paths.image(
        sawNoteMisses > 0
            ? endingSprites[1]
            : endingSprites[0]
    ));
    
    // Center in the middle of the screen
    endingSpr.screenCenter();
    
    // Camera and scroll configuration
    endingSpr.cameras = [camGame];
    endingSpr.scrollFactor.set();
    endingSpr.alpha = 0;
    
    // If sawnote misses are greater than 0, shift slightly higher
    if(sawNoteMisses > 0)
    {
        endingSpr.y -= 100;
    }
    
    add(endingSpr);
    
    // Scale
    endingSpr.scale.set(0.8, 0.8);
    
    // Appearance animation
    FlxTween.tween(endingSpr, {alpha: 1}, 2, {
        ease: FlxEase.quadOut
    });
}