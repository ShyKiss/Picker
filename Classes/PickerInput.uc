Class PickerInput extends OLPlayerInput within PickerController
    Config(Input);

var PrivateWrite IntPoint MousePos;
var Array<Name> Keys;
var Vector2D Movement, Turning;
var Bool bSpacePressed, bCtrlPressed, FirstLaunchMousePos;
var String MathTasksAnswer;
var Int CommandPos;
var Config Int HistoryTop, HistoryBot, HistoryCur;
var Config String History[24];
var Transient Bool bNavigatingHistory;

Event PlayerInput(Float DeltaTime) {
    if(myHUD != None && PickerHud(HUD).ToggleHUD) {
        if(FirstLaunchMousePos) {
            MousePos.X = myHUD.SizeX / 2;
            MousePos.Y = myHUD.SizeY / 2;
            FirstLaunchMousePos = false;
        }
        else {
            MousePos.X = Clamp(MousePos.X + aMouseX, 0, myHUD.SizeX);
            MousePos.Y = Clamp(MousePos.Y - aMouseY, 0, myHUD.SizeY);
        }
    }
    Super.PlayerInput(DeltaTime);
    Movement = Vect2D(aBaseY, aStrafe);
    Turning = Vect2D(aMouseX, aMouseY);
}

Function SetCursorPos(Int Pos) {
    CommandPos = Pos; 
}

Function InputCommand(String Text) {
    PickerHud(HUD).Command = Text;
}

Function Bool Key(Int ControllerId, Name Key, EInputEvent Event, Float AmountDepressed=1.f, Bool bGamepad=false) {
    local Name PKName;
    local Int PKIndex, NewPos, SpacePos, PeriodPos;

    if(PickerHud(HUD).ToggleHUD && Event == IE_Pressed || PickerHud(HUD).ToggleHUD && Event == IE_Repeat) {
        if(bCtrlPressed) {
            Switch(Key) {
                case 'R':
                    Reload();
                    break;
                case 'V':
                    if(PasteFromClipBoard() != "") {
                        SendMsg("Pasted from Clipboard!");
                        InputCommand((Left(PickerHud(HUD).Command, CommandPos) $ PasteFromClipBoard()) $ Right(PickerHud(HUD).Command, Len(PickerHud(HUD).Command) - CommandPos));
                        SetCursorPos(CommandPos + Len(PasteFromClipBoard()) + 1);
                    }
                    else {
                        SendMsg("Clipboard is Empty!");
                    }
                    break;
                case 'C':
                    if(PickerHud(HUD).Command != "") {
                        SendMsg("Copied to Clipboard!");
                        CopyToClipboard(PickerHud(HUD).Command);
                    }
                    else {
                        SendMsg("Nothing to Copy!");
                    }
                    break;
                case 'X':
                    if(PickerHud(HUD).Command != "") {
                        SendMsg("Cut and Copied to Clipboard!");
                        CopyToClipboard(PickerHud(HUD).Command);
                        InputCommand("");
                    }
                    else {
                        SendMsg("Nothing to Copy!");
                    }
                    break;
                case 'Left':
                    NewPos = Max(InStr(PickerHud(HUD).Command, ".", true, false, CommandPos), InStr(PickerHud(HUD).Command, " ", true, false, CommandPos));
                    SetCursorPos(Max(0, NewPos));
                    break;
                case 'Right':
                    SpacePos = InStr(PickerHud(HUD).Command, " ", false, false, CommandPos + 1);
                    PeriodPos = InStr(PickerHud(HUD).Command, ".", false, false, CommandPos + 1);
                    NewPos = ((SpacePos < 0) ? PeriodPos : ((PeriodPos < 0) ? SpacePos : Min(SpacePos, PeriodPos)));
                    if(NewPos == -1) {
                        NewPos = Len(PickerHud(HUD).Command);
                    }
                    SetCursorPos(Min(Len(PickerHud(HUD).Command), Max(CommandPos, NewPos)));
                    break;
                case 'BackSpace':
                    NewPos = Max(InStr(PickerHud(HUD).Command, ".", true, false, CommandPos), InStr(PickerHud(HUD).Command, " ", true, false, CommandPos));
                    InputCommand(Left(PickerHud(HUD).Command, Max(InStr(PickerHud(HUD).Command, ".", true, false, CommandPos), InStr(PickerHud(HUD).Command, " ", true, false, CommandPos))) $ Right(PickerHud(HUD).Command, Len(PickerHud(HUD).Command) - CommandPos));
                    if(CommandPos > 0) {
                        SetCursorPos(Max(0, NewPos));
                    }
                    break;
                case 'LeftControl':
                    return false;
                    break;
            }
            return true;
        }
        else {
            Switch(Key) {
                case 'LeftMouseButton':
                    PickerHud(HUD).Click();
                    break;
                case 'RightMouseButton':
                    PickerHud(HUD).Back();
                    break;
                case 'Enter':
                    PurgeCommandFromHistory(PickerHud(HUD).Command);
                    History[HistoryTop] = PickerHud(HUD).Command;
                    HistoryTop = (HistoryTop + 1) % 24;
                    if((HistoryBot == -1) || HistoryBot == HistoryTop) {
                        HistoryBot = (HistoryBot + 1) % 24;
                    }
                    HistoryCur = HistoryTop;
                    PickerHud(HUD).Commit();
                    break;
                case 'Up':
                    /*if(PickerHud(HUD).LatestCommand != "") {
                        PickerHud(HUD).Command = PickerHud(HUD).LatestCommand;
                        SetCursorPos(Len(PickerHud(HUD).Command));
                    }*/
                    if(HistoryBot >= 0) {
                        if(HistoryCur == HistoryBot) {
                            HistoryCur = HistoryTop;
                        }
                        else {
                            -- HistoryCur;
                            if(HistoryCur < 0) {
                                HistoryCur = 24 - 1;
                            }
                        }
                        InputCommand(History[HistoryCur]);
                        SetCursorPos(Len(History[HistoryCur]));
                        bNavigatingHistory = true;
                    }
                    break;
                case 'Down':
                    if(HistoryBot >= 0) {
                        if(HistoryCur == HistoryTop) {
                            HistoryCur = HistoryBot;
                        }
                        else {
                            HistoryCur = (HistoryCur + 1) % 24;
                        }
                        InputCommand(History[HistoryCur]);
                        SetCursorPos(Len(History[HistoryCur]));
                        bNavigatingHistory = true;
                    }
                    break;
                case 'Left':
                    SetCursorPos(Max(0, CommandPos - 1));
                    break;
                case 'Right':
                    SetCursorPos(Min(Len(PickerHud(HUD).Command), CommandPos + 1));
                    break;
                case 'Delete':
                    InputCommand("");
                    SetCursorPos(0);
                    break;
                case 'Backspace':
                    InputCommand(Left(PickerHud(HUD).Command, CommandPos - 1) $ Right(PickerHud(HUD).Command, Len(PickerHud(HUD).Command) - CommandPos));
                    if(CommandPos > 0) {
                        SetCursorPos(CommandPos - 1);
                    }
                    break;
                case 'Tilde':
                    TogglePickerMenu(false);
                    break;
                case 'LeftControl':
                    return false;
                    break;
            }
            return true;
        }
    }
    else if(PickerHud(HUD).MathTasksHUD && MathTasksTimer && Event == IE_Pressed || PickerHud(HUD).MathTasksHUD && MathTasksTimer && Event == IE_Repeat) {
        Switch(Key) {
            case 'Delete':
                MathTasksAnswer = "";
                break;
            case 'Backspace':
                MathTasksAnswer = Left(MathTasksAnswer, Len(MathTasksAnswer)-1);
                break;
            case 'LeftControl':
                return false;
                break;
        }
        return true;
    }
    return false;
}

Function PurgeCommandFromHistory(String Command) {
    local int HistoryIdx, Idx, NextIdx;

    if((HistoryTop >= 0) && HistoryTop < 16) {
        HistoryIdx = 0;
        J0x2C:
        if(HistoryIdx < 16) {
            if(History[HistoryIdx] ~= Command) {
                Idx = HistoryIdx;
                NextIdx = (HistoryIdx + 1) % 16;
                J0x8A:
                if(Idx != HistoryTop) {
                    History[Idx] = History[NextIdx];
                    Idx = NextIdx;
                    NextIdx = (NextIdx + 1) % 16;
                    goto J0x8A;
                }
                HistoryTop = ((HistoryTop == 0) ? 16 - 1 : HistoryTop - 1);
            }
            ++ HistoryIdx;
            goto J0x2C;
        }
    } 
}

Function Bool Char(Int ControllerId, String Unicode) {
    local Int Character;

    Character = Asc(Left(Unicode, 1));
    if(PickerHud(HUD).ToggleHUD) {
        if(Character >= 0x20 && Character < 0x100 && Unicode != "`" && Character != 0x7f || Character >= 0x410 && Character < 0x450 && Unicode != "`" && Character != 0x7f) {
            InputCommand((Left(PickerHud(HUD).Command, CommandPos) $ Chr(Character)) $ Right(PickerHud(HUD).Command, Len(PickerHud(HUD).Command) - CommandPos));
            SetCursorPos(CommandPos + 1);
        }
        return true;
    }
    else if(PickerHud(HUD).MathTasksHUD && MathTasksTimer) {
        if(Character >= 0x30 && Character < 0x3A && Unicode != "`" && Character != 0x7f) {
            MathTasksAnswer = (Left(PickerHud(HUD).Command, CommandPos) $ Chr(Character)) $ Right(PickerHud(HUD).Command, Len(PickerHud(HUD).Command) - CommandPos);
            SetCursorPos(CommandPos + 1);
        }
        return true;
    }
    return false;
}

/*Function Bool ContainsName(Array<Name> Array, Name Find) {
    Switch(Array.Find(Find)) {
        case -1:
            return false;
            break;
        Default:
            return true;
            break;
    }
}*/

DefaultProperties
{
    FirstLaunchMousePos = true
    HistoryBot=-1
    OnReceivedNativeInputKey = Key
    OnReceivedNativeInputChar = Char
}