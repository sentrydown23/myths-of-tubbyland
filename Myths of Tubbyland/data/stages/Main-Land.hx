var bgParts:Array<FlxSprite> = [];

function postCreate() {
    // Fill the array with background sprites
    bgParts = [forest, forest2, drop1, drop2, drop3, drop4, drop5, forest3, forest4, forest5, tinky, dipsy, lala, po];
    
    // Cache references to character sprites
    var tinky = bgParts[10];
    var dipsy = bgParts[11];
    var lala = bgParts[12];
    var po = bgParts[13];

    // Set camera for character sprites
    tinky.cameras = [camHUD];
    dipsy.cameras = [camHUD];
    lala.cameras = [camHUD];
    po.cameras = [camHUD];

    // Set initial alpha to 0 for all background parts
    for (bg in bgParts) {
        bg.alpha = 0;
    }
}

function beatHit(curBeat:Int) {
    switch (curBeat) {
        case 10:
            FlxTween.tween(bgParts[0], {alpha: 1}, 2.0);
            
        case 80:
            bgParts[0].alpha = 0;
            FlxTween.cancelTweensOf(bgParts[0]);
            
        case 84:
            bgParts[1].alpha = 1;
            
        case 152:
            bgParts[1].alpha = 0;
            bgParts[2].alpha = 0.6;
            
        case 184: 
            bgParts[7].alpha = 0.8;
            cycleDrops(-1);
            
        case 215:
            FlxTween.tween(bgParts[7], {alpha: 0}, 0.5); 
            
        case 216: 
            if (FlxG.save.data.tinkymeme == false) {
                bgParts[8].alpha = 0.3;
            }
            
        case 218, 222, 226, 230, 234, 238, 242, 246:
            if (FlxG.save.data.tinkymeme == false) {
                runMemeAnimation(curBeat); 
            }
        
        case 247:
            if (FlxG.save.data.tinkymeme == false) {
                FlxTween.tween(bgParts[8], {alpha: 0}, 0.5);
            }
        
        case 248:
            bgParts[9].alpha = 1;
            
        case 280:
            bgParts[9].alpha = 0;
            
        case 312:
            bgParts[7].alpha = 0;
            cycleDrops(-1);
            bgParts[0].alpha = 1;
            
        case 321:
            FlxTween.tween(bgParts[1], {alpha: 0}, 0.5);
    }
}

function runMemeAnimation(beat:Int) {
    // Determine which character sprite index to use
    var index = switch(beat) {
        case 218, 234: 10; // Tinky
        case 222, 238: 11; // Dipsy
        case 226, 242: 12; // Lala
        case 230, 246: 13; // Po
        default: -1;
    };
    
    // Run animation if a valid index is found
    if (index != -1) {
        bgParts[index].alpha = 1;
        bgParts[index].scale.set(2, 2);
        
        FlxTween.tween(bgParts[index].scale, {x: 3.2, y: 3.2}, 1.0, {ease: FlxEase.quadOut});
        FlxTween.tween(bgParts[index], {alpha: 0}, 1.0, {ease: FlxEase.linear});
    }
}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 610: 
            cycleDrops(1);
        case 608: 
            cycleDrops(0);
        case 612: 
            cycleDrops(2);
        case 614: 
            cycleDrops(3);
        case 616: 
            cycleDrops(4);
        case 618: 
            cycleDrops(0);
        case 620: 
            cycleDrops(1);
        case 622: 
            cycleDrops(2);
        case 624: 
            cycleDrops(3);
        case 626: 
            cycleDrops(4);
        case 628: 
            cycleDrops(0);
        case 630: 
            cycleDrops(1);
        case 632: 
            cycleDrops(2);
        case 634: 
            cycleDrops(3);
        case 636: 
            cycleDrops(4);
        case 638: 
            cycleDrops(0);
        case 640: 
            cycleDrops(1);
        case 642: 
            cycleDrops(2);
        case 644: 
            cycleDrops(3);
        case 646: 
            cycleDrops(4);
        case 648: 
            cycleDrops(0);
        case 650: 
            cycleDrops(1);
        case 652: 
            cycleDrops(2);
        case 654: 
            cycleDrops(3);
        case 656: 
            cycleDrops(4);
        case 658: 
            cycleDrops(0);
        case 660: 
            cycleDrops(1);
        case 662: 
            cycleDrops(2);
        case 664: 
            cycleDrops(3);
        case 666: 
            cycleDrops(4);
        case 668: 
            cycleDrops(0);
        case 670: 
            cycleDrops(1);
        case 672: 
            cycleDrops(2);
        case 674: 
            cycleDrops(3);
        case 676: 
            cycleDrops(4);
        case 678: 
            cycleDrops(0);
        case 680: 
            cycleDrops(1);
        case 682: 
            cycleDrops(2);
        case 684: 
            cycleDrops(3);
        case 686: 
            cycleDrops(4);
        case 688: 
            cycleDrops(0);
        case 690: 
            cycleDrops(1);
        case 692: 
            cycleDrops(2);
        case 694: 
            cycleDrops(3);
        case 696: 
            cycleDrops(4);
        case 698: 
            cycleDrops(0);
        case 700: 
            cycleDrops(1);
        case 702: 
            cycleDrops(2);
        case 704: 
            cycleDrops(3);
        case 706: 
            cycleDrops(4);
        case 708: 
            cycleDrops(0);
        case 710: 
            cycleDrops(1);
        case 712: 
            cycleDrops(2);
        case 714: 
            cycleDrops(3);
        case 716: 
            cycleDrops(4);
        case 718: 
            cycleDrops(0);
        case 720: 
            cycleDrops(1);
        case 722: 
            cycleDrops(2);
        case 724: 
            cycleDrops(3);
        case 726: 
            cycleDrops(4);
        case 728: 
            cycleDrops(0);
        case 730: 
            cycleDrops(1);
        case 732: 
            cycleDrops(2);
        case 734: 
            cycleDrops(-1);
        case 1120: 
            cycleDrops(0);
        case 1122: 
            cycleDrops(1);
        case 1124: 
            cycleDrops(2);
        case 1126: 
            cycleDrops(3);
        case 1128: 
            cycleDrops(4);
        case 1130: 
            cycleDrops(0);
        case 1132: 
            cycleDrops(1);
        case 1134: 
            cycleDrops(2);
        case 1136: 
            cycleDrops(3);
        case 1138: 
            cycleDrops(4);
        case 1140: 
            cycleDrops(0);
        case 1142: 
            cycleDrops(1);
        case 1144: 
            cycleDrops(2);
        case 1146: 
            cycleDrops(3);
        case 1148: 
            cycleDrops(4);
        case 1150: 
            cycleDrops(0);
        case 1152: 
            cycleDrops(1);
        case 1154: 
            cycleDrops(2);
        case 1156: 
            cycleDrops(3);
        case 1158: 
            cycleDrops(4);
        case 1160: 
            cycleDrops(0);
        case 1162: 
            cycleDrops(1);
        case 1164: 
            cycleDrops(2);
        case 1166: 
            cycleDrops(3);
        case 1168: 
            cycleDrops(4);
        case 1170: 
            cycleDrops(0);
        case 1172: 
            cycleDrops(1);
        case 1174: 
            cycleDrops(2);
        case 1176: 
            cycleDrops(3);
        case 1178: 
            cycleDrops(4);
        case 1180: 
            cycleDrops(0);
        case 1182: 
            cycleDrops(1);
        case 1184: 
            cycleDrops(2);
        case 1186: 
            cycleDrops(3);
        case 1188: 
            cycleDrops(4);
        case 1190: 
            cycleDrops(0);
        case 1192: 
            cycleDrops(1);
        case 1194: 
            cycleDrops(2);
        case 1196: 
            cycleDrops(3);
        case 1198: 
            cycleDrops(4);
        case 1200: 
            cycleDrops(0);
        case 1202: 
            cycleDrops(1);
        case 1204: 
            cycleDrops(2);
        case 1206: 
            cycleDrops(3);
        case 1208: 
            cycleDrops(4);
        case 1210: 
            cycleDrops(0);
        case 1212: 
            cycleDrops(1);
        case 1214: 
            cycleDrops(2);
        case 1216: 
            cycleDrops(3);
        case 1218: 
            cycleDrops(4);
        case 1220: 
            cycleDrops(0);
        case 1222: 
            cycleDrops(1);
        case 1224: 
            cycleDrops(2);
        case 1226: 
            cycleDrops(3);
        case 1228: 
            cycleDrops(4);
        case 1230: 
            cycleDrops(0);
        case 1232: 
            cycleDrops(1);
        case 1234: 
            cycleDrops(2);
        case 1236: 
            cycleDrops(3);
        case 1238: 
            cycleDrops(4);
        case 1240: 
            cycleDrops(0);
        case 1242: 
            cycleDrops(1);
        case 1244: 
            cycleDrops(2);
        case 1246: 
            cycleDrops(3);
    }
}

function cycleDrops(index:Int) {
    // Hide all drop background parts
    for (i in 2...7) {
        bgParts[i].alpha = 0;
    }
    
    // Set specified drop part alpha if index is valid
    if (index >= 0 && bgParts[index + 2] != null) {
        bgParts[index + 2].alpha = 0.2;
    }
}