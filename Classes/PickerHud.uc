Class PickerHud extends OLHud
    Config(Picker);

struct ButtonStr {
    var String Name, ConsoleCommand;
    var Vector2d Start_Points, End_Point, Location, Offset, ClipStart, ClipEnd;
    var Bool template;
    var Int Row, Column;
};

struct RGBA {
    var Byte Red;
    var Byte Green;
    var Byte Blue;
    var Byte Alpha;

    structdefaultproperties
    {
        Red=255
        Green=255
        Blue=255
        Alpha=255
    }
};

enum Menu {
    Normal,
    ShowDebug,
    Add,
    AddL,
    World,
    WChapters,
    WAdmin1,
    WAdmin2,
    WPrison1,
    WPrison2,
    WSewer,
    WMaleWard,
    WFemaleWard,
    WExit,
    WCourtyard1,
    WCourtyard2,
    WCourtyard3,
    WHospital,
    WVocational,
    WLab1,
    WLab2,
    WDoors,
    WDoorsMT,
    WDoorsMTMS,
    Enemy,
    AddE,
    AddESpawn,
    AddESpawnPatient,
    AddESpawnWeapons,
    AddP,
    AddPlayer,
    AddPO,
    Settings,
    SettingsColor,
    Player,
    Other,
    Cinematic,
    OTimers,
    RandomizerChoice,
    InsaneChoice,
    DisInsanePlus
};

var Config RGBA ConsoleTextColor, ConsoleColor, PromptTextColor, BackgroundColor, ButtonTextColor, ButtonColor, ReturnButtonTextColor, ReturnButtonColor, RangeButtonColor, RangeReturnButtonColor, RangeButtonTextColor;

var Bool ToggleHUD, Pressed, AlreadyCommited, TSVBool, MathTasksHUD, bCinematicMode;
var Array<ButtonStr> Buttons;
var ButtonStr PrevButton;
var Menu CurrentMenu;
var RGBA PushColor;
var PickerInput PickerInput;
var Config Bool DisableClickSound, DisableTeleportSound, DisablePause, DisablePickerDebug, DisableMenuMusic, DisableAllActorInfo, DisablePickerMessages, DisableButtonDescs, bForceFuncs, HudShouldAttack, bPauseFocus, TimersStop, bPossessSpawnHero, bPossessAfterKill, NFSToggle, WernickeToggle, SVToggle;
var Config Int SpawnEnemyCount;
var Config String HudWeaponToUse, SndDoorMat;
var String Name, Version, Stamina, ButtonDesc, FinalDesc,  PlayerDebug, Command, LatestCommand, TrainingMode, IndGodMode, IndNoclip, IndGhost, IndFreecam, MathTasksOperation, StrPushMessage;
var Float AudioVolume;
var Config Float TimersTime, AllActorInfoDistance;

/**************MENU TAGS**************/
var String DebugFuncs, PlayerFuncs, EnemyFuncs, WorldFuncs, SettingsFuncs, DoorsFuncs, AddFuncs, AddLightFuncs, AddEnemyFuncs, AddPropFuncs, AddPOFuncs, OtherFuncs, OTimersFuncs, InsaneChoiceFuncs, RandomizerChoiceFuncs;

/************************************************FUNCTIONS************************************************/
    
Delegate ButtonPress();

Exec Function ToggleShowVolumes() {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    SVToggle = !SVToggle;
    Controller.ShowVolumes(SVToggle);
}

Exec Function ToggleWernicke() {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    WernickeToggle = !WernickeToggle;
    Controller.Wernicke(WernickeToggle);
}

Exec Function ToggleNFS() {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    NFSToggle = !NFSToggle;
    Controller.NFS(NFSToggle);
}

Exec Function ToggleClickButton() {
    DisableClickSound=!DisableClickSound;
    SaveConfig();
}

Exec Function TogglePauseMenu() {
    DisablePause=!DisablePause;
    SaveConfig();
}

Exec Function ToggleTeleportButton() {
    DisableTeleportSound=!DisableTeleportSound;
    SaveConfig();
}

Exec Function TogglePickerDebug() {
    DisablePickerDebug=!DisablePickerDebug;
    SaveConfig();
}

Exec Function ToggleTimersStop() {
    TimersStop = !TimersStop;
    SaveConfig();
}

Exec Function ToggleTimersTime(Float Time=0.3) {
    TimersTime = Time;
    SaveConfig();
}

Exec Function ToggleAllActorInfo() {
    DisableAllActorInfo=!DisableAllActorInfo;
    SaveConfig();
}

Exec Function TogglePickerMessages() {
    DisablePickerMessages=!DisablePickerMessages;
    SaveConfig();
}

Exec Function ToggleMenuMusic() {
    DisableMenuMusic=!DisableMenuMusic;
    SaveConfig();
}

Exec Function ToggleForceFuncs() {
    bForceFuncs=!bForceFuncs;
    SaveConfig();
}

Exec Function ToggleSpawnEnemyCount(Int Count=1) {
    SpawnEnemyCount=Count;
    SaveConfig();
}

Exec Function ToggleButtonDescs() {
    DisableButtonDescs=!DisableButtonDescs;
    SaveConfig();
}

Exec Function ToggleWeaponForEnemy(String WeaponToUse) {
    HudWeaponToUse = WeaponToUse;
    SaveConfig();
}

Exec Function ToggleEnemyShouldAttack() {
    HudShouldAttack = !HudShouldAttack;
}

Exec Function TogglePossessSpawnHero() {
    bPossessSpawnHero = !bPossessSpawnHero;
}

Exec Function TogglePossessAfterKill() {
    bPossessAfterKill = !bPossessAfterKill;
}

Exec Function ToggleChangeDoorSndMat(Name SndMat) {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    Switch(SndMat) {
        case 'Wood':
            break;
        case 'Metal':
            break;
        case 'SecurityDoor':
            break;
        case 'BigPrisonDoor':
            break;
        case 'BigWoodenDoor':
            break;
        Default:
            Controller.SendMsg("Wrong Door Sound Material! Available:\nWood\nMetal\nSecurityDoor\nBigPrisonDoor\nBigWoodenDoor");
            return;
            break;
    }
    SndDoorMat = String(SndMat);
}

Function PostRender() {
    local PickerController Controller;
    local PickerGame CurrentGame;
    local PickerInput PlayerInput;
    local PickerHero PickerPawn;
    local OLProfileSettings ProfileSettings;
    local String GameType, HealthPlayer, PylonInfo, AllActorInfo, Name, FloorMaterial, SMName, PickObjectName;
    local Vector CameraPos, PickObjectLocation, PickObjectNormal;
    local Vector2D PushCenter;
    local Actor A, PickObject;
    local OLEnemyPawn Enemy;
    local Rotator CameraRot;
    local StaticMeshActor TempSMA;
    local StaticMeshCollectionActor TempSMCA;
    local StaticMeshComponent TempSMC, PickObjectComp;
    local Int IndexSM;

    Super.PostRender();
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Controller = PickerController(PlayerOwner);
    CurrentGame = PickerGame(WorldInfo.Game);
    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    PickerPawn = PickerHero(PlayerOwner.Pawn);
    if(PickerPawn == None) {
        return;
    }
    Controller.GetPlayerViewPoint(CameraPos, CameraRot);
    //Controller.ProfileSettings.GetProfileSettingValueFloat(57, AudioVolume);
    Buttons.Remove(0, Buttons.Length);
    DisplayKismetMessages();

    Switch(PickerPawn.GetMaterialBelowFeet()) {
        case 'carpet':
            FloorMaterial = DbgLoc("Carpet");
            break;
        case 'concrete':
            FloorMaterial = DbgLoc("Concrete");
            break;
        case 'Wood':
            FloorMaterial = DbgLoc("Wood");
            break;
        case 'Metal_Light':
            FloorMaterial = DbgLoc("Metal_Light");
            break;
        case 'Water':
            FloorMaterial = DbgLoc("Water");
            break;
        case 'Blood':
            FloorMaterial = DbgLoc("Blood");
            break;
        case 'Grass':
            FloorMaterial = DbgLoc("Grass");
            break;
        case 'Water_Small':
            FloorMaterial = DbgLoc("Water_Small");
            break;
        case 'Metal_Loud':
            FloorMaterial = DbgLoc("Metal_Loud");
            break;
        case 'Crutch':
            FloorMaterial = DbgLoc("Crutch");
            break;
        case 'AIRVENT':
            FloorMaterial = DbgLoc("Airvent");
            break;
        case 'Water_Deep':
            FloorMaterial = DbgLoc("Water_Deep");
            break;
        Default:
            FloorMaterial = DbgLoc("NoneBelowMat");
            break;
    }
    if(PickerPawn.bGodMode) {
        HealthPlayer = Localize("Debug", "God", "Picker");
    }
    else if(PickerPawn.bNoclip) {
        HealthPlayer = Localize("Debug", "Noclip", "Picker");
    }
    else {
        HealthPlayer = String(PickerHero(Controller.Pawn).Health);
    }
    if(CurrentGame.bIsPlayingDLC) {
        GameType = DbgLoc("WaylonDLC");
    }
    else if(CurrentGame.bIsDemo) {
        GameType = DbgLoc("MilesDemo");
    }
    else {
        GameType = DbgLoc("MilesMain");
    }
    if(PickerPawn.bGodMode) {
        IndGodMode = "  GM  ";
    }
    else {
        IndGodMode = "";
    }
    if(!Controller.UsingFirstPersonCamera()) {
        IndFreecam = "  FC  ";
    }
    else {
        IndFreecam = "";
    }
    if(PickerPawn.bNoClip) {
        IndNoclip = "  N  ";
    }
    else {
        IndNoclip = "";
    }
    if(Controller.bDebugFullyGhost) {
        IndGhost = "  G  ";
    }
    else {
        IndGhost = "";
    }
    if(bCinematicMode) {
        if(ToggleHUD || MathTasksHUD) {
            ShowPickerMenu();
        }
        return;
    }
    //PushCenter = Vect2D(0 + (0 - (Canvas.SizeX / 2)) / 2, 0 + (0 - (Canvas.SizeY / 2)) / 2);
    PushCenter = Vect2D(Canvas.SizeX / 1.02, 25);
    DrawString(StrPushMessage, PushCenter, PushColor, Vect2D(2.4, 2.4),, true);
    //Foreach TraceActors(Class'Actor', PickObject, PickObjectLocation, PickObjectNormal, CameraPos + (Normal(Vector(CameraRot)) * 10000), CameraPos) {
        SMName = "";
    //PickObject = Trace(PickObjectLocation, PickObjectNormal, CameraPos + (Normal(Vector(CameraRot)) * 10000, CameraPos));
    PickObject = Trace(PickObjectLocation, PickObjectNormal, ((vector(CameraRot) * float(5000)) * float(20)) + CameraPos, CameraPos, true);
    if(PickObject != None) {
   // if(InStr(Caps(PickObject.Name), Caps("StaticMesh") == -1) {
        PickObjectName = String(PickObject.Name);
       // if(PickObject.Class == Class'StaticMeshCollectionActor') {
           /*Foreach PickObject.ComponentList(Class'StaticMeshComponent', PickObjectComp) {
                SMName $= String(PickObjectComp.StaticMesh) @ "";
            }*/
    }
    else {
        PickObjectName = "";
    }
        //}
    //}
       /*      PickObjectName = String(PickObject.Name);
            While(IndexSM < StaticMeshCollectionActor(PickObject).StaticMeshComponents.Length) {
                //SMName = SMName @ String(StaticMeshCollectionActor(PickObject).StaticMeshComponents[IndexSM].StaticMesh) @ "1";
                SMName = String(StaticMeshCollectionActor(PickObject).StaticMeshComponents[0].StaticMesh) @ "1";
                ++IndexSM;
            }*/
            /*Foreach StaticMeshCollectionActor(PickObject).StaticMeshComponents(TempSMC) {
              //  PickObjectName = String(PickObject.Name);
                SMName = SMName @ String(TempSMC.StaticMesh) @ "1";
               // ++IndexSM;
            }*/
       // }
    //}
    Name = "[Picker]" $ IndGodMode $ IndFreecam $ IndNoclip $ IndGhost;
    PlayerDebug = DbgLoc("FPS") @ CurrentGame.FPS $ DbgLoc("Random") @ Controller.RandString(Controller.RandByte(35)) $ DbgLoc("Velocity") @ PickerPawn.Velocity @ "(" $ PickerPawn.CurrentRunSpeed $")" @ DbgLoc("Floor") @ FloorMaterial $ DbgLoc("PlayerPosRot") @ PickerPawn.Location $ "/" $ PickerPawn.Rotation.Yaw * 0.005493 $ DbgLoc("CameraPosRot") @ CameraPos $ "/" $ CameraRot.Yaw * 0.005493 $ DbgLoc("Game") @ GameType @ DbgLoc("Health") @ HealthPlayer @ DbgLoc("Limp") @ PickerPawn.bLimping @ DbgLoc("Hobble") @ PickerPawn.bHobbling $ "/" $ PickerPawn.Hobblingintensity $ DbgLoc("CPObj") @ CurrentGame.CurrentCheckpointName $ "/" $ Controller.CurrentObjective $ DbgLoc("FOV") @ PickerPawn.DefaultFOV $ "/" $ PickerPawn.RunningFOV $ "/" $ PickerPawn.CamcorderMaxFOV $ DbgLoc("EnemyDist") @ Controller.AIDistance * 100 @ DbgLoc("PhysLoc") @ PickerPawn.Physics $ "/" $ PickerPawn.LocomotionMode  $ DbgLoc("LookAt") @ PickObjectName @ "(" $ SMName $ ")";
    Stamina = DbgLoc("Stamina") @ Controller.InsanePlusStamina;
    if(!DisableAllActorInfo) {
        Foreach AllActors(Class'Actor', A) {
            Switch(A.Class) {
                case Class'OLBot':
                    break;
                case Class'PickerController':
                    break;
                Default:
                    AllActorInfo = A.Name $ "\n" $ A.Location $ "\n" $ A.Rotation * 0.005493;
                    DrawTextInWorld(AllActorInfo, A.Location, AllActorInfoDistance, 210, Vect(0,0,0));
                    break;
            }
        }
    }
    DrawString(Name, Vect2D(5, 5),MakeRGBA(226,68,61,240),Vect2D(1.3, 1.3));
    DrawString(Localize("Other", "Version", "Picker") @ "1.4", Vect2D(1855, 5),MakeRGBA(226,68,61,240),Vect2D(1.3, 1.3));

    //FlushPersistentDebugLines();
    //DrawDebugBox(PickerPawn.Location,PickerPawn.GetCollisionExtent(),255,0,0,TRUE);
    //Draw3DLine(CameraPos + (Normal(Vector(CameraRot)) * 30), PickerPawn.Location, MakeLineColor(255,255,255,255));

    if(Controller.InsanePlusState && Controller.TrainingMode) {
        DrawString(Localize("Other", "TrainingMode", "Picker"), Vect2D(830, 5),MakeRGBA(0,40,255,240),Vect2D(2.2, 2.2));
    }
    if(!DisablePickerDebug && !Controller.InsanePlusState) {
        DrawString(PlayerDebug, Vect2D(5, 23),MakeRGBA(240,240,240,240),Vect2D(1.3, 1.3));
    }
    if(Controller.TrainingMode && Controller.InsanePlusState) {
        DrawString(Stamina, Vect2D(5, 20),MakeRGBA(0,0,240,240),Vect2D(1.7, 1.7));
    }
    if(ToggleHUD || MathTasksHUD) {
        ShowPickerMenu();
        return;
    }
}

/************************MENU FUNCTION************************/

Event ShowPickerMenu() {
    local Vector2D StartClip, EndClip, Temp_Begin, Temp_End, TempTextSize, TempOffset;
    local PickerInput PlayerInput;
    local PickerController Controller;
    local PickerHero PickerPawn;
    local Texture2D MouseTexture;
    local AutoCompleteCommand TempComplete;
    local String TSVString, DRKString, OGTString, ChrisString, PlayerModelString, DoorTypeState, DoorLockState, OutComplete;
    local Float PlayerModelScale, EnemyModelScale, SpaceComplete;
    local Int IndexComplete;

    EndClip = EndClip;
    MouseTexture = Texture2D'PickerDebugMenu.PickCursor';
    Controller = PickerController(PlayerOwner);
    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    PickerPawn = PickerHero(Controller.Pawn);
    Switch(ButtonDesc) {
        case "DebugFuncs":
            ButtonDesc = "DebugFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "PlayerFuncs":
            ButtonDesc = "PlayerFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "EnemyFuncs":
            ButtonDesc = "EnemyFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "WorldFuncs":
            ButtonDesc = "WorldFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "SettingsFuncs":
            ButtonDesc = "SettingsFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "DoorsFuncs":
            ButtonDesc = "DoorsFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "AddFuncs":
            ButtonDesc = "AddFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "AddEnemyFuncs":
            ButtonDesc ="AddEnemyFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "AddLightFuncs":
            ButtonDesc = "AddLightFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "AddPropFuncs":
            ButtonDesc = "AddPropFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "AddPlayerFuncs":
            ButtonDesc = "AddPlayerFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "OtherFuncs":
            ButtonDesc = "OtherFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "InsaneChoiceFuncs":
            ButtonDesc = "InsaneChoiceFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "RandomizerChoiceFuncs":
            ButtonDesc = "RandomizerChoiceFuncs";
            FinalDesc = DescLoc(ButtonDesc);
            break;
        case "NothingFuncs":
            ButtonDesc = "NothingFuncs";
            FinalDesc = "";
            break;
    }

    /*DebugFuncs = "------------- Debug Functions -------------\n \nShow AI - Show/Hide AI Info\nShow FPS - Show/Hide FPS\nShow LEVELS - Show/Hide Loaded Parts of Levels\nShow BSP - Show/Hide Brushes\nShow STATICMESHES - Show/Hide Static Meshes\nShow SKELETALMESHES - Show/Hide Skeletal Meshes\nShow PATHS - Show/Hide Enemies Paths\nShow BOUNDS - Show/Hide Actors Bounds\nShow COLLISION - Show/Hide Actors Collision\nShow VOLUMES - Show/Hide Volumes\nShow FOG - Show/Hide Fog\nShow POSTPROCESS - Show/Hide Postprocess\nShow LEVELCOLORATION - Show/Hide Actors Colors\nUncap FPS - Remove Limiter FPS\n \n--------------------------";
    PlayerFuncs = "------------- Player Functions -------------\n \nGodMode - if true, Player is Immortal\nFreecam - if true, Camera flies Freely\nNoclip - if true, Player follows Camera\nBunny Hop - if true, Player not Landed\nLimp - if true, Player is Limp (Like Miles)\nHobble (Float Amount) - if true, Player is Hobble (Like Waylon)\nBatteries (Int Count) - Add or Remove Batteries\nFOV (Float DefFOV, Float RunFOV, Float CamFOV)- Change Player Field Of View\nDamage (Int Damage) - Give Damage Yourself\nCamera Bone (Name Bone) - Change Camera Bone\nFree in Animation - Free Rotation Camera in Animations (Only NOT Cinematic)\nAnimation Speed (Float Speed) - Change Animations Speed\nPlayer Model (String PlayerModel) - Change Player Mesh and Materials\nPlayer Scale (Float Scale) - Change Player Scale without Collision\n \n--------------------------";
    EnemyFuncs = "------------- Enemy Functions -------------\n \nKill Enemy (Bool Force) - Kills All Enemies near Player\nDisable AI - Disable AI on All Enemies near Player\nChris Model - Change Chris Model to Demo and Back\n \n--------------------------";
    WorldFuncs = "------------- World Functions -------------\n \nDoor Functions - Doors's Menu\nOff All Base Light - Partially Removes Light from Map\nStreaming Volumes - Freeze/Unfreeze Volumes Unload Map\nDarkness Volumes - On/Off Darkness Volumes\nGame Speed (Float Speed) - Change Game Speed\nLoad Checkpoint (String Checkpoint) - Load Any Checkpoint on Map\nReload Checkpoint - Reload Game to Last Checkpoint\nLoad Map Currently - Load All Currently Map\nGamma (Float Gamma) - Change Gamma\nGravity (Float Gravity) - Change World Gravity\nAudio Volume (Float Volume) - Change Audio Volume\nDestroy Class (Class Actor) - Destroy All Actors By Class\n \n--------------------------";
    SettingsFuncs = "------------- Picker Settings -------------\n \nDisable Click Sound - On/Off Click Sound when You Press LMB\nDisable Teleport Sound - On/Off Click Sound when You Teleport Enemies to Player\nDisable Pause In Menu - Currently Closed!\nDisable Picker Debug - Show/Hide Picker Debug Info\n \n--------------------------";
    DoorsFuncs = "------------- Door Functions -------------\n \nChange Doors State (Bool Force) - Locked/Unlocked All Doors\nDelete All Doors (Bool Force) - Delete All Doors\nChange Doors Type (Bool Force) - Normal/Locker Type Doors\n \n--------------------------";
    AddFuncs = "------------- Add and Remove -------------\n \nLight - Light's Menu\nEnemy - Enemy's Menu\n \n--------------------------";
    AddLightFuncs = "------------- Add Light Functions -------------\n \nAdd PointLight (Float Brightness, Float Radius, Byte R, Byte G, Byte B, Byte A, Bool CastShadows) - Add Point Light\nAdd SpotLight (Float Brightness, Float Radius, Byte R, Byte G, Byte B, Byte A, Bool CastShadows) - Add Spot Light\nRemove All Lights - Delete All Your Lights\nAdd Stalker PointLight - Currently Closed!\n \n--------------------------";
    AddEnemyFuncs = "------------- Add Enemy Functions -------------\n \nSpawn Enemy (String Enemy) - Spawn Enemy Anywhere (Soldier/Groom/Surgeon/Patient/Cannibal/Priest/NanoCloud)\n \n--------------------------";
    OtherFuncs = "------------- Other Functions -------------\n \nFinish Game (Int Game, Bool Finish) - Show/Hide Chapters Menu (0 - Original, 1 - DLC, 2 - Both)\nInsane Plus - Insane Plus's Menu\nRandomizer - Randomizer's Menu\nActors Base Player - Part Actors become Part of Player\n \n--------------------------";
    InsaneChoiceFuncs = "------------- Insane Plus v1.0 -------------\n \nStart Insane Plus! (String Checkpoint) - Starting Insane Plus Mode (with any Checkpoint)\nOne Battery - if true, Player has 1/1 Batteries\nFast Enemies - if true, All Enemies become Faster\nDisable Camera - if true, Camera is Disabled\nSlow Player - if true, Player become Slow\nOne Shot - if true, Player Dies from One Hit\nCursed Batteries - if true, Batteries are charged Differently\nLimited Stamina - if true, Player Cannot run Infinitely\nSuper Vision for Enemies - if true, Darkness Volumes Disappear\nSmart Enemies - if true, Enemies are Always Open Doors\nShow Stamina - if true, you can see Stamina Indicator\nTraining Mode - if true, Difficulty is Nightmare, not Insane\nSkip Death Screen - if true, After Death Level Restart After 1 sec\n \n--------------------------";
    RandomizerChoiceFuncs = "------------- Randomizer v1.0 -------------\n \nStart Randomizer (String FullyRandom) - Starting Randomizer Mode (with FullyRandom)\nSmall Random Time (Float Seconds) - Small Random Repeats every <Seconds> seconds\nMedium Random Time (Float Seconds) - Medium Random Repeats every <Seconds> seconds\nLarge Random Time (Float Seconds) - Large Random Repeats every <Seconds> seconds\nFully Random - if true, Randomizer will have Fully Random\n \n--------------------------";
    AddPropFuncs = "------------- Add Prop Functions -------------\n \nSpawn Prop (StaticMesh Mesh, Int MaterialIndex, MaterialInstanceConstant Material) - Spawn Prop with Mesh and Material\nChange Prop (PickerProp Prop, StaticMesh Mesh, Int MaterialIndex, MaterialInstanceConstant Material) - Change All/Selected Prop Mesh and/or Material\nDeleteProp (PickerProp Prop) - Delete All/Selected Prop\n \n--------------------------";
*/
    if(Controller.DoorTypeState) {
        DoorTypeState = DbgLoc("DoorTypeLocker");
    }
    else {
        DoorTypeState = DbgLoc("DoorTypeNormal");
    }
    if(Controller.DoorLockState) {
        DoorLockState = DbgLoc("DoorUnlock");
    }
    else {
        DoorLockState = DbgLoc("DoorLock");
    }
    if(TSVBool) {
        TSVString = DbgLoc("TSVFreeze");
    }
    else {
        TSVString = DbgLoc("TSVUnfreeze");
    }
    if(Controller.bDark) {
        DRKString = DbgLoc("DarkDisabled");
    }
    else {
        DRKString = DbgLoc("DarkEnabled");
    }
    if(Controller.ChrisState) {
        ChrisString = DbgLoc("ChrisDemo");
    }
    else {
        ChrisString = DbgLoc("ChrisOriginal");
    }
    if(PickerGame(WorldInfo.Game).IsPlayingDLC()) {
        OGTString = DbgLoc("WaylonDLC");
    }
    else {
        OGTString = DbgLoc("MilesMain");
    }
    PlayerModelString = Controller.CustomPM;
    //DrawBox(Vect2D(390, 250), Vect2D(500, 250), MakeRGBA(20,20,20,180), StartClip, EndClip);
    DrawBox(Vect2D(265, 145), Vect2D(750, 500), MakeRGBA(BackgroundColor.Red,BackgroundColor.Green,BackgroundColor.Blue,BackgroundColor.Alpha), StartClip, EndClip); // MakeRGBA(7,7,7,180)
    Foreach Controller.ManualAutoCompleteList(TempComplete, IndexComplete) {
        if(InStr(Left(Caps(TempComplete.Command),Len(Command)),Caps(Command)) != -1 &&  Command != "" && Command != " ") {
            OutComplete $= TempComplete.Command @ TempComplete.Desc $ "\n";
            break;
        }
    }
    //Canvas.SetPos(390 / 1280.0f * Canvas.SizeX, 250 / 720.0f * Canvas.SizeY);
    //Canvas.SetDrawColor(45,45,45,230);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    //Canvas.DrawRect(500 / 1280.0f * Canvas.SizeX , 12 / 720.0f * Canvas.SizeY);
    DrawBox(Vect2D(265, 130), Vect2D(750, 15), MakeRGBA(ConsoleColor.Red, ConsoleColor.Green, ConsoleColor.Blue, ConsoleColor.Alpha)); // MakeRGBA(30, 30, 33, 230)
    if(MathTasksHUD && Controller.MathTasksTimer) {
        DrawString(">" @ Controller.MathTasksGlobalA @ MathTasksOperation @ Controller.MathTasksGlobalB @ "=" @ PlayerInput.MathTasksAnswer $ "_", Vect2D(399, 196.5), MakeRGBA(170, 170, 170, 255), Vect2D(1.8, 1.8));
        AddButton(String(10 - WorldInfo.Game.GetTimerCount('MathTasksCheck', Controller)), "", Vect2D(285, 165),, StartClip, EndClip);
        return;
    }
    if(!Controller.InsanePlusState) {
        //DrawString(">" @ Command $ "_", Vect2D(590, 375), MakeRGBA(170,170,170,255));
        //DrawString(">" @ Command $ "_", Vect2D(399, 196.5), MakeRGBA(170, 170, 170, 255), Vect2D(1.8, 1.8));
        DrawString(OutComplete, Vect2D(399, 156), MakeRGBA(PromptTextColor.Red, PromptTextColor.Green, PromptTextColor.Blue, PromptTextColor.Alpha), Vect2D(1.8, 1.8)); // MakeRGBA(190, 190, 190, 255)
        DrawConsoleString(">" @ Command, Vect2D(400, 194), MakeRGBA(ConsoleTextColor.Red, ConsoleTextColor.Green, ConsoleTextColor.Blue,ConsoleTextColor.Alpha), Vect2D(1.8, 1.8)); //MakeRGBA(210, 210, 220, 255)
        if(!DisableButtonDescs) {
            DrawString(FinalDesc, Vect2D(1375, 140), MakeRGBA(240, 240, 240, 255));
        }
        Switch(CurrentMenu) {
            case Normal:
                AddButton(ButtonLoc("DebugFunctions"), "SetMenu ShowDebug DebugFuncs", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("PlayerFunctions"), "SetMenu Player PlayerFuncs",, true,,,,);
                AddButton(ButtonLoc("EnemyFunctions"), "SetMenu Enemy EnemyFuncs",, true);
                AddButton(ButtonLoc("WorldFunctions"), "SetMenu World WorldFuncs",, true);
                AddButton(ButtonLoc("OtherFunctions"), "SetMenu Other OtherFuncs",, true);
                AddButton(ButtonLoc("AddandRemove"), "SetMenu Add AddFuncs",, true);
                AddButton(ButtonLoc("CinematicFunctions"), "SetMenu Cinematic NothingFuncs",, true);
                AddButton(ButtonLoc("PickerSettings"), "SetMenu Settings SettingsFuncs",, true);
                AddButton(ButtonLoc("Close"), "TogglePickerMenu false", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha)); // MakeRGBA(226, 68, 61, 225) MakeRGBA(180, 147, 145, 225) MakeRGBA(255, 255, 255, 255)
                break;
            case ShowDebug:
                AddButton(ButtonLoc("AI"), "ToggleAIDebug", Vect2D(285, 165),, StartClip, EndClip,,);
                AddButton(ButtonLoc("FPS"), "Stat FPS",, true);
                AddButton(ButtonLoc("LEVELS"), "Stat LEVELS",, true);
                AddButton(ButtonLoc("BSP"), "Show BSP",, true);
                AddButton(ButtonLoc("STATICMESHES"), "Show STATICMESHES",, true);
                AddButton(ButtonLoc("SKELMESHES"), "Show SKELETALMESHES",, true);
                AddButton(ButtonLoc("MESHEDGES"), "Show MESHEDGES",, true);
                AddButton(ButtonLoc("PATHS"), "Show PATHS",, true);
                AddButton(ButtonLoc("BOUNDS"), "Show BOUNDS",, true);
                AddButton(ButtonLoc("COLLISION"), "Show COLLISION",, true);
                AddButton(ButtonLoc("VOLUMES"), "ToggleShowVolumes",, true);
                AddButton(ButtonLoc("FOG"), "Show FOG",, true);
                AddButton(ButtonLoc("POSTPROCESS"), "Show POSTPROCESS",, true);
                AddButton(ButtonLoc("LIGHTFUNCTIONS"), "Show LIGHTFUNCTIONS",, true);
                AddButton(ButtonLoc("ZEROEXTENT"), "Show ZEROEXTENT",, true);
                AddButton(ButtonLoc("LEVELCOLORATION"), "Show LEVELCOLORATION",, true);
                AddButton(ButtonLoc("FREEZERENDERING"), "FREEZERENDERING",, true);
                AddButton(ButtonLoc("FREEZESTREAMING"), "FREEZESTREAMING",, true);
                AddButton(ButtonLoc("SHOWMIPLEVELS"), "SHOWMIPLEVELS",, true);
                AddButton(ButtonLoc("LockFPS"), "ChangeFrameLock ",, true,,, true);
                AddButton(ButtonLoc("DeleteAllSaves"), "DeleteAllSaves",, true);
                AddButton(ButtonLoc("SaveAllSaves"), "SaveAllSaves",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Player:
                AddButton(ButtonLoc("GodMode") @ PickerPawn.bGodMode, "ToggleGodMode", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Freecam") @ Controller.bDebugFreeCam, "ToggleFreecam",, true);
                AddButton(ButtonLoc("Fixedcam") @ Controller.bDebugFixedCam, "ToggleFixedcam",, true);
                AddButton(ButtonLoc("Noclip") @ Controller.bDebugGhost, "ToggleNoclip",, true);
                AddButton(ButtonLoc("Ghost") @ Controller.bDebugFullyGhost, "ToggleGhost",, true);
                AddButton(ButtonLoc("BunnyHop") @ Controller.bBhop, "ToggleBhop",, true);
                AddButton(ButtonLoc("AutoBunnyHop") @ Controller.bAutoBunnyHop, "ToggleAutoBunnyHop",, true);
                AddButton(ButtonLoc("UnlimitedBatteries") @ Controller.CheatManager.bUnlimitedBatteries, "ToggleUnlimitedBatteries",, true);
                AddButton(ButtonLoc("Limp") @ PickerPawn.bLimping, "Limp",, true);
                AddButton(ButtonLoc("Hobble") @ PickerPawn.bHobbling $ "/" $ PickerPawn.HobblingIntensity, "Hobble ",, true,,, !PickerPawn.bHobbling);
                AddButton(ButtonLoc("ToggleThirdPerson") @ Controller.bThirdPersonMode, "ToggleThirdPerson" @  RussianBool(Controller.bThirdPersonMode),, true);
                AddButton(ButtonLoc("Batteries") @ Controller.NumBatteries, "ChangeBatteries ",, true,,, true);
                AddButton(ButtonLoc("FreeAnimations") @ Controller.bAnimFree, "AnimFree",, true);
                AddButton(ButtonLoc("PlayerAnimationSpeed") @ Controller.fPlayerAnimRate, "PlayerAnimRate ",, true,,, true);
                AddButton(ButtonLoc("PlayPlayerAnim"), "PlayPlayerAnim ",, true,,, true);
                AddButton(ButtonLoc("FOV") @ PickerPawn.DefaultFOV $ "/" $ PickerPawn.RunningFOV $ "/" $ PickerPawn.CamcorderMaxFOV, "ChangeFOV ",, true,,, true);
                AddButton(ButtonLoc("Damage") @ 100-PickerPawn.Health, "DmgSelf ",, true,,, true);
                AddButton(ButtonLoc("PlayerModel") @ PlayerModelString, "ChangePlayerModel ",, true,,, true);
                AddButton(ButtonLoc("PlayerScale") @ Controller.vScalePlayer, "ScalePlayer ",, true,,, true);
                AddButton(ButtonLoc("CameraBone") @ PickerPawn.Camera.CameraBoneName, "CameraBone ",, true,,, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Enemy:
                AddButton(ButtonLoc("KillEnemy"), "ToggleKillEnemy", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("DisableAI") @ Controller.bDisAI, "ToggleDisAI" @ RussianBool(bForceFuncs),, true);
                AddButton(ButtonLoc("TpEnemy"), "TeleportEnemyToPlayer",, true);
                AddButton(ButtonLoc("ScaleEnemies") @ Controller.vScaleEnemies, "ScaleEnemy ",, true,,, true);
                AddButton(ButtonLoc("ChrisModel") @ ChrisString, "ChangeChrisModel ",, true,,, true);
                AddButton(ButtonLoc("EnemyAnimationSpeed") @ Controller.fEnemyAnimRate, "EnemyAnimRate ",, true,,, true);
                AddButton(ButtonLoc("PlayEnemyAnim"), "PlayEnemyAnim ",, true,,, true);
                AddButton(ButtonLoc("Force") @ bForceFuncs, "ToggleForceFuncs",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case World:
                AddButton(ButtonLoc("DoorFunctions"), "SetMenu WDoors DoorsFuncs", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("OffBaseLight"), "OffBaseLight",, true);
                AddButton(ButtonLoc("StreamVolumes") @ TSVString, "TSVCommand",, true);
                AddButton(ButtonLoc("DarkVolumes") @ DRKString, "Darkness",, true);
                AddButton(ButtonLoc("GameType") @ OGTString, "ChangeGameType" @ InvertGameType(PickerGame(WorldInfo.Game).IsPlayingDLC()),, true);
                AddButton(ButtonLoc("GameSpeed") @ Controller.WorldInfo.Game.GameSpeed, "SetGameSpeed ",, true,,, true);
                AddButton(ButtonLoc("LoadCP"), "SetMenu WChapters NothingFuncs",, true);
                AddButton(ButtonLoc("ReloadCP"), "Reload",, true);
                AddButton(ButtonLoc("LoadFullMap") @ Controller.AllLoadedState, "ToggleLoadLoc",, true);
                AddButton(ButtonLoc("Gamma") @ Controller.GetGamma(), "Gamma ",, true,,, true);
                AddButton(ButtonLoc("Gravity") @ WorldInfo.WorldGravityZ, "SetGravity ",, true,,, true);
                AddButton(ButtonLoc("AudioVolume"), "SetVolume ",, true,,, true);
                AddButton(ButtonLoc("DestroyClass"), "DelClass ",, true,,, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WChapters:
                AddButton(ButtonLoc("AdminBlock1"), "SetMenu WAdmin1 NothingFuncs", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("PrisonBlock1"), "SetMenu WPrison1 NothingFuncs",, true);
                AddButton(ButtonLoc("Sewer1"), "SetMenu WSewer NothingFuncs",, true);
                AddButton(ButtonLoc("MaleWard1"), "SetMenu WMaleWard NothingFuncs",, true);
                AddButton(ButtonLoc("Courtyard1"), "SetMenu WCourtyard1 NothingFuncs",, true);
                AddButton(ButtonLoc("FemaleWard1"), "SetMenu WFemaleWard NothingFuncs",, true);
                AddButton(ButtonLoc("AdminBlock2"), "SetMenu WAdmin2 NothingFuncs",, true);
                AddButton(ButtonLoc("Lab1"), "SetMenu WLab1 NothingFuncs",, true);
                AddButton(ButtonLoc("Lab2"), "SetMenu WLab2 NothingFuncs",, true);
                AddButton(ButtonLoc("Hospital1"), "SetMenu WHospital NothingFuncs",, true);
                AddButton(ButtonLoc("Courtyard2"), "SetMenu WCourtyard2 NothingFuncs",, true);
                AddButton(ButtonLoc("PrisonBlock2"), "SetMenu WPrison2 NothingFuncs",, true);
                AddButton(ButtonLoc("Courtyard3"), "SetMenu WCourtyard3 NothingFuncs",, true);
                AddButton(ButtonLoc("VocationalBlock1"), "SetMenu WVocational NothingFuncs",, true);
                AddButton(ButtonLoc("Exit1"), "SetMenu WExit NothingFuncs",, true);
                AddButton(ButtonLoc("SkipStart"), "SkipStart",, true);
                AddButton(ButtonLoc("SkipTorture"), "SkipTorture",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu World WorldFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WAdmin1:
                AddButton(ButtonLoc("StartGame"), "CP StartGame", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Admin_Gates"), "CP Admin_Gates",, true);
                AddButton(ButtonLoc("Admin_Garden"), "CP Admin_Garden",, true);
                AddButton(ButtonLoc("Admin_Explosion"), "CP Admin_Explosion",, true);
                AddButton(ButtonLoc("Admin_Mezzanine"), "CP Admin_Mezzanine",, true);
                AddButton(ButtonLoc("Admin_MainHall"), "CP Admin_MainHall",, true);
                AddButton(ButtonLoc("Admin_WheelChair"), "CP Admin_WheelChair",, true);
                AddButton(ButtonLoc("Admin_SecurityRoom"), "CP Admin_SecurityRoom",, true);
                AddButton(ButtonLoc("Admin_Basement"), "CP Admin_Basement",, true);
                AddButton(ButtonLoc("Admin_Electricity"), "CP Admin_Electricity",, true);
                AddButton(ButtonLoc("Admin_PostBasement"), "CP Admin_PostBasement",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WPrison1:
                AddButton(ButtonLoc("Prison_Start"), "CP Prison_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Prison_IsolationCells01_Mid"), "CP Prison_IsolationCells01_Mid",, true);
                AddButton(ButtonLoc("Prison_ToPrisonFloor"), "CP Prison_ToPrisonFloor",, true);
                AddButton(ButtonLoc("Prison_PrisonFloor_3rdFloor"), "CP Prison_PrisonFloor_3rdFloor",, true);
                AddButton(ButtonLoc("Prison_PrisonFloor_SecurityRoom1"), "CP Prison_PrisonFloor_SecurityRoom1",, true);
                AddButton(ButtonLoc("Prison_PrisonFloor02_IsolationCells01"), "CP Prison_PrisonFloor02_IsolationCells01",, true);
                AddButton(ButtonLoc("Prison_Showers_2ndFloor"), "CP Prison_Showers_2ndFloor",, true);
                AddButton(ButtonLoc("Prison_PrisonFloor02_PostShowers"), "CP Prison_PrisonFloor02_PostShowers",, true);
                AddButton(ButtonLoc("Prison_PrisonFloor02_SecurityRoom2"), "CP Prison_PrisonFloor02_SecurityRoom2",, true);
                AddButton(ButtonLoc("Prison_IsolationCells02_Soldier"), "CP Prison_IsolationCells02_Soldier",, true);
                AddButton(ButtonLoc("Prison_IsolationCells02_PostSoldier"), "CP Prison_IsolationCells02_PostSoldier",, true);
                AddButton(ButtonLoc("Prison_OldCells_PreStruggle"), "CP Prison_OldCells_PreStruggle",, true);
                AddButton(ButtonLoc("Prison_OldCells_PreStruggle2"), "CP Prison_OldCells_PreStruggle2",, true);
                AddButton(ButtonLoc("Prison_Showers_Exit"), "CP Prison_Showers_Exit",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WSewer:
                AddButton(ButtonLoc("Sewer_start"), "CP Sewer_start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Sewer_FlushWater"), "CP Sewer_FlushWater",, true);
                AddButton(ButtonLoc("Sewer_WaterFlushed"), "CP Sewer_WaterFlushed",, true);
                AddButton(ButtonLoc("Sewer_Ladder"), "CP Sewer_Ladder",, true);
                AddButton(ButtonLoc("Sewer_ToCitern"), "CP Sewer_ToCitern",, true);
                AddButton(ButtonLoc("Sewer_Citern1"), "CP Sewer_Citern1",, true);
                AddButton(ButtonLoc("Sewer_Citern2"), "CP Sewer_Citern2",, true);
                AddButton(ButtonLoc("Sewer_PostCitern"), "CP Sewer_PostCitern",, true);
                AddButton(ButtonLoc("Sewer_ToMaleWard"), "CP Sewer_ToMaleWard",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WMaleWard:
                AddButton(ButtonLoc("Male_Start"), "CP Male_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Male_Chase"), "CP Male_Chase",, true);
                AddButton(ButtonLoc("Male_ChasePause"), "CP Male_ChasePause",, true);
                AddButton(ButtonLoc("Male_Torture"), "CP Male_Torture",, true);
                AddButton(ButtonLoc("Male_TortureDone"), "CP Male_TortureDone",, true);
                AddButton(ButtonLoc("Male_surgeon"), "CP Male_surgeon",, true);
                AddButton(ButtonLoc("Male_GetTheKey"), "CP Male_GetTheKey",, true);
                AddButton(ButtonLoc("Male_GetTheKey2"), "CP Male_GetTheKey2",, true);
                AddButton(ButtonLoc("Male_Elevator"), "CP Male_Elevator",, true);
                AddButton(ButtonLoc("Male_ElevatorDone"), "CP Male_ElevatorDone",, true);
                AddButton(ButtonLoc("Male_Priest"), "CP Male_Priest",, true);
                AddButton(ButtonLoc("Male_Cafeteria"), "CP Male_Cafeteria",, true);
                AddButton(ButtonLoc("Male_SprinklerOff"), "CP Male_SprinklerOff",, true);
                AddButton(ButtonLoc("Male_SprinklerOn"), "CP Male_SprinklerOn",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WCourtyard1:
                AddButton(ButtonLoc("Courtyard_Start"), "CP Courtyard_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Courtyard_Corridor"), "CP Courtyard_Corridor",, true);
                AddButton(ButtonLoc("Courtyard_Chapel"), "CP Courtyard_Chapel",, true);
                AddButton(ButtonLoc("Courtyard_Soldier1"), "CP Courtyard_Soldier1",, true);
                AddButton(ButtonLoc("Courtyard_Soldier2"), "CP Courtyard_Soldier2",, true);
                AddButton(ButtonLoc("Courtyard_FemaleWard"), "CP Courtyard_FemaleWard",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WFemaleWard:
                AddButton(ButtonLoc("Female_Start"), "CP Female_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Female_Mainchute"), "CP Female_Mainchute",, true);
                AddButton(ButtonLoc("Female_2ndFloor"), "CP Female_2ndFloor",, true);
                AddButton(ButtonLoc("Female_2ndFloorChute"), "CP Female_2ndFloorChute",, true);
                AddButton(ButtonLoc("Female_ChuteActivated"), "CP Female_ChuteActivated",, true);
                AddButton(ButtonLoc("Female_Keypickedup"), "CP Female_Keypickedup",, true);
                AddButton(ButtonLoc("Female_3rdFloor"), "CP Female_3rdFloor",, true);
                AddButton(ButtonLoc("Female_3rdFloorHole"), "CP Female_3rdFloorHole",, true);
                AddButton(ButtonLoc("Female_3rdFloorPostHole"), "CP Female_3rdFloorPostHole",, true);
                AddButton(ButtonLoc("Female_Tobigjump"), "CP Female_Tobigjump",, true);
                AddButton(ButtonLoc("Female_LostCam"), "CP Female_LostCam",, true);
                AddButton(ButtonLoc("Female_FoundCam"), "CP Female_FoundCam",, true);
                AddButton(ButtonLoc("Female_Chasedone"), "CP Female_Chasedone",, true);
                AddButton(ButtonLoc("Female_Exit"), "CP Female_Exit",, true);
                AddButton(ButtonLoc("Female_Jump"), "CP Female_Jump",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WAdmin2:
                AddButton(ButtonLoc("Revisit_Soldier1"), "CP Revisit_Soldier1", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Revisit_Mezzanine"), "CP Revisit_Mezzanine",, true);
                AddButton(ButtonLoc("Revisit_ToRH"), "CP Revisit_ToRH",, true);
                AddButton(ButtonLoc("Revisit_RH"), "CP Revisit_RH",, true);
                AddButton(ButtonLoc("Revisit_FoundKey"), "CP Revisit_FoundKey",, true);
                AddButton(ButtonLoc("Revisit_To3rdfloor"), "CP Revisit_To3rdfloor",, true);
                AddButton(ButtonLoc("Revisit_3rdFloor"), "CP Revisit_3rdFloor",, true);
                AddButton(ButtonLoc("Revisit_RoomCrack"), "CP Revisit_RoomCrack",, true);
                AddButton(ButtonLoc("Revisit_ToChapel"), "CP Revisit_ToChapel",, true);
                AddButton(ButtonLoc("Revisit_PriestDead"), "CP Revisit_PriestDead",, true);
                AddButton(ButtonLoc("Revisit_Soldier3"), "CP Revisit_Soldier3",, true);
                AddButton(ButtonLoc("Revisit_ToLab"), "CP Revisit_ToLab",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WLab1:
                AddButton(ButtonLoc("Lab_Start"), "CP Lab_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Lab_PremierAirLock"), "CP Lab_PremierAirLock",, true);
                AddButton(ButtonLoc("Lab_SwarmIntro"), "CP Lab_SwarmIntro",, true);
                AddButton(ButtonLoc("Lab_SwarmIntro2"), "CP Lab_SwarmIntro2",, true);
                AddButton(ButtonLoc("Lab_Soldierdead"), "CP Lab_Soldierdead",, true);
                AddButton(ButtonLoc("Lab_SpeachDone"), "CP Lab_SpeachDone",, true);
                AddButton(ButtonLoc("Lab_SwarmCafeteria"), "CP Lab_SwarmCafeteria",, true);
                AddButton(ButtonLoc("Lab_EBlock"), "CP Lab_EBlock",, true);
                AddButton(ButtonLoc("Lab_ToBilly"), "CP Lab_ToBilly",, true);
                AddButton(ButtonLoc("Lab_BigRoom"), "CP Lab_BigRoom",, true);
                AddButton(ButtonLoc("Lab_BigRoomDone"), "CP Lab_BigRoomDone",, true);
                AddButton(ButtonLoc("Lab_BigTower"), "CP Lab_BigTower",, true);
                AddButton(ButtonLoc("Lab_BigTowerStairs"), "CP Lab_BigTowerStairs",, true);
                AddButton(ButtonLoc("Lab_BigTowerMid"), "CP Lab_BigTowerMid",, true);
                AddButton(ButtonLoc("Lab_BigTowerDone"), "CP Lab_BigTowerDone",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WLab2:
                AddButton(ButtonLoc("DLC_Start"), "CP DLC_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("DLC_Lab_Start"), "CP DLC_Lab_Start",, true);
                AddButton(ButtonLoc("Lab_AfterExperiment"), "CP Lab_AfterExperiment",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WHospital:
                AddButton(ButtonLoc("Hospital_Start"), "CP Hospital_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Hospital_Free"), "CP Hospital_Free",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_ChaseStart"), "CP Hospital_1stFloor_ChaseStart",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_ChaseEnd"), "CP Hospital_1stFloor_ChaseEnd",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_dropairvent"), "CP Hospital_1stFloor_dropairvent",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_SAS"), "CP Hospital_1stFloor_SAS",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_Lobby"), "CP Hospital_1stFloor_Lobby",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_NeedHandCuff"), "CP Hospital_1stFloor_NeedHandCuff",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_GotKey"), "CP Hospital_1stFloor_GotKey",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_Chase"), "CP Hospital_1stFloor_Chase",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_Crema"), "CP Hospital_1stFloor_Crema",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_Bake"), "CP Hospital_1stFloor_Bake",, true);
                AddButton(ButtonLoc("Hospital_1stFloor_Crema2"), "CP Hospital_1stFloor_Crema2",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Crema"), "CP Hospital_2ndFloor_Crema",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Canibalrun"), "CP Hospital_2ndFloor_Canibalrun",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Canibalgone"), "CP Hospital_2ndFloor_Canibalgone",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_ExitIsLocked"), "CP Hospital_2ndFloor_ExitIsLocked",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_RoomsCorridor"), "CP Hospital_2ndFloor_RoomsCorridor",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_ToLab"), "CP Hospital_2ndFloor_ToLab",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Start_Lab_2nd"), "CP Hospital_2ndFloor_Start_Lab_2nd",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_GazOff"), "CP Hospital_2ndFloor_GazOff",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Labdone"), "CP Hospital_2ndFloor_Labdone",, true);
                AddButton(ButtonLoc("Hospital_2ndFloor_Exit"), "CP Hospital_2ndFloor_Exit",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WCourtyard2:
                AddButton(ButtonLoc("Courtyard1_Start"), "CP Courtyard1_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Courtyard1_RecreationArea"), "CP Courtyard1_RecreationArea",, true);
                AddButton(ButtonLoc("Courtyard1_DupontIntro"), "CP Courtyard1_DupontIntro",, true);
                AddButton(ButtonLoc("Courtyard1_Basketball"), "CP Courtyard1_Basketball",, true);
                AddButton(ButtonLoc("Courtyard1_SecurityTower"), "CP Courtyard1_SecurityTower",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WPrison2:
                AddButton(ButtonLoc("PrisonRevisit_Start"), "CP PrisonRevisit_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("PrisonRevisit_Radio"), "CP PrisonRevisit_Radio",, true);
                AddButton(ButtonLoc("PrisonRevisit_Priest"), "CP PrisonRevisit_Priest",, true);
                AddButton(ButtonLoc("PrisonRevisit_Tochase"), "CP PrisonRevisit_Tochase",, true);
                AddButton(ButtonLoc("PrisonRevisit_Chase"), "CP PrisonRevisit_Chase",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WCourtyard3:
                AddButton(ButtonLoc("Courtyard2_Start"), "CP Courtyard2_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Courtyard2_FrontBuilding2"), "CP Courtyard2_FrontBuilding2",, true);
                AddButton(ButtonLoc("Courtyard2_ElectricityOff"), "CP Courtyard2_ElectricityOff",, true);
                AddButton(ButtonLoc("Courtyard2_ElectricityOff_2"), "CP Courtyard2_ElectricityOff_2",, true);
                AddButton(ButtonLoc("Courtyard2_ToWaterTower"), "CP Courtyard2_ToWaterTower",, true);
                AddButton(ButtonLoc("Courtyard2_WaterTower"), "CP Courtyard2_WaterTower",, true);
                AddButton(ButtonLoc("Courtyard2_TopWaterTower"), "CP Courtyard2_TopWaterTower",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WVocational:
                AddButton(ButtonLoc("Building2_Start"), "CP Building2_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Building2_Attic_Mid"), "CP Building2_Attic_Mid",, true);
                AddButton(ButtonLoc("Building2_Attic_Denis"), "CP Building2_Attic_Denis",, true);
                AddButton(ButtonLoc("Building2_Floor3_1"), "CP Building2_Floor3_1",, true);
                AddButton(ButtonLoc("Building2_Floor3_2"), "CP Building2_Floor3_2",, true);
                AddButton(ButtonLoc("Building2_Floor3_3"), "CP Building2_Floor3_3",, true);
                AddButton(ButtonLoc("Building2_Floor3_4"), "CP Building2_Floor3_4",, true);
                AddButton(ButtonLoc("Building2_Elevator"), "CP Building2_Elevator",, true);
                AddButton(ButtonLoc("Building2_Post_Elevator"), "CP Building2_Post_Elevator",, true);
                AddButton(ButtonLoc("Building2_Torture"), "CP Building2_Torture",, true);
                AddButton(ButtonLoc("Building2_TortureDone"), "CP Building2_TortureDone",, true);
                AddButton(ButtonLoc("Building2_Garden"), "CP Building2_Garden",, true);
                AddButton(ButtonLoc("Building2_Floor1_1"), "CP Building2_Floor1_1",, true);
                AddButton(ButtonLoc("Building2_Floor1_2"), "CP Building2_Floor1_2",, true);
                AddButton(ButtonLoc("Building2_Floor1_3"), "CP Building2_Floor1_3",, true);
                AddButton(ButtonLoc("Building2_Floor1_4"), "CP Building2_Floor1_4",, true);
                AddButton(ButtonLoc("Building2_Floor1_5"), "CP Building2_Floor1_5",, true);
                AddButton(ButtonLoc("Building2_Floor1_5b"), "CP Building2_Floor1_5b",, true);
                AddButton(ButtonLoc("Building2_Floor1_6"), "CP Building2_Floor1_6",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WExit:
                AddButton(ButtonLoc("MaleRevisit_Start"), "CP MaleRevisit_Start", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("AdminBlock_Start"), "CP AdminBlock_Start",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WChapters NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            
            case WDoors:
                AddButton(ButtonLoc("DoorsState") @ DoorLockState, "ToggleDoorState" @ RussianBool(bForceFuncs), Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("DeleteAllDoors") @ Controller.DoorDelState, "ToggleDoorDelete" @ RussianBool(bForceFuncs) @ "true",, true);
                AddButton(ButtonLoc("BashDoor"), "BashDoor",, true);
                AddButton(ButtonLoc("BreakDoor"), "BreakDoor",, true);
                AddButton(ButtonLoc("TriggerDoor"), "TriggerDoor ",, true,,, true);
                AddButton(ButtonLoc("DoorsType") @ DoorTypeState, "ToggleDoorType" @ RussianBool(bForceFuncs),, true);
                AddButton(ButtonLoc("DoorsMeshType"), "SetMenu WDoorsMT NothingFuncs",, true);
                AddButton(ButtonLoc("Force") @ bForceFuncs, "ToggleForceFuncs",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu World WorldFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WDoorsMT:
                AddButton(ButtonLoc("Wooden"), "ChangeDoorMeshType Wooden" @ SndDoorMat, Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("WoodenOld"), "ChangeDoorMeshType WoodenOld" @ SndDoorMat,, true);
                AddButton(ButtonLoc("WoodenWindow"), "ChangeDoorMeshType WoodenWindow" @ SndDoorMat,, true);
                AddButton(ButtonLoc("WoodenWindowSmall"), "ChangeDoorMeshType WoodenWindowSmall" @ SndDoorMat,, true);
                AddButton(ButtonLoc("WoodenWindowOld"), "ChangeDoorMeshType WoodenWindowOld" @ SndDoorMat,, true);
                AddButton(ButtonLoc("WoodenWindowOldSmall"), "ChangeDoorMeshType WoodenWindowOldSmall" @ SndDoorMat,, true);
                AddButton(ButtonLoc("WoodenWindowBig"), "ChangeDoorMeshType WoodenWindowBig" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Metal"), "ChangeDoorMeshType Metal" @ SndDoorMat,, true);
                AddButton(ButtonLoc("MetalWindow"), "ChangeDoorMeshType MetalWindow" @ SndDoorMat,, true);
                AddButton(ButtonLoc("MetalWindowSmall"), "ChangeDoorMeshType MetalWindowSmall" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Enforced"), "ChangeDoorMeshType Enforced" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Grid"), "ChangeDoorMeshType Grid" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Prison"), "ChangeDoorMeshType Prison" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Entrance"), "ChangeDoorMeshType Entrance" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Bathroom"), "ChangeDoorMeshType Bathroom" @ SndDoorMat,, true);
                AddButton(ButtonLoc("IsolatedCell"), "ChangeDoorMeshType IsolatedCell" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Locker"), "ChangeDoorMeshType Locker" @ SndDoorMat,, true);
                AddButton(ButtonLoc("LockerRusted"), "ChangeDoorMeshType LockerRusted" @ SndDoorMat,, true);
                AddButton(ButtonLoc("LockerBeige"), "ChangeDoorMeshType LockerBeige" @ SndDoorMat,, true);
                AddButton(ButtonLoc("LockerGreen"), "ChangeDoorMeshType LockerGreen" @ SndDoorMat,, true);
                AddButton(ButtonLoc("LockerHole"), "ChangeDoorMeshType LockerHole" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Glass"), "ChangeDoorMeshType Glass" @ SndDoorMat,, true);
                AddButton(ButtonLoc("Fence"), "ChangeDoorMeshType Fence" @ SndDoorMat,, true);
                AddButton(ButtonLoc("ChangeDoorSndMat"), "SetMenu WDoorsMTMS NothingFuncs",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WDoors DoorsFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case WDoorsMTMS:
                AddButton(ButtonLoc("WoodSndMat"), "ToggleChangeDoorSndMat Wood", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("BigWoodSndMat"), "ToggleChangeDoorSndMat BigWoodenDoor",, true);
                AddButton(ButtonLoc("MetalSndMat"), "ToggleChangeDoorSndMat Metal",, true);
                AddButton(ButtonLoc("SecuritySndMat"), "ToggleChangeDoorSndMat SecurityDoor",, true);
                AddButton(ButtonLoc("PrisonSndMat"), "ToggleChangeDoorSndMat BigPrisonDoor",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu WDoorsMT NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Other:
                AddButton(ButtonLoc("FinishGame"), "FinishGame ", Vect2D(285, 165),, StartClip, EndClip, true);
                AddButton(ButtonLoc("InsanePlus"), "SetMenu InsaneChoice InsaneChoiceFuncs",, true);
                AddButton(ButtonLoc("Randomizer"), "SetMenu RandomizerChoice RandomizerChoiceFuncs",, true);
                AddButton(ButtonLoc("MathTasks"), "ToggleMathTasks",, true);
                AddButton(ButtonLoc("CrabGame"), "ToggleCrabGame",, true);
                AddButton(ButtonLoc("ActorsBasePlayer"), "BaseSelf",, true);
                AddButton(ButtonLoc("KAActor"), "KAActor",, true);
                AddButton(ButtonLoc("Wernicke") @ WernickeToggle, "ToggleWernicke",, true);
                AddButton(ButtonLoc("NFS") @ NFSToggle, "ToggleNFS",, true);
                AddButton(ButtonLoc("ToggleFestival") @ Controller.bFestival, "ToggleFestival",, true);
                AddButton(ButtonLoc("ToggleEightMarch") @ Controller.bEightMarch, "ToggleEightMarch",, true);
                AddButton(ButtonLoc("TimersMenu"), "SetMenu OTimers NothingFuncs",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case OTimers:
                AddButton(ButtonLoc("ToggleRandLightColor"), "ToggleRandLightColor" @ TimersTime @ RussianBool(TimersStop), Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("ToggleRandPatientModel"), "ToggleRandPatientModel" @ TimersTime @ RussianBool(TimersStop),, true);
                AddButton(ButtonLoc("ToggleRandChangeFOV"), "ToggleRandChangeFOV" @ TimersTime @ RussianBool(TimersStop),, true);
                AddButton(ButtonLoc("TimersTime") @ TimersTime, "ToggleTimersTime ",, true,,, true);
                AddButton(ButtonLoc("TimersStop") @ TimersStop, "ToggleTimersStop",, true);
                AddButton(ButtonLoc("TimersCustomFrom"), "TimerFrom ",, true,,, true);
                AddButton(ButtonLoc("TimersCustomStop"), "TimerStop",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Other OtherFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Add:
                AddButton(ButtonLoc("Light"), "SetMenu AddL AddLightFuncs", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Enemy"), "SetMenu AddE AddEnemyFuncs",, true);
                AddButton(ButtonLoc("Prop"), "SetMenu AddP AddPropFuncs",, true);
                AddButton(ButtonLoc("AddPlayer"), "SetMenu AddPlayer AddPlayerFuncs",, true);
                AddButton(ButtonLoc("PickableObjects"), "SetMenu AddPO NothingFuncs",, true);
                AddButton(ButtonLoc("ClassAdd"), "Summon ",, true,,, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs",Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddE:
                AddButton(ButtonLoc("SpawnEnemy"), "SetMenu AddESpawn NothingFuncs", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("RemoveAllEnemies"), "KillEnemy",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Add AddFuncs",Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddESpawn:
                AddButton(ButtonLoc("ChrisWalker"), "SpawnEnemy Soldier" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack), Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("EddieGluskin"), "SpawnEnemy Groom" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("WilliamHope"), "SpawnEnemy NanoCloud" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("RichardTrager"), "SpawnEnemy Surgeon" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("FrankManera"), "SpawnEnemy Cannibal" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("MartinArchimbaud"), "SpawnEnemy Priest" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("OtherPatients"), "SetMenu AddESpawnPatient",, true);
                AddButton(ButtonLoc("RandomPatient"), "SpawnRandEnemy" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Count") @ SpawnEnemyCount, "ToggleSpawnEnemyCount ",, true,,, true);
                AddButton(ButtonLoc("WeaponForEnemy") @ Localize("Buttons", HudWeaponToUse, "Picker"), "SetMenu AddESpawnWeapons",, true);
                AddButton(ButtonLoc("EnemyShouldAttack") @ HudShouldAttack, "ToggleEnemyShouldAttack",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu AddE AddEnemyFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddESpawnPatient:
                AddButton(ButtonLoc("SimpleNormal"), "SpawnEnemy Patient_SimpleNormal" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack), Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("SimpleBloodyHead"), "SpawnEnemy Patient_SimpleBloodyHead" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimpleBlind"), "SpawnEnemy Patient_SimpleBlind" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimplePuffy"), "SpawnEnemy Patient_SimplePuffy" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimplePuffyNoPants"), "SpawnEnemy Patient_SimplePuffyNoPants" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimplePuffyMutArm"), "SpawnEnemy Patient_SimplePuffyMutArm" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimpleOneEye"), "SpawnEnemy Patient_SimpleOneEye" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimpleWeird"), "SpawnEnemy Patient_SimpleWeird" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SimpleMutHead2"), "SpawnEnemy Patient_SimpleMutHead2" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2OneEye"), "SpawnEnemy Patient_Simple2OneEye" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2MutArms"), "SpawnEnemy Patient_Simple2MutArms" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2Mouth"), "SpawnEnemy Patient_Simple2Mouth" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2MutHead2"), "SpawnEnemy Patient_Simple2MutHead" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2MutHeadArms"), "SpawnEnemy Patient_Simple2MutHeadArms" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2MutArmsNoEyes"), "SpawnEnemy Patient_Simple2MutArmsNoEyes" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Simple2PuffyJeans"), "SpawnEnemy Patient_Simple2PuffyJeans" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("NudeMouth"), "SpawnEnemy Patient_NudeMouth" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("NudeMutHead2Arm"), "SpawnEnemy Patient_NudeMutHead2Arm" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("StraitJacketMouth"), "SpawnEnemy Patient_StraitJacketMouth" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("StraitJacketNoEyes"), "SpawnEnemy Patient_StraitJacketNoEyes" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("StraitJacketMutHead"), "SpawnEnemy Patient_StraitJacketMutHead" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("StraitJacketBlind"), "SpawnEnemy Patient_StraitJacketBlind" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Worker"), "SpawnEnemy Patient_Worker" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Worker2"), "SpawnEnemy Patient_Worker2" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("WorkerBloody"), "SpawnEnemy Patient_WorkerBloody" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("WorkerBloody2"), "SpawnEnemy Patient_WorkerBloody2" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("WorkerBloody3"), "SpawnEnemy Patient_WorkerBloody3" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("WorkerBloodyHeadless"), "SpawnEnemy Patient_WorkerBloodyHeadless" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Guard"), "SpawnEnemy Patient_Guard" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("GuardBloody"), "SpawnEnemy Patient_GuardBloody" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Scientist"), "SpawnEnemy Patient_Scientist" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Scientist2"), "SpawnEnemy Patient_Scientist2" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Scientist3"), "SpawnEnemy Patient_Scientist3" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Licker"), "SpawnEnemy Patient_Licker" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Masked"), "SpawnEnemy Patient_Masked" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Hazmat"), "SpawnEnemy Patient_Hazmat" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Swat"), "SpawnEnemy Patient_Swat" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SwatMouth"), "SpawnEnemy Patient_SwatMouth" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("SwatEyes"), "SpawnEnemy Patient_SwatEyes" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Blair"), "SpawnEnemy Patient_Blair" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("BlairExplode"), "SpawnEnemy Patient_BlairExplode" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("PriestBurned"), "SpawnEnemy Patient_PriestBurned" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Dupont"), "SpawnEnemy Patient_Dupont" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("Dupont2"), "SpawnEnemy Patient_Dupont2" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("PyroManic"), "SpawnEnemy Patient_PyroManic" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("RapeVictim"), "SpawnEnemy Patient_RapeVictim" @ SpawnEnemyCount @ HudWeaponToUse @ RussianBool(HudShouldAttack),, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu AddESpawn NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddESpawnWeapons:
                AddButton(ButtonLoc("Weapon_None"), "ToggleWeaponForEnemy Weapon_None", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Weapon_Knife"), "ToggleWeaponForEnemy Weapon_Knife",, true);
                AddButton(ButtonLoc("Weapon_ButcherKnife"), "ToggleWeaponForEnemy Weapon_ButcherKnife",, true);
                AddButton(ButtonLoc("Weapon_BoneShear"), "ToggleWeaponForEnemy Weapon_BoneShear",, true);
                AddButton(ButtonLoc("Weapon_Machete"), "ToggleWeaponForEnemy Weapon_Machete",, true);
                AddButton(ButtonLoc("Weapon_NightStick"), "ToggleWeaponForEnemy Weapon_NightStick",, true);
                AddButton(ButtonLoc("Weapon_Pipe"), "ToggleWeaponForEnemy Weapon_Pipe",, true);
                AddButton(ButtonLoc("Weapon_WoodPlank"), "ToggleWeaponForEnemy Weapon_WoodPlank",, true);
                AddButton(ButtonLoc("Weapon_CannibalDrill"), "ToggleWeaponForEnemy Weapon_CannibalDrill",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu AddESpawn NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddL:
                AddButton(ButtonLoc("AddPointLight"), "MadeLight ", Vect2D(285, 165),, StartClip, EndClip, true);
                AddButton(ButtonLoc("AddSpotLight"), "MadeSpot ",, true,,, true);
                AddButton(ButtonLoc("AddDominantDirectionalLight"), "MadeDom ",, true,,, true);
                AddButton(ButtonLoc("RemoveAllLights"), "RemoveAllPickerLights",, true);
                AddButton(ButtonLoc("AddStalkerPointLight") @ Controller.bFollowLight, "MadeFollowLight ",, true,,, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Add AddFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddP:
                AddButton(ButtonLoc("SpawnProp"), "SpawnProp ", Vect2D(285, 165),, StartClip, EndClip, true);
                AddButton(ButtonLoc("ChangeProp"), "ChangeProp ",, true,,, true);
                AddButton(ButtonLoc("DeleteProp"), "DeleteProp ",, true,,, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Add AddFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddPlayer:
                AddButton(ButtonLoc("SpawnHero"), "SpawnHero " @ RussianBool(bPossessSpawnHero), Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("KillHeroes"), "KillHeroes" @ bPossessAfterKill,, true);
                AddButton(ButtonLoc("PossessHero"), "PossessHero ",, true,,, true);
                AddButton(ButtonLoc("SetTargetHero"), "SetTargetHero ",, true,,, true);
                AddButton(ButtonLoc("TogglePossessSpawnHero") @ bPossessSpawnHero, "TogglePossessSpawnHero",, true);
                AddButton(ButtonLoc("TogglePossessAfterKill") @ bPossessAfterKill, "TogglePossessAfterKill",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Add AddFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case AddPO:
                AddButton(ButtonLoc("GPI_SecurityKeycard"), "GiveItem Keycard", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("GPI_GeneratorFuseNotUsed"), "GiveItem SparkPlug",, true);
                AddButton(ButtonLoc("GPI_ShowersKeycard"), "GiveItem KeycardShower",, true);
                AddButton(ButtonLoc("GPI_TragerElevatorKey"), "GiveItem ElevatorKey",, true);
                AddButton(ButtonLoc("GPI_CourtyardKey"), "GiveItem ShedKeycard",, true);
                AddButton(ButtonLoc("GPI_FemaleWardKey"), "GiveItem Keystairs",, true);
                AddButton(ButtonLoc("GPI_FemaleWardFuse1"), "GiveItem Fuse1",, true);
                AddButton(ButtonLoc("GPI_FemaleWardFuse2"), "GiveItem Fuse2",, true);
                AddButton(ButtonLoc("GPI_FemaleWardFuse3"), "GiveItem Fuse3",, true);
                AddButton(ButtonLoc("GPI_RevisitKey"), "GiveItem KeycardRH",, true);
                AddButton(ButtonLoc("GPI_LabKey"), "GiveItem KeyToLab",, true);
                AddButton(ButtonLoc("GPI_LabKeyNotUsed"), "GiveItem Keycard_Lab",, true);
                AddButton(ButtonLoc("GPI_DLC_HandCuffKey"), "GiveItem HandcuffKey",, true);
                AddButton(ButtonLoc("GPI_DLC_MaleWardKey"), "GiveItem KeyMale",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Add AddFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Cinematic:
                AddButton(ButtonLoc("Fixedcam") @ Controller.bDebugFixedCam, "ToggleFixedcam", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("Freecam") @ Controller.bDebugFreeCam, "ToggleFreecam",, true);
                AddButton(ButtonLoc("HideHud") @ bCinematicMode, "ToggleCinematicMode",, true);
                AddButton(ButtonLoc("HideCameraHud") @ Controller.bCameraHudVisible, "ToggleCameraHud" @ RussianBool(Controller.bCameraHudVisible),, true);
                AddButton(ButtonLoc("FreecamSpeed") @ Controller.fDebugSpeed, "FreecamSpeed ",, true,,, true);
                AddButton(ButtonLoc("DisableGrain") @ Controller.bGrainDisabled, "ToggleGrain",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case Settings:
                AddButton(ButtonLoc("ButtonSound") @ !DisableClickSound, "ToggleClickButton", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("TeleportSound") @ !DisableTeleportSound, "ToggleTeleportButton",, true);
                AddButton(ButtonLoc("HideHud") @ bCinematicMode, "ToggleCinematicMode",, true);
                AddButton(ButtonLoc("ShowDebug") @ !DisablePickerDebug, "TogglePickerDebug",, true);
                AddButton(ButtonLoc("ShowActorsInfo") @ !DisableAllActorInfo, "ToggleAllActorInfo",, true);
                AddButton(ButtonLoc("ShowMessages") @ !DisablePickerMessages, "TogglePickerMessages",, true);
                AddButton(ButtonLoc("MenuMusic") @ !DisableMenuMusic, "ToggleMenuMusic",, true);
                AddButton(ButtonLoc("ButtonDescs") @ !DisableButtonDescs, "ToggleButtonDescs",, true);
                AddButton(ButtonLoc("SettingsColor"), "SetMenu SettingsColor NothingFuncs",, true);
                AddButton(ButtonLoc("Author") @ Localize("Other", "Discord", "Picker"), "CopyDiscordAbout",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Normal NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case SettingsColor:
                AddStringWithButtons(ButtonLoc("ConsoleTextColor"), Vect2D(285, 165),, StartClip, EndClip);
                AddStringWithButtons(ButtonLoc("ConsoleColor"),, true);
                AddStringWithButtons(ButtonLoc("PromptTextColor"),, true);
                AddStringWithButtons(ButtonLoc("BackgroundColor"),, true);
                AddStringWithButtons(ButtonLoc("ButtonTextColor"),, true);
                AddStringWithButtons(ButtonLoc("ButtonColor"),, true);
                AddStringWithButtons(ButtonLoc("ReturnButtonColor"),, true);
                AddStringWithButtons(ButtonLoc("RangeButtonTextColor"),, true);
                AddStringWithButtons(ButtonLoc("RangeButtonColor"),, true);
                AddStringWithButtons(ButtonLoc("RangeReturnButtonColor"),, true);
                //DrawString(ButtonLoc("ConsoleTextColor"), Vect2D(350 / 1280.0f * Canvas.SizeX, 175 /720.0f * Canvas.SizeY), MakeRGBA(ButtonTextColor.Red,ButtonTextColor.Green,ButtonTextColor.Blue,ButtonTextColor.Alpha), Vect2D(1.8, 1.8), false, true);
                AddButton(String(ConsoleTextColor.Red), "ChangeColorTheme ConsoleTextColor R",, true,,,,,,,,true);
                AddButton(String(ConsoleColor.Red), "ChangeColorTheme ConsoleColor R",, true);
                AddButton(String(PromptTextColor.Red), "ChangeColorTheme PromptTextColor R",, true);
                AddButton(String(BackgroundColor.Red), "ChangeColorTheme BackgroundColor R",, true);
                AddButton(String(ButtonTextColor.Red), "ChangeColorTheme ButtonTextColor R",, true);
                AddButton(String(ButtonColor.Red), "ChangeColorTheme ButtonColor R",, true);
                AddButton(String(ReturnButtonColor.Red), "ChangeColorTheme ReturnButtonColor R",, true);
                AddButton(String(RangeButtonTextColor.Red), "ChangeColorTheme RangeButtonTextColor R",, true);
                AddButton(String(RangeButtonColor.Red), "ChangeColorTheme RangeButtonColor R",, true);
                AddButton(String(RangeReturnButtonColor.Red), "ChangeColorTheme RangeReturnButtonColor R",, true);

                AddButton(String(ConsoleTextColor.Green), "ChangeColorTheme ConsoleTextColor G",, true,,,,,,,,true);
                AddButton(String(ConsoleColor.Green), "ChangeColorTheme ConsoleColor G",, true);
                AddButton(String(PromptTextColor.Green), "ChangeColorTheme PromptTextColor G",, true);
                AddButton(String(BackgroundColor.Green), "ChangeColorTheme BackgroundColor G",, true);
                AddButton(String(ButtonTextColor.Green), "ChangeColorTheme ButtonTextColor G",, true);
                AddButton(String(ButtonColor.Green), "ChangeColorTheme ButtonColor G",, true);
                AddButton(String(ReturnButtonColor.Green), "ChangeColorTheme ReturnButtonColor G",, true);
                AddButton(String(RangeButtonTextColor.Green), "ChangeColorTheme RangeButtonTextColor G",, true);
                AddButton(String(RangeButtonColor.Green), "ChangeColorTheme RangeButtonColor G",, true);
                AddButton(String(RangeReturnButtonColor.Green), "ChangeColorTheme RangeReturnButtonColor G",, true);

                AddButton(String(ConsoleTextColor.Blue), "ChangeColorTheme ConsoleTextColor B",, true,,,,,,,,true);
                AddButton(String(ConsoleColor.Blue), "ChangeColorTheme ConsoleColor B",, true);
                AddButton(String(PromptTextColor.Blue), "ChangeColorTheme PromptTextColor B",, true);
                AddButton(String(BackgroundColor.Blue), "ChangeColorTheme BackgroundColor B",, true);
                AddButton(String(ButtonTextColor.Blue), "ChangeColorTheme ButtonTextColor B",, true);
                AddButton(String(ButtonColor.Blue), "ChangeColorTheme ButtonColor B",, true);
                AddButton(String(ReturnButtonColor.Blue), "ChangeColorTheme ReturnButtonColor B",, true);
                AddButton(String(RangeButtonTextColor.Blue), "ChangeColorTheme RangeButtonTextColor B",, true);
                AddButton(String(RangeButtonColor.Blue), "ChangeColorTheme RangeButtonColor B",, true);
                AddButton(String(RangeReturnButtonColor.Blue), "ChangeColorTheme RangeReturnButtonColor B",, true);

                AddButton(String(ConsoleTextColor.Alpha), "ChangeColorTheme ConsoleTextColor A",, true,,,,,,,,true);
                AddButton(String(ConsoleColor.Alpha), "ChangeColorTheme ConsoleColor A",, true);
                AddButton(String(PromptTextColor.Alpha), "ChangeColorTheme PromptTextColor A",, true);
                AddButton(String(BackgroundColor.Alpha), "ChangeColorTheme BackgroundColor A",, true);
                AddButton(String(ButtonTextColor.Alpha), "ChangeColorTheme ButtonTextColor A",, true);
                AddButton(String(ButtonColor.Alpha), "ChangeColorTheme ButtonColor A",, true);
                AddButton(String(ReturnButtonColor.Alpha), "ChangeColorTheme ReturnButtonColor A",, true);
                AddButton(String(RangeButtonTextColor.Alpha), "ChangeColorTheme RangeButtonTextColor A",, true);
                AddButton(String(RangeButtonColor.Alpha), "ChangeColorTheme RangeButtonColor A",, true);
                AddButton(String(RangeReturnButtonColor.Alpha), "ChangeColorTheme RangeReturnButtonColor A",, true);

                /*AddButton(ButtonLoc("ConsoleColorRed") @ ConsoleColor.Red, "ChangeColorTheme ConsoleColor R",, true);
                AddButton(ButtonLoc("ConsoleColorGreen") @ ConsoleColor.Green, "ChangeColorTheme ConsoleColor G",, true);
                AddButton(ButtonLoc("ConsoleColorBlue") @ ConsoleColor.Blue, "ChangeColorTheme ConsoleColor B",, true);
                AddButton(ButtonLoc("ConsoleColorAlpha") @ ConsoleColor.Alpha, "ChangeColorTheme ConsoleColor A",, true);

                AddButton(ButtonLoc("PromptTextColorRed") @ PromptTextColor.Red, "ChangeColorTheme PromptTextColor R",, true);
                AddButton(ButtonLoc("PromptTextColorGreen") @ PromptTextColor.Green, "ChangeColorTheme PromptTextColor G",, true);
                AddButton(ButtonLoc("PromptTextColorBlue") @ PromptTextColor.Blue, "ChangeColorTheme PromptTextColor B",, true);
                AddButton(ButtonLoc("PromptTextColorAlpha") @ PromptTextColor.Alpha, "ChangeColorTheme PromptTextColor A",, true);

                AddButton(ButtonLoc("BackgroundColorRed") @ BackgroundColor.Red, "ChangeColorTheme BackgroundColor R",, true);
                AddButton(ButtonLoc("BackgroundColorGreen") @ BackgroundColor.Green, "ChangeColorTheme BackgroundColor G",, true);
                AddButton(ButtonLoc("BackgroundColorBlue") @ BackgroundColor.Blue, "ChangeColorTheme BackgroundColor B",, true);
                AddButton(ButtonLoc("BackgroundColorAlpha") @ BackgroundColor.Alpha, "ChangeColorTheme BackgroundColor A",, true);

                AddButton(ButtonLoc("ButtonTextColorRed") @ ButtonTextColor.Red, "ChangeColorTheme ButtonTextColor R",, true);
                AddButton(ButtonLoc("ButtonTextColorGreen") @ ButtonTextColor.Green, "ChangeColorTheme ButtonTextColor G",, true);
                AddButton(ButtonLoc("ButtonTextColorBlue") @ ButtonTextColor.Blue, "ChangeColorTheme ButtonTextColor B",, true);
                AddButton(ButtonLoc("ButtonTextColorAlpha") @ ButtonTextColor.Alpha, "ChangeColorTheme ButtonTextColor A",, true);

                AddButton(ButtonLoc("ButtonColorRed") @ ButtonColor.Red, "ChangeColorTheme ButtonColor R",, true);
                AddButton(ButtonLoc("ButtonColorGreen") @ ButtonColor.Green, "ChangeColorTheme ButtonColor G",, true);
                AddButton(ButtonLoc("ButtonColorBlue") @ ButtonColor.Blue, "ChangeColorTheme ButtonColor B",, true);
                AddButton(ButtonLoc("ButtonColorAlpha") @ ButtonColor.Alpha, "ChangeColorTheme ButtonColor A",, true);

                AddButton(ButtonLoc("ReturnButtonTextColorRed") @ ReturnButtonTextColor.Red, "ChangeColorTheme ReturnButtonTextColor R",, true);
                AddButton(ButtonLoc("ReturnButtonTextColorGreen") @ ReturnButtonTextColor.Green, "ChangeColorTheme ReturnButtonTextColor G",, true);
                AddButton(ButtonLoc("ReturnButtonTextColorBlue") @ ReturnButtonTextColor.Blue, "ChangeColorTheme ReturnButtonTextColor B",, true);
                AddButton(ButtonLoc("ReturnButtonTextColorAlpha") @ ReturnButtonTextColor.Alpha, "ChangeColorTheme ReturnButtonTextColor A",, true);

                AddButton(ButtonLoc("ReturnButtonColorRed") @ ReturnButtonColor.Red, "ChangeColorTheme ReturnButtonColor R",, true);
                AddButton(ButtonLoc("ReturnButtonColorGreen") @ ReturnButtonColor.Green, "ChangeColorTheme ReturnButtonColor G",, true);
                AddButton(ButtonLoc("ReturnButtonColorBlue") @ ReturnButtonColor.Blue, "ChangeColorTheme ReturnButtonColor B",, true);
                AddButton(ButtonLoc("ReturnButtonColorAlpha") @ ReturnButtonColor.Alpha, "ChangeColorTheme ReturnButtonColor A",, true);

                AddButton(ButtonLoc("RangeButtonColorRed") @ RangeButtonColor.Red, "ChangeColorTheme RangeButtonColor R",, true);
                AddButton(ButtonLoc("RangeButtonColorGreen") @ RangeButtonColor.Green, "ChangeColorTheme RangeButtonColor G",, true);
                AddButton(ButtonLoc("RangeButtonColorBlue") @ RangeButtonColor.Blue, "ChangeColorTheme RangeButtonColor B",, true);
                AddButton(ButtonLoc("RangeButtonColorAlpha") @ RangeButtonColor.Alpha, "ChangeColorTheme RangeButtonColor A",, true);

                AddButton(ButtonLoc("RangeButtonTextColorRed") @ RangeButtonTextColor.Red, "ChangeColorTheme RangeButtonTextColor R",, true);
                AddButton(ButtonLoc("RangeButtonTextColorGreen") @ RangeButtonTextColor.Green, "ChangeColorTheme RangeButtonTextColor G",, true);
                AddButton(ButtonLoc("RangeButtonTextColorBlue") @ RangeButtonTextColor.Blue, "ChangeColorTheme RangeButtonTextColor B",, true);
                AddButton(ButtonLoc("RangeButtonTextColorAlpha") @RangeButtonTextColor.Alpha, "ChangeColorTheme RangeButtonTextColor A",, true);

                AddButton(ButtonLoc("RangeReturnButtonColorRed") @ RangeReturnButtonColor.Red, "ChangeColorTheme RangeReturnButtonColor R",, true);
                AddButton(ButtonLoc("RangeReturnButtonColorGreen") @ RangeReturnButtonColor.Green, "ChangeColorTheme RangeReturnButtonColor G",, true);
                AddButton(ButtonLoc("RangeReturnButtonColorBlue") @ RangeReturnButtonColor.Blue, "ChangeColorTheme RangeReturnButtonColor B",, true);
                AddButton(ButtonLoc("RangeReturnButtonColorAlpha") @ RangeReturnButtonColor.Alpha, "ChangeColorTheme RangeReturnButtonColor A",, true);*/

                AddButton(ButtonLoc("GoBack"), "SetMenu Settings NothingFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case RandomizerChoice:
                AddButton(ButtonLoc("StartRandomizer"), "ToggleRandomizer", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("ChallengeMode") @ Controller.RandomizerChallengeMode, "ModifyRandomizer 0" @ RussianBool(!Controller.RandomizerChallengeMode),, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Other OtherFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
            case InsaneChoice:
                AddButton(ButtonLoc("StartInsanePlus"), "ToggleInsanePlus ", Vect2D(285, 165),, StartClip, EndClip, Controller.TrainingMode);
                AddButton(ButtonLoc("DisableCamera") @ Controller.DisCamMode, "ModifyInsanePlus 0",, true);
                AddButton(ButtonLoc("TrainingMode") @ Controller.TrainingMode, "ModifyInsanePlus 1",, true);
                AddButton(ButtonLoc("GoBack"), "SetMenu Other OtherFuncs", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
        }
    }
    else if(Controller.InsanePlusState) {
        Switch(CurrentMenu) {
            case DisInsanePlus:
                AddButton(ButtonLoc("DisableInsanePlus"), "ToggleInsanePlus", Vect2D(285, 165),, StartClip, EndClip);
                AddButton(ButtonLoc("IWantToDie"), "DS 99999",, true);
                AddButton(ButtonLoc("Close"), "TogglePickerMenu false", Vect2D(945, 620), false,,,,, MakeRGBA(ReturnButtonColor.Red, ReturnButtonColor.Green, ReturnButtonColor.Blue, ReturnButtonColor.Alpha), MakeRGBA(RangeReturnButtonColor.Red, RangeReturnButtonColor.Green, RangeReturnButtonColor.Blue, RangeReturnButtonColor.Alpha), MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha));
                break;
        }
    }

    Canvas.SetPos(6, Canvas.ClipY - 18.7);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.DrawText("By" @ Localize("Other", "Discord", "Picker"), false, 0.8, 0.8);

    Canvas.SetPos(5, Canvas.ClipY - float(20));
    Canvas.SetDrawColor(255, 0, 0, 255);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.DrawText("By" @ Localize("Other", "Discord", "Picker"), false, 0.8, 0.8);

    Canvas.SetPos(Canvas.SizeX / 2, Canvas.SizeY / 2);
    Canvas.SetPos(PlayerInput.MousePos.X, PlayerInput.MousePos.Y);
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.DrawTile(MouseTexture, MouseTexture.SizeX, MouseTexture.SizeY, 0.f, 0.f, MouseTexture.SizeX, MouseTexture.SizeY,, true);
    //DrawString(String(PlayerInput.MousePos.X) @ String(PlayerInput.MousePos.Y), Vect2D(PlayerInput.MousePos.X, PlayerInput.MousePos.Y), MakeRGBA(255, 255, 255, 225), Vect2D(1, 1));
}

Function String RussianBool(Bool Bool) {
    if(Bool) {
        return "True";
    }
    else {
        return "False";
    }
}

/************************OTHER FUNCTIONS************************/

Exec Function PushMessage(String Msg) {
    StrPushMessage = Msg;
    PushColor = MakeRGBA(255, 255, 255, 255);
   // WorldInfo.Game.ClearTimer('PushMessageShow', Self);
    WorldInfo.Game.ClearTimer('PushMessageHide', Self);
   // PushMessageShow();
    WorldInfo.Game.SetTimer(0.005, true, 'PushMessageHide', Self);

}

Function PushMessageHide() {
    if(PushColor.Alpha == 0) {
        StrPushMessage = "";
        PushColor = MakeRGBA(0,0,0,0);
        WorldInfo.Game.ClearTimer('PushMessageHide', Self);
        return;
    }
    PushColor.Alpha = PushColor.Alpha - 1;
}

Event ShowMessage(OLHUD.EHUDMessageType MessageType, String MessageText) {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    if(Controller.RandomizerState) {
        //MessageText = Controller.RandString(Controller.RandByte(48));
    }
    if(MessageScreen  ==  none) {MessageScreen = new (Self) Class'OLUIMessage';}
    if(MessageScreen != none) {
        CurrentMessageType = MessageType;
        CurrentMessageText = MessageText;
        MessageScreen.Start(false);
        MessageScreen.SetMessage(MessageType, MessageText);
    }  
}

Event HideMessage() {
    if((MessageScreen != none) && MessageScreen.bMovieIsOpen) {
        MessageScreen.Close(false);
        CurrentMessageText = "";
    }
}

Event ShowSubtitle(String MessageText) {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    if(Controller.RandomizerState) {
        //MessageText = Controller.RandString(Controller.RandByte(48));
    }
    if(SubtitleScreen  ==  none) {SubtitleScreen = new (Self) Class'OLUIMessage';}
    if(SubtitleScreen != none) {
        if(!SubtitleScreen.bMovieIsOpen) {
            SubtitleScreen.Start(false);
            CurrentSubtitle = MessageText;
            SubtitleScreen.SetMessage(5, MessageText);
        } else {
            CurrentSubtitle = MessageText;
            SubtitleScreen.SetMessage(5, MessageText);
            SubtitleScreen.SetVisible(true);
        }
    }
}

Event HideSubtitle() {
    CurrentSubtitle = "";
    if((SubtitleScreen != none) && SubtitleScreen.bMovieIsOpen) {
        SubtitleScreen.SetVisible(false);
    }
}

Event Bool ShowingSubtitle() {
    return ((SubtitleScreen != none) && SubtitleScreen.bMovieIsOpen) && CurrentSubtitle != "";
}

Event ShowObjective(String ObjectiveText)  {
    local PickerController Controller;
    local String RandomObjective;
    local Byte D;

    Controller = PickerController(PlayerOwner);
    if(ObjectiveScreen  ==  none) {ObjectiveScreen = new (Self) Class'OLUIMessage';}
    if(ObjectiveScreen != none) {
        if(!Controller.RandomizerState) {CurrentObjectiveText = ObjectiveText;}
        if(Controller.RandomizerState) {D = RandRange(0, 62);
        if(D == 0) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_GetInsideAsylum", "OLGame"));}
        if(D == 1) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SecurityRoom2", "OLGame"));}
        if(D == 2) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator", "OLGame"));}
        if(D == 3) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_BackToSecurity", "OLGame"));}
        if(D == 4) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_FollowTheBlood", "OLGame"));}
        if(D == 5) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_Shower", "OLGame"));}
        if(D == 6) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_Explosion", "OLGame"));}
        if(D == 7) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_ReachSurface", "OLGame"));}
        if(D == 8) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater", "OLGame"));}
        if(D == 9) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater4", "OLGame"));}
        if(D == 10) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_ReachMaleWard", "OLGame"));}
        if(D == 11) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_Basement", "OLGame"));}
        if(D == 12) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GetOutOfMaleWard", "OLGame"));}
        if(D == 13) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GetOutOfMaleWard2", "OLGame"));}
        if(D == 14) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_PyroSaidKitchen", "OLGame"));}
        if(D == 15) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Enter", "OLGame"));}
        if(D == 16) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GetOnSecondFloor", "OLGame"));}
        if(D == 17) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_3rdFloor", "OLGame"));}
        if(D == 18) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Darkness", "OLGame"));}
        if(D == 19) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GoOn3rdFloor", "OLGame"));}
        if(D == 20) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Exit", "OLGame"));}
        if(D == 21) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_RecreationHallKey", "OLGame"));}
        if(D == 22) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_KeyToHouseofGod", "OLGame"));}
        if(D == 23) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Revisit_KeyToFreedom", "OLGame"));}
        if(D == 24) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_Start", "OLGame"));}
        if(D == 25) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_GoToMainLab", "OLGame"));}
        if(D == 26) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly", "OLGame"));}
        if(D == 27) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly2", "OLGame"));}
        if(D == 28) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_KillBilly3", "OLGame"));}
        if(D == 29) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_Final", "OLGame"));}
        if(D == 30) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SecurityRoom", "OLGame"));}
        if(D == 31) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_Keycard", "OLGame"));}
        if(D == 32) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_GoToSecurityRoom", "OLGame"));}
        if(D == 33) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_SparkPlug", "OLGame"));}
        if(D == 34) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator2", "OLGame"));}
        if(D == 35) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator3", "OLGame"));}
        if(D == 36) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator4", "OLGame"));}
        if(D == 37) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator5", "OLGame"));}
        if(D == 38) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_RestartGenerator6", "OLGame"));}
        if(D == 39) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Admin_OutOfBasement", "OLGame"));}
        if(D == 40) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_KeyCardShower", "OLGame"));}
        if(D == 41) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_EscapePrison", "OLGame"));}
        if(D == 42) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater2", "OLGame"));}
        if(D == 43) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Sewer_FlushWater3", "OLGame"));}
        if(D == 44) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_EscapeMaleWard", "OLGame"));}
        if(D == 45) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_FindKeyForMaleElevator", "OLGame"));}
        if(D == 46) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_GoBackToElevator", "OLGame"));}
        if(D == 47) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_AlternatePath", "OLGame"));}
        if(D == 48) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_WaterValve", "OLGame"));}
        if(D == 49) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_SprinklerValve", "OLGame"));}
        if(D == 50) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Male_SprinklerSwitch", "OLGame"));}
        if(D == 51) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Start", "OLGame"));}
        if(D == 52) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Key", "OLGame"));}
        if(D == 53) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Courtyard_Shed", "OLGame"));}
        if(D == 54) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_2ndFloorKey", "OLGame"));}
        if(D == 55) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_2ndFloor", "OLGame"));}
        if(D == 56) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_GetKeyFirstFloor", "OLGame"));}
        if(D == 57) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_1", "OLGame"));}
        if(D == 58) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Lab_2", "OLGame"));}
        if(D == 59) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Hospital_GetRadio", "OLGame"));}
        if(D == 60) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Hospital_Gas", "OLGame"));}
        if(D == 61) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Prison_GetAdmin", "OLGame"));}
        if(D == 62) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Building2_Key", "OLGame"));}
        if(D == 62) {RandomObjective = "" $ (Localize("Objectives", "" $ "Objective_Female_Fuse", "OLGame"));}
        //CurrentObjectiveText = RandomObjective;
        Controller.CurrentObjective = Name(RandomObjective);
    }
        ObjectiveScreen.Start(false);
        if(!Controller.RandomizerState) {ObjectiveScreen.SetMessage(1, ObjectiveText);}
        if(Controller.RandomizerState) {ObjectiveScreen.SetMessage(1, Localize("Messages", "" $ "NewObjective", "OLGame") @ RandomObjective);}
        WorldInfo.Game.SetTimer(4, false, 'HideObjective', Self);
    }
}

Event HideObjective() {
    if((ObjectiveScreen != none) && ObjectiveScreen.bMovieIsOpen) {
        ObjectiveScreen.Close(false);
        CurrentObjectiveText = "";
    }
}

Function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime) {
	local Int Idx, MsgIdx;

	MsgIdx = -1;
	// check for beep on message receipt
	if( bMessageBeep && InMessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}
	// find the first available entry
	if (ConsoleMessages.Length < ConsoleMessageCount)
	{
		MsgIdx = ConsoleMessages.Length;
	}
	else
	{
		// look for an empty entry
		for (Idx = 0; Idx < ConsoleMessages.Length && MsgIdx == -1; Idx++)
		{
			if (ConsoleMessages[Idx].Text == "")
			{
				MsgIdx = Idx;
			}
		}
	}
    if( MsgIdx == ConsoleMessageCount || MsgIdx == -1)
    {
		// push up the array
		for(Idx = 0; Idx < ConsoleMessageCount-1; Idx++ )
		{
			ConsoleMessages[Idx] = ConsoleMessages[Idx+1];
		}
		MsgIdx = ConsoleMessageCount - 1;
    }
	// fill in the message entry
	if (MsgIdx >= ConsoleMessages.Length)
	{
		ConsoleMessages.Length = MsgIdx + 1;
	}

    ConsoleMessages[MsgIdx].Text = M;
	if (LifeTime != 0.f)
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + LifeTime;
	}
	else
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + InMessageClass.default.LifeTime;
	}

    ConsoleMessages[MsgIdx].TextColor = InMessageClass.static.GetConsoleColor(PRI);
    ConsoleMessages[MsgIdx].PRI = PRI;
}

Function DrawString(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(1.5, 1.5), optional Bool ScaleLoc=true, optional Bool center) {
    local Vector2D MisScale, StringScale;

    MisScale = Vect2D((0.7 * Scale.X) / 1920 * Canvas.SizeX, (0.7 * Scale.Y) / 1080 * Canvas.SizeY);
    Canvas.TextSize(String, StringScale.X, StringScale.Y, MisScale.X, MisScale.Y);

    if(Center) {
        Loc=Vect2D(Loc.X - (StringScale.X / 2), Loc.Y - (StringScale.Y / 2));
    }
    if(ScaleLoc) {
        Loc=Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);
    }

    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(Loc.X+1, Loc.Y+1.3);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);

    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
}

Function DrawConsoleString(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(2, 2), optional Bool ScaleLoc=true, optional Bool center) {
    local Vector2D MisScale, StringScale, StringLoc, ViewportSize;
    local Float XL, YL, Y, info_xl, info_yl;
    local PickerInput PlayerInput;
    local PickerController Controller;
    local String OutStr, Cursor;
    local Int MatchIdx, Idx, StartIdx;

    Controller = PickerController(PlayerOwner);
    if(Controller != None) {
        Controller.ViewportCurrentSize = ViewportSize;
        StringScale.X = ViewportSize.X;
        StringScale.Y = ViewportSize.Y;
    }
    else {
        StringScale.X = 1920;
        StringScale.Y = 1080;
    }
    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    Cursor = "_";
    MisScale = Vect2D((1.3) / Canvas.SizeX * Canvas.SizeX, (1.3) / Canvas.SizeY * Canvas.SizeY);
    Loc = Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);

    Canvas.SetPos(Loc.X+1, Loc.Y+1.3);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(0, 0, 0, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);

    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
 
    OutStr = ">" @ Left(Command, PlayerInput.CommandPos);

    Canvas.StrLen(OutStr, XL, YL);
    Canvas.SetPos(Loc.X+1 + (XL*1.3), Loc.Y+1.3);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(0, 0, 0, Color.Alpha);
    Canvas.DrawText(Cursor, false, MisScale.X, MisScale.Y); //1.3, 1.3

    Canvas.StrLen(OutStr, XL, YL);
    Canvas.SetPos(Loc.X + (XL*1.3), Loc.Y);
    Canvas.Font = Font'PickerDebugMenu.PickerFont';
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(Cursor, false, MisScale.X, MisScale.Y);
}

Function Bool ContainsName(Array<Name> Array, Name find) {
    Switch(Array.Find(Find)) {
        case -1: return false;
        Default: return true;
    }
}

Function Bool ContainsString(Array<String> Array, String find) {
    Switch(Array.Find(Find)) {
        case -1:
            return false;
            break;
        Default:
            return true;
            break;
    }
}

Function IntPoint GetMousePos() {
    local PickerInput PlayerInput;

    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    return PlayerInput.MousePos;
}
Function bool InRange(float Target, Float RangeMin, Float RangeMax) {
    return Target > RangeMin && Target < RangeMax;
}
Function Bool Mouseinbetween(Vector2D Vector1, Vector2D Vector2) {
    local IntPoint MousePos;

    MousePos = GetMousePos();
    return InRange(MousePos.X, Vector1.X, Vector2.X) && InRange(MousePos.Y, Vector1.Y, Vector2.Y);
}
Function ButtonStr FindButton(Array<ButtonStr> Array, Int Row, Int Column) {
    local ButtonStr Button;

    Foreach array(Button) {
        if(Button.Row==Row) {
            if(Button.Column==Column) {
                return Button;
            }
        }
    }
    Button.Row=-1;
    return Button;
}

Exec Function SetMenu(Menu Menu, optional String ButtonTag) {
    CurrentMenu=Menu;
    ButtonDesc=ButtonTag;
}

Function AddStringWithButtons(
            String Name,
            optional Vector2D Location,
            optional Bool AutoDown=false,
            optional Vector2D Bound_Start,
            optional Vector2D Bound_End,
            optional String buttontag,
            optional RGBA StringColor=MakeRGBA(RangeButtonTextColor.Red,RangeButtonTextColor.Green,RangeButtonTextColor.Blue,RangeButtonTextColor.Alpha),
            optional Bool InRow=false
    ) {
    local Vector2D Begin_PointCalc, End_PointCalc, Offset, Center_Vector, TextSize;
    local ButtonStr ButtonBase, PreviousButton, FirstButtonInRow, ButtonInColumn;
    local int Row, Column;

    Canvas.TextSize(Name, TextSize.X, TextSize.Y);
    if(TextSize.X > 70) {
        Offset = Vect2D(3 + TextSize.X, TextSize.Y+1);
    }
    else {
        Offset = Vect2D(70, TextSize.Y+1);
    }
    if(Buttons.Length == 0) {
        Row = 1;
        Column = 1;
    }
    else {
        PreviousButton = Buttons[(Buttons.Length - 1)];
        Row = PreviousButton.Row;
        Column = PreviousButton.Column+1;
        FirstButtonInRow = FindButton(Buttons, Row, 1);
        if(FirstButtonInRow.Row!=-1) {
            Bound_Start = FirstButtonInRow.ClipStart;
            Bound_End = FirstButtonInRow.ClipEnd;
            if(AutoDown) {
                Location.X = PreviousButton.Location.X;
                Location.Y = (PreviousButton.Location.Y + PreviousButton.Offset.Y) + 5;
                if(!InRange(Scale2dVector(Location + Offset).Y, Bound_Start.Y, Bound_Start.Y + Bound_End.Y) || InRow) {
                    Location.X = (FirstButtonInRow.Location.X + FirstButtonInRow.Offset.X) + 5;
                    Location.Y = FirstButtonInRow.Location.Y;
                    ++ Row;
                    Column = 1;
                }
                else if (Column>1) {
                    ButtonInColumn=FindButton(Buttons, (Row - 1), Column);
                    if(ButtonInColumn.Row != -1) {
                        Location.X = (ButtonInColumn.Location.X + ButtonInColumn.Offset.X) + 5;
                    }
                }
            }
        }
    }
    StringColor = MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha);
    DrawBox(Location, Offset, MakeRGBA(0,0,0,0), Begin_PointCalc, End_PointCalc);
    Center_Vector = Vect2D((Begin_PointCalc.X + (Begin_PointCalc.X + End_PointCalc.X)) / 2, (Begin_PointCalc.Y + (Begin_PointCalc.Y + End_PointCalc.Y)) / 2);
    DrawString(Name, Center_Vector, StringColor, Vect2D(1.8, 1.8), false, true);
    ButtonBase.Name = Name;
    ButtonBase.Start_Points = Begin_PointCalc;
    ButtonBase.End_Point = Vect2D((Begin_PointCalc.X + End_PointCalc.X), (Begin_PointCalc.Y + End_PointCalc.Y));
    ButtonBase.Location = Location;
    ButtonBase.Offset = Offset;
    ButtonBase.ClipStart = Bound_Start;
    ButtonBase.ClipEnd = Bound_End;
    ButtonBase.Row = Row;
    ButtonBase.Column = Column;
    Buttons.AddItem(ButtonBase);
}

Function AddButton(
            String Name,
            String ConsoleCommand,
            optional Vector2D Location,
            optional Bool AutoDown=false,
            optional Vector2D Bound_Start,
            optional Vector2D Bound_End,
            optional Bool Template,
            optional String buttontag,
            optional RGBA Color=MakeRGBA(ButtonColor.Red,ButtonColor.Green,ButtonColor.Blue,ButtonColor.Alpha),
            optional RGBA RangeColor=MakeRGBA(RangeButtonColor.Red,RangeButtonColor.Green,RangeButtonColor.Blue,RangeButtonColor.Alpha),
            optional RGBA StringColor=MakeRGBA(RangeButtonTextColor.Red,RangeButtonTextColor.Green,RangeButtonTextColor.Blue,RangeButtonTextColor.Alpha),
            optional Bool InRow=false
    ) {
    local Vector2D Begin_PointCalc, End_PointCalc, Offset, Center_Vector, TextSize;
    local RGBA ButColor;
    local ButtonStr ButtonBase, PreviousButton, FirstButtonInRow, ButtonInColumn;
    local int Row, Column;

    Canvas.TextSize(Name, TextSize.X, TextSize.Y);
    if(TextSize.X > 70) {
        Offset = Vect2D(3 + TextSize.X, TextSize.Y+1);
    }
    else {
        Offset = Vect2D(70, TextSize.Y+1);
    }
    if(Buttons.Length == 0) {
        Row = 1;
        Column = 1;
    }
    else {
        PreviousButton = Buttons[(Buttons.Length - 1)];
        Row = PreviousButton.Row;
        Column = PreviousButton.Column+1;
        FirstButtonInRow = FindButton(Buttons, Row, 1);
        if(FirstButtonInRow.Row!=-1) {
            Bound_Start = FirstButtonInRow.ClipStart;
            Bound_End = FirstButtonInRow.ClipEnd;
            if(AutoDown) {
                Location.X = PreviousButton.Location.X;
                Location.Y = (PreviousButton.Location.Y + PreviousButton.Offset.Y) + 5;
                if(!InRange(Scale2dVector(Location + Offset).Y, Bound_Start.Y, Bound_Start.Y + Bound_End.Y) || InRow) {
                    Location.X = (FirstButtonInRow.Location.X + FirstButtonInRow.Offset.X) + 5;
                    Location.Y = FirstButtonInRow.Location.Y;
                    ++ Row;
                     Column = 1;
                }
                else if (Column>1) {
                    ButtonInColumn=FindButton(Buttons, (Row - 1), Column);
                    if(ButtonInColumn.Row != -1) {
                        Location.X = (ButtonInColumn.Location.X + ButtonInColumn.Offset.X) + 5;
                    }
                }
            }
        }
    }
    if(MouseInbetween(Scale2DVector(Location), Scale2DVector(Location + Offset))) {
        ButColor = RangeColor;
        StringColor = MakeRGBA(RangeButtonTextColor.Red, RangeButtonTextColor.Green, RangeButtonTextColor.Blue, RangeButtonTextColor.Alpha); // MakeRGBA(150, 150, 150, 255);
        DrawString(buttontag, Vect2D(1375,140), MakeRGBA(255, 255, 255, 255));
    }
    else {
        ButColor=Color;
        StringColor = MakeRGBA(ButtonTextColor.Red, ButtonTextColor.Green, ButtonTextColor.Blue, ButtonTextColor.Alpha);
    }
    DrawBox(Location, Offset, ButColor, Begin_PointCalc, End_PointCalc);
    Center_Vector = Vect2D((Begin_PointCalc.X + (Begin_PointCalc.X + End_PointCalc.X)) / 2, (Begin_PointCalc.Y + (Begin_PointCalc.Y + End_PointCalc.Y)) / 2);
    DrawString(Name, Center_Vector, StringColor, Vect2D(1.8, 1.8), false, true);
    ButtonBase.Name = Name;
    ButtonBase.ConsoleCommand = ConsoleCommand;
    ButtonBase.Start_Points = Begin_PointCalc;
    ButtonBase.End_Point = Vect2D((Begin_PointCalc.X + End_PointCalc.X), (Begin_PointCalc.Y + End_PointCalc.Y));
    ButtonBase.Template = Template;
    ButtonBase.Location = Location;
    ButtonBase.Offset = Offset;
    ButtonBase.ClipStart = Bound_Start;
    ButtonBase.ClipEnd = Bound_End;
    ButtonBase.Row = Row;
    ButtonBase.Column = Column;
    Buttons.AddItem(ButtonBase);
}

Function DrawTextInWorld(String Text, Vector location, Float Max_View_Distance, Float scale, optional Vector offset) {
    local Vector DrawLocation, CameraLocation; //Location to Draw Text & Location of Player Camera
    local Rotator CameraDir; //Direction the camera is facing
    local Float Distance; //Distance between Camera and text

    PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraDir);
    Distance =  ScaleByCam(VSize(CameraLocation - Location)); //Get the distance between the camera and the location of the text being placed, then scale it by the camera's FOV. 
    DrawLocation = Canvas.Project(Location); //Project the 3D location into 2D space. 
    if(Vector(CameraDir) dot (Location - CameraLocation) > 0.0 && Distance < Max_View_Distance) {
        Scale = Scale / Distance; //Scale By distance. 
        Canvas.SetPos(DrawLocation.X + (Offset.X * Scale), DrawLocation.Y + (Offset.Y * Scale), DrawLocation.Z + (Offset.Z * Scale)); //Set the Position of text using the Draw Location and an optional Offset. 
        Canvas.SetDrawColor(255,40,40,255);
        Canvas.Font = Font'PickerDebugMenu.PickerFont';
        Canvas.DrawText(Text, false, Scale, Scale);
    }
}

Exec Function ChangeColorTheme(Name Element, Name Channel, Bool Increase) {
    local PickerInput PickerInput;
    local Int I;

    PickerInput = PickerInput(PlayerOwner.PlayerInput);
    I = 0;
     if(Increase) {
        if(PickerInput.bShiftPressed) {
            I += 5;
        }
        else {
            ++I;
        }
     }
     else {
        if(PickerInput.bShiftPressed) {
            I -= 5;
        }
        else {
            --I;
        }
     }
    Switch(Element) {
        case 'ConsoleTextColor':
            Switch(Channel) {
                case 'R':
                    ConsoleTextColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    ConsoleTextColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    ConsoleTextColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    ConsoleTextColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'ConsoleColor':
            Switch(Channel) {
                case 'R':
                    ConsoleColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    ConsoleColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    ConsoleColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    ConsoleColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'PromptTextColor':
            Switch(Channel) {
                case 'R':
                    PromptTextColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    PromptTextColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    PromptTextColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    PromptTextColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'BackgroundColor':
            Switch(Channel) {
                case 'R':
                     BackgroundColor.Red += I;
                     SaveConfig();
                    break;
                case 'G':
                     BackgroundColor.Green += I;
                     SaveConfig();
                    break;
                case 'B':
                     BackgroundColor.Blue += I;
                     SaveConfig();
                    break;
                case 'A':
                     BackgroundColor.Alpha += I;
                     SaveConfig();
                    break;
            }
            break;
        case 'ButtonTextColor':
            Switch(Channel) {
                case 'R':
                    ButtonTextColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    ButtonTextColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    ButtonTextColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    ButtonTextColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'ButtonColor':
            Switch(Channel) {
                case 'R':
                    ButtonColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    ButtonColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    ButtonColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    ButtonColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'ReturnButtonTextColor':
            Switch(Channel) {
                case 'R':
                    ReturnButtonTextColor.Red += I;
                    SaveConfig();
                    break;
                case 'G':
                    ReturnButtonTextColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                    ReturnButtonTextColor.Blue += I;
                    SaveConfig();
                    break;
                case 'A':
                    ReturnButtonTextColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'ReturnButtonColor':
            Switch(Channel) {
                case 'R':
                   ReturnButtonColor.Red += I;
                   SaveConfig();
                    break;
                case 'G':
                    ReturnButtonColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                   ReturnButtonColor.Blue += I;
                   SaveConfig();
                    break;
                case 'A':
                    ReturnButtonColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'RangeReturnButtonColor':
            Switch(Channel) {
                case 'R':
                   RangeReturnButtonColor.Red += I;
                   SaveConfig();
                    break;
                case 'G':
                    RangeReturnButtonColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                   RangeReturnButtonColor.Blue += I;
                   SaveConfig();
                    break;
                case 'A':
                    RangeReturnButtonColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'RangeButtonColor':
            Switch(Channel) {
                case 'R':
                   RangeButtonColor.Red += I;
                   SaveConfig();
                    break;
                case 'G':
                    RangeButtonColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                   RangeButtonColor.Blue += I;
                   SaveConfig();
                    break;
                case 'A':
                    RangeButtonColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
        case 'RangeButtonTextColor':
            Switch(Channel) {
                case 'R':
                   RangeButtonTextColor.Red += I;
                   SaveConfig();
                    break;
                case 'G':
                    RangeButtonTextColor.Green += I;
                    SaveConfig();
                    break;
                case 'B':
                   RangeButtonTextColor.Blue += I;
                   SaveConfig();
                    break;
                case 'A':
                    RangeButtonTextColor.Alpha += I;
                    SaveConfig();
                    break;
            }
            break;
    }
}

Function Click(Int Type=0) {
    local PickerInput PlayerInput;
    local PickerController Controller;
    local ButtonStr ButtonStr;
    local intPoint MousePos;

    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    Controller = PickerController(PlayerOwner);
    MousePos = PlayerInput.MousePos;
    Foreach Buttons(ButtonStr) {
        if(InRange(MousePos.X, ButtonStr.Start_Points.X, ButtonStr.End_Point.X) && InRange(MousePos.Y, ButtonStr.Start_Points.Y, ButtonStr.End_Point.Y)) {
            if(CurrentMenu == SettingsColor) {
                if(Type == 1) {
                    ButtonStr.ConsoleCommand $= " true";
                    PlayerOwner.ConsoleCommand(ButtonStr.ConsoleCommand);
                    return;
                }
                else if(Type == 2) {
                    ButtonStr.ConsoleCommand $= " false";
                    PlayerOwner.ConsoleCommand(ButtonStr.ConsoleCommand);
                    return;
                }
                else if(Type == 0 && ButtonStr.ConsoleCommand == "SetMenu Settings NothingFuncs") {
                    if(!DisableClickSound) {
                        PlaySound(Controller.ButtonSound);
                    }
                    PlayerOwner.ConsoleCommand(ButtonStr.ConsoleCommand);
                    return;
                }
            }
            else if(Type == 0) {
                if(!DisableClickSound) {
                    PlaySound(Controller.ButtonSound);
                }
                if(ButtonStr.Template) {
                    Command=ButtonStr.ConsoleCommand;
                    PlayerInput.SetCursorPos(Len(Command));
                    return;
                }
                PlayerOwner.ConsoleCommand(ButtonStr.ConsoleCommand);
                return;
            }
        }
    }
    return;
}

Exec Function Back() {
    local PickerController Controller;

    Controller = PickerController(PlayerOwner);
    Switch(CurrentMenu) {
        case Normal:
            Controller.ConsoleCommand("TogglePickerMenu false");
            break;
        case ShowDebug:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case Add:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case AddL:
            Controller.ConsoleCommand("SetMenu Add AddFuncs");
            break;
        case World:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case WChapters:
            Controller.ConsoleCommand("SetMenu World WorldFuncs");
            break;
        case WAdmin1:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WAdmin2:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WPrison1:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WPrison2:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WSewer:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WMaleWard:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WFemaleWard:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WVocational:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WHospital:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WExit:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WCourtyard1:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WCourtyard2:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WCourtyard3:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WLab1:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WLab2:
            Controller.ConsoleCommand("SetMenu WChapters NothingFuncs");
            break;
        case WDoors:
            Controller.ConsoleCommand("SetMenu World WorldFuncs");
            break;
        case WDoorsMT:
            Controller.ConsoleCommand("SetMenu WDoors DoorsFuncs");
            break;
        case WDoorsMTMS:
            Controller.ConsoleCommand("SetMenu WDoorsMT NothingFuncs");
            break;
        case Enemy:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case AddE:
            Controller.ConsoleCommand("SetMenu Add AddFuncs");
            break;
        case AddESpawn:
            Controller.ConsoleCommand("SetMenu AddE AddEnemyFuncs");
            break;
        case AddESpawnPatient:
            Controller.ConsoleCommand("SetMenu AddESpawn NothingFuncs");
            break;
        case AddESpawnWeapons:
            Controller.ConsoleCommand("SetMenu AddESpawn NothingFuncs");
            break;
        case AddP:
            Controller.ConsoleCommand("SetMenu Add AddFuncs");
            break;
        case AddPlayer:
            Controller.ConsoleCommand("SetMenu Add AddFuncs");
            break;
        case AddPO:
            Controller.ConsoleCommand("SetMenu Add AddFuncs");
            break;
        case Settings:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case SettingsColor:
            Controller.ConsoleCommand("SetMenu Settings NothingFuncs");
            break;
        case Cinematic:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case Player:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case Other:
            Controller.ConsoleCommand("SetMenu Normal NothingFuncs");
            break;
        case OTimers:
            Controller.ConsoleCommand("SetMenu Other OtherFuncs");
            break;
        case RandomizerChoice:
            Controller.ConsoleCommand("SetMenu Other OtherFuncs");
            break;
        case InsaneChoice:
            Controller.ConsoleCommand("SetMenu Other OtherFuncs");
            break;
        case DisInsanePlus:
            Controller.ConsoleCommand("TogglePickerMenu false");
            break;
        Default:
            Controller.SendMsg("Nothing Selected!");
            return;
            break;
    }
    if(!DisableClickSound) {
        PlaySound(Controller.ButtonSound);
    }
}

Function DrawBox(Vector2D Begin_Point, Vector2D End_Point, RGBA Color=MakeRGBA(255,255,255,255), optional out Vector2D Begin_Point_Calculated, optional out Vector2D End_Point_Calculated) {
    Begin_Point_Calculated = Scale2DVector(Begin_Point);
    End_Point_Calculated = Scale2DVector(End_Point);
    Canvas.SetPos(Begin_Point_Calculated.X, Begin_Point_Calculated.Y);
    Canvas.SetDrawColor(Color.Red,Color.Green,Color.Blue,Color.Alpha);
    Canvas.DrawRect(End_Point_Calculated.X, End_Point_Calculated.Y);
}
Event OnLostFocusPause(Bool bEnable) {
    bLostFocus = bEnable;
    if(bEnable && bPauseFocus) {
        return;
    }
    Super.OnLostFocusPause(bEnable);
}

Function Float ScaleByCam(Float Float) {
    return Float * (PlayerOwner.GetFOVAngle() / 100);
}

Function Vector2D Scale2DVector(Vector2D Vector) {
    Vector.X=Vector.X / 1280.0f * Canvas.SizeX;
    Vector.Y=Vector.Y / 720.0f * Canvas.SizeY;
    return Vector;
}

Function Bool Vector2DInRange(Vector2D Target, Vector2D Vector1, Vector2D Vector2) {
    return InRange(Target.X, Vector1.X, Vector2.X) && InRange(Target.Y, Vector1.Y, Vector2.Y);
}

Function String VectorToString(Vector Target) {
    return Target.X $ "," @ Target.Y $ "," @ Target.Z;
}

Function Commit() {
    local PickerController Controller;
    local PickerInput PlayerInput;
    
    Controller = PickerController(PlayerOwner);
    PlayerInput = PickerInput(PlayerOwner.PlayerInput);
    if(!Controller.InsanePlusState) {
        PlayerOwner.ConsoleCommand(Command);
        if(Command != "") {
            LatestCommand=Command;
        }
    }
    Command="";
    PlayerInput.SetCursorPos(0);
}

Exec Function HideDebugMenu() {
    PlayerOwner.ConsoleCommand("TogglePickerMenu false");
    Super.HideMenu();
}

Function RGBA MakeRGBA(Byte R, Byte G, Byte B, Byte A=255) {
    local PickerController Controller;
    local RGBA Color;
    
    Controller = PickerController(PlayerOwner);
    Color.Red=R;
    Color.Green=G;
    Color.Blue=B;
    Color.Alpha=A;
    if(!Controller.RandomizerState) {
        return Color;
    }
    else {
        return RandRGBA(A);
    }
}

Function Color MakeLineColor(Byte R, Byte G, Byte B, Byte A=255) {
    local Color Color;

    Color.R=R;
    Color.G=G;
    Color.B=B;
    Color.A=A;

    return Color;
}

Function RGBA RandRGBA(Byte Alpha) {
    local RGBA Color;
    
    Color.Red=Rand(255);
    Color.Green=Rand(255);
    Color.Blue=Rand(255);
    Color.Alpha=Alpha;
    return Color;
}

Function String BoolLocalize(Bool Variable) {
    local String Key;

    if(Variable) {
        Key = "bTrue";
    }
    else {
        Key = "bFalse";
    }
    return Localize("Bool", Key, "Picker");
}

Function String DbgLoc(coerce String Key) {
    return Localize("Debug", Key, "Picker");
}

Function String DescLoc(coerce String Key) {
    return Localize("Descriptions", Key, "Picker");
}

Function String ButtonLoc(coerce String Key) {
    return Localize("Buttons", Key, "Picker");
}

Function OutlastGameType InvertGameType(Bool GameType) {
    if(GameType) {
        return OGT_Outlast;
    }
    else {
        return OGT_Whistleblower;
    }
}

Function String RandLocalize() {
    local String Section, Key, File;

    Switch(Rand(0)) { // 4
        case 0:
            File="OLGame";
            Switch(Rand(26)) {
                case 0:
                    Section="Tutorials";
                    Switch(Rand(37)) {
                        case 0:
                            Key="Tutorial_FlashingIcon";
                            break;
                        case 1:
                            Key="Tutorial_Camera";
                            break;
                        case 2:
                            Key="Tutorial_Camera2_Keyboard";
                            break;
                        case 3:
                            Key="Tutorial_Camera2_Gamepad";
                            break;
                        case 4:
                            Key="Tutorial_Recording";
                            break;
                        case 5:
                            Key="Tutorial_Recording2";
                            break;
                        case 6:
                            Key="Tutorial_Recording3";
                            break;
                        case 7:
                            Key="Tutorial_Run";
                            break;
                        case 8:
                            Key="Tutorial_Door";
                            break;
                        case 9:
                            Key="Tutorial_Jump1";
                            break;
                        case 10:
                            Key="Tutorial_Jump2";
                            break;
                        case 11:
                            Key="Tutorial_Climb";
                            break;
                        case 12:
                            Key="Tutorial_Jumpover";
                            break;
                        case 13:
                            Key="Tutorial_LookBehind";
                            break;
                        case 14:
                            Key="Tutorial_LookBehind_Analog";
                            break;
                        case 15:
                            Key="Tutorial_SlowDownEnemies";
                            break;
                        case 16:
                            Key="Tutorial_BlockPath";
                            break;
                        case 17:
                            Key="Tutorial_Peak_Keyboard";
                            break;
                        case 18:
                            Key="Tutorial_Peak_Gamepad";
                            break;
                        case 19:
                            Key="Tutorial_NightVision1";
                            break;
                        case 20:
                            Key="Tutorial_NightVision2";
                            break;
                        case 21:
                            Key="Tutorial_GetOnLedge";
                            break;
                        case 22:
                            Key="Tutorial_StrafeOnLedge";
                            break;
                        case 23:
                            Key="Tutorial_DropFromLedge";
                            break;
                        case 24:
                            Key="Tutorial_DropFromLedge_Gamepad";
                            break;
                        case 25:
                            Key="Tutorial_Crouch_Keyboard";
                            break;
                        case 26:
                            Key="Tutorial_Crouch_Keyboard_Toggle";
                            break;
                        case 27:
                            Key="Tutorial_Crouch_Gamepad";
                            break;
                        case 28:
                            Key="Tutorial_JumpFromLedge";
                            break;
                        case 29:
                            Key="Tutorial_SqueezeThrough";
                            break;
                        case 30:
                            Key="Tutorial_Airvent";
                            break;
                        case 31:
                            Key="Tutorial_Hide";
                            break;
                        case 32:
                            Key="Tutorial_JumpOverLedge";
                            break;
                        case 33:
                            Key="Tutorial_LedgeHangStrafe";
                            break;
                        case 34:
                            Key="Tutorial_Push";
                            break;
                        case 35:
                            Key="Tutorial_Inventory";
                            break;
                        case 36:
                            Key="Tutorial_Documents";
                            break;
                        case 37:
                            Key="Tutorial_Objectives";
                            break;
                    }
                    break;
                case 1:
                    Section="OLTutorialManager";
                    Switch(Rand(2)) {
                        case 0:
                            Key="BatteriesTutorialText";
                            break;
                        case 1:
                            Key="ClimbUpTutorialText_Keyboard";
                            break;
                        case 2:
                            Key="ClimbUpTutorialText_Gamepad";
                            break;
                    }
                    break;
                case 2:
                    Section="Objectives";
                    Switch(Rand(59)) {
                        case 0:
                            Key="Objective_Admin_GetInsideAsylum";
                            break;
                        case 1:
                            Key="Objective_Admin_SecurityRoom2";
                            break;
                        case 2:
                            Key="Objective_Admin_RestartGenerator";
                            break;
                        case 3:
                            Key="Objective_Admin_BackToSecurity";
                            break;
                        case 4:
                            Key="Objective_Prison_FollowTheBlood";
                            break;
                        case 5:
                            Key="Objective_Prison_Shower";
                            break;
                        case 6:
                            Key="Objective_Prison_Explosion";
                            break;
                        case 7:
                            Key="Objective_Sewer_ReachSurface";
                            break;
                        case 8:
                            Key="Objective_Sewer_FlushWater";
                            break;
                        case 9:
                            Key="Objective_Sewer_FlushWater4";
                            break;
                        case 10:
                            Key="Objective_Sewer_ReachMaleWard";
                            break;
                        case 11:
                            Key="Objective_Male_PyroSaidKitchen";
                            break;
                        case 12:
                            Key="Objective_Female_Enter";
                            break;
                        case 13:
                            Key="Objective_Female_GetOnSecondFloor";
                            break;
                        case 14:
                            Key="Objective_Female_3rdFloor";
                            break;
                        case 15:
                            Key="Objective_Female_Darkness";
                            break;
                        case 16:
                            Key="Objective_Female_GoOn3rdFloor";
                            break;
                        case 17:
                            Key="Objective_Female_Exit";
                            break;
                        case 18:
                            Key="Objective_Revisit_RecreationHallKey";
                            break;
                        case 19:
                            Key="Objective_Revisit_KeyToHouseofGod";
                            break;
                        case 20:
                            Key="Objective_Revisit_KeyToFreedom";
                            break;
                        case 21:
                            Key="Objective_Lab_Start";
                            break;
                        case 22:
                            Key="Objective_Lab_GoToMainLab";
                            break;
                        case 23:
                            Key="Objective_Lab_KillBilly";
                            break;
                        case 24:
                            Key="Objective_Lab_KillBilly2";
                            break;
                        case 25:
                            Key="Objective_Lab_KillBilly3";
                            break;
                        case 26:
                            Key="Objective_Lab_Final";
                            break;
                        case 27:
                            Key="Objective_Admin_SecurityRoom";
                            break;
                        case 28:
                            Key="Objective_Admin_Keycard";
                            break;
                        case 29:
                            Key="Objective_Admin_GoToSecurityRoom";
                            break;
                        case 30:
                            Key="Objective_Admin_SparkPlug";
                            break;
                        case 31:
                            Key="Objective_Admin_RestartGenerator2";
                            break;
                        case 32:
                            Key="Objective_Admin_RestartGenerator3";
                            break;
                        case 33:
                            Key="Objective_Admin_RestartGenerator4";
                            break;
                        case 34:
                            Key="Objective_Admin_RestartGenerator5";
                            break;
                        case 35:
                            Key="Objective_Admin_RestartGenerator6";
                            break;
                        case 36:
                            Key="Objective_Admin_OutOfBasement";
                            break;
                        case 37:
                            Key="Objective_Prison_KeyCardShower";
                            break;
                        case 38:
                            Key="Objective_Sewer_FlushWater2";
                            break;
                        case 39:
                            Key="Objective_Sewer_FlushWater3";
                            break;
                        case 40:
                            Key="Objective_Male_EscapeMaleWard";
                            break;
                        case 41:
                            Key="Objective_Male_FindKeyForMaleElevator";
                            break;
                        case 42:
                            Key="Objective_Male_GoBackToElevator";
                            break;
                        case 43:
                            Key="Objective_Male_AlternatePath";
                            break;
                        case 44:
                            Key="Objective_Male_WaterValve";
                            break;
                        case 45:
                            Key="Objective_Male_SprinklerValve";
                            break;
                        case 46:
                            Key="Objective_Male_SprinklerSwitch";
                            break;
                        case 47:
                            Key="Objective_Courtyard_Start";
                            break;
                        case 48:
                            Key="Objective_Courtyard_Key";
                            break;
                        case 49:
                            Key="Objective_Courtyard_Shed";
                            break;
                        case 50:
                            Key="Objective_Female_2ndFloorKey";
                            break;
                        case 51:
                            Key="Objective_Female_2ndFloor";
                            break;
                        case 52:
                            Key="Objective_Female_GetKeyFirstFloor";
                            break;
                        case 53:
                            Key="Objective_Female_Fuse";
                            break;
                        case 54:
                            Key="Objective_Lab_1";
                            break;
                        case 55:
                            Key="Objective_Lab_2";
                            break;
                        case 56:
                            Key="Objective_Hospital_GetRadio";
                            break;
                        case 57:
                            Key="Objective_Hospital_Gas";
                            break;
                        case 58:
                            Key="Objective_Prison_GetAdmin";
                            break;
                        case 59:
                            Key="Objective_Building2_Key";
                            break;
                        
                    }
                    break;
                case 3:
                    Section="GameplayItems";
                    Switch(Rand(17)) {
                        case 0:
                            Key="InventoryHeading";
                            break;
                        case 1:
                            Key="Collectible";
                            break;
                        case 2:
                            Key="Battery";
                            break;
                        case 3:
                            Key="Batteries";
                            break;
                        case 4:
                            Key="Keycard";
                            break;
                        case 5:
                            Key="SparkPlug";
                            break;
                        case 6:
                            Key="KeycardShower";
                            break;
                        case 7:
                            Key="ElevatorKey";
                            break;
                        case 8:
                            Key="ShedKeycard";
                            break;
                        case 9:
                            Key="Keystairs";
                            break;
                        case 10:
                            Key="Fuse1";
                            break;
                        case 11:
                            Key="Fuse2";
                            break;
                        case 12:
                            Key="Fuse3";
                            break;
                        case 13:
                            Key="KeycardRH";
                            break;
                        case 14:
                            Key="KeyToLab";
                            break;
                        case 15:
                            Key="Keycard_Lab";
                            break;
                        case 16:
                            Key="HandcuffKey";
                            break;
                        case 17:
                            Key="KeyMale";
                            break;
                    }
                    break;
                case 4:
                    Section="Messages";
                    Switch(Rand(60)) {
                        case 0:
                            Key="DefaultPromptRequiredItem";
                            break;
                        case 1:
                            Key="NewObjective";
                            break;
                        case 2:
                            Key="RecordingComplete";
                            break;
                        case 3:
                            Key="PickedUpItem";
                            break;
                        case 4:
                            Key="PickedUpCollectible";
                            break;
                        case 5:
                            Key="PickedUpBattery";
                            break;
                        case 6:
                            Key="PickedUpBatteries";
                            break;
                        case 7:
                            Key="PromptPickup";
                            break;
                        case 8:
                            Key="PromptBatteriesFull";
                            break;
                        case 9:
                            Key="PromptLockedDoor";
                            break;
                        case 10:
                            Key="PromptOpenDoor";
                            break;
                        case 11:
                            Key="PromptNeedKey";
                            break;
                        case 12:
                            Key="PromptNeedKey2";
                            break;
                        case 13:
                            Key="PromptNeedKey3";
                            break;
                        case 14:
                            Key="PromptAutoCloseDoor";
                            break;
                        case 15:
                            Key="PromptOpenPartiallyOpenDoor";
                            break;
                        case 16:
                            Key="PromptCloseDoor";
                            break;
                        case 17:
                            Key="PromptEnterBed";
                            break;
                        case 18:
                            Key="PromptEnterLocker";
                            break;
                        case 19:
                            Key="PromptExitLocker";
                            break;
                        case 20:
                            Key="PromptGemericCSA";
                            break;
                        case 21:
                            Key="PromptSecurityControl";
                            break;
                        case 22:
                            Key="PromptElevator";
                            break;
                        case 23:
                            Key="PromptPump1";
                            break;
                        case 24:
                            Key="PromptPump2";
                            break;
                        case 25:
                            Key="PromptBreaker";
                            break;
                        case 26:
                            Key="PromptRestartGenerator";
                            break;
                        case 27:
                            Key="PromptGenerator1";
                            break;
                        case 28:
                            Key="PromptGeneratorOff";
                            break;
                        case 29:
                            Key="PromptFuse";
                            break;
                        case 30:
                            Key="PromptReloadBatteries";
                            break;
                        case 31:
                            Key="PromptStruggleMouse";
                            break;
                        case 32:
                            Key="PromptStruggleGamepad";
                            break;
                        case 33:
                            Key="PromptPushObject";
                            break;
                        case 34:
                            Key="PromptWaterValve";
                            break;
                        case 35:
                            Key="PromptSprinkler";
                            break;
                        case 36:
                            Key="PromptValve1";
                            break;
                        case 37:
                            Key="PromptValve2";
                            break;
                        case 38:
                            Key="PromptWaterPump1";
                            break;
                        case 39:
                            Key="PromptWaterPump2";
                            break;
                        case 40:
                            Key="PromptWaterPump3";
                            break;
                        case 41:
                            Key="PromptCamcorder";
                            break;
                        case 42:
                            Key="PromptProceedAfterStartMovie";
                            break;
                        case 43:
                            Key="PromptAirlock1";
                            break;
                        case 44:
                            Key="PromptFoodElevator";
                            break;
                        case 45:
                            Key="PromptElevatorTrap";
                            break;
                        case 46:
                            Key="PromptMorphegenicDontWork";
                            break;
                        case 47:
                            Key="PromptCables";
                            break;
                        case 48:
                            Key="PromptValveLab";
                            break;
                        case 49:
                            Key="PromptFailsafe";
                            break;
                        case 50:
                            Key="PromptChute";
                            break;
                        case 51:
                            Key="PromptSendEmail";
                            break;
                        case 52:
                            Key="PromptMorpho";
                            break;
                        case 53:
                            Key="PromptNeedHandcuffKey";
                            break;
                        case 54:
                            Key="PromptUnlockHandcuffs";
                            break;
                        case 55:
                            Key="PromptBashWall";
                            break;
                        case 56:
                            Key="PromptRadio";
                            break;
                        case 57:
                            Key="PromptBreakerOff";
                            break;
                        case 58:
                            Key="PromptTurnOffSasGaz";
                            break;
                        case 59:
                            Key="PromptJeep";
                            break;
                        case 60:
                            Key="PromptFootage";
                            break;
                    }
                    break;
                case 5:
                    Section="OLUIFrontEnd_Screen";
                    Switch(Rand(5)) {
                        case 0:
                            Key="BackText";
                            break;
                        case 1:
                            Key="EnterText";
                            break;
                        case 2:
                            Key="YesText";
                            break;
                        case 3:
                            Key="NoText";
                            break;
                        case 4:
                            Key="CloseText";
                            break;
                        case 5:
                            Key="AcceptText";
                            break;
                    }
                    break;
                case 6:
                    Section="OLUIFrontEnd_MainMenu";
                    Switch(Rand(9)) {
                        case 0:
                            Key="TitleText";
                            break;
                        case 1:
                            Key="ContinueText";
                            break;
                        case 2:
                            Key="StartText";
                            break;
                        case 3:
                            Key="PlayDemoText";
                            break;
                        case 4:
                            Key="LoadText";
                            break;
                        case 5:
                            Key="OptionsText";
                            break;
                        case 6:
                            Key="CreditsText";
                            break;
                        case 7:
                            Key="ExitText";
                            break;
                        case 8:
                            Key="NewGameIntroText";
                            break;
                        case 9:
                            Key="ChaptersText";
                            break;
                        case 10:
                            Key="StartDLCText";
                            break;
                    }
                    break;
                case 7:
                    Section="OLUIFrontEnd_Options";
                    Switch(Rand(19)) {
                        case 0:
                            Key="ApplyText";
                            break;
                        case 1:
                            Key="GammaText";
                            break;
                        case 2:
                            Key="ResetText";
                            break;
                        case 3:
                            Key="GameplayText";
                            break;
                        case 4:
                            Key="GhaphicsText";
                            break;
                        case 5:
                            Key="AudioText";
                            break;
                        case 6:
                            Key="ControlsText";
                            break;
                        case 7:
                            Key="ConfirmResolutionTitleText";
                            break;
                        case 8:
                            Key="ConfirmResolutionMessageText";
                            break;
                        case 9:
                            Key="ConfirmChangesTitleText";
                            break;
                        case 10:
                            Key="ConfirmChangesMessageText";
                            break;
                        case 11:
                            Key="KeyBindingConflictTitleText";
                            break;
                        case 12:
                            Key="KeyBindingConflictMessageText";
                            break;
                        case 13:
                            Key="MustRestartTitleText";
                            break;
                        case 14:
                            Key="MustRestartMessageText";
                            break;
                        case 15:
                            Key="OKText";
                            break;
                        case 16:
                            Key="CancelText";
                            break;
                        case 17:
                            Key="DifficultyOptions[0]";
                            break;
                        case 18:
                            Key="DifficultyOptions[1]";
                            break;
                        case 19:
                            Key="DifficultyOptions[2]";
                            break;
                    }
                    break;
                case 8:
                    Section="OLUIFrontEnd_Options_Console";
                    Key="SettingsText";
                    break;
                case 9:
                    Section="OLUIFrontEnd_PauseMenu";
                    Switch(Rand(8)) {
                        case 0:
                            Key="ReturnText";
                            break;
                        case 1:
                            Key="OptionsText";
                            break;
                        case 2:
                            Key="ExitToMenuText";
                            break;
                        case 3:
                            Key="SaveAndExitText";
                            break;
                        case 4:
                            Key="SaveText";
                            break;
                        case 5:
                            Key="ConfirmExitTitle";
                            break;
                        case 6:
                            Key="ConfirmExitText";
                            break;
                        case 7:
                            Key="ConfirmExitInsaneText";
                            break;
                        case 8:
                            Key="ExitToWindowsText";
                            break;
                    }
                    break;
                case 10:
                    Section="OLUIFrontEnd_GammaScreen";
                    Key="GammaLabelText";
                    break;
                case 11:
                    Section="OLUIFrontEnd_GammaScreen_Console";
                    Key="GammaLabelText";
                    break;
                case 12:
                    Section="OLUIFrontEnd_DifficultySelectionScreen";
                    Switch(Rand(6)) {
                        case 0:
                            Key="ChooseDifficultyText";
                            break;
                        case 1:
                            Key="NormalText";
                            break;
                        case 2:
                            Key="HardText";
                            break;
                        case 3:
                            Key="NightmareText";
                            break;
                        case 4:
                            Key="InsaneText";
                            break;
                        case 5:
                            Key="ConfirmInsaneTitleText";
                            break;
                        case 6:
                            Key="ConfirmInsaneMsgText";
                            break;
                    }
                    break;
                case 13:
                    Section="OLUIFrontEnd_ChapterSelection";
                    Switch(Rand(2)) {
                        case 0:
                            Key="ChapterSelectionTitle";
                            break;
                        case 1:
                            Key="ChapterSelectionSubTitle";
                            break;
                        case 2:
                            Key="LoadText";
                            break;
                    }
                    break;
                case 14:
                    Section="OLUIFrontEnd_Journal";
                    Switch(Rand(3)) {
                        case 0:
                            Key="ObjectivesTitle";
                            break;
                        case 1:
                            Key="TutorialsTitle";
                            break;
                        case 2:
                            Key="RecordingsTitle";
                            break;
                        case 3:
                            Key="DocumentsTitle";
                            break;
                    }
                    break;
                case 15:
                    Section="OLUIFrontEnd_TabMenu";
                    Switch(Rand(2)) {
                        case 0:
                            Key="ObjectiveText";
                            break;
                        case 1:
                            Key="EvidenceText";
                            break;
                        case 2:
                            Key="RecordingText";
                            break;
                    }
                    break;
                case 16:
                    Section="OLUIFrontEnd_LoadGame";
                    Switch(Rand(2)) {
                        case 0:
                            Key="TitleText";
                            break;
                        case 1:
                            Key="LoadText";
                            break;
                        case 2:
                            Key="DeleteText";
                            break;
                    }
                    break;
                case 17:
                    Section="OLUIFrontEnd_RecordingList";
                    Key="Title";
                    break;
                case 18:
                    Section="OLUIFrontEnd_EvidenceList";
                    Key="Title";
                    break;
                case 19:
                    Section="OLEmailScreen";
                    Switch(Rand(1)) {
                        case 0:
                            Key="SubjectText";
                            break;
                        case 1:
                            Key="EmailText";
                            break;
                    }
                    break;
                case 20:
                    Section="InputKeys";
                    Switch(Rand(69)) {
                        case 0:
                            Key="MouseScrollUp";
                            break;
                        case 1:
                            Key="MouseScrollDown";
                            break;
                        case 2:
                            Key="LeftMouseButton";
                            break;
                        case 3:
                            Key="RightMouseButton";
                            break;
                        case 4:
                            Key="MiddleMouseButton";
                            break;
                        case 5:
                            Key="ThumbMouseButton";
                            break;
                        case 6:
                            Key="ThumbMouseButton2";
                            break;
                        case 7:
                            Key="BackSpace";
                            break;
                        case 8:
                            Key="Tab";
                            break;
                        case 9:
                            Key="Enter";
                            break;
                        case 10:
                            Key="Pause";
                            break;
                        case 11:
                            Key="CapsLock";
                            break;
                        case 12:
                            Key="Escape";
                            break;
                        case 13:
                            Key="SpaceBar";
                            break;
                        case 14:
                            Key="PageUp";
                            break;
                        case 15:
                            Key="PageDown";
                            break;
                        case 16:
                            Key="End";
                            break;
                        case 17:
                            Key="Home";
                            break;
                        case 18:
                            Key="Left";
                            break;
                        case 19:
                            Key="Right";
                            break;
                        case 20:
                            Key="Up";
                            break;
                        case 21:
                            Key="Down";
                            break;
                        case 22:
                            Key="Insert";
                            break;
                        case 23:
                            Key="Delete";
                            break;
                        case 24:
                            Key="Zero";
                            break;
                        case 25:
                            Key="One";
                            break;
                        case 26:
                            Key="Two";
                            break;
                        case 27:
                            Key="Three";
                            break;
                        case 28:
                            Key="Four";
                            break;
                        case 29:
                            Key="Five";
                            break;
                        case 30:
                            Key="Six";
                            break;
                        case 31:
                            Key="Seven";
                            break;
                        case 32:
                            Key="Eight";
                            break;
                        case 33:
                            Key="Nine";
                            break;
                        case 34:
                            Key="A";
                            break;
                        case 35:
                            Key="B";
                            break;
                        case 36:
                            Key="C";
                            break;
                        case 37:
                            Key="D";
                            break;
                        case 38:
                            Key="E";
                            break;
                        case 39:
                            Key="F";
                            break;
                        case 40:
                            Key="G";
                            break;
                        case 41:
                            Key="H";
                            break;
                        case 42:
                            Key="I";
                            break;
                        case 43:
                            Key="J";
                            break;
                        case 44:
                            Key="K";
                            break;
                        case 45:
                            Key="L";
                            break;
                        case 46:
                            Key="M";
                            break;
                        case 47:
                            Key="N";
                            break;
                        case 48:
                            Key="O";
                            break;
                        case 49:
                            Key="P";
                            break;
                        case 50:
                            Key="Q";
                            break;
                        case 51:
                            Key="R";
                            break;
                        case 52:
                            Key="S";
                            break;
                        case 53:
                            Key="T";
                            break;
                        case 54:
                            Key="U";
                            break;
                        case 55:
                            Key="V";
                            break;
                        case 56:
                            Key="W";
                            break;
                        case 57:
                            Key="X";
                            break;
                        case 58:
                            Key="Y";
                            break;
                        case 59:
                            Key="Z";
                            break;
                        case 60:
                            Key="NumPadZero";
                            break;
                        case 61:
                            Key="NumPadOne";
                            break;
                        case 62:
                            Key="NumPadTwo";
                            break;
                        case 63:
                            Key="NumPadThree";
                            break;
                        case 64:
                            Key="NumPadFour";
                            break;
                        case 65:
                            Key="NumPadFive";
                            break;
                        case 66:
                            Key="NumPadSix";
                            break;
                        case 67:
                            Key="NumPadSeven";
                            break;
                        case 68:
                            Key="NumPadEight";
                            break;
                        case 69:
                            Key="NumPadNine";
                            break;
                        
                    }
                    break;
                case 21:
                    Section="Locations";
                    Switch(Rand(14)) {
                        case 0:
                            Key="Admin";
                            break;
                        case 1:
                            Key="Prison";
                            break;
                        case 2:
                            Key="Sewer";
                            break;
                        case 3:
                            Key="Male";
                            break;
                        case 4:
                            Key="Courtyard";
                            break;
                        case 5:
                            Key="Female";
                            break;
                        case 6:
                            Key="AdminRevisit";
                            break;
                        case 7:
                            Key="Lab";
                            break;
                        case 8:
                            Key="DLC_Lab";
                            break;
                        case 9:
                            Key="DLC_Hospital";
                            break;
                        case 10:
                            Key="DLC_Courtyard1";
                            break;
                        case 11:
                            Key="DLC_Prison";
                            break;
                        case 12:
                            Key="DLC_Courtyard2";
                            break;
                        case 13:
                            Key="DLC_Building2";
                            break;
                        case 14:
                            Key="DLC_Exit";
                            break;
                    }
                    break;
                case 22:
                    Section="InputActions";
                    Switch(Rand(25)) {
                        case 0:
                            Key="OLA_MoveForward";
                            break;
                        case 1:
                            Key="OLA_MoveBackward";
                            break;
                        case 2:
                            Key="OLA_TurnLeft";
                            break;
                        case 3:
                            Key="OLA_TurnRight";
                            break;
                        case 4:
                            Key="OLA_StrafeLeft";
                            break;
                        case 5:
                            Key="OLA_StrafeRight";
                            break;
                        case 6:
                            Key="OLA_Crouch";
                            break;
                        case 7:
                            Key="OLA_Use";
                            break;
                        case 8:
                            Key="OLA_Run";
                            break;
                        case 9:
                            Key="OLA_ToggleCamcorder";
                            break;
                        case 10:
                            Key="OLA_ToggleNightVision";
                            break;
                        case 11:
                            Key="OLA_LeanLeft";
                            break;
                        case 12:
                            Key="OLA_LeanRight";
                            break;
                        case 13:
                            Key="OLA_ZoomImpulseIn";
                            break;
                        case 14:
                            Key="OLA_ZoomImpulseOut";
                            break;
                        case 15:
                            Key="OLA_ZoomContinuousIn";
                            break;
                        case 16:
                            Key="OLA_ZoomContinuousOut";
                            break;
                        case 17:
                            Key="OLA_Reload";
                            break;
                        case 18:
                            Key="OLA_Jump";
                            break;
                        case 19:
                            Key="OLA_ShowMenu";
                            break;
                        case 20:
                            Key="OLA_ShowTabMenu";
                            break;
                        case 21:
                            Key="OLA_ShowRecordingMenu";
                            break;
                        case 22:
                            Key="OLA_ShowEvidenceMenu";
                            break;
                        case 23:
                            Key="OLA_CrouchToggle";
                            break;
                        case 24:
                            Key="OLA_AnalogLeanLeft";
                            break;
                        case 25:
                            Key="OLA_AnalogLeanRight";
                            break;
                    }
                    break;
                case 23:
                    Section="OLMainHud";
                    Key="SavingMessageText";
                    break;
                case 24:
                    Section="OLFlashBackScreen";
                    Key="Text";
                    break;
                case 25:
                    Section="OLFlashForwardScreen";
                    Key="Text";
                    break;
                case 26:
                    Section="PS4";
                    Switch(Rand(6)) {
                        case 0:
                            Key="NewSaveGame";
                            break;
                        case 1:
                            Key="ProfileDataLabel";
                            break;
                        case 2:
                            Key="SaveDifficultyNormal";
                            break;
                        case 3:
                            Key="SaveDifficultyHard";
                            break;
                        case 4:
                            Key="SaveDifficultyNightmare";
                            break;
                        case 5:
                            Key="SaveDifficultyInsane";
                            break;
                        case 6:
                            Key="DLCUninstalled";
                            break;
                    }
                    break;
                
            }
            break;
        case 1:
            File="OLNarrative";
            break;
        case 2:
            File="OLNarrativeDLC";
            break;
        case 3:
            File="OLSubtitles";
            break;
        case 4:
            File="OLSubtitlesDLC";
            break;
        Switch(File) {
            case "OLGame":

                break;
        }
    }

    return Localize(Section, Key, File);
}

DefaultProperties
{
    DisableClickSound = false
    DisableTeleportSound = false
    DisablePause = true
    DisablePickerDebug = false
    DisableMenuMusic = false
    DisableAllActorInfo = true
    DisablePickerMessages = false
    DisableButtonDescs = false
    bForceFuncs = false
    bPossessSpawnHero = false
    bPossessAfterKill = true
    SpawnEnemyCount = 1
    HudWeaponToUse = "Weapon_None"
    SndDoorMat = "Wood"
    TimersTime = 0.3
    AllActorInfoDistance = 2000.0
    TimersStop = false
    HudShouldAttack = true
    bPauseFocus = false
    SmallFont = Font'PickerDebugMenu.PickerFont'
    MediumFont = Font'PickerDebugMenu.PickerFont'
    LargeFont = Font'PickerDebugMenu.PickerFont'
    HugeFont = Font'PickerDebugMenu.PickerFont'
}