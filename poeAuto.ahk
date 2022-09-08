;----------------------------------------------------------------------
; PoE Flasks macro for AutoHotKey
;
; Keys used and monitored:
; alt+f12 - activate automatic flask usage
; right mouse button - primary attack skills
; 1-5 - number keys to manually use a specific flask
; ` (backtick) - use all flasks, now
; "e" and "r" for casting buffs
; Note - the inventory buttons assume a starting location based on screen
; resolution - you'll need to update some locations, see below.
; Alt+c to Ctrl-Click every location in the (I)nventory screen.
; Alt+m - Allow setting stash tab size as normal (12x12) or large (24x24)
; Alt+g - Get the current screen coordinates of the mouse pointer.
; Alt+s - Swap a skill gem with an alternate.
;----------------------------------------------------------------------
#IfWinActive Path of Exile
  #SingleInstance force
  #NoEnv 
  #Warn 
  #Persistent 

  SetMouseDelay, 10
  SetDefaultMouseSpeed,0
  FlaskDurationInit := []
  ;----------------------------------------------------------------------
  ; Set the duration of each flask, in ms, below.  For example, if the 
  ; flask in slot 3 has a duration of "Lasts 4.80 Seconds", then use:
  ;		FlaskDurationInit[3] := 4800
  ;
  ; To disable a particular flask, set it's duration to 0
  ;
  ; Note: Delete the last line (["e"]), or set value to 0, if you don't use a buff skill
  ;----------------------------------------------------------------------
  FlaskDurationInit[1] := 6000
  FlaskDurationInit[2] := 4000
  FlaskDurationInit[3] := 6000
  FlaskDurationInit[4] := 4000
  FlaskDurationInit[5] := 6000
  FlaskDurationInit["{Numpad7}"] := 18000	; blood rage
  FlaskDurationInit["{Numpad8}"] := 18000	; 
  FlaskDurationInit["{Numpad9}"] := 18000	; 

  FlaskDuration := []
  FlaskLastUsed := []
  HoldRightClick := false
  LastRightClick := 0
  UseFlasks := false

  spells := []
  ; spells["{Numpad7}"] := 500	 ; time not used 
  spells["{Numpad8}"] := 500	; 
  spells["{Numpad9}"] := 500	; 

  ;----------------------------------------------------------------------
  ; The following are used for fast ctrl-click from the Inventory screen
  ; using alt-c.  The coordinates for ix,iy come from MouseGetPos (Alt+g)
  ; of the top left location in the inventory screen.  The delta is the
  ; pixel change to the next box, either down or right.
  ; 
  ; To get the correct values for use below, do the following:
  ;	1. Load the macro into AutoHotKey
  ;	2. open Inventory screen (I) and place the mouse cursor in the
  ;	   middle of the top left inventory box.
  ;	3. Press Alt+g and note the coordinates displayed by the mouse.
  ;   4. Replace the coordinates below.
  ;	5. To get the "delta", do the same for the next inventory box down
  ;	   and note the difference
  ;----------------------------------------------------------------------
  ix := 2680
  iy := 815
  delta := 74

  ;----------------------------------------------------------------------
  ; The following are used for fast ctrl-click from Stash tabs into the
  ; inventory screen, using alt-m.
  ; Stash top left and delta for 12x12 and 24x24 stash are defined here.
  ; As above, you'll use Alt+g to determine the actual values needed.
  ;
  ; To get these values, follow the instructions for the Inventory screen
  ; except use the stash tab boxes, instead.  Note, the first COLUMN is 
  ; for the 12x12 stash and the second COLUMN is for the 24x24 "Quad" stash.
  ;----------------------------------------------------------------------
  StashX := [ 57, 38] 
  StashY := [205, 185] 
  StashD := [ 69, 36]
  StashSize := [ 12, 24]

  ;----------------------------------------------------------------------
  ; The following are used for gem swapping.  Useful
  ; when you use one skill for clearing and another for bossing.
  ; Put the coordinates of your primary attack skill in PrimX, PrimY
  ; Put the coordinates of alternate attack skill in AltX, AltY
  ; WeaponSwap determines if alt gem is in inventory or alternate weapon.
  ;----------------------------------------------------------------------
  PrimX := 2080
  PrimY := 334
  AltX := 2505
  AltY := 820
  WeaponSwap := False

  ;----------------------------------------------------------------------
  ; Main program loop - basics are that we use flasks whenever flask
  ; usage is enabled via hotkey (default is F12), and we've attacked
  ; within the last 0.5 second (or are channeling/continuous attacking.
  ;----------------------------------------------------------------------
  ; Loop {
  ;   ; have we attacked in the last 0.5 seconds?
  ;   if ((A_TickCount - LastRightClick) < 500) {
  ;     Gosub, CycleAllFlasksWhenReady
  ;   } else {
  ;     ; We haven't attacked recently, but are we channeling/continuous?
  ;     if (HoldRightClick) {
  ;       Gosub, CycleAllFlasksWhenReady
  ;     }
  ;   }
  ; }

  ; for general cry build
  ; Loop {
  ;   if (UseFlasks) {
  ;     ; have we attacked in the last 0.5 seconds?
  ;     if ((A_TickCount - LastRightClick) < 500) {
  ;       Gosub, CastSpells
  ;     } 
  ;   }
  ; }

  ; !F12:: ; alt + F12
  F12::
    UseFlasks := not UseFlasks
    if UseFlasks {
      ; initialize start of auto-flask use
      ; ToolTip, UseFlasks On

    } else {
      ; ToolTip, UseFlasks Off
    }
  return
  ;----------------------------------------------------------------------
  ; To use a different moust button (default is right click), change the
  ; "RButton" to:
  ;		RButton - to use the {default} right mouse button
  ;		MButton - to use the {default} middle mouse button (wheel)
  ;		LButton - to use the {default} Left mouse button
  ;
  ; Make the change in both places, below (the first is click,
  ; 2nd is release of button}
  ;----------------------------------------------------------------------
  ~RButton::
    ; pass-thru and capture when the last attack (Right click) was done
    ; we also track if the mouse button is being held down for continuous attack(s) and/or channelling skills
    HoldRightClick := true
    LastRightClick := A_TickCount
  return

  ~RButton up::
    ; pass-thru and release the right mouse button
    HoldRightClick := false
  return

  ; general cry build
  ~LButton::
    if (UseFlasks) {
      Gosub, CastSpells
    }
  return

  ~LButton up::
    ; pass-thru and release the right mouse button
    HoldRightClick := false
  return
  ;----------------------------------------------------------------------
  ; The following 5 hotkeys allow for manual use of flasks while still
  ; tracking optimal recast times.
  ;----------------------------------------------------------------------
  ~1::
    ; pass-thru and start timer for flask 1
    FlaskLastUsed[1] := A_TickCount
    Random, VariableDelay, -99, 99
    FlaskDuration[1] := FlaskDurationInit[1] + VariableDelay ; randomize duration to simulate human
  return

  ~2::
    ; pass-thru and start timer for flask 2
    FlaskLastUsed[2] := A_TickCount
    Random, VariableDelay, -99, 99
    FlaskDuration[2] := FlaskDurationInit[2] + VariableDelay ; randomize duration to simulate human
  return

  ~3::
    ; pass-thru and start timer for flask 3
    FlaskLastUsed[3] := A_TickCount
    Random, VariableDelay, -99, 99
    FlaskDuration[3] := FlaskDurationInit[3] + VariableDelay ; randomize duration to simulate human
  return

  ~4::
    ; pass-thru and start timer for flask 4
    FlaskLastUsed[4] := A_TickCount
    Random, VariableDelay, -99, 99
    FlaskDuration[4] := FlaskDurationInit[4] + VariableDelay ; randomize duration to simulate human
  return

  ~5::
    ; pass-thru and start timer for flask 5
    FlaskLastUsed[5] := A_TickCount
    Random, VariableDelay, -99, 99
    FlaskDuration[5] := FlaskDurationInit[5] + VariableDelay ; randomize duration to simulate human
  return

  ; trigger spells on flask input
  ; ~Numpad7::
  ; 	FlaskLastUsed["{Numpad7}"] := A_TickCount
  ; 	Random, VariableDelay, -99, 99
  ; 	FlaskDuration["{Numpad7}"] := FlaskDurationInit["{Numpad7}"] + VariableDelay ; randomize duration to simulate human
  ; 	return

  ; ~Numpad8::
  ; 	FlaskLastUsed["{Numpad8}"] := A_TickCount
  ; 	Random, VariableDelay, -99, 99
  ; 	FlaskDuration["{Numpad8}"] := FlaskDurationInit["{Numpad8}"] + VariableDelay ; randomize duration to simulate human
  ; 	return

  ; ~Numpad9::
  ; 	FlaskLastUsed["{Numpad9}"] := A_TickCount
  ; 	Random, VariableDelay, -99, 99
  ; 	FlaskDuration["{Numpad9}"] := FlaskDurationInit["{Numpad9}"] + VariableDelay ; randomize duration to simulate human
  ; 	return

  ; trigger spells on main loop
  ~Numpad7::
    Random, VariableDelay, -99, 99
    spells["{Numpad7}"] := VariableDelay ; randomize duration to simulate human
  return

  ~Numpad8::
    Random, VariableDelay, -99, 99
    spells["{Numpad8}"] := VariableDelay ; randomize duration to simulate human
  return

  ~Numpad9::
    Random, VariableDelay, -99, 99
    spells["{Numpad9}"] := VariableDelay ; randomize duration to simulate human
  return

  ;----------------------------------------------------------------------
  ; Use all flasks, now.  A variable delay is included between flasks
  ; NOTE: this will use all flasks, even those with a FlaskDurationInit of 0
  ;----------------------------------------------------------------------
  `::
    ; Send 1
    ; Random, VariableDelay, -99, 99
    ; Sleep, %VariableDelay%
    Send 2
    Random, VariableDelay, -99, 99
    Sleep, %VariableDelay%
    Send 3
    Random, VariableDelay, -99, 99
    Sleep, %VariableDelay%
    Send 4
    Random, VariableDelay, -99, 99
    Sleep, %VariableDelay%
    Send 5
    Random, VariableDelay, -99, 99
    Sleep, %VariableDelay%
    Send {Numpad7}
    ; Random, VariableDelay, -99, 99
    ; Sleep, %VariableDelay%
    ; Send {Numpad8}
  return

  ; CycleAllFlasksWhenReady:
  ;   for flask, duration in FlaskDuration {
  ;     ; skip flasks with 0 duration and skip flasks that are still active
  ;     if ((duration > 0) & (duration < A_TickCount - FlaskLastUsed[flask])) {
  ;       Send %flask%
  ;       FlaskLastUsed[flask] := A_TickCount
  ;       Random, VariableDelay, -99, 99
  ;       FlaskDuration[flask] := FlaskDurationInit[flask] + VariableDelay ; randomize duration to simulate human
  ;       sleep, %VariableDelay%
  ;     }
  ;   }
  ; return

  CastSpells:
    for spell, duration in spells {
      Send %spell%
      Random, VariableDelay, -99, 99
      Sleep, %VariableDelay%
    }
  return
  ;----------------------------------------------------------------------
  ; Alt+c to Ctrl-Click every location in the (I)nventory screen.
  ;----------------------------------------------------------------------
  !c::
    Loop, 6 {
      col := ix + (A_Index * 0.96 - 1) * delta
      Loop, 5 {
        row := iy + (A_Index - 1) * delta
        Send ^{Click, %col%, %row%}
      }
    }
  return

  ;----------------------------------------------------------------------
  ; Alt+c to Ctrl-Click every location in the (I)nventory screen.
  ;----------------------------------------------------------------------
  !v::
    Loop, 5 {
      col := ix + ((A_Index + 6) * 0.96 - 1) * delta
      Loop, 5 {
        row := iy + (A_Index - 1) * delta
        Send ^{Click, %col%, %row%}
      }
    }
  return

  ;----------------------------------------------------------------------
  ; Alt+c to Ctrl-Click every location in the (I)nventory screen.
  ;----------------------------------------------------------------------
  !d::
    col := ix + (0.96 - 1) * delta
    Loop, 5 {
      row := iy + (A_Index - 1) * delta
      Loop, 10 {
        Sleep, 60
        Send {Click, %col%, %row%, Right}
        Sleep, 60
        Send {Click, 820, 1000}
      }
    }
  return
  ;----------------------------------------------------------------------
  ; Alt+m - Allow setting stash tab size as normal (12x12) or large (24x24)
  ; 
  ; vMouseRow := 1 (default) means starting in row 1 of stash tab
  ; always place mouse pointer in starting box
  ;
  ; ItemsToMove := 50 (default) is how many items to move to Inventory
  ;----------------------------------------------------------------------
  !m::
    Gui, Add, Radio, vSelStash checked, Norm Stash Tab (12x12)
    Gui, Add, Radio,, Quad Stash Tab (24x24)
    Gui, Add, Text,, &Clicks:
    Gui, Add, Edit, w50
    Gui, Add, UpDown, vClicks Range1-48, 48
    Gui, Add, Text,, Mouse is in &Row:
    Gui, Add, Edit, w50
    Gui, Add, UpDown, vStartRow Range1-24, 1
    Gui, Add, Button, default, OK
    Gui, Show
  return

  ButtonOK:
    Gui, Submit ; Save each control's contents to its associated variable.
    ; MouseGetPos, x, y			; start from current mouse pos
    x := StashX[SelStash] + (StashD[SelStash]*(StartRow-1))
    y := StashY[SelStash]
    ; ToolTip, %x% %y%
    ClickCt := 0
    Loop {
      Send ^{Click, %x%, %y%}
      y := y + StashD[SelStash]
      if (++ClickCt >= StashSize[SelStash]) {
        x := x + StashD[SelStash]
        y := StashY[SelStash]
        ClickCt := 0
      }
    } until (--Clicks <= 0)
    Gui, Destroy
  return
  GuiClose:
    Gui, Destroy
  GuiEscape:
    Gui, Destroy

    ;----------------------------------------------------------------------
    ; Alt+g - Get the current screen coordinates of the mouse pointer.
    ;----------------------------------------------------------------------
  !g::
    MouseGetPos, x, y
    ToolTip, %x% %y%
  return

  ;----------------------------------------------------------------------
  ; Alt+s - Swap a skill gem with an alternate. Gems must be same color if alt
  ; weapon slot is used for holding gems.
  ;----------------------------------------------------------------------
  ; !s::
  ; 	MouseGetPos, x, y					; Save the current mouse position
  ; 	Send i
  ; 	Sleep 100
  ; 	Send {Click Right, %PrimX%, %PrimY%}
  ; 	Sleep 100
  ; 	if (WeaponSwap) {
  ; 		Send {x}
  ; 		Sleep 100
  ; 	}
  ; 	Send {Click %AltX%, %AltY%}
  ; 	Sleep 100
  ; 	if (WeaponSwap) {
  ; 		Send {x}
  ; 		Sleep 100
  ; 	}
  ; 	Send {Click %PrimX%, %PrimY%}
  ; 	Sleep 100
  ; 	Send i
  ; 	Sleep 100
  ; 	MouseMove, x, y
  ; 	Return

  ;----------------------------------------------------------------------
  ; Alt+f to Ctrl-Click 100 times
  ;----------------------------------------------------------------------
  !f::
    MouseGetPos, x, y					; Save the current mouse position
    Send {shift down}
    KeyWait shift
    Loop, 100 {
      Send {Click, %x%, %y%}
      Random, VariableDelay, 70, 120
      Sleep, %VariableDelay%
    }
    Send {shift up}
  return

  F5::
    BlockInput On
    SendInput {Enter}
    Sleep 2
    SendInput /hideout
    SendInput {Enter}
    Sleep, 75
    BlockInput Off
  return

  F6::
    BlockInput On
    SendInput {Enter}
    Sleep 2
    SendInput /harvest
    SendInput {Enter}
    Sleep, 75
    BlockInput Off
  return