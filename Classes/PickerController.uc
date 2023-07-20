Class PickerController extends OLPlayerController
    Config(Picker);

var Float InsanePlusStamina, fPlayerAnimRate, fEnemyAnimRate, fDebugSpeed;
var String CustomPM, CustomSEnemySkelMesh, CustomGEnemySkelMesh, CommandTimerFrom;
var Vector vScalePlayer, vScaleEnemies, TeleportPosCoordsTemp;
var Vector2D ViewportCurrentSize;
var PickerHud PickerHud;
var PickerInput PickerInput;
var SoundCue TeleportSound, ButtonSound, MenuMusic;
var SkeletalMesh Current_SkeletalMesh;
var Transient OLCheatManager CheatManager;
var Class<OLCheatManager> CheatClass;
var Array<Materialinterface> Materials;
var SkeletalMeshActorSpawnable NFSCar, WernickeModelPlayer;
var Array<AutoCompleteCommand> ACList, ManualAutoCompleteList;
var AudioComponent MenuMusicComponent;
var PickerPointLight PickerFollowLight;
var Array<String> ArrayPatientTypes, ArrayPatientModel;
var Private String CurrentAddCPGame;
var Int MathTasksGlobalA, MathTasksGlobalB, MathTasksTempOperation;
var Bool AIDebug, bScalePlayerVel, bGrainDisabled, bDebugFullyGhost, bThirdPersonMode, bEightMarch, bFestival, DoorLockState, DoorTypeState, DoorDelState, FreecamState, LightState, ChrisState, BoolKillEnemy, ForceKillEnemy,
bDefaultPlayer, ForceDisAI, EverytimeLightState, bBhop, bAutoBunnyHop, bFlyMode, bResetTimer, bTimer, bDisAI, bAnimFree, bLMFree, bSMFree, bDark, GroomChrisState,
SMRandomState, AllLoadedState, InsanePlusState, RandomizerState, LSMDamage, ResetJumpStam, RandomizerFR, MathTasksState, MathTasksTimer, bFollowLight, CrabGameState;
var Float SmallRandomTime, MediumRandomTime, LargeRandomTime;
var Config Bool DisCamMode, TrainingMode, AlwaysSaveCheckpoint, RandomizerChallengeMode;

/************************************************FUNCTIONS************************************************/

Exec Function ToggleScalePlayerVel() {
    bScalePlayerVel = !bScalePlayerVel;
    if(bScalePlayerVel) {
        WorldInfo.Game.SetTimer(0.001, true, 'ScalePlayerVelTimer', Self);
    }
    else {
        WorldInfo.Game.ClearTimer( 'ScalePlayerVelTimer', Self);
    }
}

Function ScalePlayerVelTimer() {
    if(VSize(PickerHero(Pawn).Velocity) <= 50) {
        ScalePlayer(0.5,0.5,0.5);
    }
    else if(VSize(PickerHero(Pawn).Velocity) > 50 && VSize(PickerHero(Pawn).Velocity) <= 100) {
        ScalePlayer(ScalebyVel(0.5),ScalebyVel(0.5),ScalebyVel(0.5));
    }
    else {
        ScalePlayer(ScalebyVel(1),ScalebyVel(1),ScalebyVel(1));
    }
}

Exec Function PP(String Name, Name Bone) {
    local EmitterPool Pool;
    local ParticleSystemComponent Component;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewpoint(C, Rot);

    Pool = Spawn(Class'EmitterPool', Self, 'PppickerPool', C, Rot);
    //PickerHero(Pawn).Mesh.AttachComponent(Pool, Bone);
    Component = Pool.SpawnEmitterMeshAttachment(ParticleSystem(DynamicLoadObject(Name, Class'ParticleSystem')), PickerHero(Pawn).Mesh, Bone, true);
    Component.SetKillOnCompleted(0, true);
}

Exec Function sds() {
    ConsoleCommand("ToggleFixedcam");
    ConsoleCommand("TimerFrom 0.001 ThirdPersonTimer");
}

Exec Function ToggleThirdPerson(Bool Disable=false) {
    local Rotator Rot;
    local PickerInput Input;
    local Int Index, Index2;

    Input = PickerInput(PlayerInput);
    if(!bDebugFullyGhost && !bDebugFreeCam && !bDebugGhost && !bDebugFixedCam) {
        ToggleFixedcam();
    }
    if(Disable) {
        if(bDebugFixedCam) {
            ToggleFixedcam();
        }
        bThirdPersonMode = false;
        WorldInfo.Game.ClearTimer('ThirdPersonTimer', Self);
        DebugCamPos = PickerHero(Pawn).Camera.BaseLocation;
        PickerHero(Pawn).HeadMesh.SetHidden(true);
        bIgnoreLookInput = 0;
        IgnoreLookInput(false);
        ClientIgnoreLookInput(false);
        bCinematicMode = false;
        PickerHero(Pawn).CameraMesh.SetHidden(true); 
        PickerHero(Pawn).CamParams.MaxPitchCS = PickerHero(Pawn).Default.CamParams.MaxPitchCS;
        PickerHero(Pawn).CamParams.MinPitchCS = PickerHero(Pawn).Default.CamParams.MinPitchCS;
        PickerHero(Pawn).CamParams.MaxPitchWS = PickerHero(Pawn).Default.CamParams.MaxPitchWS;
        PickerHero(Pawn).CamParams.MinPitchWS = PickerHero(Pawn).Default.CamParams.MinPitchWS;
        PickerHero(Pawn).CamParams.MaxYaw = PickerHero(Pawn).Default.CamParams.MaxYaw;
        PickerHero(Pawn).CamParams.MinYaw = PickerHero(Pawn).Default.CamParams.MinYaw;
        While(Index <= 15) {
            if(Index == 9) {
                PickerHero(Pawn).LocomotionModeParams[Index].GP.CameraMode = PickerHero(Pawn).Default.LocomotionModeParams[Index].GP.CameraMode;
            }
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinYaw;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxYaw;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinPitchCS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxPitchCS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinPitchWS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxPitchWS;
            ++Index;
        }
        While(Index2 <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinYaw;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxYaw;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinPitchCS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxPitchCS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinPitchWS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxPitchWS;
            ++Index2;
        }
        Reload();
    }
    else {
        bThirdPersonMode = true;
        WorldInfo.Game.SetTimer(0.001, true, 'ThirdPersonTimer', Self);
    }
}

Exec Function ThirdPersonTimer() {
    local Vector HitLoc, HitNorm;
    local Rotator Rot;
    local PickerInput Input;
    local Int Index, Index2;

    Input = PickerInput(PlayerInput);
    if(bDebugFullyGhost || bDebugGhost || bDebugFreeCam) return;
    if(PickerHero(Pawn).Physics == PHYS_Custom) {
        DebugCamRot.Yaw = Self.Rotation.Yaw;
        DebugCamRot.Pitch = Self.Rotation.Pitch;
        DebugCamRot.Roll = Self.Rotation.Roll;
    }
    else {
        DebugCamRot.Yaw = PickerHero(Pawn).Camera.BaseRotation.Yaw;
        DebugCamRot.Pitch = Self.Rotation.Pitch;
        DebugCamRot.Roll = Self.Rotation.Roll;
    }
    if(Input.Outer.bDuck == 1 && PickerHero(Pawn).Physics == PHYS_Walking && !PickerHero(Pawn).bLimping || PickerHero(Pawn).bWasUnder || PickerHero(Pawn).Health <= 0 || PickerHero(Pawn).LocomotionMode == LM_Bed || PickerHero(Pawn).LocomotionMode == LM_Locker) {
        DebugCamPos = PickerHero(Pawn).Camera.BaseLocation;
        PickerHero(Pawn).HeadMesh.SetHidden(true);
        if(PickerHero(Pawn).CamcorderState == CCS_Active && PickerHero(Pawn).LocomotionMode != LM_Cinematic || PickerHero(Pawn).CamcorderState == CCS_Inactive && PickerHero(Pawn).LocomotionMode != LM_Cinematic || PickerHero(Pawn).LocomotionMode == LM_Cinematic && PickerHero(Pawn).CamcorderState != CCS_Active) {
            bCinematicMode = false;
            PickerHero(Pawn).CameraMesh.SetHidden(true); 
        }
        else {
            bCinematicMode = true;
            PickerHero(Pawn).CameraMesh.SetHidden(false);
        }
    }
    else {
        if(PickerHero(Pawn).CamcorderState == CCS_Inactive && PickerHero(Pawn).LocomotionMode != LM_Cinematic || PickerHero(Pawn).LocomotionMode == LM_Cinematic && PickerHero(Pawn).CamcorderState != CCS_Active) {
            bCinematicMode = false;
            PickerHero(Pawn).CameraMesh.SetHidden(true);
        }
        else {
            bCinematicMode = true;
            PickerHero(Pawn).CameraMesh.SetHidden(false);
        }
        //Trace(HitLoc, HitNorm, PickerHero(Pawn).Camera.BaseLocation - (Normal(Vector(DebugCamRot)) * 9999),, true, vect(12,12,12));
        //DebugCamPos = PickerHero(Pawn).Camera.BaseLocation - ClampLength(HitLoc, 135);
        DebugCamPos = PickerHero(Pawn).Camera.BaseLocation - (Normal(Vector(DebugCamRot)) * 135);
        PickerHero(Pawn).HeadMesh.SetHidden(false);
    }

    //Rot.Pitch = DebugCamRot.Pitch + 90 * 182.044449;
    Rot.Pitch =  90 * 182.044449;
    Rot.Yaw= -1 * (DebugCamRot.Roll + 180 * 182.044449);
    Rot.Roll = -1 * Clamp(DebugCamRot.Pitch, 3226, 9500);

    if(PickerHero(Pawn).Health > 0) {
        While(Index <= 15) {
            if(Index == 9) {
                PickerHero(Pawn).LocomotionModeParams[Index].GP.CameraMode = CRM_Limited;
            }
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinYaw = -MaxInt;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxYaw = MaxInt;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchCS = -90;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchCS = 90;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchWS = -90;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchWS = 90;
            ++Index;
        }
        While(Index2 <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MinYaw = -MaxInt;
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MaxYaw = MaxInt;
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MinPitchCS = -90;
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MaxPitchCS = 90;
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MinPitchWS = -90;
            PickerHero(Pawn).SpecialMoveParams[Index2].GP.MaxPitchWS = 90;
            ++Index2;
        }
    }
    else {
        While(Index <= 15) {
            if(Index == 9) {
                PickerHero(Pawn).LocomotionModeParams[Index].GP.CameraMode = PickerHero(Pawn).Default.LocomotionModeParams[Index].GP.CameraMode;
            }
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinYaw;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxYaw;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinPitchCS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxPitchCS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MinPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MinPitchWS;
            PickerHero(Pawn).LocomotionModeParams[Index].GP.MaxPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.MaxPitchWS;
            ++Index;
        }
        While(Index2 <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinYaw;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxYaw = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxYaw;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinPitchCS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxPitchCS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxPitchCS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MinPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MinPitchWS;
            PickerHero(Pawn).SpecialMoveParams[Index].GP.MaxPitchWS = PickerHero(Pawn).Default.SpecialMoveParams[Index2].GP.MaxPitchWS;
            ++Index2;
        }
    }
    if(PickerHud(HUD).ToggleHUD || PickerHud(HUD).MathTasksHUD) {
        bIgnoreLookInput = 1;
        IgnoreLookInput(true);
        ClientIgnoreLookInput(true);
    }
    else {
        bIgnoreLookInput = 0;
        IgnoreLookInput(false);
        ClientIgnoreLookInput(false);

    }

    PickerHero(Pawn).CamParams.MaxPitchCS = 90;
    PickerHero(Pawn).CamParams.MinPitchCS = -90;
    PickerHero(Pawn).CamParams.MaxPitchWS = 90;
    PickerHero(Pawn).CamParams.MinPitchWS = -90;
    PickerHero(Pawn).CamParams.MaxYaw = MaxInt;
    PickerHero(Pawn).CamParams.MinYaw = -MaxInt;

    PickerHero(Pawn).Mesh.AttachComponent(PickerHero(Pawn).HeadMesh, 'Hero-Head');
    if(PickerHero(Pawn).LocomotionMode == LM_Walk || PickerHero(Pawn).LocomotionMode == LM_Fall) {
        PickerHero(Pawn).HeadMesh.SetRotation(Rot);
    }
}

Exec Function door(float X, float Y, float Z) {
    local OLDoor Door;
    local Vector C;

    C.X = X;
    C.Y = Y;
    C.Z = Z;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.Mesh.SetScale3D(C);
    }
}

Exec Function ps() {
     local StaticMeshCollectionActor A;
     local StaticMeshComponent Component;

     Foreach AllActors(Class'StaticMeshCollectionActor', A) {
        Foreach A.ComponentList(Class'StaticMeshComponent', Component) {
            PickerHero(Pawn).AttachComponent(Component);
        }
     }
}

Exec Function tt() {
    local Actor A;
    local Vector Start, End, HitLoc, HitNorm, C;
    local Rotator Rot;
    local ActorComponent Component;

    GetPlayerViewPoint(C, Rot);
    Foreach TraceActors(Class'Actor', A, HitLoc, HitNorm, C + (Normal(Vector(Rot)) * 1000), C) {
        SendMsg(A.Class @ "||" @ A.Name, 1);
        Foreach A.ComponentList(Class'ActorComponent', Component);
            SendMsg(Component.Class @ "||" @ Component.Name, 1);
    }
}

Exec Function ToggleEightMarch() {
    bEightMarch = !bEightMarch;
    if(!bEightMarch) {
        WorldInfo.Game.ClearTimer('EightMarch', Self);
        EightMarch(true);
    }
    else {
        WorldInfo.Game.SetTimer(0.1, true, 'EightMarch', Self);
    }
}

Exec Function EightMarch(Bool Disable=false) {
    local OLEnemyPawn Patient, A;
    local SkeletalMeshActorSpawnable SM;
    local SkeletalMeshComponent Component;

    Foreach AllActors(Class'OLEnemyPawn', A) {
        Foreach A.Mesh.AttachedComponents(Class'SkeletalMeshComponent', Component) {
            if(Component.SkeletalMesh == SkeletalMesh'flowers.flowers') {
                A.Mesh.DetachComponent(Component);
                if(Disable) {
                    Patient.Weapons[8].Type = Patient.Default.Weapons[8].Type;
                    Patient.Weapons[8].Mesh = Patient.Default.Weapons[8].Mesh;
                    Patient.Mesh.AttachComponent(Patient.Default.WeaponMesh, Patient.WeaponAttachBone);
                }
            }
        }
    }

     if(Disable) return;

     Foreach AllActors(Class'OLEnemyPawn', Patient) {
        SM = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'flowers.flowers');
        SM.SkeletalMeshComponent.SetMaterial(0,MaterialInstanceConstant'flowers.Prikol1');
        SM.SkeletalMeshComponent.SetMaterial(1,MaterialInstanceConstant'flowers.Prikol2');
        SM.SkeletalMeshComponent.SetMaterial(2,MaterialInstanceConstant'flowers.Prikol');
        SM.SkeletalMeshComponent.SetMaterial(3,MaterialInstanceConstant'flowers.Prikol');
        SM.SetCollision(false,false);
        SM.SetHidden(false);
        Patient.Weapons[8].Type = WeaponType_Blunt;
        Patient.Weapons[8].Mesh = None;
        Patient.Modifiers.WeaponToUse = 8;
        Patient.Modifiers.WeaponMeshToUse = None;
        Patient.Mesh.DetachComponent(Patient.WeaponMesh);
        Patient.Mesh. AttachComponent(SM.SkeletalMeshComponent, Patient.WeaponAttachBone);
    }
}

Exec Function ToggleFestival() {
    bFestival = !bFestival;
    if(!bFestival) {
        WorldInfo.Game.ClearTimer('Festival', Self);
        Festival(true);
    }
    else {
        WorldInfo.Game.SetTimer(0.1, true, 'Festival', Self);
    }
}

Exec Function Flashlights(Bool Disable=false) {
    local OLEnemyPawn Patient, A;
    local SkeletalMeshActorSpawnable SM1, SM2, SM3, SM4, SM5, SM6, SM7;
    local SkeletalMeshComponent Component;
    local ActorComponent CCC;
    local OLFlashLight OLFlashLight;

    Foreach AllActors(Class'OLEnemyPawn', A) {
        Foreach A.Mesh.AttachedComponents(Class'SkeletalMeshComponent', Component) {
            if(Component.SkeletalMesh == SkeletalMesh'flowers.flowers') {
                A.Mesh.DetachComponent(Component);
                if(Disable) {
                    Patient.Weapons[8].Type = Patient.Default.Weapons[8].Type;
                    Patient.Weapons[8].Mesh = Patient.Default.Weapons[8].Mesh;
                    Patient.Mesh.AttachComponent(Patient.Default.WeaponMesh, Patient.WeaponAttachBone);
                }
            }
        }
    }

     if(Disable) return;

     Foreach AllActors(Class'OLEnemyPawn', Patient) {
        SM1 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM2 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM3 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM4 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM5 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM6 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM7 = Spawn(Class'SkeletalMeshActorSpawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        OLFlashLight = Spawn(Class'OLFlashLight',,'PickerFlashLight',Patient.Location, rot(0,0,0),,true);
        SM1.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.FlashLightMesh');
        SM2.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.ConeMesh1a');
        SM3.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.ConeMesh1b');
        SM4.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.ConeMesh2a');
        SM5.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.ConeMesh2b');
        SM6.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.LensFlareMesh');
        SM7.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'OLFlashLight.LightSpotLight');
        SM1.SetCollision(false,false);
        SM1.SetHidden(false);
        SM2.SetCollision(false,false);
        SM2.SetHidden(false);
        SM3.SetCollision(false,false);
        SM3.SetHidden(false);
        SM4.SetCollision(false,false);
        SM4.SetHidden(false);
        SM5.SetCollision(false,false);
        SM5.SetHidden(false);
        SM6.SetCollision(false,false);
        SM6.SetHidden(false);
        SM7.SetCollision(false,false);
        SM7.SetHidden(false);
        Patient.Weapons[8].Type = WeaponType_Blunt;
        Patient.Weapons[8].Mesh = None;
        Patient.Modifiers.WeaponToUse = 8;
        Patient.Modifiers.WeaponMeshToUse = None;
        Patient.Mesh.DetachComponent(Patient.WeaponMesh);
        Patient.Mesh. AttachComponent(SM1.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM2.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM3.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM4.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM5.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM6.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Patient.Mesh. AttachComponent(SM7.SkeletalMeshComponent, Patient.WeaponAttachBone);
        Foreach Patient.Mesh.AttachedComponents(Class'ActorComponent', CCC) {
            `log(CCC.Name);
        }
    }
}

Exec Function Festival(Bool Disable=false) {
    local OLEnemyGenericPatient Patient;
    local OLEnemySoldier Soldier;
    local OLEnemyNanoCloud NanoCloud;
    local DynamicSMActor_Spawnable SM;
    local OLEnemyPawn Enemy;
    local Actor A;
    local StaticMeshComponent Component;
    local SkeletalMeshComponent MeshComp;
    local Rotator Rot;

    Rot.Roll = 0;
    Rot.Yaw = 0;
    Rot.Pitch = -90 * 182.044449;

    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Foreach Enemy.Mesh.AttachedComponents(Class'StaticMeshComponent', Component) {
            if(Component.StaticMesh == StaticMesh'Cone.cone') {
                Enemy.Mesh.DetachComponent(Component);
            }
        }
    }

    Foreach AllActors(Class'Actor', A) {
        if(A.Class == Class'OLEnemyPawn' || A.Class == Class'OLEnemySoldier' || A.Class == Class'OLEnemyGroom' || A.Class == Class'OLEnemyGenericPatient' || A.Class == Class'OLEnemySurgeon' || A.Class == Class'OLEnemyNanoCloud' || A.Class == Class'OLEnemyCannibal' )  break;
        if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
        Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
            if(MeshComp == None) continue;
            Foreach MeshComp.AttachedComponents(Class'StaticMeshComponent', Component) {
                if(Component.StaticMesh == StaticMesh'Cone.cone') {
                    MeshComp.DetachComponent(Component);
                }
            }
        }
    }

    if(Disable) return;

    Foreach AllActors(Class'Actor', A) {
        if(A.Class == Class'OLEnemyPawn' || A.Class == Class'OLEnemySoldier' || A.Class == Class'OLEnemyGroom' || A.Class == Class'OLEnemyGenericPatient' || A.Class == Class'OLEnemySurgeon' || A.Class == Class'OLEnemyNanoCloud' || A.Class == Class'OLEnemyCannibal' )  break;
        if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
        Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
            if(MeshComp == None) continue;
            Foreach MeshComp.AttachedComponents(Class'StaticMeshComponent', Component) {
                if(Component.StaticMesh == StaticMesh'Cone.cone') {
                    MeshComp.DetachComponent(Component);
                }
            }
            if(
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Patient")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Surgeon")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Priest")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Dupont")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(CustomGEnemySkelMesh)) != -1
            ) {
                SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', vect(0,0,0), rot(0,0,0),,true);
                SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
                SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
                SM.SetCollision(false,false);
                SM.SetHidden(false);
                SM.StaticMeshComponent.SetScale3D(vect(0.12,0.12,0.145));
                MeshComp.AttachComponent(SM.StaticMeshComponent, 'NPCMedium-Head',vect(25,-1.5,0),Rot);
            }
             if(
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Soldier")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Groom")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("NanoCloud")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(CustomSEnemySkelMesh)) != -1
            ) {
                SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', vect(0,0,0), rot(0,0,0),,true);
                SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
                SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
                SM.SetCollision(false,false);
                SM.SetHidden(false);
                SM.StaticMeshComponent.SetScale3D(vect(0.11,0.125,0.148));
                MeshComp.AttachComponent(SM.StaticMeshComponent, 'NPCLarge-Head',vect(26.5,-3,0),Rot);
            }
        }
    }

    Foreach AllActors(Class'OLEnemyGenericPatient', Patient) {
        SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', Patient.Location, rot(0,0,0),,true);
        SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
        SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
        SM.SetCollision(false,false);
        SM.SetHidden(false);
        SM.StaticMeshComponent.SetScale3D(vect(0.12,0.12,0.145));
        Patient.Mesh. AttachComponent(SM.StaticMeshComponent, 'NPCMedium-Head',vect(25,-1.5,0),Rot);
    }
    Foreach AllActors(Class'OLEnemySoldier', Soldier) {
        if(Soldier.Class == Class'OLEnemyGroom') {
            SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', Soldier.Location, rot(0,0,0),,true);
            SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
            SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
            SM.SetCollision(false,false);
            SM.SetHidden(false);
            SM.StaticMeshComponent.SetScale3D(vect(0.11,0.125,0.148));
            Soldier.Mesh. AttachComponent(SM.StaticMeshComponent, 'NPCLarge-Head',vect(26.5,-3,0),Rot);
            break;
        }
        SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', Soldier.Location, rot(0,0,0),,true);
        SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
        SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
        SM.SetCollision(false,false);
        SM.SetHidden(false);
        SM.StaticMeshComponent.SetScale3D(vect(0.11,0.12,0.145));
        Soldier.Mesh. AttachComponent(SM.StaticMeshComponent, 'NPCLarge-Head',vect(26.5,-1.5,0),Rot);
    }
    Foreach AllActors(Class'OLEnemyNanoCloud', NanoCloud) {
        SM = Spawn(Class'DynamicSMActor_Spawnable',,'KillerHappy', NanoCloud.Location, rot(0,0,0),,true);
        SM.StaticMeshComponent.SetStaticMesh(StaticMesh'Cone.cone');
        SM.StaticMeshComponent.SetMaterial(0,MaterialInstanceConstant'Cone.PartyHatConst');
        SM.SetCollision(false,false);
        SM.SetHidden(false);
        SM.StaticMeshComponent.SetScale3D(vect(0.11,0.125,0.148));
        NanoCloud.Mesh. AttachComponent(SM.StaticMeshComponent, 'NPCLarge-Head',vect(26.5,-3,0),Rot);
    }
}

Exec Function DumpT3D() {
    
}

Exec Function CopyDiscordAbout() {
    CopyToClipBoard(Localize("Other", "Discord", "Picker"));
    SendMsg("Copied to Clipboard!");
}

Exec Function ShowVolumes(Bool Show=true, Bool ForTrigger=false) {
    local Volume Volume;
    local Trigger Trigger;

    if(ForTrigger) {
        Foreach AllActors(Class'Trigger', Trigger) {
            Trigger.CylinderComponent.SetHidden(!Show);
            Trigger.CollisionComponent.SetHidden(!Show);
            Trigger.SetHidden(!Show);
        }
    }
    else {
        Foreach AllActors(Class'Volume', Volume) {
            Volume.BrushComponent.SetHidden(!Show);
            Volume.SetHidden(!Show);
        }
    }

}

Exec Function ToggleCinematicMode() {
    PickerHud(HUD).bCinematicMode = !PickerHud(HUD).bCinematicMode;
}

Exec Function PlayEnemyAnim(String EnemyType, Name Anim) {
    local OLEnemyGenericPatient Patient;
    local OLEnemySoldier Soldier;

    if(EnemyType ~= "Soldier") {
        Foreach AllActors(Class'OLEnemySoldier', Soldier) {
            Soldier.FullBodyAnimSlot.PlayCustomAnim(Anim, 1);
            //Soldier.LocomotionMode = LM_Cinematic;
            //Soldier.SetPhysics(PHYS_Custom);
            WorldInfo.Game.SetTimer(Soldier.FullBodyAnimSlot.GetCustomAnimNodeSeq().AnimSeq.SequenceLength, false, 'StopEnemyAnim', Self);
        }
    }
    else {
        Foreach AllActors(Class'OLEnemyGenericPatient', Patient) {
            Patient.FullBodyAnimSlot.PlayCustomAnim(Anim, 1);
            //Patient.LocomotionMode = LM_Cinematic;
            //Patient.SetPhysics(PHYS_Custom);
            WorldInfo.Game.SetTimer(Patient.FullBodyAnimSlot.GetCustomAnimNodeSeq().AnimSeq.SequenceLength, false, 'StopEnemyAnim', Self);
        }
    }
}

Exec Function StopEnemyAnim() {
    local OLEnemyPawn Enemy;

    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.FullBodyAnimSlot.StopCustomAnim(0);
        //Enemy.LocomotionMode = LM_Walk;
        //Enemy.SetPhysics(PHYS_Walking);
    }
}

/*Exec Function OL2() {
    local OLDoor Door;
    local StaticMesh MainMeshL, MainMeshR;
    
    MainMeshL = StaticMesh'Outlast2Package.01_Doors.SchoolDoorL';
    MainMeshR = StaticMesh'Outlast2Package.01_Doors.SchoolDoorR';
    Foreach AllActors(Class'OLDoor', Door) {
        if(Door.bReverseDirection) {
            Door.Mesh.SetStaticMesh(MainMeshR);
        }
        else {
            Door.Mesh.SetStaticMesh(MainMeshL);
        }
        Door.Mesh.SetMaterial(0, MaterialInstanceConstant'Outlast2Package.01_Doors.DoorSchoolWood-01');
        Door.Mesh.SetMaterial(1, MaterialInstanceConstant'Outlast2Package.01_Doors.DoorSchoolMetal-01');
        Door.Mesh.SetMaterial(2, MaterialInstanceConstant'Outlast2Package.01_Doors.DoorDetails-02_inst');
    }
}*/

Exec Function Wernicke(Bool ToggleWer=true) {
    local Rotator Rot;

    if(ToggleWer) {
        Rot.Pitch = 0;
        Rot.Yaw = PickerHero(Pawn).Rotation.Yaw - (0 * 182.044449);
        Rot.Roll = 0;
        WernickeModelPlayer = Spawn(Class'SkeletalMeshActorSpawnable',,, PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15), Rot,,true);
        WernickeModelPlayer.SetBase(PickerHero(Pawn), PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15));
        WernickeModelPlayer.SetCollisionType(1);
        WernickeModelPlayer.SetHidden(false);
        WernickeModelPlayer.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'Lab_LD.02_Vernekei.Mesh.Vernekey_paralized_face');
        WorldInfo.Game.SetTimer(0.000001, true, 'WerTimerFunc', Self);
        WorldInfo.Game.SetTimer(1, true, 'WerTimerFuncRot', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('WerTimerFunc', Self);
        WorldInfo.Game.ClearTimer('WerTimerFuncRot', Self);
        WernickeModelPlayer.Destroy();
        PickerHero(Pawn).SetHidden(false);
    }
}

Function WerTimerFunc() {
    WernickeModelPlayer.SetBase(PickerHero(Pawn), PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15));
    WernickeModelPlayer.SetRelativeLocation(vect(0,0,0));
    PickerHero(Pawn).SetHidden(true);
}

Function WerTimerFuncRot() {
    local Rotator Rot;

    Rot.Pitch = 0;
    Rot.Yaw = PickerHero(Pawn).Rotation.Yaw - (0 * 182.044449);
    Rot.Roll = 0;
    WernickeModelPlayer.SetRotation(Rot);
}

Exec Function NFS(Bool ToggleNFS=true) {
    local Rotator Rot;

    if(ToggleNFS) {
        Rot.Pitch = 0;
        Rot.Yaw = PickerHero(Pawn).Rotation.Yaw - (90 * 182.044449);
        Rot.Roll = 0;
        NFSCar = Spawn(Class'SkeletalMeshActorSpawnable',,, PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15), Rot,,true);
        NFSCar.SetBase(PickerHero(Pawn), PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15));
        NFSCar.SetCollisionType(1);
        NFSCar.SetHidden(false);
        NFSCar.SkeletalMeshComponent.SetSkeletalMesh(SkeletalMesh'Asylum_Exterior-LD.01_Animated_Props.SE_Jeep_03');
        WorldInfo.Game.SetTimer(0.000001, true, 'NFSTimerFunc', Self);
        WorldInfo.Game.SetTimer(1, true, 'NFSTimerFuncRot', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('NFSTimerFunc', Self);
        WorldInfo.Game.ClearTimer('NFSTimerFuncRot', Self);
        NFSCar.Destroy();
    }
}

Function NFSTimerFunc() {
    NFSCar.SetBase(PickerHero(Pawn), PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 15));
    NFSCar.SetRelativeLocation(vect(45,40,10));
}

Function NFSTimerFuncRot() {
    local Rotator Rot;

    Rot.Pitch = 0;
    Rot.Yaw = PickerHero(Pawn).Rotation.Yaw - (90 * 182.044449);
    Rot.Roll = 0;
    NFSCar.SetRotation(Rot);
}

Exec Function KillerMake(String CMaterial) { // Replaces Every Material of Every StaticMesh (Fun)
    local Actor A;
    local StaticMeshComponent MeshComp;
    local Int Index;
    local MaterialInterface Material;

    Foreach AllActors(Class'Actor', A) {
        if(InStr(Caps(A.Name), Caps("StaticMesh")) != -1) {//continue;
            //if(InStr(Caps(A.Name), Caps("Actor")) != -1) continue;
           // `log(A.Name);
            Foreach A.ComponentList(Class'StaticMeshComponent', MeshComp) {
                Index = 0;
                //if(MeshComp == None || MeshComp.StaticMesh == None) continue;
                //if(MeshComp.Materials.Length == -1) continue;
                while(Index < MeshComp.Materials.Length) {
                    MeshComp.SetMaterial(Index, MaterialInstanceConstant(DynamicLoadObject(CMaterial, Class'MaterialInstanceConstant')));
                    //`log(MeshComp.Materials.Length);
                    Index++;
                }
            }
        }
    }
}

Exec Function SkipTorture() {
    local PickerGame CGame;

    CGame = PickerGame(WorldInfo.Game);
    if(CGame.IsPlayingDLC()) {
        CP("Building2_TortureDone");
    }
    else {
        CP("Male_TortureDone");
    }
}

Exec Function SkipStart() {
    local PickerGame CGame;

    CGame = PickerGame(WorldInfo.Game);
    if(CGame.IsPlayingDLC()) {
        CP("Hospital_Free");
    }
    else {
        CP("Admin_Gates");
    }
}

Exec Function TimerFrom(Float TimerFromTime, coerce String Command) {
    CommandTimerFrom = Command;
    WorldInfo.Game.SetTimer(TimerFromTime, true, 'TimerFromFunc', Self);
    
}

Function TimerFromFunc() {
    ConsoleCommand(CommandTimerFrom);
}

Exec Function TimerStop() {
    WorldInfo.Game.ClearTimer('TimerFromFunc', Self);
}

Exec Function StopCurrentMovie() {
    local Engine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Engine.StopMovie(false);
}

Exec Function SpawnHero(Bool Possessed=false) {
    local Vector C;
    local Rotator Rot;
    local PickerHero Hero;

    GetPlayerViewPoint(C, Rot);
    Hero = Spawn(Class'PickerHero',,,C,Rot,,true);
    if(Possessed) {
        UnPossess();
        Possess(Hero, false);
    }
}

Exec Function KillHeroes(Bool AfterPossess=true) {
    local PickerHero Hero;

    Foreach AllActors(Class'PickerHero', Hero) {
        Hero.Destroy();
    }
    if(AfterPossess) {
        SpawnHero(true);
    }
}

Exec Function String GetHeroList() {
    local PickerHero Hero;
    local String Result;

    Foreach AllActors(Class'PickerHero', Hero) {
        Result = Result @ Hero.Name $ "\n";
    }
    SendMsg(Result);
    `log(Result);
    return Result;
}

Exec Function PossessHero(Int HeroIndex) {
    local PickerHero Hero;

    Foreach AllActors(Class'PickerHero', Hero) {
        if(Hero.Name == Name("PickerHero_" $ String(HeroIndex))) {
            UnPossess();
            Possess(Hero, false);
            break;
        }
    }
}

Exec Function SetTargetHero(Int HeroIndex) {
    local OLBot Bot;
    local PickerHero Hero;

    Foreach AllActors(Class'OLBot', Bot) {
        Foreach AllActors(Class'PickerHero', Hero) {
            if(Hero.Name == Name("PickerHero_" $ String(HeroIndex))) {
                Bot.TargetPlayer = Hero;
                break;
            }
        }
    }
}

Exec Function SpawnProp(StaticMesh Meshh, optional Int MatIndex, optional MaterialInstanceConstant Material) {
    local Rotator Rot;
    local PickerProp Prop;

    Rot.Pitch = 0;
    Rot.Yaw = Pawn.Rotation.Yaw - (90 * 182.044449);
    Rot.Roll = 0;
    Prop = Spawn(Class'PickerProp',,, PickerHero(Pawn).Location + (Normal(Vector(PickerHero(Pawn).Rotation)) * 100), Rot,,true);
    Prop.SetHidden(false);
    if(Material != None) {
        Prop.StaticMeshComponent.SetMaterial(MatIndex, Material);
    }
    if(Meshh != None) {
        Prop.StaticMeshComponent.SetStaticMesh(Meshh);
        Prop.SetCollision(true, true);
    }
    else {
        SendMsg("Mesh is missing!");
        return;
    }
}

Exec Function ChangeProp(PickerProp Prop, optional StaticMesh Mesh, optional Int MatIndex, optional MaterialInstanceConstant Material) {
    local PickerProp D;
    local Bool bAllProps;

    if(Prop == None) {
        bAllProps = true;
    }
    Foreach AllActors(Class'PickerProp', D) {
        if(bAllProps) {
            if(Material != None) {
                D.StaticMeshComponent.SetMaterial(MatIndex, Material);
            }
            if(Mesh != None) {
                D.StaticMeshComponent.SetStaticMesh(Mesh);
            }
        }
        else if(D == Prop) {
            if(Material != None) {
                D.StaticMeshComponent.SetMaterial(MatIndex, Material);
            }
            if(Mesh != None) {
                D.StaticMeshComponent.SetStaticMesh(Mesh);
            }
        }
    }
}

Exec Function DeleteProp(PickerProp Prop) {
    local PickerProp D;
    local Bool bAllProps;

    if(Prop == None) {
        bAllProps = true;
    }
    Foreach AllActors(Class'PickerProp', D) {
        if(bAllProps) {
            D.Destroy();
        }
        else {
            if(D == Prop) {
                D.Destroy();
            }
        }
    }
}

/************************RANDOMIZER FUNCTIONS************************/

Exec Function ModifyRandomizer(Byte Modifier, String Value) {
    if(RandomizerState) {
        SendMsg("Unavailable in Randomizer!");
        return;
    }
    Switch(Modifier) {
        case 0:
            RandomizerChallengeMode = Bool(Value);
            break;
        Default:
            SendMsg("Wrong Modifier!");
            break;
    }
}

Exec Function ToggleRandomizer() {
    RandomizerState = !RandomizerState;
    if(RandomizerState) {
        SendMsg("RANDOMIZER STARTED, ENJOY!");
    }
    else {
        SendMsg("RANDOMIZER DISABLED!");
    }
    Randomizer();
}

Function Randomizer() {
    if(!RandomizerState) {
        WorldInfo.Game.ClearTimer('RandomizerMediumRandom', Self);
        WorldInfo.Game.ClearTimer('RandomizerLargeRandom', Self);
        WorldInfo.Game.ClearTimer('RandomizerQuickEvents', Self);
    }
    else {
        WorldInfo.Game.SetTimer(15.0, true, 'RandomizerMediumRandom', Self);
        WorldInfo.Game.SetTimer(30.0, true, 'RandomizerLargeRandom', Self);
        WorldInfo.Game.SetTimer(0.5, true, 'RandomizerQuickEvents', Self);
    }
}

/*Function RandomizerSmallRandom() {
    Switch(Rand(5)) {
        case 0:
            if(RandBool() && bHasCamcorder || PickerHero(Pawn).bCamcorderDesired) {
                ToggleNightVision();
            }
            else if(RandBool() && bHasCamcorder) {
                ToggleCamcorder();
            }
            else {
                if(RandBool()) {
                    bHasCamcorder = true;
                    ToggleCamcorder();
                }
                if(RandBool()) {
                    bHasCamcorder = false;
                }
            }
            break;
        case 1:
            RandPatientModel();
            break;
        case 2:
            if(!RandomizerFR) {
                RandPlayerSpeed(RandBool());
            }
            break;
        case 3:
            PickerGame(WorldInfo.Game).DifficultyMode = EDifficultyMode(Rand(3));
            break;
        case 4:
            CantHideFromUs(RandBool());
            break;
        case 5:
            break;
        
    }
}*/

Function RandomizerMediumRandom() {
    Switch(Rand(11)) {
        case 0:
            DS(Rand(10));
            SendMsg("You're hurt!");
            break;
        case 1:
            RandPlayerState();
            SendMsg("I feel self... different");
            break;
        case 2:
            if(RandBool()) {
                LockDoor();
                SendMsg("Doors are Locked!");
            }
            else if(RandBool()) {
                UnlockDoor();
                SendMsg("Doors are Unlocked!");
            }
            else {
                DeleteDoors(RandBool());
                SendMsg("Doors are Deleted! (or reseted...)");
            }
            break;
        case 3:
            RandSpawnEnemyCount(1, 5);
            SendMsg("Oh no!");
            break;
        case 4:
            ConsoleCommand("PressedJump");
            SendMsg("Just Jump?");
            break;
        case 5:
            RandUberEffect();
            SendMsg("Blind Mode!");
            break;
        case 6:
            if(RandBool() && bHasCamcorder || PickerHero(Pawn).bCamcorderDesired) {
                ToggleNightVision();
            }
            else if(RandBool() && bHasCamcorder) {
                ToggleCamcorder();
            }
            else {
                if(RandBool()) {
                    bHasCamcorder = true;
                    ToggleCamcorder();
                }
                if(RandBool()) {
                    bHasCamcorder = false;
                }
            }
            SendMsg("Where my camera?!");
            break;
        case 7:
            if(RandBool()) {
                MadeLight();
            }
            else {
                MadeSpot();
            }
            SendMsg("It's getting brighter here...");
            break;
        case 8:
            TeleportEnemyToPlayer();
            SendMsg("I didn't want to THIS rain!");
            break;
        case 9:
            PickerGame(WorldInfo.Game).DifficultyMode = EDifficultyMode(Rand(3));
            SendMsg("Difficulty is... new!");
            break;
        case 10:
            CantHideFromUs(RandBool());
            SendMsg("You can't hide! (or hide)");
            break;
        case 11:
            Rand100PlayerPos();
            SendMsg("Poof!");
            break;
        case 12:
            RandDoors();
            SendMsg("The doors were different... I think");
            break;
        
    }
}

Function RandomizerLargeRandom() {
    Switch(Rand(5)) {
        case 0:
            if(Rand(100) >= 99) {
                if(PickerGame(WorldInfo.Game).IsPlayingDLC()) {
                    CP("Hospital_Free");
                }
                else {
                    CP("Admin_Gates");
                }
            }
            else {
                if(!RandomizerChallengeMode) {
                    Reload();
                }
            }
            break;
        case 1:
            SendMsg("No Reload :)");
            DS(1);
            break;
        case 2:
            SendMsg("No Reload :)");
            DS(2);
            break;
        case 3:
            SendMsg("No Reload :)");
            DS(3);
            break;
        case 4:
            SendMsg("No Reload :)");
            DS(4);
            break;
        case 5:
            SendMsg("No Reload :)");
            DS(5);
            break;
    }
}

Function RandomizerQuickEvents() {
    PlayerAnimRate(RandFloat(2.5));
    RandLightColor();
    RandPatientModel();
    RandPlayerSpeed();
    RandChangeDoorMeshType();
    //RandChangeFOV();
}

/************************INSANEPLUS FUNCTIONS************************/

Exec Function ModifyInsanePlus(Byte Modifier) {
    Switch(Modifier) {
        case 0:
            DisCamMode=!DisCamMode;
            break;
        case 1:
            TrainingMode=!TrainingMode;
            break;
        Default:
            SendMsg("Wrong Modifier!");
            return;
            break;
    }
}

Exec Function ToggleInsanePlus(optional String CPD) {
    InsanePlusState = !InsanePlusState;
    InsanePlus(CPD);
}
Function InsanePlus(optional String CPD) {
    local PickerGame CGame;
    local PickerHero Hero;

    CGame = PickerGame(WorldInfo.Game);
	Hero = PickerHero(Pawn);
    if(!InsanePlusState) {
        ConsoleCommand("Set OLAnimBlendBySpeed MaxSpeed 400");
        Hero.bCameraCracked = false;
        Hero.DeathScreenDuration = 7.50;
        Hero.NormalWalkSpeed = 200;
        Hero.NormalRunSpeed = 450;
        Hero.CrouchedSpeed = 75;
        Hero.BatteryDuration = 150;
        PickerHud(HUD).SetMenu(Normal);
        CGame.DifficultyMode = EDM_Normal;
        DisCamMode = Default.DisCamMode;
        TrainingMode = Default.TrainingMode;
        InsanePlusStamina = 100;
        ResetJumpStam = false;
        LSMDamage = true;
        Hero.ForwardSpeedForJumpWalking = Hero.Default.ForwardSpeedForJumpWalking;
        Hero.ForwardSpeedForJumpRunning = Hero.Default.ForwardSpeedForJumpRunning;
        Hero.JumpClearanceWalking = Hero.Default.JumpClearanceWalking;
        Hero.JumpClearanceRunning = Hero.Default.JumpClearanceRunning;
        Hero.NormalWalkSpeed = Hero.Default.NormalWalkSpeed;
        Hero.NormalRunSpeed = Hero.Default.NormalRunSpeed;
        WorldInfo.Game.ClearTimer('InsanePlusOneBattery', Self);
        WorldInfo.Game.ClearTimer('InsanePlusDisCam', Self);
        WorldInfo.Game.ClearTimer('InsanePlusSlowHero', Self);
        WorldInfo.Game.ClearTimer('InsanePlusFastEnemy', Self);
        WorldInfo.Game.ClearTimer('InsanePlusNoDark', Self);
        WorldInfo.Game.ClearTimer('InsanePlusOneShot', Self);
        WorldInfo.Game.ClearTimer('InsanePlusLimitedStamina', Self);
        WorldInfo.Game.ClearTimer('InsanePlusBadBattery', Self);
        WorldInfo.Game.ClearTimer('InsanePlusSmartAI', Self);
        WorldInfo.Game.ClearTimer('InsanePlusMainFunc', Self);
        WorldInfo.Game.ClearTimer('InsanePlusLSAddFunc', Self);
        WorldInfo.Game.ClearTimer('InsanePlusLSAddFunc2', Self);
        SendMsg("INSANE PLUS DISABLED!");}
    else {
        LSMDamage = true;
        ResetJumpStam = false;
        PickerHud(HUD).SetMenu(DisInsanePlus);
        WorldInfo.Game.SetTimer(0.0001, true, 'InsanePlusMainFunc', Self);
        DefaultNumBatteries = 0;
        NumBatteries = 0;
        NightmareMaxNumBatteries = 1;
        if(DisCamMode) {
            WorldInfo.Game.SetTimer(0.0001, true, 'InsanePlusDisCam', Self);
        }
        ConsoleCommand("Set OLAnimBlendBySpeed MaxSpeed 360");
        WorldInfo.Game.SetTimer(0.0001, true, 'InsanePlusOneBattery', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusSlowHero', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusFastEnemy', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusNoDark', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusOneShot', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusBadBattery', Self);
        WorldInfo.Game.SetTimer(0.001, true, 'InsanePlusSmartAI', Self);
        WorldInfo.Game.SetTimer(0.01, true, 'InsanePlusLimitedStamina', Self);
        InsanePlusStamina=100;
        if(TrainingMode) {
            CGame.DifficultyMode = EDM_Nightmare;
            if(CPD != "") {
                CP(CPD, false);
            }
            else {
                Reload();
            }
        }
        else {
            CGame.DifficultyMode = EDM_Insane;
            if(CGame.IsPlayingDLC()) {
                CP("Hospital_Free", false);
            }
            else {
                CP("Admin_Gates", false);
            }
        }
        SendMsg("INSANE PLUS STARTED, ENJOY!");
    }
}

Function InsanePlusMainFunc() {
    local PickerGame CGame;

    CGame = PickerGame(WorldInfo.Game);
    PickerHero(Pawn).BatteryDuration = 90;
    PickerHero(Pawn).bCameraCracked = true;
    if(TrainingMode) {
        PickerHero(Pawn).DeathScreenDuration = 0;
    }
    if(CGame.IsPlayingDLC()) {
        PickerHero(Pawn).ShatteredCameraGlassCheckpoint = 'Hospital_Start';
        FirstSoldierFindableCheckpoint = 'Hospital_Start';
        FirstSurgeonFindableCheckpoint = 'Hospital_Start';
    }
    else {
        PickerHero(Pawn).ShatteredCameraGlassCheckpoint = 'Admin_Gates';
        FirstSoldierFindableCheckpoint = 'Admin_Basement';
        FirstSurgeonFindableCheckpoint = 'Male_TortureDone';
    }
}

Function InsanePlusSmartAI() {
    local OLDoor Door;
    local PickerGame CGame;
    local String Checkpoint;
    local OLEnemyGenericPatient Cannibal;
    local OLEnemyPawn Enemy;
    local Bool MapWithCannibal;
    
    CGame = PickerGame(WorldInfo.Game);
    Checkpoint = String(CGame.CurrentCheckpointName);
    FirstSoldierFindableCheckpoint = 'Admin_Basement';
    FirstSurgeonFindableCheckpoint = 'Male_TortureDone';
    Foreach WorldInfo.AllPawns(Class'OLEnemyGenericPatient', Cannibal) {
        Switch(Cannibal.Class) {
            case Class'OLEnemyCannibal':
                MapWithCannibal = true;
                break;
            Default:
                MapWithCannibal = false;
                break;
        }
    }
    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.Modifiers.bAlwaysLookAtPlayer = true;
    }
    Foreach AllActors(Class'OLDoor', Door) {
        if(Checkpoint ~= "Hospital_1stFloor_GotKey") {
            Door.bDontBreak = false;
            Door.bAICanUseDoor = true;
            Door.bAlwaysBreak = true;
        }
        else if(Checkpoint ~= "Hospital_1stFloor_NeedHandcuff" && !MapWithCannibal) {
            Door.bDontBreak = false;
            Door.bAICanUseDoor = true;
            Door.bAlwaysBreak = true;
        }
        else {
            Door.bDontBreak = true;
            Door.bAICanUseDoor = true;
            Door.bAlwaysBreak = false;
        }
    }
}

Function InsanePlusBadBattery() {
    local Float Energy;

    if(PickerHero(Pawn).CurrentBatterySetEnergy > 0.95) {
        Energy = RandRange(0.05, 0.94);
        PickerHero(Pawn).CurrentBatterySetEnergy = Energy;
    }
}

Function InsanePlusLimitedStamina() {
    local Bool IsMoving;
    local PickerInput Input;

    Input = PickerInput(PlayerInput);
    IsMoving = Input.Movement.X != 0 || Input.Movement.Y != 0;
    if(PickerHero(Pawn).LocomotionMode == LM_Walk || PickerHero(Pawn).LocomotionMode == LM_LookBack || PickerHero(Pawn).LocomotionMode == LM_Fall) {
        if(PickerHero(Pawn).IsRunning() && InsanePlusStamina > 0) {
            InsanePlusStamina -= 0.01;
            InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
        }
        if(IsMoving && Input.Outer.bDuck == 0 && !PickerHero(Pawn).bWasUnder && InsanePlusStamina > 0 && InsanePlusStamina != 100) {
            InsanePlusStamina -= 0.045;
            InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
        }
    }
    if(PickerHero(Pawn).bJumping) {
        if(InsanePlusStamina > 0 && !ResetJumpStam) {
            ResetJumpStam = true;
            InsanePlusStamina -= 25;
            InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
        }
    }
    if(PickerHero(Pawn).LocomotionMode == LM_Walk && !PickerHero(Pawn).bJumping && ResetJumpStam) {
        WorldInfo.Game.SetTimer(0.1, false, 'InsanePlusLSAddFunc2', Self);
    }
    if(PickerHero(Pawn).LocomotionMode!=LM_Walk && PickerHero(Pawn).LocomotionMode!=LM_LookBack && PickerHero(Pawn).LocomotionMode!=LM_Fall) {
        PickerHero(Pawn).bJumping = false;
    }
    if(InsanePlusStamina < 0) {
        InsanePlusStamina = 0;
        InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
    }
    if(InsanePlusStamina > 100) {
        InsanePlusStamina = 100;
        InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
    }
    if(InsanePlusStamina < 100 && !PickerHero(Pawn).IsRunning() && !PickerHero(Pawn).bJumping) {
        InsanePlusStamina += 0.08;
        InsanePlusStamina = Float(Left(InsanePlusStamina, Len(string(InsanePlusStamina)) - 1));
    }
    if(InsanePlusStamina >= 15) {
        WorldInfo.Game.ClearTimer('InsanePlusLSAddFunc', Self);
        LSMDamage = true;
        PickerHero(Pawn).ForwardSpeedForJumpWalking = 450;
        PickerHero(Pawn).ForwardSpeedForJumpRunning = 650;
        PickerHero(Pawn).JumpClearanceWalking = 200;
        PickerHero(Pawn).JumpClearanceRunning = 300;
        PickerHero(Pawn).NormalRunSpeed = 370;
    }
    if(InsanePlusStamina < 15) {
        PickerHero(Pawn).ForwardSpeedForJumpWalking = 0;
        PickerHero(Pawn).ForwardSpeedForJumpRunning = 0;
        PickerHero(Pawn).JumpClearanceWalking = 0;
        PickerHero(Pawn).JumpClearanceRunning = 0;
        if(InsanePlusStamina < 5) {
            if(LSMDamage) {
                WorldInfo.Game.SetTimer(3, false, 'InsanePlusLSAddFunc', Self);
                LSMDamage = false;
            }
            PickerHero(Pawn).NormalRunSpeed=135;
        }
        PickerHero(Pawn).NormalRunSpeed=250;
    }

}

Function InsanePlusLSAddFunc2() {
    ResetJumpStam = false;
}

Function InsanePlusLSAddFunc() {
    DS(25);
    LSMDamage = true;
}
Function InsanePlusOneBattery() {
    NightmareMaxNumBatteries = 1;
}

Function InsanePlusDisCam() {
    bHasCamcorder = false;
}

Function InsanePlusSlowHero(Bool d=false) {
    local PickerGame CGame;
    local Name Checkpoint;

    CGame = PickerGame(WorldInfo.Game);
    Checkpoint = CGame.CurrentCheckpointName;
    if(d && InsanePlusState) {
        if(PickerHero(Pawn).LocomotionMode == LM_Walk || PickerHero(Pawn).LocomotionMode == LM_LookBack) {
            PlayerAnimRate(1.11);
            return;
        }
        else {
            PlayerAnimRate(1);
        }
        InsanePlusSlowHero(true);
        return;
    }
    else {
        if(Checkpoint == 'Building2_Garden' || Checkpoint == 'Building2_Floor1_1' || Checkpoint == 'Building2_Floor1_2' || Checkpoint == 'Building2_Floor1_3' || Checkpoint == 'Building2_Floor1_4' || Checkpoint == 'Building2_Floor1_5' || Checkpoint == 'Building2_Floor1_5b' || Checkpoint == 'Building2_Floor1_6') {
            PickerHero(Pawn).CrouchedSpeed = 35;
            PickerHero(Pawn).HobblingWalkSpeed = 50;
            PickerHero(Pawn).HobblingRunSpeed = 110;
        }
        else {
            PickerHero(Pawn).NormalWalkSpeed = 135;
            PickerHero(Pawn).NormalRunSpeed = 370;
            PickerHero(Pawn).CrouchedSpeed = 55;
            PickerHero(Pawn).HobblingWalkSpeed = 90;
            PickerHero(Pawn).HobblingRunSpeed = 200;
        }
        if(PickerHero(Pawn).LocomotionMode == LM_Walk || PickerHero(Pawn).LocomotionMode == LM_LookBack) {
            PlayerAnimRate(1.11);
        }
        else {
            PlayerAnimRate(1);
        }
    }
}

Exec Function DDSS() {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        `log(Door.Mesh.StaticMesh);
    }
}

Function InsanePlusNoDark() {
    local OLDarknessVolume Darks;

    Foreach AllActors(Class'OLDarknessVolume', Darks) {
        Darks.bDark = false;
    }
}

Function InsanePlusFastEnemy() {
    local OLBot Bot, BotNC;
    local PickerGame CGame;
    local OLEnemyNanoCloud NanoCloud;
    local OLDoor ASRDoorCheck;
    local String Checkpoint;
    
    CGame = PickerGame(WorldInfo.Game);
    Checkpoint = String(CGame.CurrentCheckpointName);
    if(Checkpoint ~= "Sewer_Citern2") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=205;
        }
        return;
    }
    else if(Checkpoint ~= "Sewer_start") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=225;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=225;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=785;
            Bot.EnemyPawn.Modifiers.bShouldAttack=true;
            Bot.EnemyPawn.BehaviorTree=OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
            if(Bot.EnemyPawn.Tag != 'IPNC') {
                Bot.EnemyPawn.Destroy();
                NanoCloud = Spawn(Class'OLEnemyNanoCloud',,'IPNC', Vect(4661,4648,-402), Rot(0,0,0),,true);
                NanoCloud.Modifiers.bShouldAttack = true;
                BotNC = Spawn(Class'OLBot');
                BotNC.Possess(NanoCloud, false);
            }
        }
        return;
    }
    else if(Checkpoint ~= "Sewer_FlushWater") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=250;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=285;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=705;
            if(Bot.EnemyPawn.Tag == 'IPNC') {
                Bot.EnemyPawn.Destroy();
            }
        }
        return;
    }
    else if(Checkpoint ~= "Sewer_WaterFlushed") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=250;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=285;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=2305;
        }
        return;
    }
    else if(Checkpoint ~= "Admin_Basement" || Checkpoint ~= "Admin_Electricity") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=705;
        }
        
    }
    else if(Checkpoint ~= "Admin_SecurityRoom") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Foreach AllActors(Class'OLDoor', ASRDoorCheck)
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=400;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=400;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1600; //Door_Enforced_R
        }
        return;
    }
    else if(Checkpoint ~= "Prison_Start" || Checkpoint ~= "Prison_IsolationCells01_Mid" || Checkpoint ~= "Prison_SecurityRoom1" || Checkpoint ~= "Prison_Showers_2ndFloor"  || Checkpoint ~= "Prison_IsolationCells02_PostSoldier") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=705;
            Bot.EnemyPawn.Modifiers.bShouldAttack=true;
            Bot.EnemyPawn.BehaviorTree=OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        }
        return;
    }
    else if(Checkpoint ~= "Prison_IsolationCells02_Soldier") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=555;
        }
        return;
    }
    else if(Checkpoint ~= "Prison_PrisonFloor_SecurityRoom1") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=900;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=945;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1855;
            Bot.EnemyPawn.BehaviorTree=OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        }
        return;
    }
    else if(Checkpoint ~= "Male_Chase") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=450;
        }
        return;
    }
    else if(Checkpoint ~= "Male_ChasePause") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=375;
        }
        return;
    }
    else if(Checkpoint ~= "Male_TortureDone") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=1945;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1975;
        }
        return;
    }
    else if(Checkpoint ~= "Male_surgeon") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=975;
        }
        return;
    }
    else if(Checkpoint ~= "Male_GetTheKey2") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1975;
        }
        return;
    }
    else if(Checkpoint ~= "Male_SprinklerOff") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=775;
        }
        return;
    }
    else if(Checkpoint ~= "Lab_BigTowerStairs") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=425;
        }
        return;
    }
    else if(Checkpoint ~= "Lab_BigRoomDone") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=360;
        }
        return;
    }
    else if(Checkpoint ~= "Lab_BigTower") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=360;
        }
        return;
    }
    else if(Checkpoint ~= "Hospital_1stFloor_Chase") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=460;
        }
        return;
    }
    else if(Checkpoint ~= "Courtyard1_Basketball") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=270;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=270;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=270; //NOT
            Bot.EnemyPawn.BehaviorTree=OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
            Bot.EnemyPawn.AttackPushKnockbackPower=380.5;
            Bot.EnemyPawn.AttackNormalKnockbackPower=380.5;
        }
        return;
    }
    else if(Checkpoint ~= "Courtyard1_SecurityTower") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=270;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=270;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=270; //NOT
            Bot.EnemyPawn.Modifiers.bShouldAttack=true;
        }
        return;
    }
    else if(Checkpoint ~= "PrisonRevisit_Start") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=1570;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=1570;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1570; //NOT
            Bot.EnemyPawn.Modifiers.bShouldAttack=false;
        }
        return;
    }
    else if(Checkpoint ~= "Building2_Floor3_4") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=300;
            Bot.EnemyPawn.BehaviorTree = OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        }
        return;
    }
    else if(Checkpoint ~= "Building2_Floor3_3" || Checkpoint ~= "Building2_Post_Elevator" || Checkpoint ~= "Building2_TortureDone") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            if(Checkpoint != "Building2_TortureDone") {
                Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=1600;
                Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=1600;
                Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=1600;
            }
            else {
                Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
                Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=345;
                Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=555;
                Bot.EnemyPawn.DarknessSpeedValues.PatrolSpeed=300;
                Bot.EnemyPawn.DarknessSpeedValues.InvestigateSpeed=345;
                Bot.EnemyPawn.DarknessSpeedValues.ChaseSpeed=555;
                Bot.EnemyPawn.ElectricitySpeedValues.PatrolSpeed=300;
                Bot.EnemyPawn.ElectricitySpeedValues.InvestigateSpeed=345;
                Bot.EnemyPawn.ElectricitySpeedValues.ChaseSpeed=555;
                Bot.EnemyPawn.MoveSpeed_Override.PatrolSpeed=300;
                Bot.EnemyPawn.MoveSpeed_Override.InvestigateSpeed=345;
                Bot.EnemyPawn.MoveSpeed_Override.ChaseSpeed=555;
            }
            Bot.EnemyPawn.BehaviorTree = OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        }
        return;
    }
    else if(Checkpoint ~= "Building2_Floor1_4") {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=300;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=600;
            Bot.EnemyPawn.BehaviorTree = OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        }
        return;
    }
    else {
        Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
            Bot.EnemyPawn.NormalSpeedValues.PatrolSpeed=200;
            Bot.EnemyPawn.NormalSpeedValues.InvestigateSpeed=245;
            Bot.EnemyPawn.NormalSpeedValues.ChaseSpeed=505;
        }
    }
}

Function InsanePlusOneShot() {
    local OLBot Bot;
    
    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Bot.EnemyPawn.AttackNormalDamage=101;
        Bot.EnemyPawn.AttackThrowDamage=101;
        Bot.EnemyPawn.VaultDamage=101;
        Bot.EnemyPawn.DoorBashDamage=101;
    }
}

Exec Function ToggleTimer() {
    bTimer = !bTimer;
}

Exec Function ResetTimer() {
    bResetTimer = true;
}

Exec Function TeleportEnemyToPlayer(Bool ToPlayer=false) {
    local OLEnemyPawn Enemy;
    local Vector C;
    local Rotator Rot;

    if(ToPlayer) {
        C = PickerHero(Pawn).Location + Vect(0,0,10);
        Rot = PickerHero(Pawn).Rotation;
    }
    else {
        GetPlayerViewPoint(C,Rot); C -= Vect(0,0,120);
    }
    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.SetCollision(false,false);
        Enemy.SetLocation(C);
        Enemy.SetRotation(Rot);
        WorldInfo.Game.SetTimer(0.07, false, 'BackPawnCol', Self);
    }
    if(!PickerHud(HUD).DisableTeleportSound) {
        PlaySound(TeleportSound);
    }
}

Function BackPawnCol() {
    local OLEnemyPawn Enemy;

    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.SetCollision(true, true);
        WorldInfo.Game.ClearTimer('BackPawnCol');
    }
}

Exec Function Checkpoint(String Checkpoint, Bool Save=AlwaysSaveCheckpoint) {
    local OLEnemyPawn Enemy;
    local OLCheckpointList FullList, List, List2;
    local PickerGame CGame;
    local Name CPName;

    CGame = PickerGame(WorldInfo.Game);

    List = Spawn(Class'OLCheckpointList');
    List2 = Spawn(Class'OLCheckpointList');
    List.GameType = OGT_Outlast;
    List.CheckpointList[0] = 'StartGame';
    List.CheckpointList[1] = 'Admin_Gates';
    List.CheckpointList[2] = 'Admin_Garden';
    List.CheckpointList[3] = 'Admin_Explosion';
    List.CheckpointList[4] = 'Admin_Mezzanine';
    List.CheckpointList[5] = 'Admin_MainHall';
    List.CheckpointList[6] = 'Admin_WheelChair';
    List.CheckpointList[7] = 'Admin_SecurityRoom';
    List.CheckpointList[8] = 'Admin_Basement';
    List.CheckpointList[9] = 'Admin_Electricity';
    List.CheckpointList[10] = 'Admin_PostBasement';
    List.CheckpointList[11] = 'Prison_Start';
    List.CheckpointList[12] = 'Prison_IsolationCells01_Mid';
    List.CheckpointList[13] = 'Prison_ToPrisonFloor';
    List.CheckpointList[14] = 'Prison_PrisonFloor_3rdFloor';
    List.CheckpointList[15] = 'Prison_PrisonFloor_SecurityRoom1';
    List.CheckpointList[16] = 'Prison_PrisonFloor02_IsolationCells01';
    List.CheckpointList[17] = 'Prison_Showers_2ndFloor';
    List.CheckpointList[18] = 'Prison_PrisonFloor02_PostShowers';
    List.CheckpointList[19] = 'Prison_PrisonFloor02_SecurityRoom2';
    List.CheckpointList[20] = 'Prison_IsolationCells02_Soldier';
    List.CheckpointList[21] = 'Prison_IsolationCells02_PostSoldier';
    List.CheckpointList[22] = 'Prison_OldCells_PreStruggle';
    List.CheckpointList[23] = 'Prison_OldCells_PreStruggle2';
    List.CheckpointList[24] = 'Prison_Showers_Exit';
    List.CheckpointList[25] = 'Sewer_start';
    List.CheckpointList[26] = 'Sewer_FlushWater';
    List.CheckpointList[27] = 'Sewer_WaterFlushed';
    List.CheckpointList[28] = 'Sewer_Ladder';
    List.CheckpointList[29] = 'Sewer_ToCitern';
    List.CheckpointList[30] = 'Sewer_Citern1';
    List.CheckpointList[31] = 'Sewer_Citern2';
    List.CheckpointList[32] = 'Sewer_PostCitern';
    List.CheckpointList[33] = 'Sewer_ToMaleWard';
    List.CheckpointList[34] = 'Male_Start';
    List.CheckpointList[35] = 'Male_Chase';
    List.CheckpointList[36] = 'Male_ChasePause';
    List.CheckpointList[37] = 'Male_Torture';
    List.CheckpointList[38] = 'Male_TortureDone';
    List.CheckpointList[39] = 'Male_surgeon';
    List.CheckpointList[40] = 'Male_GetTheKey';
    List.CheckpointList[41] = 'Male_GetTheKey2';
    List.CheckpointList[42] = 'Male_Elevator';
    List.CheckpointList[43] = 'Male_ElevatorDone';
    List.CheckpointList[44] = 'Male_Priest';
    List.CheckpointList[45] = 'Male_Cafeteria';
    List.CheckpointList[46] = 'Male_SprinklerOff';
    List.CheckpointList[47] = 'Male_SprinklerOn';
    List.CheckpointList[48] = 'Courtyard_Start';
    List.CheckpointList[49] = 'Courtyard_Corridor';
    List.CheckpointList[50] = 'Courtyard_Chapel';
    List.CheckpointList[51] = 'Courtyard_Soldier1';
    List.CheckpointList[52] = 'Courtyard_Soldier2';
    List.CheckpointList[53] = 'Courtyard_FemaleWard';
    List.CheckpointList[54] = 'Female_Start';
    List.CheckpointList[55] = 'Female_Mainchute';
    List.CheckpointList[56] = 'Female_2ndFloor';
    List.CheckpointList[57] = 'Female_2ndfloorChute';
    List.CheckpointList[58] = 'Female_ChuteActivated';
    List.CheckpointList[59] = 'Female_Keypickedup';
    List.CheckpointList[60] = 'Female_3rdFloor';
    List.CheckpointList[61] = 'Female_3rdFloorHole';
    List.CheckpointList[62] = 'Female_3rdFloorPosthole';
    List.CheckpointList[63] = 'Female_Tobigjump';
    List.CheckpointList[64] = 'Female_LostCam';
    List.CheckpointList[65] = 'Female_FoundCam';
    List.CheckpointList[66] = 'Female_Chasedone';
    List.CheckpointList[67] = 'Female_Exit';
    List.CheckpointList[68] = 'Female_Jump';
    List.CheckpointList[69] = 'Revisit_Soldier1';
    List.CheckpointList[70] = 'Revisit_Mezzanine';
    List.CheckpointList[71] = 'Revisit_ToRH';
    List.CheckpointList[72] = 'Revisit_RH';
    List.CheckpointList[73] = 'Revisit_FoundKey';
    List.CheckpointList[74] = 'Revisit_To3rdfloor';
    List.CheckpointList[75] = 'Revisit_3rdFloor';
    List.CheckpointList[76] = 'Revisit_RoomCrack';
    List.CheckpointList[77] = 'Revisit_ToChapel';
    List.CheckpointList[78] = 'Revisit_PriestDead';
    List.CheckpointList[79] = 'Revisit_Soldier3';
    List.CheckpointList[80] = 'Revisit_ToLab';
    List.CheckpointList[81] = 'Lab_Start';
    List.CheckpointList[82] = 'Lab_PremierAirlock';
    List.CheckpointList[83] = 'Lab_SwarmIntro';
    List.CheckpointList[84] = 'Lab_SwarmIntro2';
    List.CheckpointList[85] = 'Lab_Soldierdead';
    List.CheckpointList[86] = 'Lab_SpeachDone';
    List.CheckpointList[87] = 'Lab_SwarmCafeteria';
    List.CheckpointList[88] = 'Lab_EBlock';
    List.CheckpointList[89] = 'Lab_ToBilly';
    List.CheckpointList[90] = 'Lab_BigRoom';
    List.CheckpointList[91] = 'Lab_BigRoomDone';
    List.CheckpointList[92] = 'Lab_BigTower';
    List.CheckpointList[93] = 'Lab_BigTowerStairs';
    List.CheckpointList[94] = 'Lab_BigTowerMid';
    List.CheckpointList[95] = 'Lab_BigTowerDone';
    List2.GameType = OGT_Whistleblower;
    List2.CheckpointList[0] = 'DLC_Start';
    List2.CheckpointList[1] = 'DLC_Lab_Start';
    List2.CheckpointList[2] = 'Lab_AfterExperiment';
    List2.CheckpointList[3] = 'Hospital_Start';
    List2.CheckpointList[4] = 'Hospital_Free';
    List2.CheckpointList[5] = 'Hospital_1stFloor_ChaseStart';
    List2.CheckpointList[6] = 'Hospital_1stFloor_ChaseEnd';
    List2.CheckpointList[7] = 'Hospital_1stFloor_dropairvent';
    List2.CheckpointList[8] = 'Hospital_1stFloor_SAS';
    List2.CheckpointList[9] = 'Hospital_1stFloor_Lobby';
    List2.CheckpointList[10] = 'Hospital_1stFloor_NeedHandCuff';
    List2.CheckpointList[11] = 'Hospital_1stFloor_GotKey';
    List2.CheckpointList[12] = 'Hospital_1stFloor_Chase';
    List2.CheckpointList[13] = 'Hospital_1stFloor_Crema';
    List2.CheckpointList[14] = 'Hospital_1stFloor_Bake';
    List2.CheckpointList[15] = 'Hospital_1stFloor_Crema2';
    List2.CheckpointList[16] = 'Hospital_2ndFloor_Crema';
    List2.CheckpointList[17] = 'Hospital_2ndFloor_Canibalrun';
    List2.CheckpointList[18] = 'Hospital_2ndFloor_Canibalgone';
    List2.CheckpointList[19] = 'Hospital_2ndFloor_ExitIsLocked';
    List2.CheckpointList[20] = 'Hospital_2ndFloor_RoomsCorridor';
    List2.CheckpointList[21] = 'Hospital_2ndFloor_ToLab';
    List2.CheckpointList[22] = 'Hospital_2ndFloor_Start_Lab_2nd';
    List2.CheckpointList[23] = 'Hospital_2ndFloor_GazOff';
    List2.CheckpointList[24] = 'Hospital_2ndFloor_Labdone';
    List2.CheckpointList[25] = 'Hospital_2ndFloor_Exit';
    List2.CheckpointList[26] = 'Courtyard1_Start';
    List2.CheckpointList[27] = 'Courtyard1_RecreationArea';
    List2.CheckpointList[28] = 'Courtyard1_DupontIntro';
    List2.CheckpointList[29] = 'Courtyard1_Basketball';
    List2.CheckpointList[30] = 'Courtyard1_SecurityTower';
    List2.CheckpointList[31] = 'PrisonRevisit_Start';
    List2.CheckpointList[32] = 'PrisonRevisit_Radio';
    List2.CheckpointList[33] = 'PrisonRevisit_Priest';
    List2.CheckpointList[34] = 'PrisonRevisit_Tochase';
    List2.CheckpointList[35] = 'PrisonRevisit_Chase';
    List2.CheckpointList[36] = 'Courtyard2_Start';
    List2.CheckpointList[37] = 'Courtyard2_FrontBuilding2';
    List2.CheckpointList[38] = 'Courtyard2_ElectricityOff';
    List2.CheckpointList[39] = 'Courtyard2_ElectricityOff_2';
    List2.CheckpointList[40] = 'Courtyard2_ToWaterTower';
    List2.CheckpointList[41] = 'Courtyard2_WaterTower';
    List2.CheckpointList[42] = 'Courtyard2_TopWaterTower';
    List2.CheckpointList[43] = 'Building2_Start';
    List2.CheckpointList[44] = 'Building2_Attic_Mid';
    List2.CheckpointList[45] = 'Building2_Attic_Denis';
    List2.CheckpointList[46] = 'Building2_Floor3_1';
    List2.CheckpointList[47] = 'Building2_Floor3_2';
    List2.CheckpointList[48] = 'Building2_Floor3_3';
    List2.CheckpointList[49] = 'Building2_Floor3_4';
    List2.CheckpointList[50] = 'Building2_Elevator';
    List2.CheckpointList[51] = 'Building2_Post_Elevator';
    List2.CheckpointList[52] = 'Building2_Torture';
    List2.CheckpointList[53] = 'Building2_TortureDone';
    List2.CheckpointList[54] = 'Building2_Garden';
    List2.CheckpointList[55] = 'Building2_Floor1_1';
    List2.CheckpointList[56] = 'Building2_Floor1_2';
    List2.CheckpointList[57] = 'Building2_Floor1_3';
    List2.CheckpointList[58] = 'Building2_Floor1_4';
    List2.CheckpointList[59] = 'Building2_Floor1_5';
    List2.CheckpointList[60] = 'Building2_Floor1_5b';
    List2.CheckpointList[61] = 'Building2_Floor1_6';
    List2.CheckpointList[62] = 'MaleRevisit_Start';
    List2.CheckpointList[63] = 'AdminBlock_Start';

    Foreach AllActors(Class'OLCheckpointList', FullList) {
       // FullList.GameType = FullList.Default.GameType;
        Foreach FullList.CheckpointList(CPName) {
            if(CPName == Name(Checkpoint)) {
                ConsoleCommand("Streammap All_Checkpoints");
                List.GameType = OGT_Outlast;
                List2.GameType = OGT_Whistleblower;
                Foreach AllActors(Class'OLEnemyPawn', Enemy) {
                    Enemy.Destroy();
                }
                if(bDebugFullyGhost) {
                    ToggleGhost();
                }
                PickerHero(Pawn).RespawnHero();
                StartNewGameAtCheckpoint(Checkpoint, Save);
                List.Destroy();
                List2.Destroy();
                return;
            }
        }
    }
    SendMsg("Wrong Checkpoint Name!");
   /* if(CGame.IsPlayingDLC()) {
        List.Destroy();
        List2.Destroy();
    }
    else {
        List2.Destroy();
        List.GameType = OGT_Outlast;
    }*/
    List.Destroy();
    List2.Destroy();
}

Exec Function prs(String CP) {
     StartNewGameAtCheckpoint(CP, false);
}

Exec Function FinishGame(String Game="Both") {
    Switch(Game) {
        case "Main":
            ProfileSettings.SetProfileSettingValueId(67, 0);
            ProfileSettings.SetProfileSettingValueId(65, 1);
            break;
        case "DLC":
            ProfileSettings.SetProfileSettingValueId(67, 1);
            ProfileSettings.SetProfileSettingValueId(65, 0);
            break;
        case "Both":
            ProfileSettings.SetProfileSettingValueId(65, 1);
            ProfileSettings.SetProfileSettingValueId(67, 1);
            break;
        case "UnBoth":
            ProfileSettings.SetProfileSettingValueId(65, 0);
            ProfileSettings.SetProfileSettingValueId(67, 0);
        Default:
            SendMsg("Wrong Game Name!");
            return;
            break;
    }
    Super.ClientSaveAllPlayerData();
}

Exec Function DmgSelf(Float Damage) {
    if(!PickerHero(Pawn).bGodMode && !PickerHero(Pawn).bNoclip) {
        PickerHero(Pawn).TakeDamage(Int(Damage), none, PickerHero(Pawn).Location, Vect(0,0,0), none);
    }
    else {
        SendMsg("Unavailable in GodMode!");
    }
}

Exec Function ChangePlayerHealth(Int NewHealth, Int HealthMax=100) {
    PickerHero(Pawn).Health = NewHealth;
    PickerHero(Pawn).HealthMax = HealthMax;
    PickerHero(Pawn).PreciseHealth = Float(NewHealth);
}

Exec Function ChangeGameType(OutlastGameType NewType, Bool NoReload=false) {
    local OLCheckpointList List;

    Foreach AllActors(Class'OLCheckpointList', List) {
        Switch(NewType) {
            case OGT_Outlast:
                SendMsg("Game Type like Miles");
                break;
            case OGT_Whistleblower:
                SendMsg("Game Type like Waylon");
                break;
            Default:
                return;
                break;
        }
        List.GameType = NewType;
        if(!NoReload) {
            Reload();
        }
    }
}

Exec Function SetGravity(Float NewGravity) {
    WorldInfo.WorldGravityZ = NewGravity;
}

Exec Function ChangeFrameLock(Int FPS=62) {
    local OLEngine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Engine.MaxSmoothedFramerate = FPS;
}

Function PlayerDied() {
    ++NumDeathsSinceLastCheckpoint;
    InventoryManager.ClearGameplayItems();
    InventoryManager.ClearUnsavedBatteries();
    TogglePickerMenu(false);
    CurrentObjective = 'None';
    if(bDefaultPlayer) {
        PickerHero(Pawn).Mesh.SetSkeletalMesh(Current_SkeletalMesh);
    }
    PendingRecordingMarker = none;
    if(AllLoadedState) {
        ToggleLoadLoc();
    }
    if(InsanePlusState) {
        LSMDamage = true;
        InsanePlusStamina = 100;
    }
    if(ChrisState) {
        ChrisState = false;
    }
}

Exec Function MadeLight(Float Bright=0.7, Float Radius=1024, Byte R=255, Byte G=255, Byte B=255, Byte A=255, Bool Shadows=true) {
    local PickerPointLight L;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewPoint(C, Rot);
    L = Spawn(Class'PickerPointLight', Self,, C);
    L.OnTurn(true);
    L.SetBrightness(Bright);
    L.SetColor(R,G,B,A);
    L.SetRadius(Radius);
    L.SetCastDynamicShadows(Shadows);
    `log("[Picker] Made a PointLight!");
}

Exec Function MadeSpot(Float Bright=0.7, Float Radius=1024, Byte R=255, Byte G=255, Byte B=255, Byte A=125, Bool Shadows=true) {
    local PickerSpotLight L;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewPoint(C,Rot);
    L = Spawn(Class'PickerSpotLight', Self,, C);
    L.OnTurn(true);
    L.SetBrightness(Bright);
    L.SetColor(R,G,B,A);
    L.SetRadius(Radius);
    L.SetCastDynamicShadows(Shadows);
    `log("[Picker] Made a SpotLight!");
}

Exec Function MadeDom(Float Bright=0.7, Byte R=255, Byte G=255, Byte B=255, Byte A=125, Bool Shadows=true) {
    local PickerDominantLight L;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewPoint(C,Rot);
    L = Spawn(Class'PickerDominantLight', Self,, C);
    L.OnTurn(true);
    L.SetBrightness(Bright);
    L.SetColor(R,G,B,A);
    L.SetCastDynamicShadows(Shadows);
    `log("[Picker] Made a DominantDirectionalLight!");
}

Exec Function MadeSky(Float Bright=0.7, Byte R=255, Byte G=255, Byte B=255, Byte A=125, Bool Shadows=true) {
    local PickerSkyLight L;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewPoint(C,Rot);
    L = Spawn(Class'PickerSkyLight', Self,, C);
    L.OnTurn(true);
    L.SetBrightness(Bright);
    L.SetColor(R,G,B,A);
    L.SetCastDynamicShadows(Shadows);
    `log("[Picker] Made a SkyLight!");
}

Exec Function RemoveAllPickerLights() {
    local PickerPointLight L;
    local PickerSpotLight S;
    local PickerDominantLight D;
    local PickerSkyLight SS;

    L.OnTurn(false);
    S.OnTurn(false);
    D.OnTurn(false);
    Foreach AllActors(Class'PickerPointLight', L) {
        L.Destroy();
    }
    Foreach AllActors(Class'PickerSpotLight', S) {
        S.Destroy();
    }
    Foreach AllActors(Class'PickerDominantLight', D) {
        D.Destroy();
    }
    Foreach AllActors(Class'PickerDominantLight', D) {
        SS.Destroy();
    }
    SendMsg("All Picker Lights are Deleted!");
}

Exec Function MadeFollowLight(Float Bright=0.7, Float Radius=1024, Byte R=255, Byte G=255, Byte B=255, Byte A=125, Bool Shadows=true) {
    bFollowLight = !bFollowLight;
    if(bFollowLight) {
        PickerFollowLight = Spawn(Class'PickerPointLight', Self,, vect(0,0,0));
        //PickerFollowLight.OnTurn(true);
        PickerFollowLight.SetBrightness(Bright);
        PickerFollowLight.SetColor(R,G,B,A);
        PickerFollowLight.SetRadius(Radius);
        PickerFollowLight.SetCastDynamicShadows(Shadows);
        WorldInfo.Game.SetTimer(0.001, true, 'MoveFollowLight', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('MoveFollowLight', Self);
        PickerFollowLight.Destroy();
    }
    
}

Function MoveFollowLight() {
    local Vector C, B;
    local Rotator Rot;
    local OLFlashLight FF;

    GetPlayerViewPoint(C, Rot);
    PickerFollowLight.SetLocation(C);
    /*Foreach AllActors(Class'OLFlashLight', FF) {
        FF.SetLocation(PickerHero(Pawn).Location + vect(40,20,110));
        FF.SetRotation(Rot + rot(32768,0,32768));
    }*/
}

Exec Function TogglePickerMenu(Bool Show) {
    local Float AudioVolume;

    Switch(Show) {
        case true:
            PickerHud(HUD).ToggleHUD = true;
            if(!PickerHud(HUD).DisableMenuMusic) {
                ProfileSettings.GetProfileSettingValueFloat(57, AudioVolume);
                MenuMusicComponent = CreateAudioComponent(MenuMusic);
                MenuMusicComponent.Play();
                MenuMusicComponent.bIsUISound = true;
                MenuMusicComponent.VolumeMultiplier = 1;
            }
            DisableInput(true);
            DebugFreeCamSpeed = 0;
            break;
        case false:
            PickerHud(HUD).ToggleHUD = false;
            DisableInput(false);
            PlayerInput.ResetInput();
            MenuMusicComponent.Stop();
            DebugFreeCamSpeed = fDebugSpeed;
            break;
    }
}

Exec Function TeleportPlayer(Float X=0, Float Y=0, Float Z=0) {
    local Vector C;

    C.X=X;
    C.Y=Y;
    C.Z=Z;
    PickerHero(Pawn).SetLocation(C);
}

Exec Function ToggleGodMode() {
    local OLEnemyPawn Bot;

    if(RandomizerState) {
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    PickerHero(Pawn).bGodMode = !PickerHero(Pawn).bGodMode;
    if(PickerHero(Pawn).bGodMode) {
        SendMsg("GodMode ON!", 1.5);
        WorldInfo.Game.SetTimer(0.001, true, 'DisableKillGrab', Self);
        PickerHero(Pawn).HealthRegenDelay = 0;
        PickerHero(Pawn).HealthRegenRate = MaxInt;
    }
    else {
        SendMsg("GodMode OFF!", 1.5);
        WorldInfo.Game.ClearTimer('DisableKillGrab', Self);
        Foreach AllActors(Class'OLEnemyPawn', Bot) {
            Bot.UpdateDifficultyBasedValues();
        }
        PickerHero(Pawn).HealthRegenDelay = PickerHero(Pawn).Default.HealthRegenDelay;
        PickerHero(Pawn).HealthRegenRate = PickerHero(Pawn).Default.HealthRegenRate;
    }
}

Function DisableKillGrab() {
    local OLEnemyPawn Bot;

    Foreach AllActors(Class'OLEnemyPawn', Bot)  {
        Bot.AttackGrabChance = 0;
        Bot.AttackNormalDamage = 0;
        Bot.AttackThrowDamage = 0;
        Bot.AttackNormalKnockbackPower = 0;
        Bot.AttackPushKnockbackPower = 0;
        Bot.VaultKnockbackPower = 0;
    }
}

Exec Function ToggleLoadLoc() {
    AllLoadedState=!AllLoadedState;
    LoadLoc(AllLoadedState);
}
Function LoadLoc(Bool Load) {
    local PickerController PC;
    local LevelStreamingVolume Volume;
    local Int I;

    Foreach AllActors(Class'LevelStreamingVolume', Volume) {Volume.bDisabled=Load;}
    if(Load) {
        Foreach WorldInfo.AllControllers(Class'PickerController', PC) {
            I = 0;
            J0xF6:
                if(I < WorldInfo.StreamingLevels.Length) {
                    ClientUpdateLevelStreamingStatus(WorldInfo.StreamingLevels[I].PackageName, true, true, false);
                    ++I;
                    goto J0xF6;
                }
        }
    }
}

Exec Function ChangeDoorMaterial(String Material) {
    local OLDoor Door;
    local EDoorMaterial M;

    Switch(Material) {
        case "Wood":
            M=OLDM_Wood;
            break;
        case "Metal":
            M=OLDM_Metal;
            break;
        case "SecurityDoor":
            M=OLDM_SecurityDoor;
            break;
        case "BigPrisonDoor":
            M=OLDM_BigPrisonDoor;
            break;
        case "BigWoodenDoor":
            M=OLDM_BigWoodenDoor;
            break;
        Default:
            SendMsg("Wrong Door Material!");
            return;
            break;
    }
    Foreach AllActors(Class'OLDoor', Door) {
        Door.DoorMaterial = M;
    }
}

Exec Function ChangeDoorMeshType(String MeshType, Name CustomSndMat='Default') {
    local OLDoor Door;
    local EDoorMaterial SndMat;
    local StaticMesh MainMeshL, MainMeshR;
    local SkeletalMesh BreakMeshL, BreakMeshR;
    local MaterialInstanceConstant MainMeshMat, MainMeshMat2;

    //SendMsg(MeshType @ String(CustomSndMat));

    Switch(MeshType) {
        case "Undefined":
            MainMeshL = StaticMesh'door.Standard.DOOR_L';
            MainMeshR = StaticMesh'door.Standard.DOOR_R';
            break;
        case "Wooden":
            MainMeshL = StaticMesh'door.Standard.DOOR_L';
            MainMeshR = StaticMesh'door.Standard.DOOR_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_new_mat';
            break;
        case "WoodenOld":
            MainMeshL = StaticMesh'door.Standard.DOOR_L';
            MainMeshR = StaticMesh'door.Standard.DOOR_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_mat';
            break;
        case "WoodenWindow":
            MainMeshL = StaticMesh'door.Standard.Door_windows_L';
            MainMeshR = StaticMesh'door.Standard.Door_windows_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_new_mat';
            break;
        case "WoodenWindowSmall":
            MainMeshL = StaticMesh'door.Standard.MaleWardDoor_L';
            MainMeshR = StaticMesh'door.Standard.MaleWardDoor_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_new_mat';
            break;
        case "WoodenWindowOld":
            MainMeshL = StaticMesh'door.Standard.Door_windows_L';
            MainMeshR = StaticMesh'door.Standard.Door_windows_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_mat';
            break;
        case "WoodenWindowOldSmall":
            MainMeshL = StaticMesh'door.Standard.MaleWardDoor_L';
            MainMeshR = StaticMesh'door.Standard.MaleWardDoor_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.wooden_door_mat';
            break;
        case "Metal":
            MainMeshL = StaticMesh'door.Standard.DOOR_L';
            MainMeshR = StaticMesh'door.Standard.DOOR_R';
            MainMeshMat = MaterialInstanceConstant'door.Standard.Metal_door_mat';
            break;
        case "MetalWindow":
            MainMeshL = StaticMesh'door.Standard.Door_windows_L';
            MainMeshR = StaticMesh'door.Standard.Door_windows_R';
            break;
        case "MetalWindowSmall":
            MainMeshL = StaticMesh'door.Standard.MaleWardDoor_L';
            MainMeshR = StaticMesh'door.Standard.MaleWardDoor_R';
            break;
        case "Enforced":
            MainMeshL = StaticMesh'door.Door_Enforced_L';
            MainMeshR = StaticMesh'door.Door_Enforced_R';
            break;
        case "Grid":
            MainMeshL = StaticMesh'door.Grid.Door_grid_L';
            MainMeshR = StaticMesh'door.Grid.Door_grid_R';
            break;
        case "Prison":
            MainMeshL = StaticMesh'door.Standard.PrisonDoor_L-01';
            MainMeshR = StaticMesh'door.Standard.PrisonDoor_R-01';
            break;
        case "Entrance":
            MainMeshL = StaticMesh'door.Standard.DoorWood02_L';
            MainMeshR = StaticMesh'door.Standard.DoorWood02_R';
            break;
        case "Bathroom":
            MainMeshL = StaticMesh'Bathroom.toilet_cabine.toilet_cabine_Door_L';
            MainMeshR = StaticMesh'Bathroom.toilet_cabine.toilet_cabine_Door_R';
            break;
        case "IsolatedCell":
            MainMeshL = StaticMesh'Mod_Padded.PaddedDoor-01';
            MainMeshR = StaticMesh'Mod_Padded.PaddedDoor-01';
            break;
        case "Locker":
            MainMeshL = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshR = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshMat = MaterialInstanceConstant'Warehouse.Locker.Locker_mat';
            break;
        case "LockerRusted":
            MainMeshL = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshR = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshMat = MaterialInstanceConstant'Warehouse.Locker.LockerRustDoor01_INST';
            break;
        case "LockerBeige":
            MainMeshL = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshR = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshMat = MaterialInstanceConstant'Warehouse.Locker.LockerBeige_mat';
            break;
        case "LockerGreen":
            MainMeshL = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshR = StaticMesh'Warehouse.Locker.Large_Locker_door';
            MainMeshMat = MaterialInstanceConstant'Warehouse.Locker.Locker_mat';
            break;
        case "Glass":
            MainMeshL = StaticMesh'door.Grid.Door_grid_L';
            MainMeshR = StaticMesh'door.Grid.Door_grid_R';
            MainMeshMat2 = MaterialInstanceConstant'Generic_mat.Glass.GlassDoorFrame-01_INST';
            break;
        case "Fence":
            MainMeshL = StaticMesh'Door_DLC.Door_Fence01_L';
            MainMeshR = StaticMesh'Door_DLC.Door_Fence01_R';
            break;
        case "ForceGate":
            MainMeshL = StaticMesh'Asylum_Exterior-LD.door.Gate.forge_gate';
            MainMeshR = StaticMesh'Asylum_Exterior-LD.door.Gate.forge_gate';
            MainMeshMat = MaterialInstanceConstant'Asylum_Exterior-LD.door.Gate.Forge_gate_mat';
            break;
        case "Gate":
            MainMeshL = StaticMesh'Asylum_Exterior-LD.door.Gate.GateDoor-01_R';
            MainMeshR = StaticMesh'Asylum_Exterior-LD.door.Gate.GateDoor-01_R';
            MainMeshMat = MaterialInstanceConstant'Asylum_Exterior-LD.door.Gate.DoorGateMetal-01_INST';
            break;
        case "LockerHole":
            MainMeshL = StaticMesh'Door_DLC.Large_Locker_Door_Hole';
            MainMeshR = StaticMesh'Door_DLC.Large_Locker_Door_Hole';
            break;
        Default:
            SendMsg("Wrong Door Mesh Type!");
            return;
            break;

    }
    Foreach AllActors(Class'OLDoor', Door) {
        if(Door.bReverseDirection) {
            Door.Mesh.SetStaticMesh(MainMeshR);
        }
        else {
            Door.Mesh.SetStaticMesh(MainMeshL);
        }
        Door.Mesh.SetMaterial(0, MainMeshMat);
        Door.Mesh.SetMaterial(1, MainMeshMat2);
        Switch(CustomSndMat) {
            case 'Wood':
                SndMat = OLDM_Wood;
                break;
            case 'Metal':
                SndMat = OLDM_Metal;
                break;
            case 'SecurityDoor':
                SndMat = OLDM_SecurityDoor;
                break;
            case 'BigPrisonDoor':
                SndMat = OLDM_BigPrisonDoor;
                break;
            case 'BigWoodenDoor':
                SndMat = OLDM_BigWoodenDoor;
                break;
            Default:
                if(CustomSndMat != 'Default') {
                    SendMsg("Wrong Door Sound Material!");
                }
                return;
                break;
            }
        Door.DoorMaterial = SndMat;
    }
}

Exec Function TSVCommand() {
    PickerHud(HUD).TSVBool = !PickerHud(HUD).TSVBool;
    if(PickerHud(HUD).TSVBool) {
        SendMsg("Streaming Volumes are Freezed!");
    }
    else {
        SendMsg("Streaming Volumes are Unfreezed!");
    }
    ConsoleCommand("TOGGLESTREAMINGVOLUMES");
}

Exec Function ChangeFOV(Float DefFOV=90, Float RunFOV=100, Float CameraFOV=83) {
    local PickerHero Hero;

    Hero = PickerHero(Pawn);
    Hero.DefaultFOV = DefFOV;
    Hero.RunningFOV = RunFOV;
    Hero.CamcorderMaxFOV = CameraFOV;
    Hero.CamcorderNVMaxFOV = CameraFOV;
}

Exec Function ToggleDisAI(Bool Force=true) {
    bDisAI = !bDisAI;
    WorldInfo.Game.ClearTimer('DisableAI', Self);
    WorldInfo.Game.ClearTimer('EnableAI', Self);
    if(Force) {
        if(bDisAI) {
            WorldInfo.Game.SetTimer(0.0001, true, 'DisableAI', Self);
            SendMsg("Force: AI is Disabled!");
        }
        else {
            WorldInfo.Game.SetTimer(0.0001, true, 'EnableAI', Self);
            SendMsg("Force: AI is Enabled!");
        }
    }
    else {
        if(bDisAI) {
            DisableAI();
            SendMsg("AI is Disabled!");
        }
        else {
            EnableAI();
            SendMsg("AI is Enabled!");
        }
    }
}

Function EnableAI() {
    local OLBot Bot;

    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Bot.EnemyPawn.Modifiers.bShouldAttack = true;
        Bot.SightComponent.bIgnoreTarget = false;
        Bot.Recalculate();
    }
}

Function DisableAI() {
    local OLBot Bot;

    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Bot.EnemyPawn.Modifiers.bShouldAttack = false;
        Bot.VisualDisturbance.TimeSinceUpdate =- 1.0;
        Bot.AudioDisturbance.TimeSinceUpdate =- 1.0;
        Bot.SightComponent.bIgnoreTarget = true;
        Bot.Recalculate();
    }
}

Exec Function LMFree(Bool bLMFree=false) {
    local Int Index;

    if(bLMFree) {
        While(Index <= 15) {
            PickerHero(Pawn).LocomotionModeParams[Index].GP.CameraMode = CRM_UserControlled;
            ++Index;
        }
    }
    else {
        While(Index <= 15) {
            PickerHero(Pawn).LocomotionModeParams[Index].GP.CameraMode = PickerHero(Pawn).Default.LocomotionModeParams[Index].GP.CameraMode;
            ++Index;
        }
    }
}

Exec Function SMFree(Bool bSMFree=false) {
    local Int Index;

    if(bSMFree) {
        While(Index <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].GP.CameraMode = CRM_UserControlled;
            ++Index;
        }
    }
    else {
        While(Index <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].GP.CameraMode = PickerHero(Pawn).Default.SpecialMoveParams[Index].GP.CameraMode;
            ++Index;
        }
    }
}

Exec Function AnimFree() {
    bAnimFree = !bAnimFree;
    LMFree(bAnimFree);
    SMFree(bAnimFree);
}

Exec Function KillFade(Bool D, Float Time) {
    ClientSetCameraFade(D,,,Time);
}

Exec Function TrueAnim() {
    local Int Index, Index2;

    While(Index <= 70) {
            //PickerHero(Pawn).SpecialMoveParams[Index].GP.DisableCollisions = true;
            if(Index != 20 && Index != 21 && Index != 22 && Index != 24 && Index != 26) {
                PickerHero(Pawn).SpecialMoveParams[Index].GP.CollisionRadius = PickerHero(Pawn).CylinderComponent.Default.CollisionRadius;
            }
            if(Index == 5) {
                PickerHero(Pawn).SpecialMoveParams[Index].GP.CollisionHeight = 1;
            }
            ++Index;
        }
        PickerHero(Pawn).LocomotionModeParams[7].GP.CollisionRadius = PickerHero(Pawn).CylinderComponent.Default.CollisionRadius;
        PickerHero(Pawn).LocomotionModeParams[7].GP.DisableCollisions = true;
}

Exec Function ToggleDoorDelete(Bool Force=false, Bool Reset=false) {
    DoorDelState = !DoorDelState;
    WorldInfo.Game.ClearTimer('DeleteDoors', Self);
    if(DoorDelState) {
        if(Force) {
            SendMsg("Force: All Doors are Deleted!");
            WorldInfo.Game.SetTimer(0.001, true, 'DeleteDoors', Self);
        }
        else {
            DoorDelState = false;
            SendMsg("All Doors are Deleted!");
            DeleteDoors();
        }
    }
    else {
        if(Reset) {
            DeleteDoors(true);
        }
        SendMsg("Stop: All Doors are Deleted!");
    }
}

Exec Function DeleteDoors(Bool Reset=false) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        if(Reset) {
            Door.SetHidden(false);
            Door.SetDrawScale(1);
            Door.SetCollision(true, true, true);
        }
        else {
            Door.SetHidden(true);
            Door.SetDrawScale(0);
            Door.SetCollision(false, false, false);
        }
    }
}

Exec Function ToggleDoorType(Bool Force=false) {
    DoorTypeState = !DoorTypeState;
    WorldInfo.Game.ClearTimer('NormalDoor', Self);
    WorldInfo.Game.ClearTimer('LockerDoor', Self);
    if(Force) {
        if(DoorTypeState) {
            SendMsg("Force: All Doors are Locker!");
            WorldInfo.Game.SetTimer(0.0001, true, 'LockerDoor', Self);
        }
        else {
            SendMsg("Force: All Doors are Normal!");
            WorldInfo.Game.SetTimer(0.0001, true, 'NormalDoor', Self);
        }
    }
    else {
        if(DoorTypeState) {
            SendMsg("All Doors are Locker!");
            LockerDoor();
        }
        else {
            SendMsg("All Doors are Normal!");
            NormalDoor();
        }
    }
}

Exec Function LockerDoor() {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.DoorType = DT_Locker;
    }
}

Exec Function NormalDoor() {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.DoorType = DT_Normal;
    }
}

Exec Function ToggleDoorState(Bool Force=PickerHud(HUD).bForceFuncs) {
    DoorLockState = !DoorLockState;
    WorldInfo.Game.ClearTimer('LockDoor', Self);
    WorldInfo.Game.ClearTimer('UnlockDoor', Self);
    if(Force) {
        if(DoorLockState) {
            SendMsg("Force: All Doors are Unlocked!");
            WorldInfo.Game.SetTimer(0.0001, true, 'UnlockDoor', Self);
        }
        else {
            SendMsg("Force: All Doors are Locked!");
            WorldInfo.Game.SetTimer(0.0001, true, 'LockDoor', Self);
        }
    }
    else {
        if(DoorLockState) {
            SendMsg("All Doors are Unlocked!");
            UnlockDoor();
        }
        else {
            SendMsg("All Doors are Locked!");
            LockDoor();
        }
    }
}

Exec Function LockDoor() {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.bLocked = true;
    }
}

Exec Function UnlockDoor() {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.bLocked = false;
        Door.bBlocked = false;
    }
}

Exec Function Rand100PlayerPos() {
    TeleportPlayer(RandRange(-100, 100), RandRange(-100, 100), RandRange(-100, 100));
}

Exec Function BaseSelf() {
    local Actor A;
    local Vector C;
    local Float G, X, O;

    C = PickerHero(Pawn).Location;
    Foreach AllActors(Class'Actor', A) {
        if(A != PickerHero(Pawn)) {
            G = RandRange(-100, 100);
            X = RandRange(-100, 100);
            O = RandRange(-100, 100);
            C.X += G; C.Y += X; C.Z += O;
            A.SetLocation(C); A.SetBase(Self, C);
        }
    }
}

Exec Function BasePlayer(Bool StaticMeshes=true) {
    local Actor A;
    local PickerHero Hero;

    if(StaticMeshes) {
        ConsoleCommand("Set StaticMeshActor bStatic false");
        ConsoleCommand("Set StaticMeshCollectionActor bStatic false");
        ConsoleCommand("Set StaticMeshActor bMovable true");
        ConsoleCommand("Set StaticMeshCollectionActor bMovable true");
    }
    Foreach AllActors(Class'PickerHero', Hero) {
        Foreach AllActors(Class'Actor', A) {
            A.SetBase(Hero/*, Hero.Location*/);
        }
        return;
    }
}

Exec Function Limp() {
    if(PickerHero(Pawn).bLimping) {
        PickerHero(Pawn).bLimping = false;
    }
    else {
        PickerHero(Pawn).bLimping = true;
    }
}

Exec Function SpawnBF(Bool bLeftFoot=false, Float Alpha=1, optional Bool CustomStep, optional MaterialInstanceConstant L, optional MaterialInstanceConstant R) {
    PickerHero(Pawn).SpawnBloodFootStepDecal(bLeftFoot, Alpha, CustomStep, L, R);
}

Exec Function Hobble(Float Intensity=0) {
    if(PickerHero(Pawn).bHobbling) {
        PickerHero(Pawn).bHobbling = false;
    }
    else {
        PickerHero(Pawn).bHobbling = true;
        PickerHero(Pawn).TargetHobblingIntensity = Intensity;
    }
}

Exec Function SpecialMoveEnemy(ESpecialMoveType SpecialMove) {
    local OLBot Bot;

    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Bot.EnemyPawn.StartSpecialMove(SpecialMove);
    }
}

Exec Function SpecialMovePlayer(ESpecialMoveType SpecialMove) {
    PickerHero(Pawn).StartSpecialMove(SpecialMove);
}

Exec Function CameraBone(Name BoneName) {
    PickerHero(Pawn).Camera.CameraBoneName = BoneName;
}

Exec Function Darkness() {
    local OLDarknessVolume Darks;

    bDark=!bDark;
    Foreach AllActors(Class'OLDarknessVolume', Darks) {
        Darks.bDark=!bDark;
    }
}

Exec Function CountCSA(Int Count=1) {
    local OLCSA CSA;

    Foreach AllActors(Class'OLCSA', CSA) {
        CSA.MaxTriggerCount=Count;
    }
}

Exec Function PlayerAnimRate(Float Rate=1) {
    PickerHero(Pawn).Mesh.GlobalAnimRateScale=Rate;
    fPlayerAnimRate = Rate;
}

Exec Function EnemyAnimRate(Float Rate=1) {
    local OLEnemyPawn Enemy;

    Foreach WorldInfo.AllPawns(Class'OLEnemyPawn', Enemy) {
        Enemy.Mesh.GlobalAnimRateScale=Rate;
        fEnemyAnimRate = Rate; 
    }
}

Exec Function ToggleKillEnemy(Bool Force=PickerHud(HUD).bForceFuncs) {
    if(RandomizerState) {
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    if(Force) {
        if(WorldInfo.Game.IsTimerActive('KillEnemy', Self)) {
            WorldInfo.Game.ClearTimer('KillEnemy', Self);
            SendMsg("Stop: All Enemies are Deleted");
        }
        else {
            WorldInfo.Game.SetTimer(0.01, true, 'KillEnemy', Self);
            SendMsg("Force: All Enemies are Deleted");
        }
    }
    else {
        WorldInfo.Game.ClearTimer('KillEnemy', Self);
        KillEnemy();
        SendMsg("All Enemies are Deleted!");
    }
}

Exec Function KillEnemy() {
    local OLEnemyPawn Enemy;

    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.Destroy();
    }
}

Exec Function ChangeBatteries(Int Increase=1) {
    if(CheatManager.bUnlimitedBatteries) {
        SendMsg("Unavailable with Unlimited Batteries!");
    }
    NumBatteries += Increase;
    if(Increase > 0) {
        PickerHero(Pawn).PlayAkEvent(AkEvent'Player_Sound.Pick_Up_Battery');
        SendMsg("Add Battery:" @ Increase @ "Total:" @ NumBatteries);
    }
    else if(Increase < 0) {
        SendMsg("Remove Battery:" @ Increase @ "Total:" @ NumBatteries);
    }
    else {
        SendMsg("Nothing Happened!");
    }
}

Exec Function ToggleFixedcam() {
    if(bDebugFullyGhost) {
        SendMsg("Unavailable in Ghost!");
        return;
    }
    else if(RandomizerState) { // Thanks OLHeroMefedron#6611
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    if(UsingFirstPersonCamera() || bDebugFreeCam) {
        ConsoleCommand("Camera Fixedcam");
        bDebugFixedCam = true;
    }
    else {
        ConsoleCommand("Camera Default");
        bDebugFixedCam = false;
    }
}

Exec Function ToggleFreecam() {
    if(bDebugFullyGhost) {
        SendMsg("Unavailable in Ghost!");
        return;
    }
    else if(bThirdPersonMode && bDebugFixedCam) {
        ConsoleCommand("Camera Freecam");
        bDebugFreeCam = true;
        return;
    }
    else if(bThirdPersonMode && !bDebugFixedCam && bDebugFreeCam) {
        ConsoleCommand("Camera Default");
        bDebugFreeCam = false;
        ToggleFixedcam();
        return;
    }
    else if(RandomizerState) {
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    if(UsingFirstPersonCamera() || bDebugFixedCam) {
        ConsoleCommand("Camera Freecam");
        bDebugFreeCam = true;
    }
    else {
        ConsoleCommand("Camera Default");
        bDebugFreeCam = false;
    }
}

Exec Function FreecamSpeed(Float Speed=0.0040) {
    fDebugSpeed = Speed;
    DebugFreeCamSpeed = Speed;
}

Exec Function FreecamFOV(Float FOV){
    local CameraActor CamActor;
    DebugFreeCamFOV = FOV;
    CamActor = CameraActor(ViewTarget);
    CamActor.FOVAngle = FOV;
}

Exec Function ToggleGrain() {
    bGrainDisabled = !bGrainDisabled;
    if(bGrainDisabled) {
        FXManager.CurrentUberPostEffect.GrainOpacity = 0;
    }
    else {
       FXManager.CurrentUberPostEffect.GrainOpacity = FXManager.CurrentUberPostEffect.Default.GrainOpacity;
    }
}

Exec Function Execute(Name Command='Prikol') {
    WorldInfo.Game.SetTimer(0.0001, false, Command, Self);
}

Exec Function ToggleAIDebug() {
    AIDebug=!AIDebug;
    if(AIDebug) {
        Super.ConsoleCommand("Showdebug OLAI");
    }
    else {
        Super.ConsoleCommand("Showdebug");
    }
}

Exec Function Reload() {
    local OLEngine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    PickerHero(Pawn).RespawnHero();
}

Exec Function PlayAkEvent(AkEvent Event) {
    PickerHero(Pawn).PlayAkEvent(Event);
}

Exec Function SetGameSpeed(Float Speed=1) {
    WorldInfo.Game.SetGameSpeed(Speed);
}

Exec Function ToggleNoclip() {
    if(bDebugFullyGhost) {
        SendMsg("Unavailable in Ghost!");
        return;
    }
    else if(bThirdPersonMode && !bDebugFixedCam && bDebugGhost) {
        bDebugGhost = false;
        PickerHero(Pawn).bNoclip = false;
        SendMsg("Noclip OFF!", 1.5);
        ToggleFixedcam();
        return;
    }
    else if(bThirdPersonMode && !bDebugFixedCam && !bDebugGhost) {
        SendMsg("Unavailable in ThirdPerson!");
        return;
    }
    else if(RandomizerState) {
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    bDebugGhost=!bDebugGhost;
    if(bDebugGhost) {
        PickerHero(Pawn).bNoclip = true;
        SendMsg("Noclip ON!", 1.5);
    }
    else {
        PickerHero(Pawn).bNoclip = false;
        SendMsg("Noclip OFF!", 1.5);
    }
}

Exec Function ToggleGhost() {
    if(PickerHero(Pawn).Health == 0) {
        SendMsg("Unavailable from Afterworld!");
        return;
    }
    else if(bThirdPersonMode && !bDebugFixedCam && bDebugFullyGhost) {
        bDebugFullyGhost = false;
        PickerHero(Pawn).bNoclip = false;
        bDebugGhost = false;
        ConsoleCommand("Camera Default");
        PickerHero(Pawn).ResetAfterTeleport();
        SendMsg("Ghost OFF!", 1.5);
        CheatManager.GhostPawn(bDebugFullyGhost);
        ToggleFixedcam();
        return;
    }
    else if(RandomizerState) {
        Reload();
        return;
    }
    else if(InsanePlusState) {
        DS(9999);
        return;
    }
    bDebugFullyGhost=!bDebugFullyGhost;
    if(bDebugFullyGhost) {
        PickerHero(Pawn).bNoclip = true;
        bDebugGhost = true;
        ConsoleCommand("Camera Freecam");
        SendMsg("Ghost ON!", 1.5);
    }
    else {
        PickerHero(Pawn).bNoclip = false;
        bDebugGhost = false;
        ConsoleCommand("Camera Default");
        PickerHero(Pawn).ResetAfterTeleport();
        SendMsg("Ghost OFF!", 1.5);
    }
    CheatManager.GhostPawn(bDebugFullyGhost);
}

Exec Function PlayPlayerAnim(Name Anim) {
    StopPlayerAnim();
    PickerHero(Pawn).FullBodyAnimSlot.PlayCustomAnim(Anim, 1);
    PickerHero(Pawn).LocomotionMode = LM_Cinematic;
    PickerHero(Pawn).SetPhysics(PHYS_Custom);
    WorldInfo.Game.SetTimer(PickerHero(Pawn).FullBodyAnimSlot.GetCustomAnimNodeSeq().AnimSeq.SequenceLength, false, 'StopPlayerAnim', Self);
}

Exec Function StopPlayerAnim() {
    PickerHero(Pawn).FullBodyAnimSlot.StopCustomAnim(0);
    PickerHero(Pawn).LocomotionMode = LM_Walk;
    PickerHero(Pawn).SetPhysics(PHYS_Walking);
}

Exec Function CPList() {
    CheatManager.CPList();
}

Exec Function GiveItem(String ItemName) {
    Switch(ItemName) {
        case "Keycard":
            break;
        case "SparkPlug":
            break;
        case "KeycardShower":
            break;
        case "ElevatorKey":
            break;
        case "ShedKeycard":
            break;
        case "Keystairs":
            break;
        case "Fuse1":
            break;
        case "Fuse2":
            break;
        case "Fuse3":
            break;
        case "KeycardRH":
            break;
        case "KeyToLab":
            break;
        case "Keycard_Lab":
            break;
        case "HandcuffKey":
            break;
        case "KeyMale":
            break;
        Default:
            SendMsg("Wrong Item Name!");
            return;
            break;
    }
    PlayAkEvent(AkEvent'Player_Sound.Pick_Up_Object');
    SendMsg("Added Item:" @ Localize("GameplayItems", ItemName, "OLGame"));
    CheatManager.GiveItem(ItemName);
}

Exec Function BadFPS(optional Float SlowDown) {
    CheatManager.BadFPS(SlowDown);
}

Exec Function ApplyCP(String Checkpoint) {
    CheatManager.ApplyCP(Checkpoint);
}

Exec Function DebugPause() {
    WorldInfo.Game.DebugPause();
}

Exec Function SaveGame(String FileName) {
    CheatManager.SaveGame(FileName);
}

Exec Function Summon(String ClassName) {
    local Class<Actor> NewClass;
    local Vector SpawnLoc;

    NewClass = Class<Actor>(DynamicLoadObject(ClassName, Class'Class'));
    if(NewClass != None) {
        if(PickerHero(Pawn) != None) {
            SpawnLoc = PickerHero(Pawn).Location;
        }
        else {
            SpawnLoc = Location;
        }
        Spawn(NewClass,,, (SpawnLoc + (Float(72) * Vector(Rotation))) + (Vect(0.0, 0.0, 1.0) * Float(15)));
    }
}

Exec Function SetLevelStreamingStatus(Name PackageName, Bool bShouldBeLoaded, Bool bShouldBeVisible) {
    local PlayerController PC;
    local Int I;

    if(PackageName != 'All') {
        Foreach AllActors(class'PlayerController', PC) {
            PC.ClientUpdateLevelStreamingStatus(PackageName, bShouldBeLoaded, bShouldBeVisible, false);            
        }        
    }
    else {
        Foreach AllActors(Class'PlayerController', PC) {
            I = 0;
            J0xF6:
            if(I < WorldInfo.StreamingLevels.Length) {
                PC.ClientUpdateLevelStreamingStatus(WorldInfo.StreamingLevels[I].PackageName, bShouldBeLoaded, bShouldBeVisible, false);
                ++ I;
                goto J0xF6;
            }            
        }        
    } 
}

Exec Function SaveAllCheckpoints() {
    local OLEngine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Engine.SaveAllCheckpoints();
}

Exec Function DeleteSaveFile(String Filename) {
    local OLEngine Engine;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Engine.DeleteSaveFile(Filename);
}

Exec Function LoadGame(String FileName) {
    CheatManager.LoadGame(FileName);
}

Exec Function ResetDoors() {
    CheatManager.ResetDoors();
}

Exec Function ResetPushs() {
    CheatManager.ResetPushables();
}

Exec Function ResetWorld() {
    CheatManager.ResetWorldState();
}

Exec Function SetLang(String LangCode) {
    CheatManager.SetLanguage(LangCode);
}

Exec Function ReloadWwise(Bool bDLC) {
    CheatManager.ReloadSoundBanks(bDLC);
}

Exec Function DumpGS() {
    CheatManager.DumpGS();
}

Exec Function SetGS(Name GSName) {
    CheatManager.ActivateGS(GSName);
}

Exec Function ResetGS() {
    CheatManager.ResetGS();
}

Exec Function ToggleUnlimitedBatteries() {
    CheatManager.bUnlimitedBatteries = !CheatManager.bUnlimitedBatteries;
    if(CheatManager.bUnlimitedBatteries) {
        WorldInfo.Game.SetTimer(0.001, true, 'UnlimitedBatteries', Self);
        SendMsg("Batteries are unlimited!");
    }
    else {
        WorldInfo.Game.ClearTimer('UnlimitedBatteries', Self);
        PickerHero(Pawn).BatteryDuration = 150;
        PickerHero(Pawn).CurrentBatterySetEnergy = 1;
        UpdateDifficultyBasedValues();
        SendMsg("Batteries are limited!");
    }
}

Function UnlimitedBatteries() {
    PickerHero(Pawn).BatteryDuration = 99999999;
    PickerHero(Pawn).CurrentBatterySetEnergy = 99999999;
    NumBatteries = 99999999;
    MaxNumBatteries = 99999999;
}

Exec Function SingleFrame(Bool Cancel=false) {
    if(Cancel) {
        SetPause(false);
    }
    else {
        CheatManager.SingleFrame();
    }
}

Exec Function DeleteAllSaves() {
    local PickerEngine Engine;
    local SaveFileInfo SaveInfo;
    local Int Index;

    Engine = PickerEngine(class'PickerEngine'.static.GetEngine());
    Foreach Engine.SaveFiles(SaveInfo) {
        Engine.DeleteSaveFile(Engine.SaveFiles[Index].Filename);
        ++Index;
    }
    //CheatManager.DeleteAllSaves();
}

Exec Function SaveAllSaves() {
    CheatManager.SaveAllCheckpoints();
}

Exec Function DebugGameplay() {
    CheatManager.DebugGameplay();
}

Exec Function CVect(String MainCommand, Float X=0, Float Y=0, Float Z=0) {
    local Vector C;

    C.X = X;
    C.Y = Y;
    C.Z = Z;
    ConsoleCommand(MainCommand @ C);
} 

Exec Function TriggerDoor(DoorEventType Event) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.TriggerEvent(Event, PickerHero(Pawn));
    }
}

Exec Function FunBash(Bool bReversed=false) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        if(Int(GetRightMost(String(Door.Name))) % 2 == 0) {
            Door.BashDoor(bReversed);
        }
        else {
            WorldInfo.Game.SetTimer(0.25, false, 'FunBashSecond', Self);
        }
    }
}

Function FunBashSecond(Bool bReversed=false) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        if(Int(GetRightMost(String(Door.Name))) % 2 != 0) {
            Door.BashDoor(bReversed);
        }
    }
}

Exec Function BashDoor(Bool bReversed) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.BashDoor(bReversed);
    }
}

Exec Function BreakDoor(Bool bReversed) {
    local OLDoor Door;

    Foreach AllActors(Class'OLDoor', Door) {
        Door.BreakDoor(PickerHero(Pawn), bReversed);
    }
}
Exec Function ChangeEnemyModel(String Model, Bool ForChrisType=false) {
    local OLEnemyGenericPatient Enemy;
    local OLEnemySoldier EnemySol;

    if(ForChrisType) {
        Foreach AllActors(Class'OLEnemySoldier', EnemySol) {
            Enemy.Mesh.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(Model, Class'SkeletalMesh')));
        }
    }
    else {
        Foreach AllActors(Class'OLEnemyGenericPatient', Enemy) {
            Enemy.Mesh.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(Model, Class'SkeletalMesh')));
        }
    }
}

Exec Function ChangeGenericEnemyMesh(String Model) {
     local Actor A;
    local SkeletalMeshComponent MeshComp;
    local SkeletalMesh Mesh;
    local Int Index;
    local MaterialInterface Material;

    Mesh = SkeletalMesh(DynamicLoadObject(Model, Class'SkeletalMesh'));
    CustomGEnemySkelMesh = String(DynamicLoadObject(Model, Class'SkeletalMesh'));
    Foreach AllActors(Class'Actor', A) {
        if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
        Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
            if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
            if(
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Patient")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Surgeon")) != -1 || // Thanks ijedi1234#4601 for such a thing
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Priest")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps("Dupont")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(CustomGEnemySkelMesh)) != -1
            ) {
                MeshComp.SetSkeletalMesh(Mesh);
                Foreach MeshComp.SkeletalMesh.Materials(Material) {
                    MeshComp.SetMaterial(Index, none);
                    ++Index;
                }
            }
        }
    }
}

Exec Function ChangeSoldierEnemyMesh(String Model) {
    local Actor A;
    local SkeletalMeshComponent MeshComp;
    local SkeletalMesh Mesh;
    local Int Index;
    local MaterialInterface Material;

    Mesh = SkeletalMesh(DynamicLoadObject(Model, Class'SkeletalMesh'));
    Foreach AllActors(Class'Actor', A) {
        if(InStr(Caps(A.Name), Caps("SkeletalMesh")) == -1) continue;
        Foreach A.ComponentList(Class'SkeletalMeshComponent', MeshComp) {
            if(MeshComp == None || MeshComp.SkeletalMesh == None) continue;
            if(
                InStr(Caps(MeshComp.PathName), Caps("Soldier")) != -1 ||
                InStr(Caps(MeshComp.PathName), Caps("Groom")) != -1 || // Thanks ijedi1234#4601 for such a thing
                InStr(Caps(MeshComp.PathName), Caps("NanoCloud")) != -1 ||
                InStr(Caps(MeshComp.SkeletalMesh.PathName), Caps(CustomSEnemySkelMesh)) != -1
            ) {
                MeshComp.SetSkeletalMesh(Mesh);
                Foreach MeshComp.SkeletalMesh.Materials(Material) {
                    MeshComp.SetMaterial(Index, none);
                    ++Index;
                }
            }
        }
    }
    CustomSEnemySkelMesh = String(DynamicLoadObject(Model, Class'SkeletalMesh'));
}


Exec Function SpawnEnemy(String CEnemy, Int Count=1, EWeapon WeaponToUse=Weapon_None, Bool ShouldAttack=true) {
    local Vector C;
    local Int I;
    local Rotator Rot;
    local Bool AllEnemies;
    local SkeletalMesh PatientMesh;
    local OLBot Bot;
    local OLEnemyPawn Enemy;
    local OLEnemySoldier Soldier;
    local OLEnemyGroom Groom;
    local OLEnemyGenericPatient Patient, Priest;
    local OLEnemySurgeon Surgeon;
    local OLEnemyCannibal Cannibal;
    local OLEnemyNanoCloud NanoCloud;

    GetPlayerViewPoint(C, Rot);
    PickerHero(Pawn).SetCollision(false, false, false);
    if(Count == 0) {
        Count = 1;
    }
    else if(Count < 0) {
        Count = Count - (Count * 2);
    }
    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.SetCollision(false, false, false);
    }
    While(I < Count) {
        Switch(CEnemy) {
            case "Soldier":
                Soldier = Spawn(Class'OLEnemySoldier',,,C, Rot,,true);
                Soldier.SetCollision(false, false, false);
                Soldier.Modifiers.bShouldAttack = ShouldAttack;
                Soldier.Modifiers.bUseForMusic = true;
                Soldier.Modifiers.WeaponToUse = WeaponToUse;
                Soldier.ApplyModifiers(Soldier.Modifiers);
                Bot = Spawn(Class'OLBot');
                Bot.Possess(Soldier, false);
                break;
            case "Groom":
                Groom = Spawn(Class'OLEnemyGroom',,,C, Rot,,true);
                Groom.SetCollision(false, false, false);
                Groom.Modifiers.bShouldAttack = ShouldAttack;
                Groom.Modifiers.bUseForMusic = true;
                Groom.Modifiers.WeaponToUse = WeaponToUse;
                Groom.ApplyModifiers(Groom.Modifiers);
                Groom.Mesh.SetSkeletalMesh(SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt');
                Bot = Spawn(Class'OLBot');
                Bot.Possess(Groom, false);
                break;
            case "Surgeon":
                Surgeon = Spawn(Class'OLEnemySurgeon',,,C, Rot,,true);
                Surgeon.SetCollision(false, false, false);
                Surgeon.Mesh.SetSkeletalMesh(SkeletalMesh'Male_ward_SE.02_Surgeon.Mesh.Surgeon');
                Surgeon.Modifiers.bShouldAttack = ShouldAttack;
                Surgeon.Modifiers.bUseForMusic = true;
                Surgeon.Modifiers.WeaponToUse = WeaponToUse;
                Surgeon.ApplyModifiers(Surgeon.Modifiers);
                Surgeon.BehaviorTree = OLBTBehaviorTree'Male_ward_03_LD.02_AI_Behaviors.Surgeon_FullLoop_BT';
                //Surgeon.VOAsset = OLAIContextualVOAsset'Male_ward_03_LD.02_AI_Behaviors.Surgeon';
                Bot = Spawn(Class'OLBot');
                Bot.Possess(Surgeon, false);
                break;
            case "Cannibal":
                Cannibal = Spawn(Class'OLEnemyCannibal',,,C, Rot,,true);
                Cannibal.SetCollision(false, false, false);
                Cannibal.Modifiers.bShouldAttack = ShouldAttack;
                Cannibal.Modifiers.bUseForMusic = true;
                Cannibal.Modifiers.WeaponToUse = WeaponToUse;
                Cannibal.ApplyModifiers(Cannibal.Modifiers);
                Cannibal.BehaviorTree = OLBTBehaviorTree'Male_ward_03_LD.02_AI_Behaviors.Surgeon_FullLoop_BT';
                //Cannibal.VOAsset = OLAIContextualVOAsset'Prison_01-LD.02_AI_Behaviors.ManicYell';
                Bot = Spawn(Class'OLBot');
                Bot.Possess(Cannibal, false);
                break;
            case "Priest":
                Priest = Spawn(Class'OLEnemyGenericPatient',,,C, Rot,,true);
                Priest.SetCollision(false, false, false);
                Priest.Mesh.SetSkeletalMesh(SkeletalMesh'02_Priest.Pawn.Priest-01');
                Priest.Modifiers.bShouldAttack = ShouldAttack;
                Priest.Modifiers.bUseForMusic = true;
                Priest.Modifiers.WeaponToUse = WeaponToUse;
                Priest.ApplyModifiers(Priest.Modifiers);
                Priest.BehaviorTree = OLBTBehaviorTree'Male_ward_LD.02_AI_Behaviors.Generic_FullLoop_BT';
                Bot = Spawn(Class'OLBot');
                Bot.Possess(Priest, false);
                break;
            case "NanoCloud":
                NanoCloud = Spawn(Class'OLEnemyNanoCloud',,,C, Rot,,true);
                NanoCloud.SetCollision(false, false, false);
                NanoCloud.Modifiers.bShouldAttack = ShouldAttack;
                NanoCloud.Modifiers.bUseForMusic = true;
                NanoCloud.Modifiers.WeaponToUse = WeaponToUse;
                NanoCloud.ApplyModifiers(NanoCloud.Modifiers);
                Bot = Spawn(Class'OLBot');
                Bot.Possess(NanoCloud, false);
                break;
            Default:
                if(Left(CEnemy, 7) ~= "Patient") {
                    Switch(GetRightMost(CEnemy)) {
                        case "Dupont":
                            PatientMesh = SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont';
                            break;
                        case "Dupont2":
                            PatientMesh = SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont_2';
                            break;
                        case "Guard":
                            PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_LD.02_Scientist_DLC.Guard_alive';
                            break;
                        case "GuardBloody":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Worker.Mesh.Guard';
                            break;
                        case "RapeVictim":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Rape_victim';
                            break;
                        case "SimpleBloodyHead":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Patient_19_wound';
                            break;
                        case "StraitJacketMutHead":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_8';
                            break;
                        case "Simple2MutArms":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_7';
                            break;
                        case "Simple2OneEye":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_6';
                            break;
                        case "StraitJacketNoEyes":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_4';
                            break;
                        case "NudeMutHead2Arm":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_3';
                            break;
                        case "SimplePuffyNoPants":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_21';
                            break;
                        case "SimpleBlind":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_2';
                            break;
                        case "SimpleNormal":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19';
                            break;
                        case "SimplePuffy":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_18';
                            break;
                        case "SimpleOneEye":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_17';
                            break;
                        case "Simple2PuffyJeans":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_16';
                            break;
                        case "Simple2MutHead":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_12';
                            break;
                        case "Simple2MutHeadArms":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_1';
                            break;
                        case "SimplePuffyMutArm":
                            PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_11';
                            break;
                        case "Simple2MutArmsNoEyes":
                            PatientMesh = SkeletalMesh'FemaleWard_Floor1-LD.02_Generic_Patient.Meshes.Patient_14';
                            break;
                        case "SimpleWeird":
                            PatientMesh = SkeletalMesh'FemaleWard_Floor2-LD.02_Generic_Patient.Meshes.Patient_15';
                            break;
                        case "Simple2Mouth":
                            PatientMesh = SkeletalMesh'Male_ward_03a-SE.02_Generic_Patient.Meshes.Patient_5';
                            break;
                        case "WorkerBloody":
                            PatientMesh = SkeletalMesh'Male_ward_LD.02_Generic_Worker.Mesh.Worker_01';
                            break;
                        case "StraitJacketBlind":
                            PatientMesh = SkeletalMesh'Sewers_LD.02_Generic_Patient.Meshes.Patient_9';
                            break;
                        case "PriestBurned":
                            PatientMesh = SkeletalMesh'Center_block_03-LD.02_Priest.Pawn.Priest-burned';
                            break;
                        case "WorkerBloody2":
                            PatientMesh = SkeletalMesh'Center_block_sript_Revisit.02_Generic_Worker.Mesh.worker_4';
                            break;
                        case "WorkerBloody3":
                            PatientMesh = SkeletalMesh'Center_block_sript.02_Generic_Worker.Mesh.worker_3';
                            break;
                        case "PyroManic":
                            PatientMesh = SkeletalMesh'Male_ward_Cafeteria_fire.02_Generic_Patient_2nd_package.Mesh.pyro_dialogue';
                            break;
                        case "Blair":
                            PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Blair.Blair';
                            break;
                        case "BlairExplode":
                            PatientMesh = SkeletalMesh'DLC_AdmFloor1-01_SE.02_Blair.Blair_exploded';
                            break;
                        case "NudeMouth":
                            PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Generic_Patient.Meshes.Patient_13';
                            break;
                        case "StraitJacketMouth":
                            PatientMesh = SkeletalMesh'DLC_PrisonCourtYard-01_LD.02_Generic_Patient_DLC.Meshes.Patient_10';
                            break;
                        case "Swat":
                            PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v3';
                            break;
                        case "SwatMouth":
                            PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v2';
                            break;
                        case "SwatEyes":
                            PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v1';
                            break;
                        case "Licker":
                            PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.Scientist_Licker';
                            break;
                        case "Masked":
                            PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.masked_scientist';
                            break;
                        case "Hazmat":
                            PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.hazmat_scientist';
                            break;
                        case "Scientist":
                            PatientMesh = SkeletalMesh'DLC_Build1Floor2-01_SE.02_Scientist_DLC.Mesh.Scientist';
                            break;
                        case "Worker":
                            PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Generic_Worker_DLC.worker_4';
                            break;
                        case "Worker2":
                            PatientMesh = SkeletalMesh'DLC_Build2Attic-01_LD.02_Generic_Worker.Mesh.Worker_02';
                            break;
                        case "SimpleMutHead2":
                            PatientMesh = SkeletalMesh'DLC_Build2Floor3-01_LD.02_Generic_Patient_DLC.Meshes.Patient_20';
                            break;
                        case "Scientist2":
                            PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_03';
                            break;
                        case "Scientist3":
                            PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_02';
                            break;
                        case "WorkerBloodyHeadless":
                            PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Generic_Worker.Mesh.Worker_01_headless';
                            break;
                        Default:
                            SendMsg("Wrong Patient Name!");
                            return;
                            break;
                    }
                    Patient = Spawn(Class'OLEnemyGenericPatient',,,C, Rot,,true);
                    Patient.SetCollision(false, false, false);
                    Patient.Mesh.SetSkeletalMesh(PatientMesh);
                    Patient.Modifiers.bShouldAttack = ShouldAttack;
                    Patient.Modifiers.bUseForMusic = true;
                    Patient.Modifiers.WeaponToUse = WeaponToUse;
                    Patient.ApplyModifiers(Patient.Modifiers);
                    Patient.BehaviorTree = OLBTBehaviorTree'Male_ward_LD.02_AI_Behaviors.Generic_FullLoop_BT';
                    Bot = Spawn(Class'OLBot');
                    Bot.Possess(Patient, false);
                }
                else {
                    SendMsg("Wrong Enemy Name!");
                    return;
                }
                break;
        }
    i += 1;
    }
    `Log("Spawned Enemies:" @ CEnemy @ "/" @ Count @ "/" @ WeaponToUse @ "/" @ ShouldAttack @ "/" @ C);
    WorldInfo.Game.SetTimer(0.07, false, 'BackPawnCol', Self);
    PickerHero(Pawn).SetCollision(true, true);
}

Exec Function SpawnRandEnemy(Int Count=1, EWeapon WeaponToUse=Weapon_None, Bool ShouldAttack=true) {
    local String FirstChoice, ResultChoice;

    FirstChoice = ArrayPatientTypes[Rand(7)];
    if(FirstChoice ~= "Patient") {
        ResultChoice = FirstChoice $ "_" $ ArrayPatientModel[Rand(46)];
    }
    else {
        ResultChoice = FirstChoice;
    }
    SpawnEnemy(ResultChoice, Count, WeaponToUse, ShouldAttack);
}

Exec Function RotateEnemy(Float Pitch=0, Float Yaw=0, Float Roll=0) {
    local OLBot Bot;
    local Rotator D;

    D.Pitch=Pitch;
    D.Yaw=Yaw;
    D.Roll=Roll;
    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Bot.EnemyPawn.SetDesiredRotation(D);
    }
}

Exec Function ChangeChrisModel(String Model, Bool ForGroom=false) {
    local OLEnemySoldier Soldier;
    local OLEnemyGroom Groom;
    local SkeletalMesh Mesh;
    local OLBot Bot;

    Switch(Model) {
        case "Chris":
            Mesh = SkeletalMesh'02_Soldier.Pawn.Soldier-03';
            break;
        case "Groom":
            Mesh = SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt';
            break;
        case "GroomLab":
            Mesh = SkeletalMesh'02_Groom.Groom_Pre_mutation_1';
            break;
        case "Lady":
            Mesh = SkeletalMesh'chrislady.Mesh.chrislady';
            break;
        case "Blake":
            Mesh = SkeletalMesh'chrisblake.Mesh.chrisblakebr';
            break;
        case "Demo":
            Mesh = SkeletalMesh'demochris.Mesh.chriswalker';
            break;
        Default:
            SendMsg("Wrong Model Name! Available:\nChris\nGroom\nGroomLab\nLady\nBlake\nDemo");
            return;
            break;
    }
    Foreach WorldInfo.AllActors(Class'OLBot', Bot) {
        if(Bot.EnemyPawn.Class == Class'OLEnemySoldier' || Bot.EnemyPawn.Class == Class'OLEnemyGroom') {
            if(ForGroom) {
                Foreach WorldInfo.AllActors(Class'OLEnemyGroom', Groom) {
                    Groom.Mesh.SetSkeletalMesh(Mesh);
                }
                return;
            }
            else {
                Foreach WorldInfo.AllActors(Class'OLEnemySoldier', Soldier) {
                    if(Soldier.Class != Class'OLEnemyGroom') {
                        Soldier.Mesh.SetSkeletalMesh(Mesh);
                    }
                    return;
                }
            }
        }
    }
    SendMsg("Chris/Eddie are Missing!");
}

Exec Function SpawnDoor(EOLDoorMeshType MeshType) {
    local Vector C;
    local Rotator Rot;
    local OLDoor Door;

    Rot.Pitch = 0;
    Rot.Yaw = Pawn.Rotation.Yaw;
    Rot.Roll = 0;
    C = Pawn.Location + (Normal(Vector(Pawn.Rotation)) * 100);
    Door = Spawn(Class'OLDoor', Self,, C, Rot,,true);
    Door.DoorMeshType = MeshType;
}

Exec Function ScaleEnemy(Float X=1, Float Y=1, Float Z=1) {
    local OLEnemyPawn Enemy;
    local Vector NewScale;

    NewScale.X = X;
    NewScale.Y = Y;
    NewScale.Z = Z;
    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        Enemy.Mesh.SetScale3D(NewScale);
        vScaleEnemies = NewScale;
    }
}

Exec Function ScalePlayer(Float X=1, Float Y=1, Float Z=1) {
    local PickerHero Hero;
    local Vector NewScale;

    NewScale.X = X;
    NewScale.Y = Y;
    NewScale.Z = Z;
    Hero = PickerHero(Pawn);
    Foreach AllActors(Class'PickerHero', Hero) {
        Hero.Mesh.SetScale3D(NewScale);
        vScalePlayer = NewScale;
    }
}

Exec Function ToggleBhop() {
    bBhop = !bBhop;
}

Exec Function ToggleAutoBunnyHop() {
    bAutoBunnyHop = !bAutoBunnyHop;
}

Function DisableInput(Bool Input) {
    local PickerInput HeroInput;
    local PickerHero Hero;

    HeroInput = PickerInput(PlayerInput);
    Hero = PickerHero(Pawn);
    if(Hero == None) {
        return;
    }
    if(Input) {
        HeroInput.MoveCommand="asdtyunbv";
        HeroInput.StrafeCommand="asdtyunbv";
        HeroInput.LookXCommand="asdtyunbv";
        HeroInput.LookYCommand="asdtyunbv";
        Hero.NormalWalkSpeed=0;
        Hero.NormalRunSpeed=0;
        Hero.CrouchedSpeed=0;
        Hero.ElectrifiedSpeed=0;
        Hero.WaterWalkSpeed=0;
        Hero.WaterRunSpeed=0;
        Hero.LimpingWalkSpeed=0;
        Hero.HobblingWalkSpeed=0;
        Hero.HobblingRunSpeed=0;
        IgnoreLookInput(true);
        IgnoreMoveInput(true);
    }
    else {
        HeroInput.MoveCommand=HeroInput.Default.MoveCommand;
        HeroInput.StrafeCommand=HeroInput.Default.StrafeCommand;
        HeroInput.LookXCommand=HeroInput.Default.LookXCommand;
        HeroInput.LookYCommand=HeroInput.Default.LookYCommand;
        Hero.NormalWalkSpeed=Hero.Default.NormalWalkSpeed;
        Hero.NormalRunSpeed=Hero.Default.NormalRunSpeed;
        Hero.CrouchedSpeed=Hero.Default.CrouchedSpeed;
        Hero.ElectrifiedSpeed=Hero.Default.ElectrifiedSpeed;
        Hero.WaterWalkSpeed=Hero.Default.WaterWalkSpeed;
        Hero.WaterRunSpeed=Hero.Default.WaterRunSpeed;
        Hero.LimpingWalkSpeed=Hero.Default.LimpingWalkSpeed;
        Hero.HobblingWalkSpeed=Hero.Default.HobblingWalkSpeed;
        Hero.HobblingRunSpeed=Hero.Default.HobblingRunSpeed;
        IgnoreLookInput(false);
        IgnoreMoveInput(false);
    }
    HeroInput.bWasForward=false;
    HeroInput.bWasBack=false;
    HeroInput.bWasLeft=false;
    HeroInput.bWasRight=false;
    HeroInput.bEdgeForward=false;
    HeroInput.bEdgeBack=false;
    HeroInput.bEdgeLeft=false;
    HeroInput.bEdgeRight=false;
}

Exec Function CPP() {
    local OLEnemySoldier Soldier;

    Foreach AllActors(Class'OLEnemySoldier', Soldier) {
        Soldier.Mesh.SetSkeletalMesh(SkeletalMesh'02_Player.Pawn.Miles_beheaded');
        Soldier.Mesh.SetAnimTreeTemplate(AnimTree'02_Behaviors.Player.Player_AnimTree');
        Soldier.Mesh.SetPhysicsAsset(PhysicsAsset'02_Player.Pawn.Player_Physics');
        Soldier.Mesh.AnimSets[0] = AnimSet'03_Hero.Hero-01_AS';
    }
    return;
    PickerHero(Pawn).Mesh.SetAnimTreeTemplate(AnimTree'02_Behaviors.Enemy.Generic_AnimTree');
    PickerHero(Pawn).Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont');
    //PickerHero(Pawn).Mesh.SetAnimTreeTemplate(AnimTree'02_Behaviors.Enemy.Generic_AnimTree');
    PickerHero(Pawn).Mesh.AnimSets[0] = AnimSet'01_Animated_Props.SurgeonWeapon.SurgeonWeapon_GP-AS';
    //PickerHero(Pawn).Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont');
    //PickerHero(Pawn).Mesh.AnimSets[0] = AnimSet'01_Animated_Props.SurgeonWeapon.SurgeonWeapon_GP-AS';
}

Exec Function ChangePlayerModel(String CustomPlayer) {
    local MaterialInterface Mat;
    local OLPlayerModel FoundCP;
    local String Link;

    if(PickerHero(Pawn) == None) {
        return;
    }

    Switch(CustomPlayer) {
        case "Default":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(Current_SkeletalMesh);
            CustomPM = "Default";
            ResetPlayerMaterials();
            bDefaultPlayer = true;
            break;
        case "Miles":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(SkeletalMesh'02_Player.Pawn.Miles_beheaded');
            CustomPM = "Miles";
            ResetPlayerMaterials();
            bDefaultPlayer = false;
            break;
        case "MilesNoFingers":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(PickerHero(Pawn).FingerlessMesh);
            CustomPM = "MilesNoFingers";
            ResetPlayerMaterials();
            bDefaultPlayer = false;
            break;
        case "Waylon":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(PickerHero(Pawn).ITTechMesh);
            CustomPM = "Waylon";
            ResetPlayerMaterials();
            bDefaultPlayer = false;
            break;
        case "WaylonPrisoner":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(PickerHero(Pawn).PrisonerMesh);
            CustomPM = "WaylonPrisoner";
            ResetPlayerMaterials();
            bDefaultPlayer = false;
            break;
        case "WaylonNude":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(SkeletalMesh'DLC_Build2Floor2-01_SE.02_Waylon_Park.Mesh.Waylon_Park_Nude');
            CustomPM = "WaylonNude";
            ResetPlayerMaterials();
            bDefaultPlayer = false;
            break;
        case "WaylonBloody":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(PickerHero(Pawn).PrisonerMesh);
            CustomPM = "WaylonBloody";
            ResetPlayerMaterials();
            PickerHero(Pawn).Mesh.SetMaterial(0, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_1_bloody');
            PickerHero(Pawn).Mesh.SetMaterial(1, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_2_bloody');
            PickerHero(Pawn).Mesh.SetMaterial(2, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_3_bloody');
            PickerHero(Pawn).Mesh.SetMaterial(4, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_3_bloody');
            PickerHero(Pawn).Mesh.SetMaterial(5, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_2_bloody');
            bDefaultPlayer = false;
            break;
        case "WaylonWound":
            PickerHero(Pawn).Mesh.SetSkeletalMesh(PickerHero(Pawn).PrisonerMesh);
            CustomPM = "WaylonWound";
            ResetPlayerMaterials();
            PickerHero(Pawn).Mesh.SetMaterial(0, MaterialInstanceConstant'DLC_AdmFloor1-01_SE.02_Waylon_Park.Textures.Id_1_stab_wound');
            bDefaultPlayer = false;
            break;
        Default:
            if(Class'OLPlayerModel' == None) {
                Link="https://bit.ly/3hUJBvA";
                SendMsg("OLCustomPlayerModelSDK not installed! (Check Log)");
                `log("Download SDK:" @ Link);
                return;
            }
            FoundCP = OLPlayerModel(DynamicLoadObject(CustomPlayer, Class'Object'));
            LogInternal(FoundCP);
            if(FoundCP == None) {
                SendMsg("PlayerModel not found!");
                SendMsg("Available:\nDefault\nMiles\nMilesNoFingers\nWaylon\nWaylonPrisoner\nWaylonNude\nWaylonBloody\nWaylonWound\n<Custom>");
                return;
            }
            CustomPM=CustomPlayer;
            SendMsg("Player Model is" @ CustomPM);
            bDefaultPlayer = false;
            PickerHero(Pawn).Mesh.SetSkeletalMesh(FoundCP.HeroBody);
            ResetPlayerMaterials();
            break;
    }
}

Function InitPlayerModel() {
    WorldInfo.Game.SetTimer(0.5, false, 'LoadCurrent', Self);
}

Function LoadCurrent() {
    Current_SkeletalMesh = PickerHero(Pawn).Mesh.SkeletalMesh;
    Materials = PickerHero(Pawn).Mesh.Materials;
    if(CustomPM != "Default") {
        ChangePlayerModel(CustomPM);
    }
}

Function ResetPlayerMaterials() {
    local Int Index;
    local MaterialInterface Material;

    Foreach PickerHero(Pawn).Mesh.SkeletalMesh.Materials(Material) {
        PickerHero(Pawn).Mesh.SetMaterial(Index, none);
        ++Index;
    }
    return;
}

Function ResetEnemyMaterials() {
    local Int Index;
    local MaterialInterface Material;
    local OLBot Bot;

    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        Foreach Bot.EnemyPawn.Mesh.SkeletalMesh.Materials(Material) {
            Bot.EnemyPawn.Mesh.SetMaterial(Index, none);
            ++Index;
        }
    }
}

Exec Function DelClass(Class<Actor> aClass) {
    local Actor A;

    CheatManager.KillAll(aClass);
    if(ClassIsChildOf(aClass, Class'Pawn')) {
        KillAllPawns(Class<Pawn>(aClass));
        return;
    }
    Foreach DynamicActors(Class'Actor', A) {
        if(ClassIsChildOf(A.Class, aClass)) {
            A.Destroy();
        }
    }
}

Function KillAllPawns(Class<Pawn> aClass) {
    local Pawn P;

    Foreach DynamicActors(Class'Pawn', P) {
        if(ClassIsChildOf(P.Class, aClass) && !P.IsPlayerPawn()) {
            if(P.Controller != None) {
                P.Controller.Destroy();
            }
            P.Destroy();
        }
    }
}

Exec Function OffBaseLight() {
    local OLLight OLLight;
    local PointLight Point;
    local SpotLight Spot;
    local DominantDirectionalLight Dom;

    Foreach AllActors(Class'OLLight', OLLight) {
        OLLight.SpotLight.SetEnabled(false);
        OLLight.FogMesh.SetHidden(true);
        OLLight.Destroy();
    }
    Foreach AllActors(Class'PointLight', Point) {
        Point.LightComponent.SetEnabled(false);
        Point.LightComponent.OnUpdatePropertyBrightness();
        Point.Destroy();
    }
    Foreach AllActors(Class'SpotLight', Spot) {
        Spot.LightComponent.SetEnabled(false);
        Spot.LightComponent.OnUpdatePropertyBrightness();
        Spot.Destroy();
    }
    Foreach AllActors(Class'DominantDirectionalLight', Dom) {
        Dom.LightComponent.SetEnabled(false);
        Dom.Destroy();
    }
}

/******************************************OTHER FUNCTIONS******************************************/

Exec Function ToggleCrabGame() {
    CrabGameState = !CrabGameState;
    if(CrabGameState) {
        WorldInfo.Game.SetTimer(10, true, 'CrabGame', Self);
        SendMsg("CRAB GAME STARTED, ENJOY!");
    }
    else {
        WorldInfo.Game.ClearTimer('CrabGame', Self);
        SendMsg("CRAB GAME DISABLED!");
    }
}

Function CrabGame() {
    if(PickerHero(Pawn).Velocity != Vect(0, 0, 0) && PickerHero(Pawn).LocomotionMode != LM_Cinematic) {
        SendMsg("Don't move!");
        Reload();
    }
    else {
        SendMsg("Good job!");
    }
}

Exec Function ToggleMathTasks() {
    MathTasksState = !MathTasksState;
    if(MathTasksState) {
        WorldInfo.Game.SetTimer(10, false, 'MathTasks', Self);
        SendMsg("MATH TASKS STARTED, ENJOY!");
    }
    else {
        WorldInfo.Game.ClearTimer('MathTasks', Self);
        SendMsg("MATH TASKS DISABLED!");
    }
}

Function MathTasks() {
    MathTasksGlobalA = Rand(1000);
    MathTasksGlobalB = Rand(1000);
    Switch(Rand(3)) {
        case 0:
            MathTasksTempOperation = 0;
            PickerHud(HUD).MathTasksOperation = "+";
            break;
        case 1:
            if(MathTasksGlobalA < MathTasksGlobalB) {
                MathTasks();
                return;
                break;
            }
            MathTasksTempOperation = 1;
            PickerHud(HUD).MathTasksOperation = "-";
            break;
        case 2:
            MathTasksTempOperation = 2;
            PickerHud(HUD).MathTasksOperation = "*";
            break;
        case 3:
            MathTasksTempOperation = 2;
            PickerHud(HUD).MathTasksOperation = "*";
            break;
        
    }
    DisableInput(true);
    DebugFreeCamSpeed = 0;
    PlayerInput.ResetInput();
    MathTasksTimer = true;
    PickerHud(HUD).MathTasksHUD = true;
    WorldInfo.Game.SetTimer(10, false, 'MathTasksCheck', Self);
}

Function MathTasksCheck() {
    local String RightAnswer;

    Switch(MathTasksTempOperation) {
        case 0:
            RightAnswer = String(MathTasksGlobalA + MathTasksGlobalB);
            break;
        case 1:
            RightAnswer = String(MathTasksGlobalA - MathTasksGlobalB);
            break;
        case 2:
            RightAnswer = String(MathTasksGlobalA * MathTasksGlobalB);
            break;
    }
    MathTasksGlobalA = 0;
    MathTasksGlobalB = 0;
    MathTasksTimer = false;
    PickerHud(HUD).MathTasksHUD = false;
    if(PickerInput(PlayerInput).MathTasksAnswer != RightAnswer) {
        Reload();
        SendMsg("Wrong! Right answer:" @ RightAnswer);
    }
    else {
        DS(5);
        SendMsg("Right! Good Job!");
    }
    PickerInput(PlayerInput).MathTasksAnswer = "";
    DisableInput(false);
    PlayerInput.ResetInput();
    DebugFreeCamSpeed = Default.DebugFreeCamSpeed;
    WorldInfo.Game.SetTimer(10, false, 'MathTasks', Self);
}

Exec Function TeleportSavePos() {
    if(!PickerHud(HUD).DisableTeleportSound) {
        PlaySound(SoundCue'PickerDebugMenu.MDLSave');
    }
    TeleportPosCoordsTemp = PickerHero(Pawn).Location;
}

Exec Function TeleportLoadPos() {
    if(!PickerHud(HUD).DisableTeleportSound) {
        PlaySound(SoundCue'PickerDebugMenu.MDLLoad');
    }
    PickerHero(Pawn).SetLocation(TeleportPosCoordsTemp);
}

/****************** ALIASES ******************/

Exec Function DS(Float Dmg) {
    DmgSelf(Dmg);
}

Exec Function Bind(String Key, String Command) {
    ConsoleCommand("SetBind" @ Key @ Command);
}

Exec Function CP(String CP, Bool SV=false) {
    Checkpoint(CP, SV);
}

Exec Function SME(ESpecialMoveType SpecialMove) {
    SpecialMoveEnemy(SpecialMove);
}

Exec Function SMP(ESpecialMoveType SpecialMove) {
    SpecialMovePlayer(SpecialMove);
}

Exec Function GS(Float Speed=1) {
    SetGameSpeed(Speed);
}

Exec Function SS() {
    SkipStart();
}

Exec Function ST() {
    SkipTorture();
}

Exec Function CBatt(Int Increase) {
    ChangeBatteries(Increase);
}

Exec Function CHealth(Int NewHealth) {
    ChangePlayerHealth(NewHealth);
}

Exec Function Van(Bool Force=true) { //NOT DUNGEON MASTER!!
    ToggleDisAI(Force);
}

Exec Function InfBatt() {
    ToggleUnlimitedBatteries();
}

Exec Function CPM(String PlayerModel) {
    ChangePlayerModel(PlayerModel);
}

/****************** INFO ******************/

Exec Function HideObj() {
    PickerHud(HUD).ObjectiveScreen.SetVisible(false);
    PickerHud(HUD).ObjectiveScreen.SetMessage(1, "");
}
Exec Function ShowObj(String ObjectiveText, Float LifeTime=0, Bool Normal=false) {
    if(PickerHud(HUD).ObjectiveScreen == None) {
        PickerHud(HUD).ObjectiveScreen = new (Self) Class'OLUIMessage';
    }
    if(PickerHud(HUD).ObjectiveScreen != None) {
        PickerHud(HUD).ObjectiveScreen.Start(false);
        if(Normal) {
            PickerHud(HUD).ObjectiveScreen.SetMessage(1, Localize("Messages", "NewObjective", "OLGame") @ (Localize("Objectives", String(CurrentObjective), "OLGame")));
        }
        else {
            PickerHud(HUD).ObjectiveScreen.SetMessage(1, Localize("Messages", "NewObjective", "OLGame") @ ObjectiveText);
        }
        PickerHud(HUD).ObjectiveScreen.SetVisible(true);
        if(LifeTime != 0 && LifeTime > 0) {
            WorldInfo.Game.SetTimer(LifeTime, false, 'HideObj', Self);
        }
    }
}

Exec Function ShowTrig(Bool Show) {
    local TriggerVolume TriggerVolume;
    local Trigger Trigger;

    Foreach AllActors(Class'TriggerVolume', TriggerVolume) {
		TriggerVolume.BrushComponent.SetHidden(!Show);
		TriggerVolume.SetHidden(!Show);
	}
    Foreach AllActors(Class'Trigger', Trigger) {
        Trigger.CylinderComponent.SetHidden(!Show);
    }
}

Function ShowMsg(EHUDMessageType MsgType, String Msg) {
    PickerHud(HUD).ShowMessage(MsgType, Msg);
}

Exec Function SendMsg(String Msg, Float LifeTime=3.0) {
    if(!PickerHud(HUD).DisablePickerMessages) {
        PickerHud(HUD).AddConsoleMessage(Msg, Class'LocalMessage', PlayerReplicationInfo, LifeTime);
    }
}

Exec Function SendLocalize(String File, String Section, String Key) {
    SendMsg(Localize(Section, Key, File));
}

Exec Function SendLog(String Msg) {
    `log(Msg);
}

Exec Function SendFloor() {
    SendMsg(String(PickerHero(Pawn).GetMaterialBelowFeet()));
}

Exec Function SendRandLoc() {
    SendMsg(PickerHud(HUD).RandLocalize());
}



/****************** RANDOM ******************/


Exec Function RandUberEffect() {
    local OLUberPostProcessEffect Effect;

    Effect = FXManager.CurrentUberPostEffect;
    Effect.VignetteBlack=RandRange(0.100f, 1.750f);
    Effect.VignetteWhite=RandRange(0.100f, 1.750f);
    Effect.GrainBrightness=RandRange(0.500f, 1.000f);
    Effect.GrainOpacity=RandRange(0.000f, 255.000f);
    Effect.GrainScale=RandRange(0.200f, 3.500f);
    Effect.HurtExp=RandRange(0.000f, 10.000f);
    Effect.HurtTimeScale=RandRange(0.000f, 10.000f);
    Effect.HurtScale=RandRange(0.000f, 10.000f);
    Effect.CameraColorEffect=RandRange(0.200f, 2.000f);
    Effect.CameraScale=RandRange(0.000f, 2.000f);
    Effect.CameraGlassLightintensity=RandRange(0.200f, 2.000f);
}

Function Bool RandBool() {
    return Bool(Rand(2));
}

Function String RandChar() {
    return Chr(RandRange(33, 126));
}

Function String RandString(Int Length) {
    local Int I;
    local String Out;

    While(I < Length) {
        Out = Out $ RandChar(); i += 1;
    }
    return Out;
}
Function Float RandFloat(Float Max) {
    local Float Out;
    
    Out = RandRange(0.0000000f, Max);
    return Out;
}

Function Byte RandByte(Byte Max) {
    return Byte(Rand(Max));
}

Exec Function RandSpawnEnemy(Int Count=1) {
    local Int I;

    While(I < Count) {
        Switch(Rand(5)) {
            case 0:
                SpawnEnemy("Soldier");
                break;
            case 1:
                SpawnEnemy("Groom");
                break;
            case 2:
                SpawnEnemy("NanoCloud");
                break;
            case 3:
                SpawnEnemy("Surgeon");
                break;
            case 4:
                SpawnEnemy("Priest");
                break;
            case 5:
                SpawnEnemy("Cannibal");
                break;
        }
        i += 1;
    }
}

Exec Function RandSpawnEnemyCount(Int Min, Int Max, String Enemy="") {
    local Int Out;
    
    Out = RandRange(Min, Max);
    if(Enemy != "Soldier" && Enemy != "Groom" && Enemy != "NanoCloud" && Enemy != "Surgeon" && Enemy != "Priest" && Enemy != "Cannibal") {
        RandSpawnEnemy(Out);
        return;
    }
    SpawnEnemy(Enemy, Out);

}

Exec Function RandSpecialMoveAnims(Bool Normal=false) {
    local Int Index;
    local SpecialMoveParameters Params;

    if(!Normal && Rand(100) > 25) {
        While(Index <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].AnimName = PickerHero(Pawn).Mesh.AnimSets[0].Sequences[Rand(358)].SequenceName;
            ++Index;
        }
    }
    else {
        While(Index <= 70) {
            PickerHero(Pawn).SpecialMoveParams[Index].AnimName = PickerHero(Pawn).Default.SpecialMoveParams[Index].AnimName;
            ++Index;
        }
    }
}

Exec Function RandLightColor() {
    local PointLight Point;
    local SpotLight Spot;
    local DominantDirectionalLight Dom;
    local SkyLight Sky;

    Foreach AllActors(Class'PointLight', Point) {
        Point.LightComponent.SetLightProperties(,RandColor(Point.LightComponent.LightColor.A));
    }
    Foreach AllActors(Class'SpotLight', Spot) {
        Spot.LightComponent.SetLightProperties(,RandColor(Spot.LightComponent.LightColor.A));
    }
    Foreach AllActors(Class'DominantDirectionalLight', Dom) {
        Dom.LightComponent.SetLightProperties(,RandColor(Dom.LightComponent.LightColor.A));
    }
    Foreach AllActors(Class'SkyLight', Sky) {
        Sky.LightComponent.SetLightProperties(,RandColor(Sky.LightComponent.LightColor.A));
    }
}

Exec Function ToggleRandDoors(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandDoors', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandDoors', Self);
    }
}

Exec Function ToggleRandUberEffect(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandUberEffect', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandUberEffect', Self);
    }
}

Exec Function RandDoors() {
    local String Mat, SndMat;

    Switch(Rand(24)) {
        case 0:
            Mat = "Undefined";
            break;
        case 1:
            Mat = "Wooden";
            break;
        case 2:
            Mat = "WoodenOld";
            break;
        case 3:
            Mat = "WoodenWindow";
            break;
        case 4:
            Mat = "WoodenWindowSmall";
            break;
        case 5:
            Mat = "WoodenWindowOld";
            break;
        case 6:
            Mat = "WoodenWindowOldSmall";
            break;
        case 7:
            Mat = "Metal";
            break;
        case 8:
            Mat = "MetalWindow";
            break;
        case 9:
            Mat = "MetalWindowSmall";
            break;
        case 10:
            Mat = "Enforced";
            break;
        case 11:
            Mat = "Grid";
            break;
        case 12:
            Mat = "Prison";
            break;
        case 13:
            Mat = "Entrance";
            break;
        case 14:
            Mat = "Bathroom";
            break;
        case 15:
            Mat = "IsolatedCell";
            break;
        case 16:
            Mat = "Locker";
            break;
        case 17:
            Mat = "LockerRusted";
            break;
        case 18:
            Mat = "LockerBeige";
            break;
        case 19:
            Mat = "LockerGreen";
            break;
        case 20:
            Mat = "Glass";
            break;
        case 21:
            Mat = "Fence";
            break;
        case 22:
            Mat = "ForceGate";
            break;
        case 23:
            Mat = "Gate";
            break;
        case 24:
            Mat = "LockerHole";
            break;
        
    }
    Switch(Rand(4)) {
        case 0:
            SndMat = "Wood";
            break;
        case 1:
            SndMat = "Metal";
            break;
        case 2:
            SndMat = "SecurityDoor";
            break;
        case 3:
            SndMat = "BigPrisonDoor";
            break;
        case 4:
            SndMat = "BigWoodenDoor";
            break;
    }
    ChangeDoorMeshType(Mat, Name(SndMat));
}

Exec Function ToggleRandPPS(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandPPS', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandPPS', Self);
    }
}

Exec Function RandPPS() {
    FXManager.SetPPSFromScript(EPPSMode(Rand(FXManager.EPPSMode.EnumCount)));
}

Exec Function RandPatientModel() {
    local OLEnemyGenericPatient Patient;
    local OLEnemySoldier Soldier;
    local OLEnemyNanoCloud ForMesh;
    local SkeletalMesh PatientMesh, SoldierMesh;
    local Int Index;
    local MaterialInterface Material;
    
    Foreach AllActors(Class'OLEnemyGenericPatient', Patient) {
        Switch(Rand(45)) {
            case 0:
                PatientMesh = SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont';
                break;
            case 1:
                PatientMesh = SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont_2';
                break;
            case 2:
                PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_LD.02_Scientist_DLC.Guard_alive';
                break;
            case 3:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Worker.Mesh.Guard';
                break;
            case 4:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Rape_victim';
                break;
            case 5:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Patient_19_wound';
                break;
            case 6:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_8';
                break;
            case 7:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_7';
                break;
            case 8:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_6';
                break;
            case 9:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_4';
                break;
            case 10:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_3';
                break;
            case 11:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_21';
                break;
            case 12:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_2';
                break;
            case 13:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19';
                break;
            case 14:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_18';
                break;
            case 15:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_17';
                break;
            case 16:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_16';
                break;
            case 17:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_12';
                break;
            case 18:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_1';
                break;
            case 19:
                PatientMesh = SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_11';
                break;
            case 20:
                PatientMesh = SkeletalMesh'FemaleWard_Floor1-LD.02_Generic_Patient.Meshes.Patient_14';
                break;
            case 21:
                PatientMesh = SkeletalMesh'FemaleWard_Floor2-LD.02_Generic_Patient.Meshes.Patient_15';
                break;
            case 22:
                PatientMesh = SkeletalMesh'Male_ward_03a-SE.02_Generic_Patient.Meshes.Patient_5';
                break;
            case 23:
                PatientMesh = SkeletalMesh'Male_ward_LD.02_Generic_Worker.Mesh.Worker_01';
                break;
            case 24:
                PatientMesh = SkeletalMesh'Sewers_LD.02_Generic_Patient.Meshes.Patient_9';
                break;
            case 25:
                PatientMesh = SkeletalMesh'Center_block_03-LD.02_Priest.Pawn.Priest-burned';
                break;
            case 26:
                PatientMesh = SkeletalMesh'Center_block_sript_Revisit.02_Generic_Worker.Mesh.worker_4';
                break;
            case 27:
                PatientMesh = SkeletalMesh'Center_block_sript.02_Generic_Worker.Mesh.worker_3';
                break;
            case 28:
                PatientMesh = SkeletalMesh'Male_ward_Cafeteria_fire.02_Generic_Patient_2nd_package.Mesh.pyro_dialogue';
                break;
            case 29:
                PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Blair.Blair';
                break;
            case 30:
                PatientMesh = SkeletalMesh'DLC_AdmFloor1-01_SE.02_Blair.Blair_exploded';
                break;
            case 31:
                PatientMesh = SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Generic_Patient.Meshes.Patient_13';
                break;
            case 32:
                PatientMesh = SkeletalMesh'DLC_PrisonCourtYard-01_LD.02_Generic_Patient_DLC.Meshes.Patient_10';
                break;
            case 33:
                PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v3';
                break;
            case 34:
                PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v2';
                break;
            case 35:
                PatientMesh = SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v1';
                break;
            case 36:
                PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.Scientist_Licker';
                break;
            case 37:
                PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.masked_scientist';
                break;
            case 38:
                PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.hazmat_scientist';
                break;
            case 39:
                PatientMesh = SkeletalMesh'DLC_Build1Floor2-01_SE.02_Scientist_DLC.Mesh.Scientist';
                break;
            case 40:
                PatientMesh = SkeletalMesh'DLC_Lab-01_SE.02_Generic_Worker_DLC.worker_4';
                break;
            case 41:
                PatientMesh = SkeletalMesh'DLC_Build2Attic-01_LD.02_Generic_Worker.Mesh.Worker_02';
                break;
            case 42:
                PatientMesh = SkeletalMesh'DLC_Build2Floor3-01_LD.02_Generic_Patient_DLC.Meshes.Patient_20';
                break;
            case 43:
                PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_03';
                break;
            case 44:
                PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_02';
                break;
            case 45:
                PatientMesh = SkeletalMesh'DLC_Build1Floor1-01_SE.02_Generic_Worker.Mesh.Worker_01_headless';
                break;
        }
        Patient.Mesh.SetSkeletalMesh(PatientMesh);
        Foreach Patient.Mesh.SkeletalMesh.Materials(Material) {
            Patient.Mesh.SetMaterial(Index, none);
            ++Index;
        }
    }
    Foreach AllActors(Class'OLEnemySoldier', Soldier) {
        Switch(Rand(4)) {
            case 0:
                SoldierMesh = SkeletalMesh'02_Soldier.Pawn.Soldier-03';
                Soldier.Mesh.SetPhysicsAsset(PhysicsAsset'02_Soldier.Pawn.Soldier-v2_Physics', true);
                break;
            case 1:
                SoldierMesh = SkeletalMesh'02_Groom.Groom_Pre_mutation_1';
                Soldier.Mesh.SetPhysicsAsset(None, true);
                break;
            case 2:
                SoldierMesh = SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt';
                Soldier.Mesh.SetPhysicsAsset(None, true);
                break;
            case 3:
                SoldierMesh = SkeletalMesh'02_NanoCloud.Pawn.Nano_Swarm_body';
                Soldier.Mesh.SetPhysicsAsset(PhysicsAsset'02_Soldier.Pawn.Soldier-v2_Physics', true);
                break;
        }
        Soldier.Mesh.SetSkeletalMesh(SoldierMesh);
        Foreach Soldier.Mesh.SkeletalMesh.Materials(Material) {
            Soldier.Mesh.SetMaterial(Index, none);
            ++Index;
        }
    }
}

Exec Function RandDoorType() {
    ConsoleCommand("Set OLDoor DoorMeshType" @ Rand(23));
}

Exec Function RandPlayerState() {
    Switch(Rand(3)) {
        case 0:
            PickerHero(Pawn).bLimping = false;
            PickerHero(Pawn).bHobbling = false;
            break;
        case 1:
            PickerHero(Pawn).bLimping = true;
            PickerHero(Pawn).bHobbling = false;
            break;
        case 2:
            PickerHero(Pawn).bHobbling = true;
            PickerHero(Pawn).TargetHobblingIntensity = FRand();
            PickerHero(Pawn).bLimping = false;
            break;
    }
}

Exec Function ToggleRandPatientModel(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandPatientModel', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandPatientModel', Self);
    }
}

Exec Function ToggleRandLightColor(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandLightColor', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandLightColor', Self);
    }
}

Exec Function ToggleRandChangeFOV(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandChangeFOV', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandChangeFOV', Self);
    }
}

Exec Function RandChangeFOV() {
    local PickerHero Hero;

    Hero = PickerHero(Pawn);
    Hero.DefaultFOV = Rand(177) + FRand();
    Hero.RunningFOV = Rand(177) + FRand();
    Hero.CamcorderMaxFOV = Rand(177) + FRand();
    Hero.CamcorderNVMaxFOV = Rand(177) + FRand();
}

Exec Function ToggleRandChangeDoorMeshType(Float Speed=0.3, Bool Stop=false) {
    if(!Stop) {
        WorldInfo.Game.SetTimer(Speed, true, 'RandChangeDoorMeshType', Self);
    }
    else {
        WorldInfo.Game.ClearTimer('RandChangeDoorMeshType', Self);
    }
}

Exec Function RandChangeDoorMeshType() {
    local String MeshType;
    local Name SndMat;

    Switch(Rand(24)) {
        case 0:
            MeshType = "Undefined";
            break;
        case 1:
            MeshType = "Wooden";
            break;
        case 2:
            MeshType = "WoodenOld";
            break;
        case 3:
            MeshType = "WoodenWindow";
            break;
        case 4:
            MeshType = "WoodenWindowSmall";
            break;
        case 5:
            MeshType = "WoodenWindowOld";
            break;
        case 6:
            MeshType = "WoodenWindowOldSmall";
            break;
        case 7:
            MeshType = "Metal";
            break;
        case 8:
            MeshType = "MetalWindow";
            break;
        case 9:
            MeshType = "MetalWindowSmall";
            break;
        case 10:
            MeshType = "Enforced";
            break;
        case 11:
            MeshType = "Grid";
            break;
        case 12:
            MeshType = "Prison";
            break;
        case 13:
            MeshType = "Entrance";
            break;
        case 14:
            MeshType = "Bathroom";
            break;
        case 15:
            MeshType = "IsolatedCell";
            break;
        case 16:
            MeshType = "Locker";
            break;
        case 17:
            MeshType = "LockerRusted";
            break;
        case 18:
            MeshType = "LockerBeige";
            break;
        case 19:
            MeshType = "LockerGreen";
            break;
        case 20:
            MeshType = "LockerHole";
            break;
        case 21:
            MeshType = "Glass";
            break;
        case 22:
            MeshType = "Fence";
            break;
        case 23:
            MeshType = "Gate";
            break;
        case 24:
            MeshType = "ForceGate";
            break;
    }
    Switch(Rand(4)) {
        case 0:
            SndMat = 'Wood';
            break;
        case 1:
            SndMat = 'Metal';
            break;
        case 2:
            SndMat = 'SecurityDoor';
            break;
        case 3:
            SndMat = 'BigPrisonDoor';
            break;
        case 4:
            SndMat = 'BigWoodenDoor';
            break;
    }
    ChangeDoorMeshType(MeshType, SndMat);
}

Exec Function RandPlayerSpeed() {
    local PickerHero Hero;

    Hero = PickerHero(Pawn);
    Hero.NormalWalkSpeed = Rand(400);
    Hero.NormalRunSpeed = Rand(900);
    Hero.CrouchedSpeed = Rand(150);
    Hero.ElectrifiedSpeed = Rand(200);
    Hero.WaterWalkSpeed = Rand(200);
    Hero.WaterRunSpeed = Rand(400);
    Hero.LimpingWalkSpeed = Rand(174);
    Hero.HobblingWalkSpeed = Rand(280);
    Hero.HobblingRunSpeed = Rand(500);
    Hero.SpeedPenaltyBackwards = Rand(0.7);
    Hero.SpeedPenaltyStrafe = Rand(0.4);
    Hero.ForwardSpeedForJumpWalking = Rand(900);
    Hero.ForwardSpeedForJumpRunning = Rand(1300);
    Hero.JumpClearanceWalking = Rand(400);
    Hero.JumpClearanceRunning = Rand(600);
}

Exec Function KAActor() {
    local KActorFromStatic Act;
    local FracturedStaticMeshActor StaF;
    local StaticMeshActor Sta;
    local StaticMeshCollectionActor Stca;
    local StaticMeshComponent Comp;

    Act = Spawn(Class'KActorFromStatic');
    ConsoleCommand("set StaticMeshActor bStatic false");
    ConsoleCommand("set StaticMeshCollectionActor bStatic false");
    ConsoleCommand("set StaticMeshActor bMovable true");
    ConsoleCommand("set StaticMeshCollectionActor bMovable true");
    Foreach AllActors(Class'StaticMeshActor', Sta) {
        Act.MakeDynamic(Sta.StaticMeshComponent);
    }
    Foreach AllActors(Class'StaticMeshCollectionActor', Stca) {
        Foreach Stca.StaticMeshComponents(Comp) {
            Act.MakeDynamic(Comp);
        }
    }
    Foreach AllActors(Class'FracturedStaticMeshActor', StaF) {
        Act.MakeDynamic(StaF.FracturedStaticMeshComponent);
    }
    Act.Destroy();
    
}

Exec Function ToggleKAActor(Float Speed=0.3, Bool Stop=false) {
    if(Stop) {
        WorldInfo.Game.ClearTimer('KAActor', Self);
    }
    else {
        WorldInfo.Game.SetTimer(Speed, true, 'KAActor', Self);
    }
}

Exec Function CallRE( name EventName ) {
	local Array<SequenceObject> AllSeqEvents;
	local Sequence GameSeq;
	local Int i;

	GameSeq = WorldInfo.GetGameSequence();
	if(GameSeq != None) {
		//GameSeq.Reset();
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);
		for(i = 0; i < AllSeqEvents.Length; i++) {
			if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName == EventName)
				SeqEvent_RemoteEvent(AllSeqEvents[i]).CheckActivate(WorldInfo, None);
		}
	}
}

Exec Function ListRE() {
	local Array<SequenceObject> AllSeqEvents;
	local Sequence GameSeq;
	local Int i;

	GameSeq = WorldInfo.GetGameSequence();
	if(GameSeq != None) {
		//GameSeq.Reset();
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);
		for (i = 0; i < AllSeqEvents.Length; i++) {
			`log(String(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName));
		}
	}
}

Exec Function PossessPickerBot() {
    local OLEnemyPawn Enemy;
    local PickerBot Bot;

    Foreach AllActors(Class'OLEnemyPawn', Enemy) {
        if(Enemy.Controller.IsA('OLBot')) {
            Bot = Spawn(Class'PickerBot');
            Bot.Possess(Enemy, false);
            Enemy.PossessedBy(Bot, false);
        }
    }
}

Exec Function CantHideFromUs(Bool Stop=false) {
    local OLBot Bot;

    Foreach WorldInfo.AllControllers(Class'OLBot', Bot) {
        if(!Stop) {
            Bot.SightComponent.bAlwaysSeeTarget = true;
            Bot.SightComponent.bSawPlayerEnterHidingSpot = true;
            Bot.SightComponent.bSawPlayerEnterBed = true;
            Bot.SightComponent.bSawPlayerGoUnder = true;
            WorldInfo.Game.SetTimer(0.01, false, 'CantHideFromUs', Self);
        }
        else {
            WorldInfo.Game.ClearTimer('CantHideFromUs', Self);
            Bot.SightComponent.bAlwaysSeeTarget = false;
            Bot.SightComponent.bSawPlayerEnterHidingSpot = false;
            Bot.SightComponent.bSawPlayerEnterBed = false;
            Bot.SightComponent.bSawPlayerGoUnder = false;
        }
    }
}

Function Color RandColor(Byte Alpha) {
    local Color Color;

    Color.R = Rand(255);
    Color.G = Rand(255);
    Color.B = Rand(255);
    Color.A = Alpha;

    return Color;
}

Exec Function ppp() {
    SendMsg(ManualAutoCompleteList[0].Command);
}

Simulated Event PostBeginPlay() {

    Super(PlayerController).PostBeginPlay();
    if(TutorialManager != none) {
        TutorialManager.Clear();
    }
    bProfileSettingsUpdated = true;
    UpdateDifficultyBasedValues();
    CheatManager = new (Self) CheatClass;
    CheatManager.InitCheatManager();
}

State PlayerWalking {
    ignores SeePlayer, HearNoise, Bump;

    Function PlayerMove(Float DeltaTime) {
        local Rotator DeltaRot, DummyViewRotation;

        if(Pawn == None) {
            return;
        }
        if(!HUD.ShowingFullScreenOverlay()) {
            NativePlayerMove(DeltaTime);
            if(PlayerCamera != None) {
                DummyViewRotation = Rotation;
                DeltaRot.Yaw = Int(PlayerInput.aTurn);
                DeltaRot.Pitch = Int(PlayerInput.aLookUp);
                PlayerCamera.ProcessViewRotation(DeltaTime, DummyViewRotation, DeltaRot);
            }
        }       
    }
    stop;    
}

Function Float ScalebyCam(Float Float) { // Thanks speedrunhelper for idea <3
	Local Float Scale;
	Scale = (GetFOVAngle() / 100);

	Return Float * Scale;
}

Function Float ScalebyVel(Float Float) {
	Local Float Scale;
	Scale = (VSize(PickerHero(Pawn).Velocity) / 100 );

    SendMsg(String(Float * Scale));
    if(Float * Scale >= 5) {
        return 5;
    }
    else {
	    Return Float * Scale;
    }
}

Function Bool AllowAutoJump() {
    local OLCSA CSA;
    local OLPickableObject PO;
    local OLDoor Door;
    local OLGameplayItemPickup IP;
    local OLBatteriesPickupFactory Battery;
    local OLCollectiblePickup Doc;
    local OLPushableObject Push;
    local Vector C;
    local Rotator Rot;

    GetPlayerViewPoint(C, Rot);
    Foreach AllActors(Class'OLCSA', CSA) {
        if(VSize(C - CSA.Location) <= 150) {
            return True;
        }
    }
    Foreach AllActors(Class'OLPickableObject', PO) {
        if(VSize(C - PO.Location) <= 150) {
            return True;
        }
    }
    Foreach AllActors(Class'OLDoor', Door) {
        if(VSize(PickerHero(Pawn).Location - Door.Location) <= 100) {
            return True;
        }
    }
    Foreach AllActors(Class'OLGameplayItemPickup', IP) {
        if(VSize(C - IP.Location) <= 150) {
            return True;
        }
    }
    Foreach AllActors(Class'OLBatteriesPickupFactory', Battery) {
        if(VSize(C - Battery.Location) <= 150) {
            return True;
        }
    }
    Foreach AllActors(Class'OLCollectiblePickup', Doc) {
        if(VSize(C - Doc.Location) <= 150) {
            return True;
        }
    }
    Foreach AllActors(Class'OLPushableObject', Push) {
        if(VSize(PickerHero(Pawn).Location - Push.Location) <= 100) {
            return True;
        }
    }
    return False;
}

Event Tick(Float DeltaTime) {
    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportCurrentSize);
    PickerHero(Pawn).Camera.ViewCS.Yaw = 180;
    PickerHero(Pawn).Camera.ViewCS.Pitch = 180;
    if(PickerInput(PlayerInput).IsKeyPressed('LeftControl') || PickerInput(PlayerInput).IsKeyPressed('RightControl')) {
            PickerInput(PlayerInput).bCtrlPressed = true;
        }
    else {
        PickerInput(PlayerInput).bCtrlPressed = false;
    }
    if(PickerInput(PlayerInput).IsKeyPressed('LeftShift') || PickerInput(PlayerInput).IsKeyPressed('RightShift')) {
        PickerInput(PlayerInput).bShiftPressed = true;
    }
    else {
        PickerInput(PlayerInput).bShiftPressed = false;
    }
    Super.Tick(DeltaTime);
}

DefaultProperties
{
    ArrayPatientTypes(0) = "Soldier"
    ArrayPatientTypes(1) = "NanoCloud"
    ArrayPatientTypes(2) = "Groom"
    ArrayPatientTypes(3) = "Surgeon"
    ArrayPatientTypes(4) = "Cannibal"
    ArrayPatientTypes(5) = "Priest"
    ArrayPatientTypes(6) = "Patient"
    ArrayPatientModel(0) = "Dupont"
    ArrayPatientModel(1) = "Dupont2"
    ArrayPatientModel(2) = "Guard"
    ArrayPatientModel(3) = "GuardBloody"
    ArrayPatientModel(4) = "RapeVictim"
    ArrayPatientModel(5) = "SimpleBloodyHead"
    ArrayPatientModel(6) = "StraitJacketMutHead"
    ArrayPatientModel(7) = "Simple2MutArms"
    ArrayPatientModel(8) = "Simple2OneEye"
    ArrayPatientModel(9) = "StraitJacketNoEyes"
    ArrayPatientModel(10) = "NudeMutHead2Arm"
    ArrayPatientModel(11) = "SimplePuffyNoPants"
    ArrayPatientModel(12) = "SimpleBlind"
    ArrayPatientModel(13) = "SimpleNormal"
    ArrayPatientModel(14) = "SimplePuffy"
    ArrayPatientModel(15) = "SimpleOneEye"
    ArrayPatientModel(16) = "Simple2PuffyJeans"
    ArrayPatientModel(17) = "Simple2MutHead"
    ArrayPatientModel(18) = "Simple2MutHeadArms"
    ArrayPatientModel(19) = "SimplePuffyMutArm"
    ArrayPatientModel(20) = "Simple2MutArmsNoEyes"
    ArrayPatientModel(21) = "SimpleWeird"
    ArrayPatientModel(22) = "Simple2Mouth"
    ArrayPatientModel(23) = "WorkerBloody"
    ArrayPatientModel(24) = "StraitJacketBlind"
    ArrayPatientModel(25) = "PriestBurned"
    ArrayPatientModel(26) = "WorkerBloody2"
    ArrayPatientModel(27) = "WorkerBloody3"
    ArrayPatientModel(28) = "PyroManic"
    ArrayPatientModel(29) = "Blair"
    ArrayPatientModel(30) = "BlairExplode"
    ArrayPatientModel(31) = "NudeMouth"
    ArrayPatientModel(32) = "StraitJacketMouth"
    ArrayPatientModel(33) = "Swat"
    ArrayPatientModel(34) = "SwatMouth"
    ArrayPatientModel(35) = "SwatEyes"
    ArrayPatientModel(36) = "Licker"
    ArrayPatientModel(37) = "Masked"
    ArrayPatientModel(38) = "Hazmat"
    ArrayPatientModel(39) = "Scientist"
    ArrayPatientModel(40) = "Worker"
    ArrayPatientModel(41) = "Worker2"
    ArrayPatientModel(42) = "SimpleMutHead2"
    ArrayPatientModel(43) = "Scientist2"
    ArrayPatientModel(44) = "Scientist3"
    ArrayPatientModel(45) = "WorkerBloodyHeadless"
    fDebugSpeed = 0.0040
    fPlayerAnimRate = 1
    fEnemyAnimRate = 1
    vScaleEnemies = (X=1,Y=1,Z=1)
    vScalePlayer = (X=1,Y=1,Z=1)
    TeleportPosCoordsTemp = (X=0,Y=0,Z=0)
    SmallRandomTime = 5
    MediumRandomTime = 15
    LargeRandomTime = 30
    OneBatteryMode = true
    FastEnemyMode = true
    DisCamMode = false
    OneShotMode = true
    BadBatteryMode = true
    LimitedStaminaMode = true
    NoDarkMode = true
    SmartAIMode = true
    TrainingMode = false
    AlwaysSaveCheckpoint = false
    CustomPM = "Default"
    InputClass = Class'PickerInput'
    CheatClass = Class'OLCheatManager'
    TeleportSound = SoundCue'PickerDebugMenu.TeleportSound'
    ButtonSound = SoundCue'PickerDebugMenu.Button_Click'
    MenuMusic = SoundCue'PickerDebugMenu.MenuMusic'
    ManualAutoCompleteList(0)=(Command="Exit",Desc="Exit (Exits the game)")
    ManualAutoCompleteList(1)=(Command="DebugCreatePlayer 1",Desc="")
    ManualAutoCompleteList(2)=(Command="FreezeAt",Desc="Locks the player view and rendering time.")
    ManualAutoCompleteList(3)=(Command="SSSwapControllers",Desc="")
    ManualAutoCompleteList(4)=(Command="Open",Desc="Open <MapName> (Opens the specified map)")
    ManualAutoCompleteList(5)=(Command="DisplayAll",Desc="DisplayAll <ClassName> <PropertyName> (Display property values for instances of classname)")
    ManualAutoCompleteList(6)=(Command="DisplayAllState",Desc="DisplayAllState <ClassName> (Display state names for all instances of classname)")
    ManualAutoCompleteList(7)=(Command="DisplayClear",Desc="DisplayClear (Clears previous DisplayAll entries)")
    ManualAutoCompleteList(8)=(Command="FlushPersistentDebugLines",Desc="FlushPersistentDebugLines (Clears persistent debug line cache)")
    ManualAutoCompleteList(9)=(Command="GetAll ",Desc="GetAll <ClassName> <PropertyName> <Name=ObjectInstanceName> <OUTER=ObjectInstanceName> <SHOWDEFAULTS> <SHOWPENDINGKILLS> <DETAILED> (Log property values of all instances of classname)")
    ManualAutoCompleteList(10)=(Command="GetAllState",Desc="GetAllState <ClassName> (Log state names for all instances of classname)")
    ManualAutoCompleteList(11)=(Command="Obj List ",Desc="Obj List <Class=ClassName> <Type=MetaClass> <Outer=OuterObject> <Package=InsidePackage> <Inside=InsideObject>")
    ManualAutoCompleteList(12)=(Command="Obj ListContentRefs",Desc="Obj ListContentRefs <Class=ClassName> <ListClass=ClassName>")
    ManualAutoCompleteList(13)=(Command="Obj Classes",Desc="Obj Classes (Shows all classes)")
    ManualAutoCompleteList(14)=(Command="Obj Refs",Desc="Name=<ObjectName> Class=<OptionalObjectClass> Lists referencers of the specified object")
    ManualAutoCompleteList(15)=(Command="EditActor",Desc="EditActor <Class=ClassName> or <Name=ObjectName> or TRACE")
    ManualAutoCompleteList(16)=(Command="EditDefault",Desc="EditDefault <Class=ClassName>")
    ManualAutoCompleteList(17)=(Command="EditObject",Desc="EditObject <Class=ClassName> or <Name=ObjectName> or <ObjectName>")
    ManualAutoCompleteList(18)=(Command="ReloadCfg ",Desc="ReloadCfg <Class/ObjectName> (Reloads config variables for the specified object/class)")
    ManualAutoCompleteList(19)=(Command="ReloadLoc ",Desc="ReloadLoc <Class/ObjectName> (Reloads localized variables for the specified object/class)")
    ManualAutoCompleteList(20)=(Command="Set ",Desc="Set <ClassName> <PropertyName> <Value> (Sets property to value on objectname)")
    ManualAutoCompleteList(21)=(Command="Show BOUNDS",Desc="Show BOUNDS (Displays bounding boxes for all visible objects)")
    ManualAutoCompleteList(22)=(Command="Show BSP",Desc="Show BSP (Toggles BSP rendering)")
    ManualAutoCompleteList(23)=(Command="Show COLLISION",Desc="Show COLLISION (Toggles collision rendering)")
    ManualAutoCompleteList(24)=(Command="Show COVER",Desc="Show COVER (Toggles cover rendering)")
    ManualAutoCompleteList(25)=(Command="Show DECALS",Desc="Show DECALS (Toggles decal rendering)")
    ManualAutoCompleteList(26)=(Command="Show FOG",Desc="Show FOG (Toggles fog rendering)")
    ManualAutoCompleteList(27)=(Command="Show LEVELCOLORATION",Desc="Show LEVELCOLORATION (Toggles per-level coloration)")
    ManualAutoCompleteList(28)=(Command="Show PATHS",Desc="Show PATHS (Toggles path rendering)")
    ManualAutoCompleteList(29)=(Command="Show POSTPROCESS",Desc="Show POSTPROCESS (Toggles post process rendering)")
    ManualAutoCompleteList(30)=(Command="Show SKELMESHES",Desc="Show SKELMESHES (Toggles skeletal mesh rendering)")
    ManualAutoCompleteList(31)=(Command="Show TERRAIN",Desc="Show TERRAIN (Toggles terrain rendering)")
    ManualAutoCompleteList(32)=(Command="Show VOLUMES",Desc="Show VOLUMES (Toggles volume rendering)")
    ManualAutoCompleteList(33)=(Command="Show SPLINES",Desc="Show SPLINES (Toggles spline rendering)")
    ManualAutoCompleteList(34)=(Command="ShowSet",Desc="Sets a show flag to enable it")
    ManualAutoCompleteList(35)=(Command="ShowClear",Desc="Clears a show flag to disable it")
    ManualAutoCompleteList(36)=(Command="Stat FPS",Desc="Stat FPS (Shows FPS counter)")
    ManualAutoCompleteList(37)=(Command="Stat UNIT",Desc="Stat UNIT (Shows hardware unit framerate)")
    ManualAutoCompleteList(38)=(Command="Stat LEVELS",Desc="Stat LEVELS (Displays level streaming info)")
    ManualAutoCompleteList(39)=(Command="Stat GAME",Desc="Stat GAME (Displays game performance stats)")
    ManualAutoCompleteList(40)=(Command="Stat MEMORY",Desc="Stat MEMORY (Displays memory stats)")
    ManualAutoCompleteList(41)=(Command="Stat XBOXMEMORY",Desc="Stat XBOXMEMORY (Displays Xbox memory stats while playing on PC)")
    ManualAutoCompleteList(42)=(Command="Stat PHYSICS",Desc="Stat PHYSICS (Displays physics performance stats)")
    ManualAutoCompleteList(43)=(Command="Stat STREAMING",Desc="Stat STREAMING (Displays basic texture streaming stats)")
    ManualAutoCompleteList(44)=(Command="Stat STREAMINGDETAILS",Desc="Stat STREAMINGDETAILS (Displays detailed texture streaming stats)")
    ManualAutoCompleteList(45)=(Command="Stat COLLISION",Desc="Stat COLLISION")
    ManualAutoCompleteList(46)=(Command="Stat PARTICLES",Desc="Stat PARTICLES")
    ManualAutoCompleteList(47)=(Command="Stat SCRIPT",Desc="Stat SCRIPT")
    ManualAutoCompleteList(48)=(Command="Stat AUDIO",Desc="Stat AUDIO")
    ManualAutoCompleteList(49)=(Command="Stat ANIM",Desc="Stat ANIM")
    ManualAutoCompleteList(50)=(Command="Stat NET",Desc="Stat NET")
    ManualAutoCompleteList(51)=(Command="Stat LIST",Desc="Stat LIST Groups/Sets/Group (List groups of stats, saved sets, or specific stats within a specified group)")
    ManualAutoCompleteList(52)=(Command="Stat splitscreen",Desc="")
    ManualAutoCompleteList(53)=(Command="ListTextures",Desc="ListTextures (Lists all loaded textures and their current memory footprint)")
    ManualAutoCompleteList(54)=(Command="ListUncachedStaticLightingInteractions",Desc="ListUncachedStaticLightingInteractions (Lists all uncached static lighting interactions, which causes Lighting needs to be rebuilt messages)")
    ManualAutoCompleteList(55)=(Command="RestartLevel",Desc="RestartLevel (restarts the level)")
    ManualAutoCompleteList(56)=(Command="ListSounds",Desc="ListSounds (Lists all the loaded sounds and their memory footprint)")
    ManualAutoCompleteList(57)=(Command="ListWaves",Desc="ListWaves (List the WaveInstances and whether they have a source)")
    ManualAutoCompleteList(58)=(Command="ListSoundClasses",Desc="ListSoundClasses (Lists a summary of loaded sound collated by class)")
    ManualAutoCompleteList(59)=(Command="ListSoundModes",Desc="ListSoundModes (Lists loaded sound modes)")
    ManualAutoCompleteList(60)=(Command="ListAudioComponents",Desc="ListAudioComponents (Dumps a detailed list of all AudioComponent objects)")
    ManualAutoCompleteList(61)=(Command="ListSoundDurations",Desc="ListSoundDurations")
    ManualAutoCompleteList(62)=(Command="PlaySoundCue",Desc="PlaySoundCue (Lists a summary of loaded sound collated by class)")
    ManualAutoCompleteList(63)=(Command="PlaySoundWave",Desc="PlaySoundWave")
    ManualAutoCompleteList(64)=(Command="SetSoundMode",Desc="SetSoundMode <ModeName>")
    ManualAutoCompleteList(65)=(Command="DisableLowPassFilter",Desc="DisableLowPassFilter")
    ManualAutoCompleteList(66)=(Command="DisableEQFilter",Desc="DisableEQFilter")
    ManualAutoCompleteList(67)=(Command="IsolateDryAudio",Desc="IsolateDryAudio")
    ManualAutoCompleteList(68)=(Command="IsolateReverb",Desc="IsolateReverb")
    ManualAutoCompleteList(69)=(Command="ResetSoundState",Desc="ResetSoundState (Resets volumes to default and removes test filters)")
    ManualAutoCompleteList(70)=(Command="ModifySoundClass",Desc="ModifySoundClass <SoundClassName> Vol=<new volume>")
    ManualAutoCompleteList(71)=(Command="DisableAllScreenMessages",Desc="Disables all on-screen warnings/messages")
    ManualAutoCompleteList(72)=(Command="EnableAllScreenMessages",Desc="Enables all on-screen warnings/messages")
    ManualAutoCompleteList(73)=(Command="ToggleAllScreenMessages",Desc="Toggles display state of all on-screen warnings/messages")
    ManualAutoCompleteList(74)=(Command="CaptureMode",Desc="Toggles display state of all on-screen warnings/messages")
    ManualAutoCompleteList(75)=(Command="memleakcheck",Desc="")
    ManualAutoCompleteList(76)=(Command="togglehdwarning",Desc="")
    ManualAutoCompleteList(77)=(Command="Stat SOUNDWAVES",Desc="Stat SOUNDWAVES (Shows active SoundWaves)")
    ManualAutoCompleteList(78)=(Command="Stat SOUNDCUES",Desc="Stat SOUNDCUES (Shows active SoundCues)")
    ManualAutoCompleteList(79)=(Command="Stat SOUNDS",Desc="Stat SOUNDS <?> <sort=distance|class|name|waves|default> <-debug> <off> (Shows active SoundCues and SoundWaves)")
    ManualAutoCompleteList(80)=(Command="STARTMOVIECAPTURE",Desc="STARTMOVIECAPTURE")
    ManualAutoCompleteList(81)=(Command="STOPMOVIECAPTURE",Desc="STOPMOVIECAPTURE")
    ManualAutoCompleteList(82)=(Command="DoMemLeakChecking 30",Desc="Sets a timer to do a MemLeakCheck every N seconds")
    ManualAutoCompleteList(83)=(Command="StopMemLeakChecking",Desc="Stops the periodic MemLeakCheck that was started via DoMemLeakChecking")
    ManualAutoCompleteList(84)=(Command="ToggleOcclusion",Desc="Toggles use and submission of the occlusion queries,")
    ManualAutoCompleteList(85)=(Command="ToggleMultiThreadedRendering",Desc="Toggles use of multithreaded rendering on platforms that supports it.")
    ManualAutoCompleteList(86)=(Command="ShowDebug OLAI",Desc="ShowDebug OLAI (Shows Outlast AI Info)")
    ManualAutoCompleteList(87)=(Command="ShowDebug VOICEMANAGER",Desc="ShowDebug VOICEMANAGER (Shows VoiceManager Info)")
}