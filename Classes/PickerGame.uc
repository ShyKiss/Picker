Class PickerGame extends OLGame
    Config(Picker);

var Config Bool SkipGameMenu;
var Float FPS;

Static Event Class<GameInfo> SetGameType(String MapName, String Options, String Portal) {
    return Default.Class;
}

Event Tick(Float DeltaTime) {
    local OLDoor Door;
    local Float Energy;
    local PickerHero PickerPawn;
    local Actor A;
    local PickerController Controller;
    local OLEnemyPawn Enemy;
    local PickerBot Bot;
    local MaterialInterface Material;
    local SkeletalMeshComponent MeshComp;
    local PickerInput PickerInput;
    local Int Index;
    local Engine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Controller = PickerController(GetALocalPlayerController());
    PickerInput = PickerInput(Controller.PlayerInput);
    PickerPawn = PickerHero(Controller.Pawn);
    FPS = (1 / DeltaTime) + FRand();
    if(FPS > Engine.MaxSmoothedFramerate) {
        FPS = Engine.MaxSmoothedFramerate;
    }
    if(PickerPawn == None || Controller == None) {
        return;
    }

    PickerPawn.CornerPeek.LastDisconnectTime = 0;
    PickerPawn.CornerPeek.LastInterpActivatedTime = Outer.MaxInt;

    /*if(Controller.CustomGEnemySkelMesh ~= "Default") {
        Foreach AllActors(Class'Actor', A) {
            if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
            Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
                if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
                if(
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Patient")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Surgeon")) != -1 || // Thanks ijedi1234#4601 for such a thing
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Priest")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Dupont")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(Controller.CustomGEnemySkelMesh)) != -1
                ) {
                    MeshComp.SetSkeletalMesh(MeshComp.Default.SkeletalMesh);
                    Foreach MeshComp.SkeletalMesh.Materials(Material) {
                        MeshComp.SetMaterial(Index, none);
                        ++Index;
                    }
                }
            }
        }
    }
    else {
        Foreach AllActors(Class'Actor', A) {
            if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
            Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
                if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
                if(
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Patient")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Surgeon")) != -1 || // Thanks ijedi1234#4601 for such a thing
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Priest")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Dupont")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(Controller.CustomGEnemySkelMesh)) != -1
                ) {
                    MeshComp.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(Controller.CustomGEnemySkelMesh, Class'SkeletalMesh')));
                    Foreach MeshComp.SkeletalMesh.Materials(Material) {
                        MeshComp.SetMaterial(Index, none);
                        ++Index;
                    }
                }
            }
        }
    }
    if(Controller.CustomSEnemySkelMesh ~= "Default") {
        Foreach AllActors(Class'Actor', A) {
            if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
            Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
                if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
                if(
                    InStr(Caps(MeshComp.PathName), Caps("Soldier")) != -1 ||
                    InStr(Caps(MeshComp.PathName), Caps("Groom")) != -1 || // Thanks ijedi1234#4601 for such a thing
                    InStr(Caps(MeshComp.PathName), Caps("NanoCloud")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(Controller.CustomSEnemySkelMesh)) != -1
                ) {
                    MeshComp.SetSkeletalMesh(MeshComp.Default.SkeletalMesh);
                    Foreach MeshComp.SkeletalMesh.Materials(Material) {
                        MeshComp.SetMaterial(Index, none);
                        ++Index;
                    }
                }
            }
        }
    }
    else {
        Foreach AllActors(Class'Actor', A) {
            if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
            Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
                if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
                if(
                    InStr(Caps(MeshComp.PathName), Caps("Soldier")) != -1 ||
                    InStr(Caps(MeshComp.PathName), Caps("Groom")) != -1 || // Thanks ijedi1234#4601 for such a thing
                    InStr(Caps(MeshComp.PathName), Caps("NanoCloud")) != -1 ||
                    InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(Controller.CustomSEnemySkelMesh)) != -1
                ) {
                    MeshComp.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(Controller.CustomSEnemySkelMesh, Class'SkeletalMesh')));
                    Foreach MeshComp.SkeletalMesh.Materials(Material) {
                        MeshComp.SetMaterial(Index, none);
                        ++Index;
                    }
                }
            }
        }
    }*/
    /*Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        if(Enemy.Controller.IsA('OLBot')) {
            Bot = Spawn(Class'PickerBot');
            Bot.Possess(Enemy, false);
        }
    }*/
    //Controller.PossessPickerBot();

    if(PickerInput.IsKeyPressed('LeftControl')) {
        PickerInput.bCtrlPressed = true;
    }
    else {
        PickerInput.bCtrlPressed = false;
    }
    if(PickerInput.IsKeyPressed('LeftShift')) {
        PickerInput.bShiftPressed = true;
    }
    else {
        PickerInput.bShiftPressed = false;
    }
    if(Controller.bAutoBunnyHop) {
        Controller.ConsoleCommand("PressedJump");
    }
    Controller.RandSpecialMoveAnims(!Controller.RandomizerState);

    return;

    if(!IsPlayingDLC() && PickerPawn.Health == 100) {
        PickerPawn.bHobbling = false;
        PickerPawn.bLimping = false;
        PickerPawn.HobblingIntensity = 0;
    }
    else if(!IsPlayingDLC() && PickerPawn.Health < 100 && PickerPawn.Health != 1) {
        PickerPawn.bHobbling = true;
        PickerPawn.bLimping = false;
        PickerPawn.HobblingIntensity = ((100 - PickerPawn.Health) / 100) * 2;
    }
    else if(!IsPlayingDLC() && PickerPawn.Health == 1) {
        PickerPawn.bHobbling = false;
        PickerPawn.HobblingIntensity = 0;
        PickerPawn.bLimping = true;
    }

    if(PickerPawn.CurrentBatterySetEnergy > 0.9899f) {
        Energy = RandRange(0.0599f, 0.9799f);
        PickerPawn.CurrentBatterySetEnergy = Energy;
    }
    Foreach AllActors(Class'OLDoor', Door) {
        Door.bFakeUnlocked = true;
    }
    Super.Tick(DeltaTime);
}

DefaultProperties
{
    PlayerControllerClass=Class'Picker.PickerController'
    HUDType=Class'Picker.PickerHud'
    DefaultPawnClass=Class'Picker.PickerHero'
}