import funkin.game.PlayState;


function postCreate()
{
    strumLines.members[1].characters[0].visible = false;
    strumLines.members[1].characters[2].visible = false;
    strumLines.members[1].characters[3].visible = false;
    strumLines.members[1].characters[4].visible = false;
    strumLines.members[1].characters[5].visible = false;
    strumLines.members[1].characters[6].visible = false;
    strumLines.members[1].characters[7].visible = false;

    strumLines.members[0].characters[0].visible = false;
    strumLines.members[0].characters[1].visible = false;
    strumLines.members[0].characters[2].visible = false;
    strumLines.members[0].characters[3].visible = false;
    strumLines.members[0].characters[4].visible = false;
    strumLines.members[0].characters[5].visible = false;

        startSong();
}

function onCountdown(event) {
   event.cancel();
}

function beatHit(_)
{
    switch(_)
    {
        case 80:
            strumLines.members[1].characters[1].visible = false;
            strumLines.members[0].characters[2].visible = true;
            strumLines.members[0].characters[2].animation.play("anim", true);
        case 81:
            strumLines.members[0].characters[2].visible = false;
        case 82:
            strumLines.members[0].characters[1].visible = true;
            
        case 84:
            strumLines.members[0].characters[1].visible = false;
            strumLines.members[0].characters[0].visible = true;
            strumLines.members[1].characters[0].visible = true;
        case 152:
            strumLines.members[1].characters[2].visible = false;
            strumLines.members[0].characters[0].visible = false;
            strumLines.members[1].characters[3].visible = true;
            strumLines.members[0].characters[3].visible = true;
        case 153:
            strumLines.members[1].characters[0].visible = false;
        case 184:
            strumLines.members[1].characters[3].visible = false;
            strumLines.members[0].characters[3].visible = false;
            strumLines.members[1].characters[4].visible = true;
            strumLines.members[0].characters[4].visible = true;
        case 215: 
            FlxTween.tween(strumLines.members[1].characters[4], {alpha: 0}, 0.5);
            FlxTween.tween(strumLines.members[0].characters[4], {alpha: 0}, 0.5);
        case 216:
        if (FlxG.save.data.tinkymeme == false) {
            strumLines.members[0].characters[5].visible = true;
            strumLines.members[0].characters[5].animation.play("dance", true);
        }
        case 224:
        if (FlxG.save.data.tinkymeme == false) {
            strumLines.members[0].characters[5].alpha = 0;
            strumLines.members[1].characters[5].visible = true;
        }
        case 232:
        if (FlxG.save.data.tinkymeme == false) {
            strumLines.members[1].characters[5].visible = false;
            strumLines.members[0].characters[5].alpha = 1;
            strumLines.members[0].characters[5].animation.play("dance", true);
        }
        case 240:
        if (FlxG.save.data.tinkymeme == false) {
            strumLines.members[0].characters[5].alpha = 0;
            strumLines.members[1].characters[5].visible = true;
        }
        case 247:
        if (FlxG.save.data.tinkymeme == false) {
            FlxTween.tween(strumLines.members[1].characters[5], {alpha: 0}, 0.5);
        }
        case 280:
            strumLines.members[1].characters[3].visible = true;
            strumLines.members[0].characters[3].visible = true;
        case 312:
            strumLines.members[1].characters[3].visible = false;
            strumLines.members[0].characters[3].visible = false;
            strumLines.members[1].characters[6].visible = true;
        case 319:
            strumLines.members[1].characters[6].visible = false;
            strumLines.members[1].characters[7].visible = true;
            strumLines.members[1].characters[7].animation.play("walk", true);
        case 321:
            FlxTween.tween(strumLines.members[1].characters[7], {alpha: 0}, 0.5);
    }
}

function stepHit(_) {
    switch (_) {
        case 329:
            strumLines.members[0].characters[1].animation.play("turn", true);
        case 605:
            strumLines.members[1].characters[0].visible = false;
            strumLines.members[1].characters[2].visible = true;
            strumLines.members[1].characters[2].animation.play("run", true);
        case 734:
            strumLines.members[1].characters[3].visible = false;
            strumLines.members[0].characters[3].visible = false;
    }
}