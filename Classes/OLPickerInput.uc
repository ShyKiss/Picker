Class OLPickerInput extends OLPlayerInput;

var PrivateWrite IntPoint MousePos;
var array<Name> Keys;
var vector2D Movement, Turning;

Event PlayerInput(float DeltaTime) {

    if (myHUD != None /*&& OLPickerHud(HUD).ToggleHUD==true*/) {

        MousePos.X = Clamp(MousePos.X + aMouseX, 0, myHUD.SizeX);
        MousePos.Y = Clamp(MousePos.Y - aMouseY, 0, myHUD.SizeY);
    }

    Super.PlayerInput(DeltaTime);
    Movement=vect2d(aBaseY, aStrafe);
    Turning=vect2d(aMouseX, aMouseY);
}

Function bool Key(Int ControllerId, Name Key, EInputEvent Event, Float AmountDepressed = 1.f, bool bGamepad=false) {

    if (ContainsName(Keys, Key)) {
        Keys.RemoveItem(Key);
        return false;
    }

    Keys.additem(Key);
    if (OLPickerHud(HUD).ToggleHUD==true) {
        switch (key) {
            Case 'LeftMouseButton':
                OLPickerHud(HUD).Click();
                break;

            case 'Enter':
                OLPickerHud(HUD).Commit();
                break;

            case 'Backspace':
                OLPickerHud(HUD).Command = Left(OLPickerHud(HUD).Command, len(OLPickerHud(HUD).Command)-1);
                break;

            case 'Tilde':
                ConsoleCommand("ToggleDebugMenu 0");
                break;
        }

        return true;
    }

    return false;
}

Function Bool Char(Int ControllerId, string Unicode) {
    local int Character;

    Character = Asc(Left(Unicode, 1));

    if (OLPickerHud(HUD).ToggleHUD==true) {
        if (Character >= 0x20 && Character < 0x100 && Unicode!="`") {
            OLPickerHud(HUD).Command = OLPickerHud(HUD).Command $ Unicode;
        }
        return true;
    }
    return false;
}

Function Bool ContainsName(Array<Name> Array, Name find) {
    Switch(Array.Find(find))
    {
        case -1:
            return False;
        break;

        default:
            return true;
        break;
    }
}

Defaultproperties
{
    OnReceivedNativeInputKey=Key
    OnReceivedNativeInputChar=Char
}