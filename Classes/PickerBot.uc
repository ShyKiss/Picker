Class PickerBot extends OLBot;

event BashDoorNotify()
{
    local PickerMoveDoor DoorCmd;

    DoorCmd = PickerMoveDoor(GetActiveCommand());
    // End:0x7B
    //if((ActiveDoor != none) && DoorCmd != none)
    //{
        ActiveDoor.BreakDoor(EnemyPawn, DoorCmd.bReversed);
    //}
    //return;    
}

event BreakDoorNotify()
{
    local PickerMoveDoor DoorCmd;

    DoorCmd = PickerMoveDoor(GetActiveCommand());
    // End:0x84
    //if((ActiveDoor != none) && DoorCmd != none)
    //{
        ActiveDoor.BreakDoor(EnemyPawn, DoorCmd.bReversed);
    //}
    //return;    
}

auto state Idle
{
    function BeginState(name PreviousStateName)
    {
        OLNavHandle.ClearPath();
        EnemyPawn.StartIdleSound();
    }

Begin:
    Sleep(0.50);
    goto 'Begin';
    stop;        
}

state Moving
{
    function BeginState(name PreviousStateName)
    {
        CurrentMoveStatus = 0;
        LastMoveFailedReason = 0;
        EnemyPawn.StartIdleSound();
        //return;        
    }

    function EndState(name NextStateName)
    {
        bReGeneratePath = false;
        bFinishedDoor = false;
        ClearCurrentMove();
        //return;        
    }

    function bool GeneratePath()
    {
        local bool bGenerateSucceeded;

        NavigationHandle.SetFinalDestination(CurrentMove.ValidatedMovePoint);
        MoveLastLocation = CurrentMove.DestinationPoint;
        MoveTimeSinceLastPath = 0.0;
        // End:0x368
        if(!NavigationHandle.PointReachable(CurrentMove.ValidatedMovePoint) && VSizeSq(CurrentMove.ValidatedMovePoint - EnemyPawn.Location) > (30.0 * 30.0))
        {
            bGenerateSucceeded = GeneratePathToLocation(CurrentMove.ValidatedMovePoint, CurrentMove.DestinationBuffer);
            // End:0x33D
            if(bGenerateSucceeded)
            {
                bTrimmedToDoor = false;
                // End:0x26D
                if(CurrentMove.bIsInvestigation)
                {
                    // End:0x1D9
                    if(OLNavHandle.TrimPathToLastDoor(CurrentMove.ValidatedMovePoint))
                    {
                        bTrimmedToDoor = true;
                        return true;
                    }
                    // End:0x26A
                    else
                    {
                        // End:0x205
                        if(bFinishedDoor)
                        {
                            CurrentMoveStatus = 1;
                            GotoState('Idle');
                            return false;
                        }
                        // End:0x26A
                        else
                        {
                            // End:0x24E
                            if(OLNavHandle.TrimPathByDistance(500.0, CurrentMove.ValidatedMovePoint))
                            {
                                return true;
                            }
                            // End:0x26A
                            else
                            {
                                CurrentMoveStatus = 1;
                                GotoState('Idle');
                                return false;
                            }
                        }
                    }
                }
                // End:0x338
                else
                {
                    MoveModifiedBufferDist = CurrentMove.DestinationBuffer - VSize(CurrentMove.DestinationPoint - CurrentMove.ValidatedMovePoint);
                    // End:0x2F3
                    if(MoveModifiedBufferDist < 0.0)
                    {
                        MoveModifiedBufferDist = 0.0;
                    }
                    OLNavHandle.TrimPathByDistance(MoveModifiedBufferDist, CurrentMove.ValidatedMovePoint, true);
                }
                return true;
            }
            // End:0x365
            else
            {
                CurrentMoveStatus = 2;
                LastMoveFailedReason = 3;
                GotoState('Idle');
                return false;
            }
        }
        // End:0x582
        else
        {
            // End:0x3B6
            if(CurrentMove.bIsInvestigation && bFinishedDoor)
            {
                CurrentMoveStatus = 1;
                GotoState('Idle');
                return false;
            }
            // End:0x582
            else
            {
                TempTrimAmount = CurrentMove.DestinationBuffer;
                // End:0x41A
                if(CurrentMove.bIsInvestigation)
                {
                    TempTrimAmount = float(Max(int(TempTrimAmount), 500));
                }
                MoveModifiedBufferDist = TempTrimAmount - VSize(CurrentMove.DestinationPoint - CurrentMove.ValidatedMovePoint);
                // End:0x48D
                if(MoveModifiedBufferDist < 0.0)
                {
                    MoveModifiedBufferDist = 0.0;
                }
                // End:0x519
                if(Square(MoveModifiedBufferDist) > VSizeSq(CurrentMove.ValidatedMovePoint - EnemyPawn.Location))
                {
                    CurrentMove.ValidatedMovePoint = EnemyPawn.Location;
                }
                // End:0x580
                else
                {
                    CurrentMove.ValidatedMovePoint -= (Normal(CurrentMove.DestinationPoint - EnemyPawn.Location) * MoveModifiedBufferDist);
                }
                return false;
            }
        }
        //return ReturnValue;        
    }

    function bool ReachedDestination()
    {
        local bool bReachedDestination;

        // End:0x70
        if(VSizeSq(CurrentMove.DestinationPoint - EnemyPawn.Location) < Square(CurrentMove.DestinationBuffer))
        {
            bReachedDestination = true;
        }
        // End:0xB7
        else
        {
            bReachedDestination = Pawn.ReachedPoint(CurrentMove.ValidatedMovePoint, none);
        }
        return bReachedDestination;
        //return ReturnValue;        
    }

Begin:
    bReGeneratePath = false;
    bMoveCancelled = false;
    // End:0x5C
    if(NextMove.Type != 0)
    {
        CurrentMove = NextMove;
        ClearNextMove();
    }
    // End:0xA54
    if((Pawn != none) && CurrentMove.Type != 0)
    {
        // End:0x237
        if(!NavigationHandle.FindPylon())
        {
            // End:0x140
            if(!GetClosestPointOnNavMesh(MoveTempDest, EnemyPawn.Location))
            {
                DebugMessagePlayer(string(EnemyPawn) $ " not on NavMesh!");
                CurrentMoveStatus = 2;
                LastMoveFailedReason = 1;
                GotoState('Idle');
            }
            // End:0x237
            else
            {
                MoveTo(MoveTempDest, none, -25.0);
                // End:0x179
                if(bReGeneratePath)
                {
                    bReGeneratePath = false;
                    goto 'Begin';
                }
                // End:0x237
                else
                {
                    // End:0x237
                    if(VSize2D(EnemyPawn.Location - MoveTempDest) > 10.0)
                    {
                        DebugMessagePlayer(string(EnemyPawn) $ " can't move to NavMesh. Teleporting.");
                        EnemyPawn.StartSpecialMove(100, MoveTempDest, vect(0.0, 0.0, 0.0), 0);
                        WaitForSpecialMove();
                    }
                }
            }
        }
        // End:0x448
        if(CurrentMove.Type == 2)
        {
            // End:0x317
            if(bPatrolToPlayer && BehaviorState == 1)
            {
                CurrentMove.DestinationPoint = PatrolToPlayerLastLocation;
                // End:0x314
                if(!GetClosestPointOnNavMesh(CurrentMove.ValidatedMovePoint, CurrentMove.DestinationPoint))
                {
                    CurrentMoveStatus = 2;
                    LastMoveFailedReason = 2;
                    GotoState('Idle');
                }
            }
            // End:0x445
            else
            {
                CurrentMove.DestinationPoint = CurrentMove.DestinationActor.Location;
                // End:0x445
                if(!GetClosestPointToActor(CurrentMove.ValidatedMovePoint, CurrentMove.DestinationActor, CurrentMove.DestinationBuffer))
                {
                    // End:0x41F
                    if(!CurrentMove.bIsDynamic)
                    {
                        DebugMessagePlayer(string(EnemyPawn) $ " destination not on NavMesh!");
                    }
                    CurrentMoveStatus = 2;
                    LastMoveFailedReason = 2;
                    GotoState('Idle');
                }
            }
        }
        // End:0x588
        else
        {
            // End:0x4C4
            if(NavigationHandle.PointReachable(CurrentMove.DestinationPoint))
            {
                CurrentMove.ValidatedMovePoint = CurrentMove.DestinationPoint;
            }
            // End:0x588
            else
            {
                // End:0x588
                if(!GetClosestPointOnNavMesh(CurrentMove.ValidatedMovePoint, CurrentMove.DestinationPoint))
                {
                    // End:0x562
                    if(!CurrentMove.bIsDynamic)
                    {
                        DebugMessagePlayer(string(EnemyPawn) $ " destination not on NavMesh!");
                    }
                    CurrentMoveStatus = 2;
                    LastMoveFailedReason = 2;
                    GotoState('Idle');
                }
            }
        }
        // End:0x8D1
        if(GeneratePath())
        {
            bFinishedDoor = false;
            J0x5A1:
            // End:0x8CE [Loop If]
            if(((Pawn != none) && !ReachedDestination()) && !bMoveCancelled)
            {
                // End:0x7DC
                if(OLNavHandle.GetNextMovePath(MoveTempPath, 10.0))
                {
                    MoveTempDest = MoveTempPath[MoveTempPath.Length - 1];
                    // End:0x70F
                    if(!NavigationHandle.SuggestMovePreparation(MoveTempDest, self))
                    {
                        // End:0x6F8
                        if(((MoveTempDest == CurrentMove.ValidatedMovePoint) && CurrentMove.bFocusOnActor) && CurrentMove.Type == 2)
                        {
                            MoveAlongPath(MoveTempPath, CurrentMove.DestinationActor);
                        }
                        // End:0x70C
                        else
                        {
                            MoveAlongPath(MoveTempPath);
                        }
                    }
                    // End:0x7D9
                    else
                    {
                        // End:0x7B0
                        if(QueuedCommand != none)
                        {
                            PushQueuedCommand();
                            // End:0x75F
                            if((bReGeneratePath && bRegenerateWhilePerforming) && IsAtTrimmedDoor())
                            {
                                bReGeneratePath = false;
                            }
                            // End:0x7AD
                            if(NextMove.Type != 0)
                            {
                                CurrentMove = NextMove;
                                ClearNextMove();
                                goto 'Begin';
                            }
                        }
                        // End:0x7D9
                        else
                        {
                            MoveLastLocation = vect(0.0, 0.0, 0.0);
                            Sleep(0.10);
                            goto 'Begin';
                        }
                    }
                }
                // End:0x805
                else
                {
                    MoveLastLocation = vect(0.0, 0.0, 0.0);
                    Sleep(0.10);
                    goto 'Begin';
                }
                // End:0x8CB
                if(!ReachedDestination())
                {
                    // End:0x8A8
                    if((CurrentMove.bIsDynamic && CurrentMove.Type == 2) && CurrentMove.DestinationActor.Location != MoveLastLocation)
                    {
                        goto 'Begin';
                    }
                    // End:0x8CB
                    if(bReGeneratePath)
                    {
                        bReGeneratePath = false;
                        goto 'Begin';
                    }
                }
            }
        }
        // End:0x9AF
        else
        {
            bFinishedDoor = false;
            OLNavHandle.ClearPath();
            // End:0x989
            if(CurrentMove.bFocusOnActor && CurrentMove.Type == 2)
            {
                MoveTo(CurrentMove.ValidatedMovePoint, CurrentMove.DestinationActor, -20.0);
            }
            // End:0x9AF
            else
            {
                MoveTo(CurrentMove.ValidatedMovePoint,, -20.0);
            }
        }
        // End:0xA54
        if(((!ReachedDestination() && CurrentMove.bIsDynamic) && CurrentMove.Type == 2) && CurrentMove.DestinationActor.Location != MoveLastLocation)
        {
            goto 'Begin';
        }
    }
    // End:0xA70
    if(ReachedDestination())
    {
        CurrentMoveStatus = 1;
    }
    // End:0xA88
    else
    {
        CurrentMoveStatus = 2;
        LastMoveFailedReason = 0;
    }
    GotoState('Idle');
    stop;        
}

state Turning
{
    function BeginState(name PreviousStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        OLNavHandle.ClearPath();
        ClearDestination();
        EnemyPawn.StartIdleSound();
        bTurning = true;
        //return;        
    }

    function EndState(name NextStateName)
    {
        bTurning = false;
        //return;        
    }

Begin:
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(TurnToDirection);
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(TurnToDirection);
    // End:0xBD
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    GotoState('Idle');
    stop;                    
}

state Animating
{
    function BeginState(name PreviousStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        OLNavHandle.ClearPath();
        ClearDestination();
        EnemyPawn.StartIdleSound();
        //return;        
    }

    function EndState(name NextStateName)
    {
        local AnimNodeSequence CustomSequence;

        EnemyPawn.DisableRootMotion();
        CustomSequence = EnemyPawn.FullBodyAnimSlot.GetCustomAnimNodeSeq();
        // End:0xE6
        if((CustomSequence != none) && CustomSequence.AnimSeqName == CurrentAnimation.AnimationName)
        {
            EnemyPawn.FullBodyAnimSlot.StopCustomAnim(0.10);
        }
        ClearAnimation();
        // End:0x138
        if(EnemyPawn.SpecialMove == 99)
        {
            EnemyPawn.CancelSpecialMove();
        }
        EnemyPawn.ResetDesiredRotation();
        //return;        
    }

Begin:
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    // End:0xF8
    if(RDiff(TurnToDirection, EnemyPawn.Rotation) > 0.0010)
    {
        EnemyPawn.TurnOnSpot(TurnToDirection);
        WaitForSpecialMove();
        EnemyPawn.SetDesiredRotation(TurnToDirection);
        // End:0xF8
        if(!EnemyPawn.ReachedDesiredRotation())
        {
            FinishRotation();
        }
    }
    // End:0x141
    if(CurrentAnimation.bOnWaypoint)
    {
        GetCurrentWaypoint().AnimStartedEvent(EnemyPawn);
    }
    // End:0x1C7
    if(CurrentAnimation.bAlign)
    {
        EnemyPawn.StartSpecialMove(99, CurrentAnimation.AlignLocation, CurrentAnimation.AlignRotation, 0);
        WaitForSpecialMove();
    }
    EnemyPawn.ResetDesiredRotation();
    PlayFullBodyAnim(CurrentAnimation.AnimationName, CurrentAnimation.Rate, CurrentAnimation.BlendInTime, CurrentAnimation.BlendOutTime, CurrentAnimation.bLoop, CurrentAnimation.StartTime, CurrentAnimation.EndTime);
    EnemyPawn.EnableRootMotion();
    WaitForFullBodyAnim();
    GotoState('Idle');
    stop;                
}

state Attacking
{
    function BeginState(name PreviousStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        OLNavHandle.ClearPath();
        ClearDestination();
        bAttacking = true;
        bTookDamage = false;
        EnemyPawn.StopIdleSound();
        // End:0xB8
        if(Group != none)
        {
            Group.TakeAttackToken(self);
        }
        bEnableHeadTracking = false;
        //return;        
    }

    function EndState(name NextStateName)
    {
        EnemyPawn.LockDesiredRotation(false);
        EnemyPawn.ResetDesiredRotation();
        bAttacking = false;
        bKilling = false;
        // End:0x87
        if(Group != none)
        {
            Group.ReturnAttackToken(self);
        }
        bEnableHeadTracking = true;
        //return;        
    }

    function ThrowPlayer()
    {
        EnemyPawn.ThrowRotation = ThrowPlayerRotation;
        EnemyPawn.StartSpecialMove(84);
        TargetPlayer.TryThrowPlayer(EnemyPawn, ThrowPlayerRotation);
        //return;        
    }

    function bool TargetInSpecialLocation()
    {
        return (TargetPlayer != none) && (TargetPlayer.IsInLocker() || TargetPlayer.LocomotionMode == 10) || TargetPlayer.LocomotionMode == 6;
        //return ReturnValue;        
    }
    stop;    
}

state AttackNormal extends Attacking
{
    function EndState(name NextStateName)
    {
        super.EndState(NextStateName);
        bUseQuickAttack = false;
        //return;        
    }

Begin:
    WaitForSpecialMove();
    // End:0x97
    if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
    {
        PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.10, 0.10);
        WaitForFullBodyAnim();
    }
    // End:0xC3
    if((TargetInSpecialLocation()) || !IsInApproachAttackRange())
    {
        GotoState('Idle');
    }
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation), true);
    // End:0x184
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    J0x184:
    // End:0x1C9 [Loop If]
    if((TargetPlayer != none) && TargetPlayer.SpecialMove != 0)
    {
        Sleep(0.10);
    }
    // End:0x206
    if(((TargetInSpecialLocation()) || !PerformAttackCheck()) || !IsInFinalAttackRange())
    {
        GotoState('Idle');
    }
    // End:0x297
    if(bUseQuickAttack)
    {
        EnemyPawn.StartSpecialMove(77, EnemyPawn.Location, Normal2D(TargetPlayer.Location - EnemyPawn.Location), 0);
    }
    // End:0x2B6
    else
    {
        EnemyPawn.StartNormalAttack();
    }
    WaitForSpecialMove();
    EnemyPawn.LockDesiredRotation(false);
    EnemyPawn.ZeroMovementVariables();
    ClearCurrentMove();
    EnemyPawn.StartIdleSound();
    // End:0x35C
    if(Group != none)
    {
        Group.ReturnAttackToken(self);
    }
    // End:0x384
    else
    {
        AttackTimer = EnemyPawn.AttackNormalRecovery;
    }
    GotoState('Idle');
    stop;        
}

state AttackSqueeze extends Attacking
{
    function EndState(name NextStateName)
    {
        super.EndState(NextStateName);
        SightComponent.bSawPlayerInSqueeze = false;
        SightComponent.LastSqueeze = none;
        //return;        
    }

Begin:
    WaitForSpecialMove();
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation), true);
    // End:0xCC
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    // End:0xFD
    if(bAttackRight)
    {
        EnemyPawn.EnemyMode = 4;
    }
    // End:0x11E
    else
    {
        EnemyPawn.EnemyMode = 3;
    }
    EnemyPawn.StartSpecialMove(79, AttackStartLocation, AttackStartRotation, 0);
    WaitForSpecialMove(true);
    // End:0x339
    if((VSizeSq(EnemyPawn.Location - TargetPlayer.Location) < (EnemyPawn.AttackSqueezeRange * EnemyPawn.AttackSqueezeRange)) && TargetPlayer.TryGrabFromSqueeze(EnemyPawn))
    {
        EnemyPawn.LockDesiredRotation(false);
        EnemyPawn.StartSpecialMove(83);
        bAttackCycling = false;
        // End:0x2A4
        if(EnemyPawn.bCanThrow)
        {
            WaitForSpecialMove(true);
            ThrowPlayer();
            WaitForSpecialMove();
        }
        // End:0x2AF
        else
        {
            WaitForSpecialMove();
        }
        // End:0x2E1
        if(Group != none)
        {
            Group.ReturnAttackToken(self);
        }
        // End:0x309
        else
        {
            AttackTimer = EnemyPawn.AttackThrowRecovery;
        }
        EnemyPawn.StartIdleSound();
        GotoState('Idle');
    }
    // End:0x368
    else
    {
        EnemyPawn.StartSpecialMove(80);
        WaitForSpecialMove();
    }
    bAttackCycling = true;
    SetTimer(EnemyPawn.AttackSqueezeCycleTime, false, 'AttackCycleEnd');
    J0x3A0:
    // End:0x64B [Loop If]
    if(bAttackCycling)
    {
        // End:0x640
        if((VSizeSq(EnemyPawn.Location - TargetPlayer.Location) < (EnemyPawn.AttackSqueezeRange * EnemyPawn.AttackSqueezeRange)) && TargetPlayer.CanGrabFromSqueeze())
        {
            EnemyPawn.StartSpecialMove(82);
            WaitForSpecialMove(true);
            // End:0x60E
            if(TargetPlayer.TryGrabFromSqueeze(EnemyPawn))
            {
                EnemyPawn.LockDesiredRotation(false);
                EnemyPawn.StartSpecialMove(83);
                bAttackCycling = false;
                ClearTimer('AttackCycleEnd');
                // End:0x558
                if(EnemyPawn.bCanThrow)
                {
                    WaitForSpecialMove(true);
                    ThrowPlayer();
                    WaitForSpecialMove();
                }
                // End:0x563
                else
                {
                    WaitForSpecialMove();
                }
                // End:0x595
                if(Group != none)
                {
                    Group.ReturnAttackToken(self);
                }
                // End:0x5BD
                else
                {
                    AttackTimer = EnemyPawn.AttackThrowRecovery;
                }
                EnemyPawn.StartIdleSound();
                Sleep(EnemyPawn.AttackIdleTimeAfterGrab);
                GotoState('Idle');
            }
            // End:0x63D
            else
            {
                EnemyPawn.StartSpecialMove(80);
                WaitForSpecialMove();
            }
        }
        // End:0x648
        else
        {
            Sleep(0.10);
        }
    }
    EnemyPawn.StartSpecialMove(81);
    WaitForSpecialMove();
    IgnoreTarget(5.0);
    EnemyPawn.LockDesiredRotation(false);
    GotoState('Idle');
    stop;                
}

state AttackLocker extends Attacking
{
    function EndState(name NextStateName)
    {
        super.EndState(NextStateName);
        ActiveDoor = none;
        //return;        
    }

Begin:
    // End:0x523
    if(TargetPlayer.ActiveLocker != none)
    {
        WaitForSpecialMove();
        EnemyPawn.ResetDesiredRotation();
        SetFocalPoint(vect(0.0, 0.0, 0.0));
        EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
        WaitForSpecialMove();
        EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
        // End:0xF0
        if(!EnemyPawn.ReachedDesiredRotation())
        {
            FinishRotation();
        }
        J0xF0:
        // End:0x124 [Loop If]
        if(TargetPlayer.SpecialMove == 38)
        {
            Sleep(0.10);
        }
        // End:0x1D9
        if(((TargetPlayer.LocomotionMode == 8) && EnemyPawn.bUsingWeapon) && EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        // End:0x497
        if(TargetPlayer.LocomotionMode == 8)
        {
            EnemyPawn.StartSpecialMove(73, AttackStartLocation, AttackStartRotation, 0);
            ActiveDoor = TargetPlayer.ActiveLocker.AssociatedDoor;
            StartDoorTraversal(false);
            // End:0x2CD
            if(EnemyPawn.IsA('OLEnemyNanoCloud'))
            {
                TargetPlayer.TryKillInLocker(EnemyPawn);
            }
            // End:0x2F5
            else
            {
                TargetPlayer.TryGrabFromLocker(EnemyPawn);
            }
            // End:0x33A
            if(EnemyPawn.bCanThrow)
            {
                WaitForSpecialMove(true);
                ThrowPlayer();
                WaitForSpecialMove();
            }
            // End:0x345
            else
            {
                WaitForSpecialMove();
            }
            EndDoorTraversal();
            // End:0x3DB
            if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
            {
                PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
                WaitForFullBodyAnim();
            }
            EnemyPawn.ZeroMovementVariables();
            // End:0x42C
            if(Group != none)
            {
                Group.ReturnAttackToken(self);
            }
            // End:0x454
            else
            {
                AttackTimer = EnemyPawn.AttackThrowRecovery;
            }
            EnemyPawn.StartIdleSound();
            Sleep(EnemyPawn.AttackIdleTimeAfterGrab);
        }
        // End:0x523
        else
        {
            // End:0x523
            if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
            {
                PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
                WaitForFullBodyAnim();
            }
        }
    }
    GotoState('Idle');
    stop;            
}

state AttackBed extends Attacking
{
Begin:
    // End:0x3DC
    if(TargetPlayer.ActiveBed != none)
    {
        WaitForSpecialMove();
        ClearDestination();
        EnemyPawn.ResetDesiredRotation();
        SetFocalPoint(vect(0.0, 0.0, 0.0));
        EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
        WaitForSpecialMove();
        EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
        // End:0xFA
        if(!EnemyPawn.ReachedDesiredRotation())
        {
            FinishRotation();
        }
        J0xFA:
        // End:0x12E [Loop If]
        if(TargetPlayer.SpecialMove == 40)
        {
            Sleep(0.10);
        }
        // End:0x3DC
        if(TargetPlayer.LocomotionMode == 10)
        {
            // End:0x1E1
            if(EnemyPawn.bUsingWeapon && EnemyPawn.bHasWeaponEquipped)
            {
                PlayFullBodyAnim(EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.20, 0.20);
                WaitForFullBodyAnim();
            }
            EnemyPawn.StartSpecialMove(74, AttackStartLocation, AttackStartRotation, 0);
            ActiveBed = TargetPlayer.ActiveBed;
            TargetPlayer.TryGrabFromBed(EnemyPawn);
            // End:0x2AB
            if(EnemyPawn.bCanThrow)
            {
                WaitForSpecialMove(true);
                ThrowPlayer();
                WaitForSpecialMove();
            }
            // End:0x2B6
            else
            {
                WaitForSpecialMove();
            }
            // End:0x342
            if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
            {
                PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
                WaitForFullBodyAnim();
            }
            // End:0x374
            if(Group != none)
            {
                Group.ReturnAttackToken(self);
            }
            // End:0x39C
            else
            {
                AttackTimer = EnemyPawn.AttackThrowRecovery;
            }
            EnemyPawn.StartIdleSound();
            Sleep(EnemyPawn.AttackIdleTimeAfterGrab);
        }
    }
    GotoState('Idle');
    stop;        
}

state AttackGrab extends Attacking
{
Begin:
    WaitForSpecialMove();
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
    // End:0xCC
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    J0xCC:
    // End:0x111 [Loop If]
    if((TargetPlayer != none) && TargetPlayer.SpecialMove != 0)
    {
        Sleep(0.10);
    }
    // End:0x13D
    if((TargetInSpecialLocation()) || !PerformGrabCheck())
    {
        GotoState('Idle');
    }
    // End:0x15B
    if(!TryGrabNormal(false))
    {
        GotoState('Idle');
    }
    // End:0x184
    if(bKilling)
    {
        WaitForSpecialMove(true);
        GotoState('KillPlayer');
    }
    // End:0x1D4
    else
    {
        // End:0x1C9
        if(EnemyPawn.bCanThrow)
        {
            WaitForSpecialMove(true);
            ThrowPlayer();
            WaitForSpecialMove();
        }
        // End:0x1D4
        else
        {
            WaitForSpecialMove();
        }
    }
    EnemyPawn.ZeroMovementVariables();
    ClearCurrentMove();
    // End:0x22F
    if(Group != none)
    {
        Group.ReturnAttackToken(self);
    }
    // End:0x257
    else
    {
        AttackTimer = EnemyPawn.AttackThrowRecovery;
    }
    Sleep(EnemyPawn.AttackIdleTimeAfterGrab);
    EnemyPawn.StartIdleSound();
    GotoState('Idle');
    stop;            
}

state AttackGrabUnder extends Attacking
{
Begin:
    WaitForSpecialMove();
    EnemyPawn.RegisterNavMeshObstacle();
    // End:0x59
    if(Group != none)
    {
        Group.NotifyOthersPathChanged(self);
    }
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
    // End:0x11A
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    J0x11A:
    // End:0x15F [Loop If]
    if((TargetPlayer != none) && TargetPlayer.SpecialMove != 0)
    {
        Sleep(0.10);
    }
    // End:0x17A
    if(TargetInSpecialLocation())
    {
        GotoState('Idle');
    }
    // End:0x204
    if(EnemyPawn.bUsingWeapon && EnemyPawn.bHasWeaponEquipped)
    {
        PlayFullBodyAnim(EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.20, 0.20);
        WaitForFullBodyAnim();
    }
    // End:0x2AD
    if(!TryGrabUnder())
    {
        // End:0x29F
        if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        GotoState('Idle');
    }
    // End:0x2D6
    if(bKilling)
    {
        WaitForSpecialMove(true);
        GotoState('KillPlayer');
    }
    // End:0x326
    else
    {
        // End:0x31B
        if(EnemyPawn.bCanThrow)
        {
            WaitForSpecialMove(true);
            ThrowPlayer();
            WaitForSpecialMove();
        }
        // End:0x326
        else
        {
            WaitForSpecialMove();
        }
    }
    // End:0x3B2
    if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
    {
        PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
        WaitForFullBodyAnim();
    }
    EnemyPawn.ZeroMovementVariables();
    ClearCurrentMove();
    // End:0x40D
    if(Group != none)
    {
        Group.ReturnAttackToken(self);
    }
    // End:0x435
    else
    {
        AttackTimer = EnemyPawn.AttackThrowRecovery;
    }
    Sleep(EnemyPawn.AttackIdleTimeAfterGrab);
    EnemyPawn.StartIdleSound();
    GotoState('Idle');
    stop;                    
}

state AttackCrouch extends Attacking
{
Begin:
    WaitForSpecialMove();
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
    // End:0xCC
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    J0xCC:
    // End:0x111 [Loop If]
    if((TargetPlayer != none) && TargetPlayer.SpecialMove != 0)
    {
        Sleep(0.10);
    }
    // End:0x12C
    if(TargetInSpecialLocation())
    {
        GotoState('Idle');
    }
    // End:0x14A
    if(!TryGrabNormal(true))
    {
        GotoState('Idle');
    }
    // End:0x173
    if(bKilling)
    {
        WaitForSpecialMove(true);
        GotoState('KillPlayer');
    }
    // End:0x1C3
    else
    {
        // End:0x1B8
        if(EnemyPawn.bCanThrow)
        {
            WaitForSpecialMove(true);
            ThrowPlayer();
            WaitForSpecialMove();
        }
        // End:0x1C3
        else
        {
            WaitForSpecialMove();
        }
    }
    EnemyPawn.ZeroMovementVariables();
    ClearCurrentMove();
    // End:0x21E
    if(Group != none)
    {
        Group.ReturnAttackToken(self);
    }
    // End:0x246
    else
    {
        AttackTimer = EnemyPawn.AttackThrowRecovery;
    }
    EnemyPawn.StartIdleSound();
    GotoState('Idle');
    stop;                    
}

state AttackPush extends Attacking
{
Begin:
    EnemyPawn.StartSpecialMove(78);
    WaitForSpecialMove();
    EnemyPawn.StartIdleSound();
    GotoState('Idle');
    stop;                
}

state AttackKill extends Attacking
{
Begin:
    EnemyPawn.ResetDesiredRotation();
    SetFocalPoint(vect(0.0, 0.0, 0.0));
    EnemyPawn.TurnOnSpot(rotator(AttackStartRotation));
    WaitForSpecialMove();
    EnemyPawn.SetDesiredRotation(rotator(AttackStartRotation));
    // End:0xC1
    if(!EnemyPawn.ReachedDesiredRotation())
    {
        FinishRotation();
    }
    // End:0x136
    if(TargetPlayer.TryKillHero(EnemyPawn, AttackStartLocation, AttackStartRotation))
    {
        EnemyPawn.StartSpecialMove(85, AttackStartLocation, AttackStartRotation, 0);
    }
    // End:0x155
    else
    {
        EnemyPawn.StartNormalAttack();
    }
    WaitForSpecialMove();
    EnemyPawn.StartIdleSound();
    GotoState('Idle');
    stop;            
}

state KillPlayer
{
    function BeginState(name PreviousStateName)
    {
        bAttacking = true;
        //return;        
    }

    function EndState(name NextStateName)
    {
        bAttacking = false;
        //return;        
    }

Begin:
    EnemyPawn.StartSpecialMove(85);
    TargetPlayer.TryDecapitate(EnemyPawn);
    WaitForSpecialMove();
    GotoState('Idle');
    stop;            
}

state InvestigatingObject
{
    function BeginState(name PreviousStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        OLNavHandle.ClearPath();
        ClearDestination();
        bInvestigatingObject = true;
        EnemyPawn.StopIdleSound();
        //return;        
    }

    function EndState(name NextStateName)
    {
        bInvestigatingObject = false;
        // End:0x46
        if(NextMove.Type != 0)
        {
            StartMove(NextMove);
        }
        EnemyPawn.ResetDesiredRotation();
        //return;        
    }
    stop;    
}

state InvestigatingLocker extends InvestigatingObject
{
    function EndState(name NextStateName)
    {
        super.EndState(NextStateName);
        ActiveDoor = none;
        ActiveLocker = none;
        //return;        
    }

Begin:
    // End:0x2AC
    if(ActiveLocker != none)
    {
        WaitForSpecialMove();
        EnemyPawn.ResetDesiredRotation();
        SetFocalPoint(vect(0.0, 0.0, 0.0));
        EnemyPawn.TurnOnSpot(rotator(InvestigateStartRotation));
        WaitForSpecialMove();
        EnemyPawn.SetDesiredRotation(rotator(InvestigateStartRotation));
        // End:0xDB
        if(!EnemyPawn.ReachedDesiredRotation())
        {
            FinishRotation();
        }
        ActiveDoor = ActiveLocker.AssociatedDoor;
        StartDoorTraversal(false);
        // End:0x198
        if(EnemyPawn.bUsingWeapon && EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        EnemyPawn.StartSpecialMove(86, InvestigateStartLocation, InvestigateStartRotation, 0);
        WaitForSpecialMove();
        // End:0x264
        if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        EndDoorTraversal();
        EnemyPawn.ZeroMovementVariables();
        EnemyPawn.StartIdleSound();
    }
    GotoState('Idle');
    stop;        
}

state InvestigatingBed extends InvestigatingObject
{
Begin:
    // End:0x26F
    if(ActiveBed != none)
    {
        WaitForSpecialMove();
        EnemyPawn.ResetDesiredRotation();
        SetFocalPoint(vect(0.0, 0.0, 0.0));
        EnemyPawn.TurnOnSpot(rotator(InvestigateStartRotation));
        WaitForSpecialMove();
        EnemyPawn.SetDesiredRotation(rotator(InvestigateStartRotation));
        // End:0xDB
        if(!EnemyPawn.ReachedDesiredRotation())
        {
            FinishRotation();
        }
        // End:0x165
        if(EnemyPawn.bUsingWeapon && EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        EnemyPawn.StartSpecialMove(87, InvestigateStartLocation, InvestigateStartRotation, 0);
        WaitForSpecialMove();
        // End:0x231
        if(EnemyPawn.bUsingWeapon && !EnemyPawn.bHasWeaponEquipped)
        {
            PlayFullBodyAnim(EnemyPawn.AnimNameEquipWeapon, 1.0, 0.20, 0.20);
            WaitForFullBodyAnim();
        }
        EnemyPawn.ZeroMovementVariables();
        EnemyPawn.StartIdleSound();
    }
    GotoState('Idle');
    stop;            
}

state Interruption
{
    function BeginState(name PreviousStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        ClearNextMove();
        ClearDestination();
        //return;        
    }
    stop;    
}

state Avoiding extends Interruption
{
    function EndState(name NextStateName)
    {
        bAvoiding = false;
        //return;        
    }

Begin:
    EnemyPawn.StartSpecialMove(93);
    WaitForSpecialMove();
    Recalculate(true);
    GotoState('Idle');
    stop;                
}

state Knockback extends Interruption
{
Begin:
    EnemyPawn.StartSpecialMove(94);
    WaitForSpecialMove();
    Recalculate(true);
    GotoState('Idle');
    stop;                
}

state WaitForMove extends Interruption
{
Begin:
    Sleep(WaitForMoveTime);
    Recalculate(true);
    GotoState('Idle');
    stop;            
}

state Disturbed
{
    function BeginState(name PreviouStateName)
    {
        EnemyPawn.ZeroMovementVariables();
        ClearCurrentMove();
        ClearNextMove();
        ClearDestination();
        bDisturbed = true;
        //return;        
    }

    function EndState(name NextStateName)
    {
        bDisturbed = false;
        //return;        
    }

Begin:
    EnemyPawn.StartDisturbed();
    WaitForSpecialMove();
    GotoState('Idle');
    stop;                
}

state WaitForDoor extends Interruption
{
Begin:
    Sleep(2.0);
    Recalculate(true);
    GotoState('Idle');
    stop;            
}

state ScriptedMove
{
    function bool FindNavMeshPath()
    {
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;
        class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, ScriptedMoveTarget);
        class'NavMeshGoal_At'.static.AtActor(NavigationHandle, ScriptedMoveTarget);
        return NavigationHandle.FindPath();
        //return ReturnValue;        
    }

Begin:
    NavigationHandle.SetFinalDestination(ScriptedMoveTarget.Location);
    // End:0xB4
    if(!NavigationHandle.ActorReachable(ScriptedMoveTarget))
    {
        // End:0xA6
        if(FindNavMeshPath())
        {
            FlushPersistentDebugLines();
            NavigationHandle.DrawPathCache();
        }
        // End:0xB1
        else
        {
            ScriptedMoveTarget = none;
        }
    }
    // End:0xE0
    else
    {
        MoveTo(ScriptedMoveTarget.Location, ScriptedFocus);
    }
    // End:0x1C1 [Loop If]
    if(((Pawn != none) && ScriptedMoveTarget != none) && !Pawn.ReachedDestination(ScriptedMoveTarget))
    {
        // End:0x1BE
        if(NavigationHandle.GetNextMoveLocation(MoveTempDest, Pawn.GetCollisionRadius()))
        {
            // End:0x1BE
            if(!NavigationHandle.SuggestMovePreparation(MoveTempDest, self))
            {
                MoveTo(MoveTempDest, ScriptedFocus);
            }
        }
    }
    Pawn.ZeroMovementVariables();
    PopState();
    stop;                    
}