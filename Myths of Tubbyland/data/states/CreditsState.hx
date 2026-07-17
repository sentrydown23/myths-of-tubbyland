import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;

var creditsList:Array<Dynamic> = [
    {category: "DEVELOPMENT", name: "Lead Developer", txt: "data/credits/lead.txt"},
    {category: "DEVELOPMENT", name: "Helping Hand", txt: "data/credits/helper.txt"},
    {category: "Assets", name: "Nocturnal Protocol", txt: "data/credits/npasset.txt"},
    {category: "Assets", name: "The Lions Mouth", txt: "data/credits/tlmasset.txt"},
    {category: "Music", name: "Musician", txt: "data/credits/music.txt"},
    {category: "TESTERS", name: "Testers", txt: "data/credits/testers.txt"}
];

var menuItems:FlxTypedGroup;
var categoryHeaders:FlxTypedGroup; 
var titleBox:FlxText;
var displayBox:FlxText;
var bg:FlxSprite;
var leftShade:FlxSprite; 

var curSelected:Int = 0;
var fontPath:String = Paths.font("LD Slender Regular");

var targetY:Float = 0;
var menuContainerY:Float = 0;
var initialPositions:Array<Float> = []; 
var headerPositions:Array<Float> = [];

var typingTween:FlxTween;
var titleTween:FlxTween;
var targetText:String = "";
var targetTitle:String = "";

function create() {
    FlxG.mouse.visible = true;
    FlxG.cameras.bgColor = 0xFF0A0A0C; 

    leftShade = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 0.40), FlxG.height, 0xFF141416);
    leftShade.alpha = 0.85; 
    add(leftShade);

    categoryHeaders = new FlxTypedGroup();
    add(categoryHeaders);

    menuItems = new FlxTypedGroup();
    add(menuItems);

    var lastCategory:String = "";
    var currentY:Float = 0; 

    for (i in 0...creditsList.length) {
        var itemData = creditsList[i];
        
        if (itemData.category != lastCategory) {
            lastCategory = itemData.category;
            var catHeader:FlxText = new FlxText(40, currentY, 0, itemData.category.toUpperCase());
            catHeader.setFormat(fontPath, 16, 0xFF6C757D, "left"); 
            catHeader.bold = true;
            categoryHeaders.add(catHeader);
            headerPositions.push(currentY);
            currentY += 35;
        }

        var menuItem:FlxText = new FlxText(55, currentY, 450, itemData.name);
        menuItem.setFormat(fontPath, 26, FlxColor.WHITE, "left");
        menuItem.ID = i;
        menuItems.add(menuItem);
        initialPositions.push(currentY);
        
        currentY += 55;
    }

    titleBox = new FlxText(FlxG.width * 0.45, 70, FlxG.width * 0.5, "");
    titleBox.setFormat(fontPath, 44, FlxColor.WHITE, "left");
    titleBox.bold = true;
    add(titleBox);

    displayBox = new FlxText(FlxG.width * 0.45, 155, FlxG.width * 0.5, "");
    displayBox.setFormat(fontPath, 22, 0xFFE2E8F0, "left"); 
    add(displayBox);

    changeSelection(0);
    menuContainerY = targetY; 
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) changeSelection(-1);
    if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) changeSelection(1);

    if (FlxG.mouse.wheel != 0) {
        changeSelection(-FlxG.mouse.wheel);
    }

    for (item in menuItems.members) {
        if (FlxG.mouse.overlaps(item) && FlxG.mouse.justPressed) {
            if (curSelected != item.ID) {
                curSelected = item.ID;
                changeSelection(0);
            }
        }
    }

    var lerpSpeed:Float = 10 * elapsed;
    if (lerpSpeed > 1) lerpSpeed = 1;
    menuContainerY = menuContainerY + (targetY - menuContainerY) * lerpSpeed;

    for (i in 0...menuItems.members.length) {
        menuItems.members[i].y = initialPositions[i] + menuContainerY;
    }
    for (i in 0...categoryHeaders.members.length) {
        categoryHeaders.members[i].y = headerPositions[i] + menuContainerY;
    }

    for (item in menuItems.members) {
        if (item.ID == curSelected) {
            item.color = 0xFFFF0000; 
            item.alpha = 1.0;
            item.scale.set(1.03, 1.03); 
        } else {
            item.color = FlxColor.WHITE;
            item.alpha = 0.45; 
            item.scale.set(1.0, 1.0);
        }
    }

    if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE) {
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxG.mouse.visible = false;
        FlxG.switchState(new ModState("MyCustomMenu"));
    }
}

function changeSelection(change:Int = 0) {
    if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

    curSelected += change;

    if (curSelected < 0) curSelected = creditsList.length - 1;
    if (curSelected >= creditsList.length) curSelected = 0;

    loadCreditsText(creditsList[curSelected].txt);
    
    targetY = (FlxG.height * 0.45) - initialPositions[curSelected];
}

function loadCreditsText(filePath:String) {
    if (typingTween != null) typingTween.cancel();
    if (titleTween != null) titleTween.cancel();
    
    titleBox.text = "";
    displayBox.text = "";
    targetTitle = "";
    targetText = "";
    
    if (Assets.exists(Paths.file(filePath))) {
        var rawText:String = Assets.getText(Paths.file(filePath));
        var cleanText:String = StringTools.replace(rawText, "\r\n", "\n");
        
        if (StringTools.contains(cleanText, "(") && StringTools.contains(cleanText, ")")) {
            var openIdx:Int = cleanText.indexOf("(");
            var closeIdx:Int = cleanText.indexOf(")");
            
            if (closeIdx > openIdx) {
                targetTitle = cleanText.substring(openIdx + 1, closeIdx);
                targetText = StringTools.trim(cleanText.substring(closeIdx + 1));
            } else {
                targetText = cleanText;
            }
        } else {
            targetText = cleanText;
        }
    } else {
        targetText = "Missing text file at:\n" + filePath;
    }

    if (targetTitle.length > 0) {
        titleTween = FlxTween.num(0, targetTitle.length, targetTitle.length * 0.012, {
            onUpdate: function(t:FlxTween) {
                titleBox.text = targetTitle.substring(0, Std.int(t.value));
            },
            onComplete: function(_) {
                titleBox.text = targetTitle;
            }
        });
    }

    typingTween = FlxTween.num(0, targetText.length, targetText.length * 0.004, {
        onUpdate: function(t:FlxTween) {
            displayBox.text = targetText.substring(0, Std.int(t.value));
        },
        onComplete: function(_) {
            displayBox.text = targetText;
        }
    });
}