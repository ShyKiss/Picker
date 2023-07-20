Class PickerHero extends OLHero
    Config(Picker);

var PickerController Controller;
var PickerInput Input;
var OLAnimBlendBySpeed AnimBlendBySpeed;
var Bool bGodMode, bNoclip, bEnabledLight;

Event Landed(Vector HitNormal, Actor FloorActor) {
    local Vector Impulse;

    if(!Controller.bBhop) {
        Super.Landed(HitNormal, FloorActor);
        return;
    }
    TakeFallingDamage();
}

Function PlayLanded(Float ImpactVel) {
    if(!Controller.RandomizerState) {
        SetSwitch(FloorMaterialGroup, GetMaterialBelowFeet());
    }
    else {
        SetSwitch(FloorMaterialGroup, RandFloorMaterial());
    }
    NativePlayLanded(ImpactVel);
}

Function PossessedBy(Controller C, Bool bVehicleTransition) {
    //`Log("Player Respawned");
    PickerController(C).InitPlayerModel();
    //PickerController(C).LoadCurrent();
    Super.PossessedBy(C, bVehicleTransition);
    Controller = PickerController(C);
    Input = PickerInput(Controller.Playerinput);
}

Event TakeDamage(Int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, Class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) {
    if(bGodMode) {
        return;
    }
    else {
        Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
    }
}

Event Bool HealDamage(Int Amount, Controller Healer, Class<DamageType> DamageType) {
    if((Health > 0) && Health < 100) {
        Health = Min(100, Health + Amount);
        PreciseHealth = float(Health);
        return true;
    }
    else {
        return false;
    }
}


Function TakeFallingDamage() {
    if(bGodMode) {
        return;
    }
    else if(bNoclip) {
        return;
    }
    else {
        NativeTakeFallingDamage();
    }
}

Simulated Event FellOutOfWorld(Class<DamageType> DmgType) {
    if(!bNoclip) {
        ConsoleCommand("TogglePickerMenu false");
        Super.FellOutOfWorld(DmgType);
    }
}

Singular Simulated Event OutsideWorldBounds() {
    if(!bNoclip) {
        ConsoleCommand("TogglePickerMenu false");
        RespawnHero();
    }
}

Function SpawnBloodFootstepDecal(Bool bLeftFoot, Float Alpha, optional Bool CustomStep=false, optional MaterialInstanceConstant FootstepMatL, optional MaterialInstanceConstant FootstepMatR) {
    local MaterialInstanceConstant ParentMI, DecalMI;
    local Vector DecalLocation;
    local Rotator DecalRotation;

    GetFootstepDecalTransform(bLeftFoot, DecalLocation, DecalRotation);
    if(!Controller.RandomizerState) {
        if(IsBarefeet()) {
            if(bLeftFoot) {
                if(!CustomStep) {
                    if(Rand(2)  ==  0) {
                        ParentMI = FootstepBarefeetDecalMatL1;
                    }
                    else {
                        ParentMI = FootstepBarefeetDecalMatL2;
                    }
                }
                else {
                    ParentMI = FootstepMatL;
                }
            }
            else {
                if(!CustomStep) {
                    if(Rand(2)  ==  0) {
                        ParentMI = FootstepBarefeetDecalMatR1;
                    }
                    else {
                        ParentMI = FootstepBarefeetDecalMatR2;
                    }
                }
                else {
                    ParentMI = FootstepMatR;
                }
            }
        }
        else {
            if(bLeftFoot) {
                if(!CustomStep) {
                    if(Rand(2)  ==  0) {
                        ParentMI = FootstepDecalMatL1;
                    }
                    else {
                        ParentMI = FootstepDecalMatL2;
                    }
                }
                else {
                    ParentMI = FootstepMatL;
                }
            }
            else {
                if(!CustomStep) {
                    if(Rand(2)  ==  0) {
                        ParentMI = FootstepDecalMatR1;
                    }
                    else {
                        ParentMI = FootstepDecalMatR2;
                    }
                }
                else {
                    ParentMI = FootstepMatR;
                }
            }
        }
    }
    else {
        Switch(Rand(7)) {
            case 0:
                ParentMI = FootstepDecalMatL1;
                break;
            case 1:
                ParentMI = FootstepDecalMatL2;
                break;
            case 2:
                ParentMI = FootstepDecalMatR1;
                break;
            case 3:
                ParentMI = FootstepDecalMatR2;
                break;
            case 4:
                ParentMI = FootstepBarefeetDecalMatL1;
                break;
            case 5:
                ParentMI = FootstepBarefeetDecalMatL2;
                break;
            case 6:
                ParentMI = FootstepBarefeetDecalMatR1;
                break;
            case 7:
                ParentMI = FootstepBarefeetDecalMatR2;
                break;
        }
    }
    DecalMI = new (Self) Class'MaterialInstanceConstant';
    DecalMI.SetParent(ParentMI);
    DecalMI.SetScalarParameterValue('Opacity', Alpha);
    WorldInfo.MyDecalManager.SpawnDecal(DecalMI, DecalLocation, DecalRotation, 18.750, 37.50, 5.0, false, 0.0, none, false, false,,,, 90.0);  
}
simulated Event PlayFootStepSound(Int FootDown, AnimNotify_Footstep FootstepNotify) {
    local name SurfaceMat;
    local Float DecalAlpha;

    /*if(((WorldInfo.TimeSeconds < (LastFootstepTime + 0.20)) || WorldInfo.TimeSeconds < (SpawnTime + 0.750)) || IsInMainMenu()) {
        return;
    }*/
    if((VSizeSq2D(OLPC.LastPlayerInputintent) > 25.0) || FootstepNotify.bNoVelocityRequired) {
        LastFootstepTime = WorldInfo.TimeSeconds;
        if(!Controller.RandomizerState) {
            SurfaceMat = GetMaterialBelowFeet();
        }
        else {
            SurfaceMat = RandFloorMaterial();
        }
        SetSwitch(FloorMaterialGroup, SurfaceMat);
        if(!Controller.RandomizerState) {
            if(FootstepNotify.bForceRunEvent || (IsRunning()) && !FootstepNotify.bForceWalkEvent) {
                PlayAkEvent(FootStepSound_Run);
            }
            else {
                PlayAkEvent(FootStepSound_Walk);
            }
        }
        else {
            if(Controller.RandBool()) {
                PlayAkEvent(FootStepSound_Walk);
            }
            else {
                PlayAkEvent(FootStepSound_Run);
            }
        }
        if(WorldInfo.GetDetailMode() != 0) {
            if(SurfaceMat  ==  WaterMaterial) {
                ActivateWaterFootstepParticles(FootDown  ==  1);
            }
            else {
                if(SurfaceMat  ==  BloodMaterial) {
                    RemainingBloodyFootsteps = NumBloodyFootsteps;
                }
            }
            if(RemainingBloodyFootsteps > 0) {
                if(Float(RemainingBloodyFootsteps) > (0.750 * Float(NumBloodyFootsteps))) {
                    DecalAlpha = 1.0;
                }
                else {
                    DecalAlpha = Float(RemainingBloodyFootsteps) / (0.750 * Float(NumBloodyFootsteps));
                }
                SpawnBloodFootstepDecal(FootDown  ==  0, DecalAlpha);
                -- RemainingBloodyFootsteps;
            }
        }
    }   
}

Event RespawnHero() {
    local PickerGame Game;
    local OLEngine Engine;
    local EmitterPool PickerPools;
    local Vector C;
    local Rotator Rot;
    local String CCP;
    local PickerHero Hero;

    Engine = OLEngine(Class'Engine'.static.GetEngine());
    Game = PickerGame(WorldInfo.Game);
    CCP = String(Game.CurrentCheckpointName);
    Controller.GetPlayerViewPoint(C, Rot);
    //Hero = Spawn(Class'PickerHero',,,C, Rot);
    //Controller.UnPossess();
    //Controller.Possess(Hero, false);
    Controller.TogglePickerMenu(false);
    Foreach AllActors(Class'EmitterPool', PickerPools) {
        if(PickerPools.Tag == 'PppickerPool') {
            PickerPools.Destroy();
        }
    }
    if(Controller.bAnimFree) {
        Controller.AnimFree();
    }
    if(bGodMode) {
        Controller.ToggleGodMode();
    }
    if(Controller.bDebugFullyGhost) {
        Controller.ToggleGhost();
    }
    if(Controller.bDebugGhost) {
        Controller.ToggleNoclip();
    }
    if(Controller.bDebugFixedCam) {
        Controller.ToggleFixedcam();
    }
    if(!Controller.UsingFirstPersonCamera()) {
        Controller.ToggleFreecam();
    }
    if(PickerHud(Controller.HUD).TSVBool) {
        Controller.TSVCommand();
    }
    if((Game != none) && Game.DifficultyMode == 3) {
            if(Class'OLUtils'.static.IsPlayingDLC()) {
                Controller.StartNewGameAtCheckpoint("Hospital_Free", false);
            }
            else {
                Controller.StartNewGameAtCheckpoint("Admin_Gates", false);
            }
            Controller.bForceLevelReset = true;
        }
    else {
        if(Controller.RandomizerState && Controller.RandomizerChallengeMode) {
            if(Left(CCP, 5) ~= "Admin" && GetRightMost(CCP) != "Gates") {
                Engine.CurrentCheckpointSave.CheckpointName = "Admin_Gates";
            }
            else if(Left(CCP, 6) ~= "Prison" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Prison_Start";
            }
            else if(Left(CCP, 5) ~= "Sewer" && GetRightMost(CCP) != "start") {
                Engine.CurrentCheckpointSave.CheckpointName = "sewer_start";
            }
            else if(Left(CCP, 4) ~= "Male" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Male_Start";
            }
            else if(Left(CCP, 9) ~= "Courtyard" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Courtyard_Start";
            }
            else if(Left(CCP, 6) ~= "Female" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Female_Start";
            }
            else if(Left(CCP, 7) ~= "Revisit" && GetRightMost(CCP) != "Soldier1") {
                Engine.CurrentCheckpointSave.CheckpointName = "Revisit_Start";
            }
            else if(Left(CCP, 3) ~= "Lab" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Lab_Start";
            }
            else if(Left(CCP, 7) ~= "DLC_Lab" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "DLC_Lab_Start";
            }
            else if(Left(CCP, 8) ~= "Hospital" && GetRightMost(CCP) != "Free") {
                Engine.CurrentCheckpointSave.CheckpointName = "Hospital_Free";
            }
            else if(Left(CCP, 3) ~= "Courtyard1" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Courtyard1_Start";
            }
            else if(Left(CCP, 3) ~= "Courtyard2" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Courtyard2_Start";
            }
            else if(Left(CCP, 13) ~= "PrisonRevisit" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "PrisonRevisit_Start";
            }
            else if(Left(CCP, 9) ~= "Building2" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "Building2_Start";
            }
            else if(Left(CCP, 10) ~= "AdminBlock" && GetRightMost(CCP) != "Start") {
                Engine.CurrentCheckpointSave.CheckpointName = "MaleRevisit_Start";
            }
        }
        Controller.UnPossess();
        Destroy();
        Controller.PlayerDied();
        Class'OLGameStateList'.static.OnPlayerDeath();
        if((Engine != None) && Engine.CurrentCheckpointSave != None) {
            Engine.StartCurrentCheckpoint();
        }
        else {
            WorldInfo.Game.RestartPlayer(Controller);
            Controller.ClientSetCameraFade(false);
        }
    }
}

Function Name RandFloorMaterial() {
    Switch(Rand(11)) {
        case 0:
            return 'carpet';
            break;
        case 1:
            return 'concrete';
            break;
        case 2:
            return 'Wood';
            break;
        case 3:
            return 'Metal_Light';
            break;
        case 4:
            return 'Water';
            break;
        case 5:
            return 'Blood';
            break;
        case 6:
            return 'Grass';
            break;
        case 7:
            return 'Water_Small';
            break;
        case 8:
            return 'Metal_Loud';
            break;
        case 9:
            return 'Crutch';
            break;
        case 10:
            return 'AIRVENT';
            break;
        case 11:
            return 'Water_Deep';
            break;
    }
}

Function PostBeginPlay() {
    Super.PostBeginPlay();
    
}

DefaultProperties
{
    begin object name=MyLightEnvironment
		bEnabled=True
		bUseBooleanEnvironmentShadowing=false
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bForceNonCompositeDynamicLights=true
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	begin object name=WPawnSkeletalMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object

	//This is what is used for the shadow.
	begin object name=ShadowProxyComponent
		LightEnvironment=DynamicLightEnvironmentComponent'MyLightEnvironment'
	End Object

	// This is the head mesh seen in the shadow. 
	begin object name=HeadMeshComp
		LightEnvironment=DynamicLightEnvironmentComponent'MyLightEnvironment'
	End Object

}