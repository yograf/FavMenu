;**************************************************************************
;	TC FavMenu
;	
;
;	Created by Miodrag Milic								Jun 2006
;	
;	code.r-moth.com			www.r-moth.com		r-moth.deviantart.com
;
; Hacked by Ba Manzi <bamanzi@gmail.com>
; Change Log
;   2.17 Add support for xplorer2 (only tested on xplorer-lite 1.7 & 2.1)
;   2.16 Add support for Msys (console,rxvt,mintty,console2,conemu...)
;   2.15 Add support for FreeCommander{,XE}
;   2.14 Add clipboard content as a menu item (if it is a path)
;   2.13 Add 'Command Prompt Here'
;   2.12 Try to parse current directory from applications' title bar
;   2.11 Added target support for gtk open/save dialog
;   2.10 Added support for windows 7/vista's explorer
;        http://www.autohotkey.com/community/viewtopic.php?t=12412&start=75#p216232
;   2.09 Added target support for windows 7/vista's open/save diloag
;        http://www.autohotkey.com/community/viewtopic.php?p=322261
;   2.08 Added target support for mintty for msys
;   2.07 Fixed getting current paths from Total Commander 8.0
;        Added support for PowerCmd (handled as console)
;   2.06 Added support for Far/ConEmu (target & source)
;   2.05 Added target support for mintty/rxvt for Cygwin
;   2.04 Added 'copy current path' command on menu
;   2.03 Added target support for XEmacs & MicroEmacs-jasspa
;   2.02 Added target support for GNU Emacs
;   2.01 Fixed getting current paths of Total Commander >= 7.5
; TODO:
;   + Add support for FreeCommander/XP
;   + Add GetPath support for cygwin/msys
;   + Add SetPath support for cygwin/msys console
;**************************************************************************
#NoEnv
#SingleInstance force

	;prefixes: FavMenu, Setup, Properties, CM, WM, CSIDL, TV
	FAVMENU_Init()

return
;==========================================================================

FAVMENU_Init( lastGUI=0, subMenu="", bStandalone=true )
{
	global

	DetectHiddenWindows, on
	SetKeyDelay, -1 


	#include includes\messages.ahk
	#include includes\tc_cmnds.ahk

	; for the world
	Favmenu_title	   := "FavMenu"
	Favmenu_version    := "4.17"
	Favmenu_configFile := "Config.ini"
	
	;set GUIs
	Properties_GUI	:= lastGUI + 1
	Setup_GUI		:= lastGUI + 2
	Favmenu_standalone := bStandalone


	;initialise
	if ( ! FavMenu_GetConfigData() )
		Setup_Create()
	else	
		FavMenu_CheckConfigData()


	Hotkey %FavMenu_fmKey%, FavMenu_MenuHotKey, On
	if (FavMenu_Options_OnOffKey != "")
		Hotkey %FavMenu_Options_OnOffKey%, FavMenu_OnOffHotkey, UseErrorLevel On

	
	FavMenu_SetTrayMenu(subMenu)
	return lastGUI + 2
}

;--------------------------------------------------------------------------

FavMenu_Create()
{	
	global
	local t

	;will set globals dlgHWND, dlgType, dlgInput
	FavMenu_DialogGetActive()

	;check if that particular dialog is disabled in integration settings
	t :=  FavMenu_Options_I%FavMenu_dlgType%
	if FavMenu_dlgType = Office03
		t := FavMenu_Options_IOpenSave
	if !t
		return
	
	;ok, show the menu
	FavMenu_CreateFullMenu()
	FavMenu_Show()
	FavMenu_Destroy()
}

FavMenu_MenuHotKey:
	FavMenu_Create()
return


FavMenu_OnOffHotkey:
	Hotkey, %FavMenu_fmKey%, Toggle
	
	Menu, %FavMenu_trayMenu%,Rename, Enable, Disable
	if (ErrorLevel)
	{
		if FavMenu_trayMenu = Tray
			Menu, %FavMenu_trayMenu%, icon, res\disable.ico
		Menu, %FavMenu_trayMenu%, Rename, Disable, Enable
	}
	else {
		if FavMenu_trayMenu = Tray
			Menu, %FavMenu_trayMenu%, icon, res\enable.ico
	}			
return

;--------------------------------------------------------------------------

FavMenu_Show()
{
	global Favmenu_Options_MenuPos

	if (Favmenu_Options_MenuPos = 2)
	{
		posX := A_CaretX
		posY := A_CaretY
	}
	
	if (Favmenu_Options_MenuPos = 3)
	{
		h := WinExist("A")
		WinGetPos, , , win_w, win_h, ahk_id %h%

		posX := win_w /2
		posY := win_h /2
	}
	
	Menu, Favmenu_sub1, show, %posX%, %posY%
}

;---------------------------------------------------------------------------

FavMenu_CreateMenu()
{	
	global
	local cmd_cnt, submenu_id, sub_num,   mnu, cmd, ico,   delta, name, sufix
		

	Favmenu_subCnt	+= 1

	if (Favmenu_subCnt = 1)
		delta := Favmenu_deltaS
	else 
		delta := 0


	sub_num		= %Favmenu_subCnt%
	submenu_id	= Favmenu_sub%sub_num%
	Menu, %submenu_id%,UseErrorLevel

	Loop 
	{	
		;read next menu item 
		Favmenu_mnuCnt += 1
		IniRead, mnu, %FavMenu_fmIni%, DirMenu, menu%Favmenu_mnuCnt%, & 
		IniRead, cmd, %FavMenu_fmIni%, DirMenu, cmd%Favmenu_mnuCnt%, &
		IniRead, ico, %FavMenu_fmIni%, DirMenu, icon%Favmenu_mnuCnt%, &

		if (mnu = "&")
			break

		;is it separator ?
		if (mnu = "-")
     	{ 
			Menu, %submenu_id%, add 
			cmd_cnt += 1
			continue 
		} 

		; "--" exit condition (end of submenu), return this menu to the caller
		if (mnu = "--")
			return %submenu_id%


		; if "-....." submenu, create it (recursion step)
		StringMid, c1, mnu, 1, 1 
		if (c1 = "-")
		{

			StringMid, name, mnu, 2, 100 
			Menu, %submenu_id%, add, %name%, % ":" . FavMenu_CreateMenu()
			cmd_cnt += 1		

			if FileExist(ico)
				FavMenu_AssignBitmap( submenu_id, cmd_cnt + delta, ico ) 

			continue
		}

		;check for existing item with the same name
		Menu, %submenu_id%, add, %mnu%, FavMenu_MenuHandlerDispatch

		cmd_cnt += 1
	    FavMenu_command%sub_num%_%cmd_cnt% := cmd
		FavMenu_menuOrder%sub_num%_%cmd_cnt% := Favmenu_mnuCnt

		if FileExist(ico)
			FavMenu_AssignBitmap( submenu_id, cmd_cnt + delta, ico ) 
	}

	return true

}

;--------------------------------------------------------------------------


FavMenu_CreateFullMenu()
{
	global
	local tc_left, tc_right, hwnd, separator, clippath, attr

	FavMenu_currentDir =
	Favmenu_deltaS	= 0
	
	; add TC Current folders 
	if ( FavMenu_Options_ShowTCFolders )
		ifWinExist ahk_class TTOTAL_CMD
		{
			hwnd := WinExist()
			if (hwnd = WinActive())
				goto FavMenu_skip
			
			FavMenu_currentDir := FavMenu_GetTCPanels(tc_left, tc_right)
			Favmenu_command0_1 := tc_left
			Favmenu_command0_2 := tc_right
			
			Favmenu_deltaS := FavMenu_AddTCPanels(tc_left, tc_right)
		}

FavMenu_skip:		
	
	; add menu from the ini file
	if (! FavMenu_CreateMenu() )
	{
		MsgBox, ,TC Fav Menu, Can not create menu, unable to read wincmd.ini.`nApplication will exit now.
		ExitApp
	}

	; add "add current dir"
	if (FavMenu_Options_ShowAddDirs)
	{
		;;if WinActive("ahk_class TTOTAL_CMD") OR Favmenu_dlgHWND
		{
			Menu, Favmenu_sub1, add
			separator := true

			clippath := clipboard
			ifExist,%clippath%
			{
					FileGetAttrib,attr,%clippath%
					OutputDebug,path in clipboard %clippath%
					IfInString,attr,D
					{
						Menu Favmenu_sub1, add,  *[Clipboard] %clippath% , FavMenu_FullMenuHandlerDispatch
						; add separator 
						Menu Favmenu_sub1, add
						Favmenu_deltaS += 2
					}
			} 
			
			Menu, Favmenu_sub1, add, &Add current dir, FavMenu_FullMenuHandlerDispatch
		}

		; copy current dir
		Menu, Favmenu_sub1, add, &Copy current path, FavMenu_FullMenuHandlerDispatch
		
		Menu, Favmenu_sub1, add, Command &Prompt here, FavMenu_FullMenuHandlerDispatch
	}

	; add editor
	if (FavMenu_Options_ShowEditor)
	{
		if !separator
			Menu, Favmenu_sub1, add
		Menu, Favmenu_sub1, add, &Configure..., FavMenu_FullMenuHandlerDispatch
	}
}

;---------------------------------------------------------------------------

FavMenu_Destroy()
{
	global

	if (Favmenu_subCnt = 0 ) 
		return

	loop
	{
		if (Favmenu_subCnt = 0)
			break

		Menu, Favmenu_sub%Favmenu_subCnt%, Delete
		Favmenu_subCnt -= 1 
	}

	Favmenu_mnuCnt = 0
	Favmenu_deltaS = 0
}

;---------------------------------------------------------------------------
FavMenu_AddCurrentDir()
{
	global
	local name, idx, curDir, prefix, width

	curDir := FavMenu_DialogGetPath()
	if curDir =
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	;check for errors reported by OpenSave dialogs (starting with :)
	StringLeft idx, curDir, 1
	if (idx = ":")
	{
		StringMid curDir, curDir, 2, 256
		MsgBox, 16, %Favmenu_title%, Can not add this folder`n`n%curDir%
		return false
	}

	;get the Title
	StringGetPos idx, curDir, \, R
	if (idx != -1) and ( idx != 2 )
		StringMid name, curDir, idx+2, 256
	else name := curDir

	;determine width of the input box
	width := StrLen(curDir)*8
	if width < 100
		width := 200
	if width > 600
		width := 600

	InputBox name, %FavMenu_title%, Specify new title for the folder:`n%curDir%,, %width%, 150, , , , ,%name%
	if (ErrorLevel)
		return false

	; add ALT 0160 if - is first char
	StringLeft idx, name, 1
	if idx = -
			prefix := ">"
	
	;write to ini
	IniWrite %prefix%%name%,	%FavMenu_fmIni%, DirMenu, menu%FavMenu_mnuCnt%
	IniWrite cd %curDir%,		%FavMenu_fmIni%, DirMenu, cmd%FavMenu_mnuCnt%

	return true
}

FavMenu_CopyCurrentPath()
{
	local curDir

	curDir := FavMenu_DialogGetPath()
	if curDir =
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	clipboard = %curDir%
	TrayTip,FavMenu2: copy current path,%curDir%
}

FavMenu_CommandPromptHere()
{
	curDir := FavMenu_DialogGetPath()

	If curDir = 
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	Run,cmd /k "cd /d `%cd`%",%curDir%
}

;---------------------------------------------------------------------------

FavMenu_FullMenuHandler()
{
	global 
	local tmp, idx, path

	; handle editor selection
	if (FavMenu_Options_ShowEditor && A_ThisMenuItem = "&Configure...")
	{
		if FileExist(FavMenu_Options_Editor)
			Run %FavMenu_Options_Editor%
		else MsgBox 16, %FavMenu_title%, Editor can not be started:`n%FavMenu_Options_Editor%
		
		return
	}

	; handle add current dir
	if (FavMenu_Options_ShowAddDirs && A_ThisMenuItem = "&Add current dir")
		return FavMenu_AddCurrentDir()

	if ( A_ThisMenuItem = "&Copy current path")
		return FavMenu_CopyCurrentPath()
	
	if ( A_ThisMenuItem = "Command &Prompt here")
		return FavMenu_CommandPromptHere()
	
	; handle current TC folders
	if (FavMenu_Options_ShowTCFolders)
	{
		if InStr(A_ThisMenuItem, "*[")==1
		{
			;;StringGetPos, tmp, A_ThisMenuItem, "]"  //not work??
			tmp := InStr(A_ThisMenuItem, "]")
			OutputDebug,tmp=%tmp%
			if tmp > 0 
			{
					OutputDebug,line 436 here, path=%path%		
					path := SubStr(A_ThisMenuItem, tmp + 2)
					OutputDebug,line 436 here, path=%path%
			}
		} else 
		{
			path := FavMenu_command0_%A_ThisMenuItemPos%
		}
		;check for modifiers
		if GetKeyState("SHIFT") && GetKeyState("CTRL")
		{
			SendRaw %path%
			return
		}
	
		;check if dialog is active
		if (FavMenu_dlgHwnd)
		{ 
			tmp := FavMenu_command0_%A_ThisMenuItemPos%
			StringGetPos idx, tmp,\\\
			if (idx = -1)
				return FavMenu_DialogSetPath(tmp)
		}

		; if dialog is not active, just activate TC & selected panel
		if (A_ThisMenuItemPos = 1)
			FavMenu_SendTCCommand(cm_FocusLeft, false )
		else
			FavMenu_SendTCCommand(cm_FocusRight, false )
			
		WinActivate ahk_class TTOTAL_CMD
	}
}

FavMenu_FullMenuHandlerDispatch:
 FavMenu_FullMenuHandler()
return

;--------------------------------------------------------------------------
; Handle menu defintion without extra items
;
FavMenu_MenuHandler()
{
	global
	local i, j, keys, stateC, stateS, bOpenTab, tmp

;-- calculate position of the selected items index to data arrays
	j := A_ThisMenuItemPos 
	if (A_ThisMenu = "Favmenu_sub1")
		j -= Favmenu_deltaS

	StringReplace i, A_ThisMenu, Favmenu_sub, 
	keys := % FavMenu_command%i%_%j% `
	Favmenu_mnuCnt := % FavMenu_menuOrder%i%_%j% 
;-- convert environment and pseudovariables
	if ( FavMenu_IsPseudoVar(keys) )
		keys := FavMenu_ConvertPseudoPath(keys)
	keys := FavMenu_ExpandEnvVars(keys)

;-- Get modifiers
	GetKeyState, stateC, Control 
	GetKeyState, stateS, Shift


;-- SHIFT CONTROL ENTER (paste path)
	if (stateC = "D") && stateS="D"
	{
		StringLeft i, keys, 3
		if (i = "cd ")
			StringMid keys, keys, 4, 256
		SendRaw %keys%
		return
	}

;-- CTRL ENTER (open properties)
	if (stateC = "D") || properties_visible
	{ 
		Properties_mnuCnt := Favmenu_mnuCnt
		if (properties_visible)
			Properties_Close()

		Properties_Create()
		return
	} 

;-- SHIFT ENTER (open in new tab)
	if (stateS = "D")
		bOpenTab := true
	else
		bOpenTab := false

;-- Check Executables
	StringLeft, tmp, keys, 3
	if (tmp != "cd ")
	{
		if FavMenu_dlgType = Console
				SendInput {ESC}%keys%{ENTER}
		else	FavMenu_ShellExecute(keys)	
		return
	}

;-- Remove "cd " (all other commands start without this word)
	StringMid keys, keys, 4

;-- Check for TC plugins (redirect to system call)
	StringGetPos tmp, keys, \\\ 
	if (tmp != -1)
		goto FavMenu_System

;--- If dialog is active set the path (plugins and executables are already checked at this point)
	if ( Favmenu_dlgHWND )
	{ 
		FavMenu_DialogSetPath(keys, bOpenTab)
		return
	}

;-- No known windows active - redirect to file manager (i.e. System call)
FavMenu_System:
	FavMenu_FM_Open( keys, bOpenTab )   
}

FavMenu_MenuHandlerDispatch:
	FavMenu_MenuHandler()
return

;---------------------------------------------------------------------------

FavMenu_ShellExecute(ppath)
{
	global Favmenu_title

	Run %ppath%, ,UseErrorLevel
	if (ErrorLevel = "ERROR")
		MsgBox, 64, %Favmenu_title%, Invalid menu item. Command can not be executed:`n%ppath%

	return
}

;---------------------------------------------------------------------------

FavMenu_ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

;---------------------------------------------------------------------------

FavMenu_IsQuoted(str)
{
	StringLeft  sl, str, 1
	StringRight sr, str, 1
	if (sr = """") && (sl = sr)
		return true
	else 
		return false
}

;====================== INCLUDES ===========================================

#include includes\GUI_Properties.ahk
#include includes\GUI_Setup.ahk

#include includes\msg_dispatch.ahk
#include includes\menuIcons.ahk
#include includes\dialogs.ahk
#include includes\pseudo.ahk
#include includes\config.ahk
#include includes\tc_functions.ahk
#include includes\tc_hook.ahk
#include includes\tv.ahk
#include includes\RemoteBuf.ahk

#include includes\_Application.ahk
#include includes\FileManager.ahk
#include includes\defmenu.ahk
