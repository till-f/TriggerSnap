#NoEnv                       ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn                      ; Enable warnings to assist with detecting common errors.
SendMode Input               ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
#Include Gdip.ahk
#Include CaptureScreen.ahk


; -----------------------------------------------------------------
; Configuration
; -----------------------------------------------------------------

; base directoy for saved snapshots. Can be an absolute or relative path.
imgBaseDir := "snap"

; date format to be used for default file name
; (actual name may append milliseconds in sequence mode)
dateFormat := "yyyy-MM-dd HH''''mm''''ss"

; set to true if a popup asking for the filename shall appear
; for single screenshot
askForName := false


; -----------------------------------------------------------------
; Initialization
; -----------------------------------------------------------------

CoordMode, Mouse, Screen
 
gui +AlwaysOnTop -caption +Border +ToolWindow +LastFound
WinSet, Transparent, 50

IfExist, TriggerSnap.ico
	Menu, Tray, Icon, TriggerSnap.ico

FileCreateDir, % imgBaseDir


; -----------------------------------------------------------------
; Hotkeys
; -----------------------------------------------------------------

; Press <Windows> + <Space> to take a single screenshot.
; Select region on screen or press <Escape> to cancel.
; -----------------------------------------------------------------
#Space::
TakeAndShowScreenshotOverlay()
PrepareSelectRegion()
isTriggerShot := false
isSequenceShot := false
return

; Press <Windows> + <Alt> + <Space> to prepare multiple screenshots.
; Select region on screen or press <Escape> to cancel. 
; Save as many screenshots as desired by pressing <Space> or press
; <Escape> to cancel.
; -----------------------------------------------------------------
#!Space::
FormatTime, nowString, a_now, % dateFormat
InputBox, filePrefix, Take Screenshot Sequence, Enter filename prefix:, SHOW, 375, 130, , , , , % nowString "_"
if (ErrorLevel != 0)
{
	soundbeep 400
	return
}
PrepareSelectRegion()
isTriggerShot := true
isSequenceShot := false
return


; Press <Windows> + <PrintScreen> to scrape a document.
; Follow instructions in popup. Press <Escape> to cancel.
; -----------------------------------------------------------------
#Printscreen::
InputBox, nrOfScreenshots, Scrape Document, Ensure that the full page is shown and that the page down key will scroll to the next page. The document reader should gain the focus when this dialog is closed.`n`nAfter pressing OK`, select the area on screen`. Processing will start automatically.`n`nEnter number of pages:, SHOW, 375, 250
if (ErrorLevel = 0)
{
	PrepareSelectRegion()
	isTriggerShot := false
	isSequenceShot := true
	soundbeep 800
}
else
{
	soundbeep 400
}
return


; Press <Windows> + <V> to paste clipboard content as plain text.
; -----------------------------------------------------------------
#V::
clipboardString = %clipboard%
clipboardFull := ClipboardAll
clipboard := ""
clipboard := Trim(clipboardString)
Send, ^v
Sleep 200
clipboard := clipboardFull
return


; -----------------------------------------------------------------
; Entry Points
; -----------------------------------------------------------------

selectRegion:
MouseGetPos, mousex1, mousey1
SetTimer, overlay, 10
KeyWait, LButton
MouseGetPos, mousex2, mousey2
SetTimer, overlay, off
Gui, hide
Hotkey, LButton, selectRegion, Off
SetMouseCursor("")

width:=mousex2 > mousex1 ? mousex2 - mousex1 : mousex1 - mousex2
imgx:=mousex2 > mousex1 ? mousex1 : mousex2
height:=mousey2 > mousey1 ? mousey2 - mousey1 : mousey1 - mousey2
imgy:=mousey2 > mousey1 ? mousey1:mousey2

FormatTime, nowString, a_now, % dateFormat

if (isTriggerShot = true)
{
	sequenceCounter := 0
	Hotkey, Space, trigger, On
}
else if (isSequenceShot = true)
{
	cancelSequence := false
	imgDir := imgBaseDir "/" nowString
	FileCreateDir, % imgDir

	Loop %nrOfScreenshots%
	{
		SaveImage(imgx, imgy, width, height, imgDir, a_index)
		if (cancelSequence = true or a_index = nrOfScreenshots)
		{
			break
		}
		Send, {PgDn}
		Sleep, 100
	}

	Hotkey, Escape, cancelScreenshot, Off
}
else
{
	Hotkey, Escape, cancelScreenshot, Off
	SaveImage(imgx, imgy, width, height, imgBaseDir, nowString, true)
	Gui, PicGui:destroy
}
return
 
overlay:
MouseGetPos, tx, ty
ttx:= tx > mousex1 ? mousex1 : tx
tty:= ty > mousey1 ? mousey1 : ty
ttw:= tx > mousex1 ? tx - mousex1 : mousex1 - tx
tth:= ty > mousey1 ? ty - mousey1 : mousey1 - ty
Gui, Show, x%ttx% y%tty% w%ttw% h%tth%
return

trigger:
sequenceCounter := sequenceCounter + 1
SaveImage(imgx, imgy, width, height, imgBaseDir, filePrefix sequenceCounter)
return

cancelScreenshot:
Hotkey, Escape, cancelScreenshot, Off
Hotkey, Space, trigger, Off
Hotkey, LButton, selectRegion, Off
Gui, PicGui:destroy
SetMouseCursor("")
cancelSequence := true
soundbeep 400
return


; -----------------------------------------------------------------
; Functions
; -----------------------------------------------------------------

PrepareSelectRegion()
{
	Hotkey, Space, trigger, Off
	Hotkey, LButton, selectRegion, On
	Hotkey, Escape, cancelScreenshot, On
	SetMouseCursor("CROSS")
}

TakeAndShowScreenshotOverlay()
{
	CaptureScreen(0, True, "_screen.bmp")
	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79
	Gui, PicGui:new
	Gui, PicGui:-caption +ToolWindow +HWNDguiID +AlwaysOnTop
	Gui, PicGui:add, picture, x0 y0 w%VirtualScreenWidth% h%VirtualScreenHeight% hwndPic, _screen.bmp
	Gui, PicGui:show, x0 y0 w%VirtualScreenWidth% h%VirtualScreenHeight%
	FileDelete, _screen.bmp
}

SaveImage(imgx, imgy, width, height, imgPath, defaultName, isSingleShot := false)
{
	global askForName
	token := Gdip_Startup()
	image := Gdip_Bitmapfromscreen(imgx "|" imgy "|" width "|" height)
	if (isSingleShot = true)
	{
		Gdip_SetBitmapToClipboard(image)
		if (askForName = true)
		{
			InputBox, newName, Save Screenshot, Enter file name:, SHOW, 375, 130, , , , , % defaultName
			if (ErrorLevel = 0)
			{
				defaultName := newName
			}
			else
			{
				soundbeep 400
				return
			}
		}
	}
	cr := Gdip_SaveBitmapToFile(image, imgPath "/" defaultName ".png")
	Gdip_DisposeImage(image)
	Gdip_Shutdown(token)
}

SetMouseCursor(cursor := "")
{
    static cursors := {APPSTARTING: 32650, ARROW: 32512, CROSS: 32515, HAND: 32649, HELP: 32651, IBEAM: 32513, NO: 32648, SIZEALL: 32646, SIZENESW: 32643, SIZENS: 32645, SIZENWSE: 32642, SIZEWE: 32644, UPARROW: 32516, WAIT: 32514}

    if (cursor == "")
	{
        return DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
	}
	
    cursor := InStr(cursor, "3") ? cursor : cursors[cursor]

    for each, ID in cursors
    {
        hCursor := DllCall("User32.dll\LoadImageW", "Ptr", 0, "Int", cursor, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0x00008000, "Ptr")   ; 2 = IMAGE_CURSOR | 0x00008000 = LR_SHARED
        hCursor := DllCall("User32.dll\CopyIcon", "Ptr", hCursor, "Ptr")
        DllCall("User32.dll\SetSystemCursor", "Ptr", hCursor, "UInt",  ID)
    }
}
