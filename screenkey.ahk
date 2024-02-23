;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Config area

; Font settings
fontSize := 30
fontName := "Verdana"
fontStyle := "Bold"

; The max number of keys that are listed on the screen
numButtons := 5

; Gui transparecy
transparent := true

; Distance from the buttons to the edge of the window
winMargin := 25

; Clear old keys after the combo timer interval. Set to 0 to disable
comboTimer := 1000

; Clear everything in the UI after this interval. Set to 0 to never clear
clearTimer := 5000

; Hide UI hotkey
hideUIHotkey = ^+h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Command line arguments

for n, param in A_Args
{
    if (param == "-hideUIHotkey" && n != A_Args.Length-1)
      hideUIHotkey := A_Args[n+1]
    if (param == "-fontSize" && n != A_Args.Length-1)
      fontSize := A_Args[n+1]
    if (param == "-fontName" && n != A_Args.Length-1)
      fontName := A_Args[n+1]
    if (param == "-fontStyle" && n != A_Args.Length-1)
      fontStyle := A_Args[n+1]
    if (param == "-numButtons" && n != A_Args.Length-1)
      numButtons := A_Args[n+1]
    if (param == "-transparent")
      transparent := true
    if (param == "-notransparent")
      transparent := false
    if (param == "-winMargin" && n != A_Args.Length-1)
      winMargin := A_Args[n+1]
    if (param == "-comboTimer" && n != A_Args.Length-1)
      comboTimer := A_Args[n+1]
    if (param == "-clearTimer" && n != A_Args.Length-1)
      clearTimer := A_Args[n+1]
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Font metrics functions

FontLen(text)
{
    global
    return StrLen(text) * fontSize + 25
}
FontHeight()
{
    global
    return (fontSize * 3)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gui Setup

Gui +ToolWindow +AlwaysOnTop

Gui Font, s%fontSize% %fontStyle%, %fontName%

; Create the buttons with 0 width
Loop % numButtons 
{
    height := FontHeight()
    if (A_Index == 1)
        Gui Add, Button, w0 h%height% X%winMargin% ym
    else
        Gui Add, Button, w0 h%height% ym
}

; Show the gui with a default 200 width
Gui Show, w200, Screenkey.ahk  

; Save the window id
WinGet k_ID, ID, A   

If (transparent)
{
    TransColor = F1ECED
    Gui Color, %TransColor%
    WinSet TransColor, %TransColor% 220, ahk_id %k_ID%
}

uiHidden := false
Hotkey, %hideUIHotkey%, HideUILabel, UseErrorLevel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkeys

CaptureKeyboardInputs()
{
    global
    static keys
    keys=Space,Enter,Tab,Esc,BackSpace,Del,Ins,Home,End,PgDn,PgUp,Up,Down,Left,Right,CtrlBreak,ScrollLock,PrintScreen,CapsLock
,Pause,AppsKey,NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot
,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear
,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel,Media_Next,Media_Play_Pause,Media_Prev,Media_Stop,Volume_Down,Volume_Up
,Volume_Mute,Browser_Back,Browser_Favorites,Browser_Home,Browser_Refresh,Browser_Search,Browser_Stop,Launch_App1,Launch_App2
,Launch_Mail,Launch_Media,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22
,1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
,[,],',=,\,/

    Loop Parse, keys, `,
        Hotkey, ~*%A_LoopField%, KeyHandleLabel, UseErrorLevel
    return

    KeyHandleLabel:
        KeyHandle()
    return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkey handles

current := 1
clear := false

KeyHandle()
{
    global

    keyname := RegExReplace(A_ThisHotKey, "~\*", "")

    dispkey := Up(keyname)

    mods := ModifierNames(keyname)

    dispkey := mods . dispkey

    len := FontLen(dispkey)

    ; resize the button with what needs to be displayed
    GuiControl Move, Button%current%, w%len%
    ControlSetText Button%current%, %dispkey%, ahk_id %k_ID%

    if (current == 1 && clear)
    {
        ; Clear the rest of buttons - resize them to 0 width
        Loop % numButtons - 1
        {
            curr := A_Index + 1
            GuiControl Move, Button%curr%, w0 
        }
    }

    ; move to the next button
    current++

    if (current > numButtons)
    {
        current := 1
        clear := true
    }
    else 
    {
        ; reposition the remaining buttons
        Loop
        {
            if (A_Index < current)
                continue

            prev := A_Index - 1
            GuiControlGet Button%prev%, Pos
            newX := % Button%prev%X + Button%prev%W 
            GuiControl Move, Button%A_Index%, X%newX% 

            if (A_Index >= numButtons)
                break
        }
    }
   
    ; calculate the new total width of the window 
    winWidth := 0
    Loop % numButtons
    {
        GuiControlGet Button%A_Index%, Pos
        w := Button%A_Index%W
        winWidth := w + winWidth
    }

    WinMove ahk_id %k_ID%,,,, winWidth + 2 * winMargin

    ; install the combo timer that clears all the buttons when the next key is hit
    if (comboTimer > 0)
    {
        SetTimer HandleComboType, %comboTimer%
    }

    if (clearTimer > 0)
    {
        SetTimer HandleClearTimer, Off 
        SetTimer HandleClearTimer, %clearTimer%
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper functions

IsUpperCase(key)
{
    caps := GetKeyState("CapsLock", "T")
    shift := GetKeyState("Shift", "P")

    if (caps && !shift || !caps && shift)
    {
        return true
    }
    
    return false
}

ModifierNames(key)
{
    mods := ""
    shift := GetKeyState("Shift", "P")
    ctrl := GetKeyState("Ctrl", "P")
    alt := GetKeyState("Alt", "P")
    win := GetKeyState("LWin", "P")

    special := "[,],',=,\,/,;,``,."

    if (StrLen(key) == 1)
    {
        if (key >= "0" && key <="9")
            shift := false
        if (key >= "a" && key <="z")
            shift := false
        if (key >= "A" && key <="Z")
            shift := false
        if (Instr(special, key))
            shift := false
    }
    
    if (shift)
        mods := mods . "Shift+"
    if (ctrl)
        mods := mods . "Ctrl+"
    if (alt)
        mods := mods . "Alt+"
    if (win)
        mods := mods . "Win+"
        
    return (mods)
}

Up(inkey)
{   
    outkey := ""

    if (IsUpperCase(inkey) && StrLen(inkey) == 1 && inkey >= "a" && inkey <= "z")
    {
        StringUpper outkey, inkey 
        return outkey
    }
    
    shift := GetKeyState("Shift", "P")

    if (shift)
    {
        if (inkey == "1") 
            return "!"
        if (inkey == "2")
            return "@"
        if (inkey == "3")
            return "#"
        if (inkey == "4")
            return "$"
        if (inkey == "5")
            return "%"
        if (inkey == "6")
            return "^"
        if (inkey == "7")
            return "&&"
        if (inkey == "8")
            return "*"
        if (inkey == "9")
            return "("
        if (inkey == "0")
            return ")"
        if (inkey == "-")
            return "_"
        if (inkey == "=")
            return "+"
        if (inkey == "[")
            return "{"
        if (inkey == "]")
            return "}"
        if (inkey == "\")
            return "|"
        if (inkey == ",")
            return "<"
        if (inkey == ".")
            return ">"
        if (inkey == "/")
            return "?"
        if (inkey == "``")
            return "~"
        if (inkey == ";")
            return ":"
        if (inkey == "'")
        {
            quote = "
            return quote
        }
    }

    return inkey
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Install hotkeys

CaptureKeyboardInputs()
return

HideUILabel:
  uiHidden := !uiHidden
  if (uiHidden)
    Gui, -Caption
  else
    Gui, +Caption
return

; special handling for special characters
~*;::
~*,::
~*.::
~*`::
    KeyHandle()
return

HandleComboType:
    current := 1
    clear := true
    SetTimer HandleComboType, Off
return

HandleClearTimer:
    Loop % numButtons
    {
        i := A_Index
        GuiControl Move, Button%i%, w0 
    }
    WinMove ahk_id %k_ID%,,,,200
    SetTimer HandleClearTimer, Off
return

GuiClose:
  ExitApp
return

