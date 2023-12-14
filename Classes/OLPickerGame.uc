Class OLPickerGame extends OLGame
    Config(Tool);

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal) { return Default.class; }

DefaultProperties
{
    PlayerControllerClass=Class'Picker.OLPickerController'
    HUDType=Class'Picker.OLPickerHud'
    DefaultPawnClass=Class'Picker.OLPickerPawn'
}