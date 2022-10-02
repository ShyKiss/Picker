Class PickerMoveDoor extends OLAICmd_MoveAbility_Door;

var OLDoor door;
var Vector LastDestination;
var int BashIter;

static event OLAICmd_MoveAbility_Door MoveThruDoor(OLBot Bot, OLDoor InDoor, Vector InitialDestination, bool bInReversed)
{
    local OLAICmd_MoveAbility_Door Cmd;

    // End:0xFF
    if(Bot != none)
    {
        Cmd = new (Bot) default.Class;
        // End:0xFF
        if(Cmd != none)
        {
            Cmd.door = InDoor;
            Cmd.CurrentDestination = InitialDestination;
            Cmd.bReversed = bInReversed;
            Cmd.WaitPointComponent = InDoor.WaitPointComponent;
            return Cmd;
        }
    }
    return none;
    //return ReturnValue;    
}

function bool IsDoorOpen()
{
    return (door.GetOpenAngle() > 80.0) || door.IsBroken();
    //return ReturnValue;    
}

function bool ModifyApproach(out Vector NewDestination)
{
    // End:0x3F
    if(IsDoorOpen())
    {
        return Outer.GetDoorApproachPoint(door, NewDestination);
    }
    return false;
    //return ReturnValue;    
}

function Popped()
{
    super.Popped();
    Outer.ActiveDoor = none;
    Outer.bCancelBash = false;
    //return;    
}

function Cancel()
{
    Outer.bMoveCancelled = true;
    Outer.Recalculate();
    //Completed();
    //return;    
}

function bool IsObjectInUse()
{
    return door.Bots.Length > 1;
    //return ReturnValue;    
}

function RegisterWithObject()
{
    local bool bFound;
    local int Idx;

    bFound = false;
    Idx = 0;
    J0x17:
    // End:0x9D [Loop If]
   // if(Idx < door.Bots.Length)
   // {
        // End:0x8F
        if(door.Bots[Idx] == OLBot(GameAIOwner))
        {
            bFound = true;
        }
        ++ Idx;
        // [Loop Continue]
  //  }
    // End:0xE0
    if(!bFound)
    {
        door.Bots.AddItem(OLBot(GameAIOwner));
    }
    //return;    
}

function UnregisterWithObject()
{
    door.Bots.RemoveItem(OLBot(GameAIOwner));
    // End:0x89
    if(door.ActiveBot == OLBot(GameAIOwner))
    {
        door.ActiveBot = none;
    }
    //return;    
}

function OLBot GetClosestToObject()
{
    local int Idx;
    local OLBot TempClosestBot;

    Idx = 0;
    J0x0B:
    // End:0x18C [Loop If]
 //   if(Idx < door.Bots.Length)
  //  {
        // End:0x7C
        if(TempClosestBot == none)
        {
            TempClosestBot = door.Bots[Idx];
        }
        // End:0x17E
        else
        {
            // End:0x17E
            if(VSizeSq(TempClosestBot.EnemyPawn.Location - door.ScriptGetCenterLocation()) > VSizeSq(door.Bots[Idx].EnemyPawn.Location - door.ScriptGetCenterLocation()))
            {
                TempClosestBot = door.Bots[Idx];
            }
        }
        ++ Idx;
        // [Loop Continue]
 //   }
    return TempClosestBot;
    //return ReturnValue;    
}

function OLBot GetActiveOnObject()
{
    return door.ActiveBot;
    //return ReturnValue;    
}

function SetActiveOnObject(OLBot NewActiveBot)
{
    door.ActiveBot = NewActiveBot;
    //return;    
}

function array<OLBot> GetBotsOnObject()
{
    return door.Bots;
    //return ReturnValue;    
}

state Performing
{
    function BeginState(name PreviousStateName)
    {
        Outer.ActiveDoor = door;
        //return;        
    }

    function EndState(name NextStateName)
    {
        Outer.ActiveDoor = none;
        Outer.bCancelBash = false;
        //return;        
    }

    J0x00:    // End:0x74 [Loop If]
    if((door.DoorState == 1) || door.DoorState == 2)
    {
        Outer.Sleep(0.10);
        // [Loop Continue]
    }
    // End:0xC6
    if(door.bBlocked || door.DoorUser != none)
    {
        Cancel();
    }
    // End:0xEC9
    if(!IsDoorOpen())
    {
        door.BreakDoor(Outer.EnemyPawn, bReversed);
        Outer.bFinishedDoor = true;
        Cancel();
        stop;
        Outer.ClearDestination();
        LastDestination = CurrentDestination;
        CurrentDestination = ((bReversed) ? door.Edge1Dest : door.Edge0Dest);
        Outer.EnemyPawn.TurnOnSpot(rotator(CurrentDestination - Outer.EnemyPawn.Location));
        Outer.WaitForSpecialMove();
        Outer.EnemyPawn.SetDesiredRotation(rotator(CurrentDestination - Outer.EnemyPawn.Location), true,,, false);
        Outer.FinishRotation();
        // End:0x308
        if(door.bBlocked || door.DoorUser != none)
        {
            Outer.EnemyPawn.LockDesiredRotation(false);
            Cancel();
        }
        Outer.StartDoorTraversal(bReversed);
        LastDestination.Z = Outer.EnemyPawn.Location.Z;
        // End:0x488
        if(Outer.EnemyPawn.IsA('OLEnemyNanoCloud'))
        {
            door.bAITraversing = true;
            Outer.EnemyPawn.StartSpecialMove(97, LastDestination, Normal(CurrentDestination - LastDestination), 0);
            Outer.WaitForSpecialMove();
            door.bAITraversing = false;
        }
        // End:0xE71
        else
        {
            Outer.bBreachingDoor = false;
            // End:0x534
            if(door.ShouldBreak(Outer))
            {
                Outer.bBreachingDoor = true;
                door.TriggerEvent(6, Outer.EnemyPawn);
            }
            // End:0x627
            if(Outer.EnemyPawn.bUsingWeapon && Outer.EnemyPawn.bHasWeaponEquipped)
            {
                Outer.PlayFullBodyAnim(Outer.EnemyPawn.AnimNameUnequipWeapon, 1.0, 0.10, 0.10);
                Outer.WaitForFullBodyAnim();
            }
            // End:0xCC3
            if(Outer.bBreachingDoor && Outer.EnemyPawn.bUsesDoorBashLoop)
            {
                Outer.EnemyPawn.StartSpecialMove(89, LastDestination, Normal(CurrentDestination - LastDestination), 0);
                Outer.WaitForSpecialMove(true);
                BashIter = 0;
                J0x704:
                // End:0x88E [Loop If]
                if(((((!door.bWaitForTriggerToBreak && BashIter < Outer.EnemyPawn.NumOfDoorBashLoops) && !door.bBlocked) || door.bWaitForTriggerToBreak && !door.bBreakTriggered) && !door.bInstantBreak) && !Outer.bCancelBash)
                {
                    Outer.EnemyPawn.StartSpecialMove(90);
                    Outer.WaitForSpecialMove(true);
                    ++ BashIter;
                    // [Loop Continue]
                }
                // End:0x99A
                if((!door.bWaitForTriggerToBreak && door.bBlocked) && !Outer.bCancelBash)
                {
                    BashIter = 0;
                    J0x907:
                    // End:0x99A [Loop If]
               //     if(BashIter < door.NumBashesAfterBlocked)
              //      {
                        Outer.EnemyPawn.StartSpecialMove(90);
                        Outer.WaitForSpecialMove(true);
                        ++ BashIter;
                        // [Loop Continue]
               //     }
                }
                // End:0xB90
                if(door.bBlocked || Outer.bCancelBash)
                {
                    Outer.EndDoorTraversal();
                    Outer.EnemyPawn.StartSpecialMove(92);
                    Outer.WaitForSpecialMove();
                    // End:0xB4D
                    if(Outer.EnemyPawn.bUsingWeapon && !Outer.EnemyPawn.bHasWeaponEquipped)
                    {
                        Outer.PlayFullBodyAnim(Outer.EnemyPawn.AnimNameEquipWeapon, 1.0, 0.10, 0.10);
                        Outer.WaitForFullBodyAnim();
                    }
                    Outer.EnemyPawn.LockDesiredRotation(false);
                    Cancel();
                }
                // End:0xCC0
                else
                {
                    door.bAITraversing = true;
                    Outer.EnemyPawn.StartSpecialMove(91, door.Location + (Normal(LastDestination - door.Location) * Outer.EnemyPawn.DoorBreakFinishDistance), Normal(CurrentDestination - LastDestination), 0);
                    Outer.WaitForSpecialMove();
                    door.bAITraversing = false;
                }
            }
            // End:0xD7C
            else
            {
                door.bAITraversing = true;
                Outer.EnemyPawn.StartSpecialMove(28, LastDestination, Normal(CurrentDestination - LastDestination), 0);
                Outer.WaitForSpecialMove();
                door.bAITraversing = false;
            }
            // End:0xE71
            if(Outer.EnemyPawn.bUsingWeapon && !Outer.EnemyPawn.bHasWeaponEquipped)
            {
                Outer.PlayFullBodyAnim(Outer.EnemyPawn.AnimNameEquipWeapon, 1.0, 0.10, 0.10);
                Outer.WaitForFullBodyAnim();
            }
        }
        Outer.EndDoorTraversal();
        Outer.EnemyPawn.LockDesiredRotation(false);
    }
    // End:0xFD0
    else
    {
        Outer.StartDoorTraversal(bReversed);
        door.bAITraversing = true;
        CurrentDestination = ((bReversed) ? door.Edge1Dest : door.Edge0Dest);
        Outer.MoveTo(CurrentDestination, none, -20.0);
        door.bAITraversing = false;
        Outer.EndDoorTraversal();
    }
    Outer.bFinishedDoor = true;
   // Completed();
    stop;                    
}