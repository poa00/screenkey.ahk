# Screenkey.ahk

Screenkey.ahk is a tool that displays the keys that you type anywhere in Windows.
It can be useful for screencasts or remote help.

It is available as an [Autohotkey](http://www.autohotkey.com/) script or standalone executable.

![image](https://github.com/mihaifm/screenkey.ahk/assets/981184/b94d0fd0-ba0b-4ae2-baa5-5b1faeda5b82)

## Customization

There are a few customization options that can be tweaked at the top of the script:

Font settings

    fontSize := 20
    fontName := "Verdana"
    fontStyle := "Bold"

Maximum number of keys that can be displayed on the screen at any time

    numButtons := 5

Gui transparency:

    transparent := true

Distance from the buttons to the edge of the window
    
    winMargin := 25

Combo timer (in miliseconds). Old keys are cleared from display when a new key is pressed after the interval. 
All keys typed within the interval will be displayed at the same time. Set to 0 to disable.

    comboTimer := 1000

Clear timer (in miliseconds). Clear everything in the UI after this interval. Set to 0 to never clear.

    clearTimer := 5000

Hide UI hotkey. Press this hotkey to hide the UI elements of the Screenkey window (the captured keys will still be displayed). Default is `Ctrl+Shift+h`

    hideUIHotkey := ^+h

## Command line parameters

The script or the exe can be run with command line parameters. The name of the params is the same as the settings above. Use `-notransparent` to turn transparency off.

    screenkey.exe -numButtons 9 -fontName Rockwell -fontSize 50 -comboTimer 300 -notransparent
