import funkin.game.PlayState;


var border:FlxSprite;
var barLeft:FlxSprite;
var barRight:FlxSprite;
var barTop:FlxSprite;
var barBottom:FlxSprite;

// Create a separate camera for the border and bars
var borderCam:FlxCamera;

function create() {
    switch (FlxG.save.data.borderToggle) {
        case "on":
            borderON();
        case "partial":
            borderPartial();
        case "off":
            borderOFF();
        default:
            // Fallback if the setting is null or invalid
            borderOFF();
    }
}

function borderOFF() {}

function borderON() {
    // Screen dimensions
    var screenW:Int = FlxG.width;   // 1280
    var screenH:Int = FlxG.height;  // 720
    
    // Dimensions for 4:3 (height 720, width 960)
    var gameW:Int = 960;
    var gameH:Int = 720;
    var offsetX:Int = (screenW - gameW) / 2; // 160 pixels of black bars on the sides
    
    // ---- CREATE CAMERA FOR THE BORDER ----
    borderCam = new FlxCamera(0, 0, screenW, screenH);
    borderCam.bgColor = 0x00000000; // Transparent background
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;
    
    // Add camera to the camera list (above all others)
    FlxG.cameras.add(borderCam, false);
    
    // Left bar
    barLeft = new FlxSprite(0, 0);
    barLeft.makeGraphic(offsetX, screenH, 0xFF000000);
    barLeft.scrollFactor.set(0, 0);
    barLeft.cameras = [borderCam]; // Assign to the new camera
    add(barLeft);
    
    // Right bar
    barRight = new FlxSprite(screenW - offsetX, 0);
    barRight.makeGraphic(offsetX, screenH, 0xFF000000);
    barRight.scrollFactor.set(0, 0);
    barRight.cameras = [borderCam]; // Assign to the new camera
    add(barRight);
    
    // ---- CREATE STROKE INSIDE 4:3 ----
    
    border = new FlxSprite(offsetX, 0);
    border.loadGraphic(Paths.image("stages/satstat/obv"));
    
    if (border.graphic == null)
    {
        trace("❌ Image not found!");
        border.makeGraphic(gameW, gameH, 0xFFFF0000);
    }
    
    // Stretch to 4:3 size
    border.setGraphicSize(gameW, gameH);
    border.updateHitbox();
    border.scrollFactor.set(0, 0);
    border.cameras = [borderCam]; // Assign to the new camera
    add(border);
}

function borderPartial() {
    // Screen dimensions
    var screenW:Int = FlxG.width;   // 1280
    var screenH:Int = FlxG.height;  // 720
    
    // Dimensions for 4:3 (height 720, width 960)
    var gameW:Int = 960;
    var gameH:Int = 720;
    var offsetX:Int = (screenW - gameW) / 2; // 160 pixels of black bars on the sides
    
    // ---- CREATE CAMERA FOR THE BORDER ----
    borderCam = new FlxCamera(0, 0, screenW, screenH);
    borderCam.bgColor = 0x00000000; // Transparent background
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;
    
    // Add camera to the camera list (above all others)
    FlxG.cameras.add(borderCam, false);
    
    // Left bar
    barLeft = new FlxSprite(0, 0);
    barLeft.makeGraphic(offsetX, screenH, 0xFF000000);
    barLeft.scrollFactor.set(0, 0);
    barLeft.cameras = [borderCam]; // Assign to the new camera
    add(barLeft);
    
    // Right bar
    barRight = new FlxSprite(screenW - offsetX, 0);
    barRight.makeGraphic(offsetX, screenH, 0xFF000000);
    barRight.scrollFactor.set(0, 0);
    barRight.cameras = [borderCam]; // Assign to the new camera
    add(barRight);
}