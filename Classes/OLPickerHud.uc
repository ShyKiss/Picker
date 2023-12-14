Class OLPickerHud extends OLHud
    Config(Tool);

struct ButtonStr
{
    var string Name;
    var string ConsoleCommand;
    var vector2d Start_Points;
    var vector2d End_Point;
    var vector2D Location;
    var vector2D Offset;
    var vector2D ClipStart;
    var vector2D ClipEnd;
    var bool template;
    var int Row;
    Var int Column;
};

struct RGBA
{
    var Byte Red;
    var Byte Green;
    var Byte Blue;
    var Byte Alpha;
};

enum Menu
{
    Normal,
    ShowDebug,
    Add,
    AddL,
    World,
    WDoors,
    WDoorsMT,
    Enemy,
    AddE,
    AddESpawn,
    Settings,
    STimer,
    Player,
    Other,
    RandomizerChoice,
    InsaneChoice,
    DisInsanePlus
};

var bool ToggleHUD, Pressed, AlreadyCommited, TSVBool;
var array<ButtonStr> Buttons;
var ButtonStr PrevButton;
var Menu CurrentMenu;
var OLPickerInput PickerInput;
var config bool DisableClickSound, DisableTeleportSound, DisablePause, DisablePickerDebug, DisableTimerDebug, DisableShowStamina;
var string Name, Version, Stamina, ButtonDesc, TimerTime, PlayerDebug, Command, TrainingMode;
var float TimerTimeSeconds, AudioVolume;

/**************MENU TAGS**************/
var string DebugFuncs, PlayerFuncs, EnemyFuncs, WorldFuncs, SettingsFuncs, DoorsFuncs, AddFuncs, TimerFuncs, LightFuncs, AddEnemyFuncs, OtherFuncs, InsaneChoiceFuncs, RandomizerChoiceFuncs;

/************************************************FUNCTIONS************************************************/
    
delegate ButtonPress();

Exec Function ToggleClickButton() {
    DisableClickSound=!DisableClickSound;
}

Exec Function TogglePauseMenu() {
    DisablePause=!DisablePause;
}

Exec Function ToggleTeleportButton() {
    DisableTeleportSound=!DisableTeleportSound;
}

Exec Function TogglePickerDebug() {
    DisablePickerDebug=!DisablePickerDebug;
}

Exec Function ToggleTimerDebug() {
    DisableTimerDebug=!DisableTimerDebug;
}

Exec Function ToggleShowDebugOnlyStamina() {
    DisableShowStamina=!DisableShowStamina;
}


/************************MAIN HUD FUNCTION************************/

Function DrawHUD() {
    local OLPickerController Controller;
    local OLGame CurrentGame;
    local OLPickerInput PlayerInput;
    local OLPickerPawn PickerPawn;
    local String GameType, HealthPlayer, PylonInfo;
    local Pylon P;
    Super.DrawHUD();

    Controller = OLPickerController(PlayerOwner);
    CurrentGame = OLPickerGame(WorldInfo.Game);
    PlayerInput = OLPickerInput(PlayerOwner.PlayerInput);
    PickerPawn = OLPickerPawn(PlayerOwner.Pawn);
    //Controller.ProfileSettings.GetProfileSettingValueFloat(57, AudioVolume);
    Buttons.Remove(0, Buttons.Length);
    if(PickerPawn.GodMode==true) {HealthPlayer="God";} else if(PickerPawn.GodModeInNoclip==true) {HealthPlayer="Noclip";} else {HealthPlayer="" $ OLHero(Controller.Pawn).Health;}
    if(CurrentGame.bIsPlayingDLC==true) {GameType = "Waylon/DLC";} else if(CurrentGame.bIsDemo==true) {GameType = "Miles/Demo";} else {GameType = "Miles/Main";}

    /******** WORLD INFO ********/

    Name = "[Picker]";
    Version = "Beta\nv1.1";
    PlayerDebug = "Random: " $ Controller.RandString(Controller.RandByte(35)) $ "\nVelocity: " $ OLHero(Controller.Pawn).AvgVelocity $ "\nPlayer Pos/Rot: " $ OLHero(Controller.Pawn).Location $ "/" $ OLHero(Controller.Pawn).Rotation.Yaw $ "\nCamera Pos/Rot: " $ Controller.DebugCamPos $ "/" $ Controller.DebugCamRot.Yaw $ "\nGame: " $ GameType $ " Health: " $ HealthPlayer $ " Limp: " $ OLHero(Controller.Pawn).bLimping $ " Hobble: " $ OLHero(Controller.Pawn).bHobbling $ "/" $ OLHero(Controller.Pawn).HobblingIntensity $ "\nCheckpoint/Objective: " $ CurrentGame.CurrentCheckpointName $ "/" $ Controller.CurrentObjective $ "\nFOV: " $ OLHero(Controller.Pawn).DefaultFOV $ "/" $ OLHero(Controller.Pawn).RunningFOV $ "/" $ OLHero(Controller.Pawn).CamcorderMaxFOV $ "\nEnemy Dist: " $ Controller.AIDistance * 100 $ "\nPhys/Loc: " $ OLHero(Controller.Pawn).Physics $ "/" $ OLHero(Controller.Pawn).LocomotionMode $ "\nStamina: " $ Controller.InsanePlusStamina;
    Stamina = "Stamina:" @ Controller.InsanePlusStamina; //$ "\n" $ CurrentGame.CurrentCheckpointName $ "\nJump: " $ OLHero(Controller.Pawn).bJumping $ "\nLSMDamage: " $ Controller.LSMDamage;
    TrainingMode = "Training Mode Enabled!";
    /*Foreach AllActors(Class'Pylon', P) {PylonInfo = "Pos: " $ P.Location $ "\nRadius: " $ P.ExpansionRadius $ "\nMax Radius: " $ P.MaxExpansionRadius $ "\nPoly Height: " $ P.MaxPolyHeight_Optional $ "\nRecast: " $ P.bUseRecast $ "\nForceCol: " $ P.bForceObstacleMeshCollision $ "\nDisabled: " $ P.bDisabled $ "\nNavMeshPtr: " $P.NavMeshPtr $ "\nObsMesh: " $ P.ObstacleMesh $ "\nDynObsMesh: " $ P.DynamicObstacleMesh $ "\nSetPtr: " $ P.WorkingSetPtr $"\nObjects: " $ P.PathObjectsThatAffectThisPylon $"\nOctree: " $ P.OctreeId $ "\nImported Mesh: " $ P.bImportedMesh $ "\nSphere Pylon: " $ P.bUseExpansionSphereOverride $ "\nNeed Check: " $ P.bNeedsCostCheck $ "\nInHighPath: " $ P.bPylonInHighLevelPath $ "\nAllow Recast: " $ P.bAllowRecastGenerator $ "\nBuild Pylon: " $ P.bBuildThisPylon $ 
     "\nNavGen: " $ P.NavMeshGenerator $ "\nPath Extent: " $ P.DebugPathExtent $ "\nPath Start Pos: " $ P.DebugPathStartLocation $ "\nSphere Center: " $ P.ExpansionSphereCenter $ "\nNext Pylon: " $ P.NextPylon $ "\nEdge Count: " $ P.DebugEdgeCount;
    //WorldTextDraw(PylonInfo, P.Location, 1500, 210, vect(100,0,0));}*/
    JDS(Name, vect2D(5, 5),MakeRGBA(255,40,40,240),vect2D(1.3, 1.3));
    JDS(Version, vect2D(1875, 5),MakeRGBA(255,40,40,240),vect2D(1.3, 1.3));
    if(Controller.InsanePlusState && Controller.TrainingMode) {JDS(TrainingMode, vect2D(830, 5),MakeRGBA(0,40,255,240),vect2D(2.2, 2.2));}
    if(!DisablePickerDebug && !Controller.InsanePlusState) {JDS(PlayerDebug, vect2D(5, 20),MakeRGBA(240,240,240,240),vect2D(1.3, 1.3));}
    if(!DisableTimerDebug) {JDS(TimerTime, vect2D(1770, 1050),MakeRGBA(0,255,90,240),vect2D(2.5, 2.5));}
    if(!DisableShowStamina && Controller.InsanePlusState) {JDS(Stamina, vect2D(5, 20),MakeRGBA(0,0,240,240),vect2D(1.7, 1.7));}
    PTimer(0.016);
    if(ToggleHUD) {

        PickerFunc();
        return;
    }
}

/************************MENU FUNCTION************************/

Event PickerFunc() {
    local Vector2D StartClip, EndClip;
    local OLPickerInput PlayerInput;
    local OLPickerController Controller;
    local OLPickerPawn PickerPawn;
    local Texture2D MouseTexture;
    local String TSVString, DRKString, ChrisString, PlayerModelString, DoorTypeState, DoorState;
    local Float PlayerModelScale;
    EndClip = EndClip;
    Controller = OLPickerController(PlayerOwner);
    PlayerInput = OLPickerInput(PlayerOwner.PlayerInput);
    PickerPawn = OLPickerPawn(Controller.Pawn);
    if(ButtonDesc == "DebugFuncs") {ButtonDesc=DebugFuncs;} else if(ButtonDesc == "PlayerFuncs") {ButtonDesc=PlayerFuncs;}
    else if(ButtonDesc == "EnemyFuncs") {ButtonDesc=EnemyFuncs;} else if(ButtonDesc == "WorldFuncs") {ButtonDesc=WorldFuncs;}
    else if(ButtonDesc == "SettingsFuncs") {ButtonDesc=SettingsFuncs;} else if(ButtonDesc == "DoorsFuncs") {ButtonDesc=DoorsFuncs;}
    else if(ButtonDesc == "AddFuncs") {ButtonDesc=AddFuncs;} else if(ButtonDesc == "TimerFuncs") {ButtonDesc=TimerFuncs;}
    else if(ButtonDesc == "LightFuncs") {ButtonDesc=LightFuncs;} else if(ButtonDesc == "OtherFuncs") {ButtonDesc=OtherFuncs;}
    else if(ButtonDesc == "AddEnemyFuncs") {ButtonDesc=AddEnemyFuncs;} else if(ButtonDesc == "InsaneChoiceFuncs") {ButtonDesc=InsaneChoiceFuncs;}
    else if(ButtonDesc == "RandomizerChoiceFuncs") {ButtonDesc=RandomizerChoiceFuncs;}

    /******** MENU DESCRIPTIONS ********/

    DebugFuncs = "-------------Debug Functions-------------\n \nShow AI - Show/Hide AI Info\nShow FPS - Show/Hide FPS\nShow LEVELS - Show/Hide Loaded Parts of Levels\nShow BSP - Show/Hide Brushes\nShow STATICMESHES - Show/Hide Static Meshes\nShow SKELETALMESHES - Show/Hide Skeletal Meshes\nShow PATHS - Show/Hide Enemies Paths\nShow BOUNDS - Show/Hide Actors Bounds\nShow COLLISION - Show/Hide Actors Collision\nShow VOLUMES - Show/Hide Volumes\nShow FOG - Show/Hide Fog\nShow POSTPROCESS - Show/Hide Postprocess\nShow LEVELCOLORATION - Show/Hide Actors Colors\nUncap FPS - Remove Limiter FPS\n \n--------------------------";
    PlayerFuncs = "-------------Player Functions-------------\n \nGodMode - If true, Player is Immortal\nFreecam - If true, Camera flies Freely\nNoclip - If true, Player follows Camera\nBunny Hop - If true, Player not Landed\nLimp - If true, Player is Limp (Like Miles)\nHobble (Float Amount) - If true, Player is Hobble (Like Waylon)\nBatteries (Int Count) - Add or Remove Batteries\nFOV (Float DefFOV, Float RunFOV, Float CamFOV)- Change Player Field Of View\nDamage (Int Damage) - Give Damage Yourself\nCamera Bone (Name Bone) - Change Camera Bone\nFree in Animation - Free Rotation Camera in Animations (Only NOT Cinematic)\nAnimation Speed (Float Speed) - Change Animations Speed\nPlayer Model (String PlayerModel) - Change Player Mesh and Materials\nPlayer Scale (Float Scale) - Change Player Scale without Collision\n \n--------------------------";
    EnemyFuncs = "-------------Enemy Functions-------------\n \nKill Enemy (Bool Force) - Kills All Enemies near Player\nDisable AI - Disable AI on All Enemies near Player\nChris Model - Change Chris Model to Demo and Back\n \n--------------------------";
    WorldFuncs = "-------------World Functions-------------\n \nDoor Functions - Doors's Menu\nOff All Base Light - Partially Removes Light from Map\nStreaming Volumes - Freeze/Unfreeze Volumes Unload Map\nDarkness Volumes - On/Off Darkness Volumes\nGame Speed (Float Speed) - Change Game Speed\nLoad Checkpoint (String Checkpoint) - Load Any Checkpoint on Map\nReload Checkpoint - Reload Game to Last Checkpoint\nLoad Map Currently - Load All Currently Map\nGamma (Float Gamma) - Change Gamma\nGravity (Float Gravity) - Change World Gravity\nAudio Volume (Float Volume) - Change Audio Volume\nDestroy Class (Class Actor) - Destroy All Actors By Class\n \n--------------------------";
    SettingsFuncs = "-------------Picker Settings-------------\n \nTimer Settings - Timer's Menu\nDisable Click Sound - On/Off Click Sound when You Press LMB\nDisable Teleport Sound - On/Off Click Sound when You Teleport Enemies to Player\nDisable Pause In Menu - Currently Closed!\nDisable Picker Debug - Show/Hide Picker Debug Info\nDisable Timer - Show/Hide Timer\n \n--------------------------";
    DoorsFuncs = "-------------Door Functions-------------\n \nChange Doors State (Bool Force) - Locked/Unlocked All Doors\nDelete All Doors (Bool Force) - Delete All Doors\nChange Doors Type (Bool Force) - Normal/Locker Type Doors\n \n--------------------------";
    AddFuncs = "-------------Add and Remove-------------\n \nLight - Light's Menu\nEnemy - Enemy's Menu\n \n--------------------------";
    TimerFuncs = "-------------Timer Settings-------------\n \nToggle Timer - Start/Stop Time on Timer\nReset Timer - Reset Time on Timer\n \n--------------------------";
    LightFuncs = "-------------Light Add Functions-------------\n \nAdd PointLight (Float Brightness, Float Radius, Byte R, Byte G, Byte B, Byte A, Bool CastShadows) - Add Point Light\nAdd SpotLight (Float Brightness, Float Radius, Byte R, Byte G, Byte B, Byte A, Bool CastShadows) - Add Spot Light\nRemove All Lights - Delete All Your Lights\nAdd Stalker PointLight - Currently Closed!\n \n--------------------------";
    AddEnemyFuncs = "-------------Enemy Add Functions-------------\n \nSpawn Enemy (String Enemy) - Spawn Enemy Anywhere (Soldier/Groom/Surgeon/Patient/Cannibal/Priest/NanoCloud)\n \n--------------------------";
    OtherFuncs = "-------------Other Functions-------------\n \nFinish Game (Int Game, Bool Finish) - Show/Hide Chapters Menu (0 - Original, 1 - DLC, 2 - Both)\nInsane Plus - Insane Plus's Menu\nRandomizer - Randomizer's Menu\nActors Base Player - Part Actors become Part of Player\n \n--------------------------";
    InsaneChoiceFuncs = "-------------Insane Plus-------------\n \n*Coming Soon*\n \n--------------------------";
    RandomizerChoiceFuncs = "-------------Randomizer-------------\n \n*Coming Soon*\n \n--------------------------";

    if(Controller.DoorTypeState==true) {DoorTypeState="Locker";} else {DoorTypeState="Normal";}
    if(Controller.DoorState==true) {DoorState="Unlock";} else {DoorState="Lock";}
    MouseTexture = Texture2D'PickerDebugMenu.PickCursor';
    if(Controller.CustomPM == "") {PlayerModelString="Default";} else if(Controller.CustomPM == "Default") {PlayerModelString="Default";} else {PlayerModelString=Controller.CustomPM;}
    if(TSVBool==true) {TSVString="Freezed";} else {TSVString="Unfreezed";}
    if(Controller.bDark==true) {DRKString="Disabled";} else {DRKString="Enabled";}
    if(Controller.ChrisState==true) {ChrisString="Demo";} else {ChrisString="Original";}
    DrawScaledBox( Vect2D(640 - 250, 250), Vect2D(500, 250), MakeRGBA(20,20,20,180), StartClip, EndClip);
    Controller = OLPickerController(PlayerOwner);
    Canvas.SetPos( ( 640 - 250 ) / 1280.0f * Canvas.SizeX, 250 / 720.0f * Canvas.SizeY);
    Canvas.SetDrawColor(45,45,45,230);
    Canvas.DrawRect( 500 / 1280.0f * Canvas.SizeX , 10 / 720.0f * Canvas.SizeY );
    if(!Controller.InsanePlusState) {
    JDS(">" @ Command, vect2D(590, 375), MakeRGBA(170,170,170,255));
    JDS(ButtonDesc, vect2d(1375,140), MakeRGBA(240,240,240,255));
    Switch(CurrentMenu)
    {
        case Normal:
            AddButton("Debug Functions", "SetMenu ShowDebug DebugFuncs", vect2d(425, 275),, StartClip, EndClip,,);
            AddButton("Player Functions", "SetMenu Player PlayerFuncs",, true,,,,);
            AddButton("Enemy Functions", "SetMenu Enemy EnemyFuncs",, true);
            AddButton("World Functions", "SetMenu World WorldFuncs",, true);
            AddButton("Other Functions", "SetMenu Other OtherFuncs",, true);
            AddButton("Add and Remove", "SetMenu Add AddFuncs",, true);
            AddButton("Picker Settings", "SetMenu Settings SettingsFuncs",, true);
            AddButton("Close", "ToggleDebugMenu 0", vect2d(825, 480), false);
            break;
        case Player:
            AddButton("GodMode: " $ Controller.PickerPawn.GodMode, "ToggleGodMode", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Freecam: " $ Controller.FreecamState, "ToggleFreecam",, true,,, true);
            AddButton("Noclip: " $ Controller.NoclipState, "Superman",, true);
            AddButton("Bunny Hop: " $ Controller.bBhop, "ToggleBhop",, true);
            AddButton("Limp: " $ OLHero(Controller.Pawn).bLimping, "Limp",, true);
            AddButton("Hobble: " $ OLHero(Controller.Pawn).bHobbling $ "/" $ OLHero(Controller.Pawn).HobblingIntensity, "Hobble ",, true,,, true);
            AddButton("Batteries: " $ Controller.NumBatteries, "Batt ",, true,,, true);
            AddButton("FOV: " $ OLHero(Controller.Pawn).DefaultFOV $ "/" $ OLHero(Controller.Pawn).RunningFOV $ "/" $ OLHero(Controller.Pawn).CamcorderMaxFOV, "ChangeFOV ",, true,,, true);
            AddButton("Damage: " $ 100-OLHero(Controller.Pawn).Health, "DS ",, true,,, true);
            AddButton("Camera Bone: " $ OLHero(Controller.Pawn).Camera.CameraBoneName, "CameraBone ",, true,,, true);
            AddButton("Free Animations: " $ Controller.bAnimFree, "AnimFree",, true);
            AddButton("Animation Speed", "PRate ",, true,,, true);
            AddButton("Player Model: " $ PlayerModelString, "CustomPlayerModel ",, true,,, true);
            AddButton("Player Scale: " $ OLHero(Controller.Pawn).Mesh.Scale, "HeroScale ",, true,,, true);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case Other:
            AddButton("Finish Game", "FinishGame ", vect2d(425, 275),, StartClip, EndClip, true);
            AddButton("Insane Plus", "SetMenu InsaneChoice InsaneChoiceFuncs",, true);
            AddButton("Randomizer", "SetMenu RandomizerChoice RandomizerChoiceFuncs",, true);
            AddButton("Actors Base Player", "BaseSelf",, true);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case World:
            AddButton("Door Functions", "SetMenu WDoors DoorsFuncs", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Off All Base Light", "OffBaseLight",, true);
            AddButton("Streaming Volumes: " $ TSVString, "TSVCommand",, true);
            AddButton("Darkness Volumes: " $ DRKString, "Darkness",, true);
            AddButton("Game Speed: " $ Controller.WorldInfo.Game.GameSpeed, "GameSpeed ",, true,,, true);
            AddButton("Load Checkpoint", "CP ",, true,,, true);
            AddButton("Reload Checkpoint", "Reload",, true);
            AddButton("Load Map Currently: " $ Controller.AllLoadedState, "ToggleLoadLoc",, true);
            AddButton("Gamma: " $ Controller.GetGamma(), "Gamma ",, true,,, true);
            AddButton("Gravity: " $ WorldInfo.WorldGravityZ, "Gravity ",, true,,, true);
            AddButton("Audio Volume", "AVolume ",, true,,, true);
            AddButton("Destroy Class", "DstrClass ",, true,,, true);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case Enemy:
            AddButton("Kill Enemy", "ToggleKillEnemy", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Disable AI: " $ Controller.bDisAI, "ToggleDisAI",, true);
            AddButton("Chris Model: " $ ChrisString, "ToggleChangeChris",, true);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case ShowDebug:
            AddButton("Show AI", "ToggleAIDebug", vect2d(425, 275),, StartClip, EndClip,,);
            AddButton("Show FPS", "Stat FPS",, true,,,,);
            AddButton("Show LEVELS", "Stat LEVELS",, true,,,,);
            AddButton("Show BSP", "Show BSP",, true,,,,);
            AddButton("Show STATICMESHES", "Show STATICMESHES",, true,,,,);
            AddButton("Show SKELETALMESHES", "Show SKELETALMESHES",, true,,,,);
            AddButton("Show MESHEDGES", "Show MESHEDGES",, true,,,,);
            AddButton("Show PATHS", "Show PATHS",, true,,,,);
            AddButton("Show BOUNDS", "Show BOUNDS",, true,,,,);
            AddButton("Show COLLISION", "Show COLLISION",, true,,,,);
            AddButton("Show VOLUMES", "Show VOLUMES",, true,,,,);
            AddButton("Show FOG", "Show FOG",, true,,,,);
            AddButton("Show POSTPROCESS", "Show POSTPROCESS",, true,,,,);
            AddButton("Show LIGHTFUNCTIONS", "Show LIGHTFUNCTIONS",, true,,,,);
            AddButton("Show ZEROEXTENT", "Show ZEROEXTENT",, true,,,,);
            AddButton("Show LEVELCOLORATION", "Show LEVELCOLORATION",, true,,,,);
            AddButton("Uncap FPS", "Uncapfps",, true,,,,);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case Add:
            AddButton("Light", "SetMenu AddL LightFuncs", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Enemy", "SetMenu AddE AddEnemyFuncs",, true);
            AddButton("Go Back", "SetMenu Normal",vect2d(825, 480), false);
            break;
        case AddE:
            AddButton("Spawn Enemy", "SetMenu AddESpawn", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Remove All Enemies", "KillEnemy",, true);
            AddButton("Go Back", "SetMenu Add AddFuncs",vect2d(825, 480), false);
            break;
        case AddESpawn:
            AddButton("Chris Walker", "SpawnEnemy Soldier", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Eddie Gluskin", "SpawnEnemy Groom",, true);
            AddButton("William Hope", "SpawnEnemy NanoCloud",, true);
            AddButton("Rick Trager (Currently Closed)", "SpawnEnemy Surgeon",, true);
            AddButton("Frank Manera (Friendly)", "SpawnEnemy Cannibal",, true);
            AddButton("Martin Archimbaud (Friendly)", "SpawnEnemy Priest",, true);
            AddButton("Random Patient (Currently Closed)", "SpawnEnemy Patient",, true);
            AddButton("Go Back", "SetMenu AddE AddEnemyFuncs", vect2d(825, 480), false);
            break;
        case AddL:
            AddButton("Add PointLight", "MadeLight ", vect2d(425, 275),, StartClip, EndClip, true);
            AddButton("Add SpotLight", "MadeSpot ",, true,,, true);
            AddButton("Remove All Lights", "RemoveAllPickerLights",, true);
            AddButton("Add Stalker PointLight (Currently closed): " $ Controller.LightState, "ToggleEverytimeLight ",, true,,, true);
            AddButton("Go Back", "SetMenu Add AddFuncs", vect2d(825, 480), false);
            break;
        case WDoors:
            AddButton("Doors State: " $ DoorState, "ToggleDoorsState ", vect2d(425, 275),, StartClip, EndClip, true);
            AddButton("Delete All Doors: " $ Controller.DelDoorState, "ToggleDeleteDoors ",, true,,, true);
            AddButton("Doors Type: " $ DoorTypeState, "ToggleTypeDoors ",, true,,, true);
            AddButton("Doors Mesh Type", "SetMenu WDoorsMT",, true);
            AddButton("Go Back", "SetMenu World WorldFuncs", vect2d(825, 480), false);
            break;
        case Settings:
            AddButton("Timer Settings", "SetMenu STimer TimerFuncs", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Disable Click Sound: " $ DisableClickSound, "ToggleClickButton",, true);
            AddButton("Disable Teleport Sound: " $ DisableTeleportSound, "ToggleTeleportButton",, true);
            AddButton("Disable Pause In Menu (Currently closed): " $ DisablePause, "TogglePauseMenu",, true);
            AddButton("Disable Picker Debug: " $ DisablePickerDebug, "TogglePickerDebug",, true);
            AddButton("Disable Timer: " $ DisableTimerDebug, "ToggleTimerDebug",, true);
            AddButton("Go Back", "SetMenu Normal", vect2d(825, 480), false);
            break;
        case STimer:
            AddButton("Toggle Timer: " $ Controller.bTimer, "ToggleTimer", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Reset Timer", "ResetTimer",, true);
            AddButton("Go Back", "SetMenu Settings SettingsFuncs", vect2d(825, 480), false);
            break;
        case WDoorsMT:
            AddButton("Wooden", "ChangeDoorsMeshType Wooden", vect2d(425, 275),, StartClip, EndClip);
            AddButton("Wooden Old", "ChangeDoorsMeshType WoodenOld",, true);
            AddButton("Wooden Window", "ChangeDoorsMeshType WoodenWindow",, true);
            AddButton("Wooden Window Small", "ChangeDoorsMeshType WoodenWindowSmall",, true);
            AddButton("Wooden Window Old", "ChangeDoorsMeshType WoodenWindowOld",, true);
            AddButton("Wooden Window Old Small", "ChangeDoorsMeshType WoodenWindowOldSmall",, true);
            AddButton("Wooden Window Big", "ChangeDoorsMeshType WoodenWindowBig",, true);
            AddButton("Metal", "ChangeDoorsMeshType Metal",, true);
            AddButton("Metal Window", "ChangeDoorsMeshType MetalWindow",, true);
            AddButton("Metal Window Small", "ChangeDoorsMeshType MetalWindowSmall",, true);
            AddButton("Enforced", "ChangeDoorsMeshType Enforced",, true);
            AddButton("Grid", "ChangeDoorsMeshType Grid",, true);
            AddButton("Prison", "ChangeDoorsMeshType Prison",, true);
            AddButton("Entrance", "ChangeDoorsMeshType Entrance",, true);
            AddButton("Bathroom", "ChangeDoorsMeshType Bathroom",, true);
            AddButton("IsolatedCell", "ChangeDoorsMeshType IsolatedCell",, true);
            AddButton("Locker", "ChangeDoorsMeshType Locker",, true);
            AddButton("Locker Rusted", "ChangeDoorsMeshType LockerRusted",, true);
            AddButton("Locker Beige", "ChangeDoorsMeshType LockerBeige",, true);
            AddButton("Locker Green", "ChangeDoorsMeshType LockerGreen",, true);
            AddButton("Locker Hole", "ChangeDoorsMeshType LockerHole",, true);
            AddButton("Glass", "ChangeDoorsMeshType Glass",, true);
            AddButton("Fence", "ChangeDoorsMeshType Fence",, true);
            AddButton("Go Back", "SetMenu WDoors DoorsFuncs", vect2d(825, 480), false);
            break;
        case RandomizerChoice:
            AddButton("Start Randomizer!", "ToggleRandomizer", vect2d(425, 275),, StartClip, EndClip, true);
            AddButton("Small Random Time: " $ Controller.SmallRandomTime, "ModifyRandomizer 0 ",, true,,, true);
            AddButton("Medium Random Time: " $ Controller.MediumRandomTime, "ModifyRandomizer 1 ",, true,,, true);
            AddButton("Large Random Time: " $ Controller.LargeRandomTime, "ModifyRandomizer 2 ",, true,,, true);
            AddButton("Go Back", "SetMenu Other OtherFuncs", vect2d(825, 480), false);
            break;
        case InsaneChoice:
            AddButton("Start Insane Plus!", "ToggleInsanePlus", vect2d(425, 275),, StartClip, EndClip, Controller.TrainingMode);
            AddButton("One Battery: " $ Controller.OneBatteryMode, "ModifyInsanePlus 0",, true);
            AddButton("Fast Enemies: " $ Controller.FastEnemyMode, "ModifyInsanePlus 1",, true);
            AddButton("Disable Camera: " $ Controller.DisCamMode, "ModifyInsanePlus 2",, true);
            AddButton("Slow Player: " $ Controller.SlowHeroMode, "ModifyInsanePlus 3",, true);
            AddButton("One Shot: " $ Controller.OneShotMode, "ModifyInsanePlus 4",, true);
            AddButton("Cursed Batteries: " $ Controller.BadBatteryMode, "ModifyInsanePlus 5",, true);
            AddButton("Limited Stamina: " $ Controller.LimitedStaminaMode, "ModifyInsanePlus 6",, true);
            AddButton("Super Vision for Enemies: " $ Controller.NoDarkMode, "ModifyInsanePlus 7",, true);
            AddButton("Smart Enemies: " $ Controller.SmartAIMode, "ModifyInsanePlus 8",, true);
            AddButton("Show Stamina: " $ !DisableShowStamina, "ToggleShowDebugOnlyStamina",, true);
            AddButton("Training Mode: " $ Controller.TrainingMode, "ModifyInsanePlus 9",, true);
            AddButton("Skip Death Screen: " $ Controller.SkipDeathScreen, "ModifyInsanePlus 10",, true);
            AddButton("Go Back", "SetMenu Other OtherFuncs", vect2d(825, 480), false);
    }
    }
    if(Controller.InsanePlusState) {
        Switch(CurrentMenu) {
            case DisInsanePlus:
                AddButton("Disable Insane Plus", "ToggleInsanePlus", vect2d(425, 275),, StartClip, EndClip);
                AddButton("Close", "ToggleDebugMenu 0", vect2d(825, 480), false);
                break;
        }
    }

    /******** DRAW MOUSE ********/

    Canvas.SetPos(PlayerInput.MousePos.X, PlayerInput.MousePos.Y);
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.DrawTile(MouseTexture, MouseTexture.SizeX, MouseTexture.SizeY, 0.f, 0.f, MouseTexture.SizeX, MouseTexture.SizeY,, true);
}

/************************TIMER FUNCTION************************/

Function PTimer(float DeltaTime) {
    local int TotalSeconds;
    local OLPickerController Controller;
    local String Hours, Minutes, Seconds, HundredthsOfASecond, DisplayedTime;

    Controller = OLPickerController(PlayerOwner);
    if(Controller.bResetTimer) {Controller.bResetTimer=false; TotalSeconds=0; TimerTimeSeconds=0;}
    if(Controller.bTimer) {TimerTimeSeconds += DeltaTime;}
    TotalSeconds = FFloor(TimerTimeSeconds);
    HundredthsOfASecond = string(FFloor((TimerTimeSeconds - float(TotalSeconds)) * float(100)));
    Seconds = string(TotalSeconds % 60);
    Minutes = string((TotalSeconds / 60) % 60);
    Hours = string(TotalSeconds / 3600);
    if(Len(Hours) == 1)
    {
        Hours = "0" $ Hours;
    }
    if(Len(Minutes) == 1)
    {
        Minutes = "0" $ Minutes;
    }
    if(Len(Seconds) == 1)
    {
        Seconds = "0" $ Seconds;
    }
    if(Len(HundredthsOfASecond) == 1)
    {
        HundredthsOfASecond = "0" $ HundredthsOfASecond;
    }
    DisplayedTime = (((((Hours $ ":") $ Minutes) $ ":") $ Seconds) $ ":") $ HundredthsOfASecond;
    TimerTime=DisplayedTime;
}

/************************OTHER FUNCTIONS************************/

Event ShowObjective(string ObjectiveText)
{
    local OLPickerController Controller;
    local String RandomObjective;
    local Byte D;
    Controller = OLPickerController(PlayerOwner);
    if(ObjectiveScreen == none) {ObjectiveScreen = new (self) class'OLUIMessage';}
    if(ObjectiveScreen != none) {
        if(!Controller.RandomizerState) {CurrentObjectiveText = ObjectiveText;}
        if(Controller.RandomizerState) {D = RandRange(0, 62);
        if(D==0) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_GetInsideAsylum", "OLGame"));}
        if(D==1) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SecurityRoom2", "OLGame"));}
        if(D==2) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator", "OLGame"));}
        if(D==3) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_BackToSecurity", "OLGame"));}
        if(D==4) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_FollowTheBlood", "OLGame"));}
        if(D==5) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_Shower", "OLGame"));}
        if(D==6) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_Explosion", "OLGame"));}
        if(D==7) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_ReachSurface", "OLGame"));}
        if(D==8) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater", "OLGame"));}
        if(D==9) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater4", "OLGame"));}
        if(D==10) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_ReachMaleWard", "OLGame"));}
        if(D==11) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_Basement", "OLGame"));}
        if(D==12) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GetOutOfMaleWard", "OLGame"));}
        if(D==13) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GetOutOfMaleWard2", "OLGame"));}
        if(D==14) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_PyroSaidKitchen", "OLGame"));}
        if(D==15) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Enter", "OLGame"));}
        if(D==16) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GetOnSecondFloor", "OLGame"));}
        if(D==17) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_3rdFloor", "OLGame"));}
        if(D==18) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Darkness", "OLGame"));}
        if(D==19) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GoOn3rdFloor", "OLGame"));}
        if(D==20) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Exit", "OLGame"));}
        if(D==21) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_RecreationHallKey", "OLGame"));}
        if(D==22) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_KeyToHouseofGod", "OLGame"));}
        if(D==23) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_KeyToFreedom", "OLGame"));}
        if(D==24) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_Start", "OLGame"));}
        if(D==25) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_GoToMainLab", "OLGame"));}
        if(D==26) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly", "OLGame"));}
        if(D==27) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly2", "OLGame"));}
        if(D==28) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly3", "OLGame"));}
        if(D==29) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_Final", "OLGame"));}
        if(D==30) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SecurityRoom", "OLGame"));}
        if(D==31) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_Keycard", "OLGame"));}
        if(D==32) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_GoToSecurityRoom", "OLGame"));}
        if(D==33) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SparkPlug", "OLGame"));}
        if(D==34) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator2", "OLGame"));}
        if(D==35) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator3", "OLGame"));}
        if(D==36) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator4", "OLGame"));}
        if(D==37) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator5", "OLGame"));}
        if(D==38) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator6", "OLGame"));}
        if(D==39) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_OutOfBasement", "OLGame"));}
        if(D==40) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_KeyCardShower", "OLGame"));}
        if(D==41) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_EscapePrison", "OLGame"));}
        if(D==42) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater2", "OLGame"));}
        if(D==43) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater3", "OLGame"));}
        if(D==44) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_EscapeMaleWard", "OLGame"));}
        if(D==45) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_FindKeyForMaleElevator", "OLGame"));}
        if(D==46) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GoBackToElevator", "OLGame"));}
        if(D==47) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_AlternatePath", "OLGame"));}
        if(D==48) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_WaterValve", "OLGame"));}
        if(D==49) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_SprinklerValve", "OLGame"));}
        if(D==50) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_SprinklerSwitch", "OLGame"));}
        if(D==51) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Start", "OLGame"));}
        if(D==52) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Key", "OLGame"));}
        if(D==53) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Shed", "OLGame"));}
        if(D==54) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_2ndFloorKey", "OLGame"));}
        if(D==55) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_2ndFloor", "OLGame"));}
        if(D==56) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GetKeyFirstFloor", "OLGame"));}
        if(D==57) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_1", "OLGame"));}
        if(D==58) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_2", "OLGame"));}
        if(D==59) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Hospital_GetRadio", "OLGame"));}
        if(D==60) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Hospital_Gas", "OLGame"));}
        if(D==61) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_GetAdmin", "OLGame"));}
        if(D==62) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Building2_Key", "OLGame"));}
        if(D==62) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Fuse", "OLGame"));}
        //CurrentObjectiveText = RandomObjective;
        Controller.CurrentObjective = Name(RandomObjective);
    }
        ObjectiveScreen.Start(false);
        if(!Controller.RandomizerState) {ObjectiveScreen.SetMessage(1, ObjectiveText);}
        if(Controller.RandomizerState) {ObjectiveScreen.SetMessage(1, Localize("Messages", "" $ "NewObjective", "OLGame") @ RandomObjective);}
        WorldInfo.Game.SetTimer(4, false, 'HideObjective', Self);
    }
}

Event HideObjective() {if((ObjectiveScreen != none) && ObjectiveScreen.bMovieIsOpen) {ObjectiveScreen.Close(false); CurrentObjectiveText = "";}    }

Function JDS(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(1.5, 1.5), optional bool ScaleLoc=true, optional bool center) {
    local Vector2D MisScale, StringScale;

    MisScale=Vect2D((0.7 * Scale.X) / 1920 * Canvas.SizeX, (0.7 * Scale.Y) / 1080 * Canvas.SizeY);
    Canvas.TextSize(String, StringScale.X, StringScale.Y, MisScale.X, MisScale.Y);
    if(Center) {Loc=Vect2D(Loc.X - (StringScale.X / 2), Loc.Y - (StringScale.Y / 2));}
    if(ScaleLoc) {Loc=Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);}
    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
}

Function Bool ContainsName(Array<Name> Array, Name find) {Switch(Array.Find(find) ) {case -1: return False; Default: return true;}}
Function Bool ContainsString(Array<String> Array, String find) {Switch(Array.Find(find)) {case -1: return False; break; Default: return true;break;}}
Function IntPoint GetMousePos() {local OLPickerInput PlayerInput; PlayerInput = OLPickerInput(PlayerOwner.PlayerInput); return PlayerInput.MousePos;}
Function Bool InRange(float Target, Float RangeMin, Float RangeMax) {return Target>RangeMin && Target<RangeMax;}
Function Bool Mouseinbetween(Vector2D Vector1, Vector2D Vector2) {local intpoint MousePos; MousePos=GetMousePos(); return InRange(MousePos.X, Vector1.X, Vector2.X) && InRange(MousePos.Y, Vector1.Y, Vector2.Y);}
Function ButtonStr FindButton(Array<ButtonStr> Array, Int Row, Int Column) {local ButtonStr Button; Foreach array(Button) {if (Button.Row==Row) {if (Button.Column==Column) {return Button;}}} Button.Row=-1; return Button;}
Exec Function SetMenu(Menu Menu, optional String ButtonTag) {CurrentMenu=Menu; ButtonDesc=ButtonTag;}
Function AddButton(String Name, String ConsoleCommand, optional Vector2D Location, optional Bool AutoDown=False, optional Vector2D Bound_Start, optional Vector2D Bound_End, optional bool Template, optional String buttontag) {
    local vector2D Begin_PointCalc, End_PointCalc, Offset, Center_Vector, TextSize;
    local RGBA Color;
    local ButtonStr ButtonBase, PreviousButton, FirstButtonInRow, ButtonInColumn;
    local int Row, Column;

    Canvas.TextSize(Name, TextSize.X, TextSize.Y );

    offset=vect2D( 15 + (TextSize.X / 1.5), 5 + (TextSize.Y / 1.5) );

    if (Buttons.Length==0) {Row=1; Column=1;}
    else {
        PreviousButton=Buttons[ (Buttons.Length - 1 ) ];
        Row=PreviousButton.Row;
        Column=PreviousButton.Column+1;
        FirstButtonInRow=FindButton(Buttons, Row, 1);
        if (FirstButtonInRow.Row!=-1) {
            Bound_Start = FirstButtonInRow.ClipStart;
            Bound_End = FirstButtonInRow.ClipEnd;
            if (AutoDown) {
                Location.X = PreviousButton.Location.X;
                Location.Y = (PreviousButton.Location.Y + PreviousButton.Offset.Y) + 10;
                if( !InRange(Scale2dVector(Location + Offset).Y, Bound_Start.Y, Bound_Start.Y + Bound_End.Y) ) {
                    Location.X = (FirstButtonInRow.Location.X + FirstButtonInRow.Offset.X) + 10;
                    Location.Y = FirstButtonInRow.Location.Y;
                    ++ Row;
                    Column=1;
                }
                else if (Column>1) {
                    ButtonInColumn=FindButton(Buttons, (Row - 1), Column);
                    if (ButtonInColumn.Row!=-1) {
                        Location.X = (ButtonInColumn.Location.X + ButtonInColumn.Offset.X) + 10;
                    }
                }
            }
        }
    }

    if ( MouseInbetween(Scale2DVector(Location), Scale2DVector(Location + Offset) ) ) {Color=MakeRGBA(255,255,255,225); JDS(buttontag, vect2d(1375,140), MakeRGBA(255,255,255,255));}
    else {Color=MakeRGBA(50,50,50,225);}
    //Draw the button box
    DrawScaledBox(Location, offset, Color, Begin_PointCalc, End_PointCalc);

    //Get the center of the button
    Center_Vector=vect2D( ( Begin_PointCalc.X + (Begin_PointCalc.X + End_PointCalc.X) ) / 2, ( Begin_PointCalc.Y + ( Begin_PointCalc.Y + End_PointCalc.Y ) ) / 2);

    //Draw Button Text Centered.
    JDS(Name, Center_Vector,  MakeRGBA(170,170,170,255),, false, true );

    //Add the button info to the array
    ButtonBase.Name=Name;
    ButtonBase.ConsoleCommand=ConsoleCommand;
    ButtonBase.Start_Points=Begin_PointCalc;
    ButtonBase.End_Point=vect2d( (Begin_PointCalc.X + End_PointCalc.X), (Begin_PointCalc.Y + End_PointCalc.Y ) );
    ButtonBase.Template=template; //Does button require user input after pressing
    ButtonBase.Location=Location;
    ButtonBase.Offset=Offset;
    ButtonBase.ClipStart=Bound_Start;
    ButtonBase.ClipEnd=Bound_End;
    ButtonBase.Row=Row;
    ButtonBase.Column=Column;
    Buttons.AddItem(ButtonBase);

}

Function WorldTextDraw( string Text, vector location, Float Max_View_Distance, float scale, optional vector offset ) {
    local Vector DrawLocation, CameraLocation; //Location to Draw Text & Location of Player Camera
    local Rotator CameraDir; //Direction the camera is facing
    local Float Distance; //Distance between Camera and text

    PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraDir);
    Distance =  ScalebyCam( VSize(CameraLocation - Location)); //Get the distance between the camera and the location of the text being placed, then scale it by the camera's FOV. 
    DrawLocation = Canvas.Project(Location); //Project the 3D location into 2D space. 
    if (vector(CameraDir) dot (Location - CameraLocation) > 0.0 && Distance < Max_View_Distance )
    {
        Scale = Scale / Distance; //Scale By distance. 
        Canvas.SetPos(DrawLocation.X + (Offset.X * Scale), DrawLocation.Y + (Offset.Y * Scale), DrawLocation.Z + (Offset.Z * Scale)); //Set the Position of text using the Draw Location and an optional Offset. 
        canvas.SetDrawColor(255,40,40,255);
        Canvas.DrawText(Text, false, Scale, Scale); //Draw the text
    }
}


Function Click() {
    local OLPickerInput PlayerInput;
    local OLPickerController Controller;
    local ButtonStr Butvarka;
    local IntPoint MousePos;

    PlayerInput = OLPickerInput(PlayerOwner.PlayerInput);
    Controller = OLPickerController(PlayerOwner);
    MousePos = PlayerInput.MousePos;

    Foreach Buttons(Butvarka) {
        if(InRange(MousePos.X, Butvarka.Start_Points.X, Butvarka.End_Point.X) && InRange(MousePos.Y, Butvarka.Start_Points.Y, Butvarka.End_Point.Y)) {
            if(!DisableClickSound) {PlaySound(Controller.ButtonSound);}
            if(Butvarka.Template) {
                Command=Butvarka.ConsoleCommand;
                return;

            }
            PlayerOwner.ConsoleCommand(Butvarka.ConsoleCommand);
            return;
        }
    }
    return;
}

Function DrawScaledBox(Vector2D Begin_Point, Vector2D End_Point, optional RGBA Color=MakeRGBA(255,255,255,255), optional out Vector2D Begin_Point_Calculated, optional out Vector2D End_Point_Calculated) {
    Begin_Point_Calculated = Scale2DVector(Begin_Point);
    End_Point_Calculated = Scale2DVector(End_Point);

    Canvas.SetPos( Begin_Point_Calculated.X, Begin_Point_Calculated.Y);
    Canvas.SetDrawColor(Color.Red,Color.Green,Color.Blue,Color.Alpha);
    Canvas.DrawRect( End_Point_Calculated.X, End_Point_Calculated.Y);
}

Function Float ScalebyCam(Float Float) {local Float Scale; Scale = ( PlayerOwner.GetFOVAngle() / 100 ); return Float * Scale;}
Function Vector2D Scale2DVector(Vector2D Vector) {Vector.X=Vector.X / 1280.0f * Canvas.SizeX; Vector.Y=Vector.Y / 720.0f * Canvas.SizeY; return Vector;}
Function Bool Vector2DInRange(Vector2D Target, Vector2D Vector1, Vector2D Vector2) {return InRange(Target.X, Vector1.X, Vector2.X) && InRange(Target.Y, Vector1.Y, Vector2.Y );}
Function String Vectortostring(Vector Target) {local String String; String=Target.X $ ", " $ Target.Y $ ", " $ Target.Z; return string;}
Function Commit() {local OLPickerController Controller; Controller = OLPickerController(PlayerOwner); if(!Controller.InsanePlusState) {PlayerOwner.ConsoleCommand(Command);} Command="";}
Exec Function HideDebugMenu() {PlayerOwner.ConsoleCommand("ToggleDebugMenu 0"); Super.HideMenu();}   
Function RGBA MakeRGBA(byte R, byte G, byte B, optional byte A=255) {local RGBA Color; Color.Red=R; Color.Green=G; Color.Blue=B; Color.Alpha=A; return Color;}
