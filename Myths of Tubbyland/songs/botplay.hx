import flixel.FlxG;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// Clean, untyped variable at the script level
var bText;
var breathingTime:Float = 0;

function postCreate()
{
    if (FlxG.save.data.botplayBox)
    {
        player.cpu = true;

        // 1. Create a transparent top camera overlay and add it to the game
        var botplayCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        botplayCam.bgColor = 0; 
        FlxG.cameras.add(botplayCam, false);

        // 2. Create the "[BOTPLAY]" indicator text using your original layout
        bText = new FlxText(0, 0, FlxG.width, "[BOTPLAY]");
        bText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, "center", "outline", FlxColor.BLACK);
        bText.borderSize = 2;

        // 3. Position it using your original working alignment
        bText.screenCenter(FlxAxes.X);
        bText.y = FlxG.height - 60;

        // 4. Pin the text directly to the new camera overlay
        bText.cameras = [botplayCam];

        add(bText);
    }
}

function update(elapsed:Float)
{
    // Ultimate universal check: If bText doesn't exist yet, stop immediately
    if (bText == null || bText.alpha == null) return;

    breathingTime += elapsed;
    
    // Smoothly pulse the opacity of the text on its camera layer
    bText.alpha = 0.6 + (Math.sin(breathingTime * 3) * 0.4);
}
