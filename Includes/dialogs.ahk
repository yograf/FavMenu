; Explorer is seen as dialog if there is another app set as a file manager
; or as a File Manager if not. 
; If Explorer is current File Manager don't report it as a dialog.
;
FavMenu_DialogGetActive(hw=0)
{	
	global 
	local class, title

	WinGet, Favmenu_dlgHwnd, ID, A
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	WinGetTitle, title, ahk_id %Favmenu_dlgHwnd%
	
	if FavMenu_IsOpenSave( Favmenu_dlgHwnd )
			return 1
	
	if FavMenu_IsBrowseForFolder( Favmenu_dlgHwnd )
			return 1

	If (InStr(title, "MINGW32", true)>0)
	{
		FavMenu_dlgType := "Msys"
		return 1
	}

	if (class = "ConsoleWindowClass") or (class = "VirtualConsoleClass")
	{
		FavMenu_dlgType	 := "Console"
		return 1
	}

	if (class = "ExploreWClass") or (class = "CabinetWClass")
	{
		FavMenu_GetExplorerInput()
		FavMenu_dlgType := "Explorer"
		return 1
	}

	if (class = "TTOTAL_CMD")
	{
		FavMenu_dlgType := "TC"
		return 1
	}
	
	If (class = "TfcForm") Or (class="FreeCommanderXE.SingleInst.1")
	{
		FavMenu_dlgType := "FreeCommander"
		return 1
	}	
	
	if ( (class = "Emacs") Or (class = "MicroEmacsClass") Or (class = "XEmacs" ) )
	{
		FavMenu_dlgType := "Emacs"
		return 1
	}
	
	If (class = "mintty") Or (SubStr(class, 1, 4) = "rxvt")
	{
		FavMenu_dlgType := "Cygwin"
		return 1
	}
	
	If (class = "gdkWindowToplevel")
	{
		FavMenu_dlgType := "GTK"
		return 1
	}
	
	If (class = "ATL:ExplorerFrame")
	{
		FavMenu_dlgType := "Xplorer2"
		return 1
	}	

	Favmenu_dlgType := "System"
	Favmenu_dlgHwnd := 0
	return 0
}

;------------------------------------------------------------------------------------------------

FavMenu_GetExplorerInput()
{
	global
	Favmenu_dlgInput := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "WorkerW", 0) 
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ReBarWindow32", 0) 
	;Remember last good value. If Vista, we need the value to retry
	Favmenu_dlgInputOriginal := Favmenu_dlgInput
      
	;Try Combobox. If Vista, that command fails
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBoxEx32", 0)
   
	if Favmenu_dlgInput = 0
	{
		;Perhaps Vista... ??? Use Favmenu_dlgInputOriginal
		Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInputOriginal, "Address Band Root", 0)   
		Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "msctls_progress32", 0)
		FavMenu_msctls_progress32 := Favmenu_dlgInput
		Return
	}   
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBoxEx32", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBox", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "Edit", 0)
}

;------------------------------------------------------------------------------------------------

FavMenu_IsBrowseForFolder( dlg )
{
	global FavMenu_dlgInput, FavMenu_dlgType

	;check for old browse for folder dialog first
	static1 := FavMenu_FindWindowExID(dlg, "Static", 14146)
	static2 := FavMenu_FindWindowExID(dlg, "Static", 14147)
	tree	:= FavMenu_FindWindowExID(dlg, "SysTreeView32", 14145)
	bOK		:= FavMenu_FindWindowExID(dlg, "Button", 1)
	bCancel := FavMenu_FindWindowExID(dlg, "Button", 2)
	
	if static1 * static2 * tree * bOK * bCancel = 0
	{
		;check for new browse for folder dialog
		ctrl := FavMenu_FindWindowExID(dlg, "SHBrowseForFolder ShellNameSpace Control", 0)
		tree := FavMenu_FindWindowExID(ctrl, "SysTreeView32", 100)

		if tree*ctrl  = 0
			return 0
	}

	FavMenu_dlgInput := tree
	FavMenu_dlgType	 := "BFF"

	return 1
}

;------------------------------------------------------------------------------------------------

FavMenu_IsOpenSave(dlg)
{
	global FavMenu_dlgInput, FavMenu_dlgType, FavMenu_msctls_progress32, bread
   
	FavMenu_dlgType =

	toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x440)   ;windows XP
	if (toolbar = "0")
		toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x001)  ;windows 2k

	; Windows 7 OpenSave
	rebar := FavMenu_FindWindowExID(dlg, "WorkerW", 0)
	rebar := FavMenu_FindWindowExID(rebar, "ReBarWindow32", 0)
	rebar := FavMenu_FindWindowExID(rebar, "Address Band Root", 0)
	rebar := FavMenu_FindWindowExID(rebar, "msctls_progress32", 0)
	FavMenu_msctls_progress32 := rebar
	rebar := FavMenu_FindWindowExID(rebar, "Breadcrumb Parent", 0)
	bread := rebar
	rebar := FavMenu_FindWindowExID(rebar, "ToolbarWindow32", 0)
	 
	combo  := FavMenu_FindWindowExID(dlg, "ComboBoxEx32", 0x47C) ; comboboxex field
	button := FavMenu_FindWindowExID(dlg, "Button", 0x001)		; second button
	 
	edit := FavMenu_FindWindowExID(dlg, "Edit", 0x480)			; edit field
	 
	if ((rebar || (toolbar && (combo || edit))) && button) 
	{
		FavMenu_dlgInput   := combo + edit
		if rebar
			FavMenu_dlgInput   := rebar
		FavMenu_dlgType      := "OpenSave"
		return 1
	}

	return FavMenu_IsOffice03(dlg)
}

;------------------------------------------------------------------------------------------------

FavMenu_IsOffice03(dlg)
{
	global FavMenu_dlgInput, FavMenu_dlgType, FavMenu_cOffice

	WinGetClass cls, ahk_id %dlg%

	FavMenu_dlgIsOffice := false
	if cls contains %FavMenu_cOffice%
	{
		snake := FavMenu_FindWindowExID(dlg, "Snake List", 0)
		FavMenu_dlgInput := FavMenu_FindWindowExID(dlg, "RichEdit20W", 54)

		if ! (snake && FavMenu_dlgInput)
			return 0	
			
		FavMenu_dlgType	:= "Office03"
		return 1
	}

	return 0
}
 
;--------------------------------------------------------------------------

FavMenu_DialogGetPath()
{
	global
	OutputDebug,FavMenu_DialogGetPath called with Favmenu_dlgType = %Favmenu_dlgType%`n

	if Favmenu_dlgType = TC
		return Favmenu_DialogGetPath_TC()

	if Favmenu_dlgType = Explorer
		return Favmenu_DialogGetPath_Explorer()

	if Favmenu_dlgType = OpenSave
		return Favmenu_DialogGetPath_OS()
	
	if Favmenu_dlgType = BFF
		return Favmenu_DialogGetPath_BFF()
	
	If FavMenu_dlgType = FreeCommander
		return FavMenu_DialogGetPath_FreeCommander()
	
	if Favmenu_dlgType = Console
		return Favmenu_DialogGetPath_Console()
	
	if Favmenu_dlgType = Emacs
		return Favmenu_DialogGetPath_Emacs()
	
	if Favmenu_dlgType = Xplorer2
		return FavMenu_DialogGetPath_Xplorer2()

	return Favmenu_DialogGetPath_fromTitle()
}

Favmenu_DialogGetPath_fromTitle()
{
	;;for other applications/dialogs, try to parse title
	Local title
	WinGetActiveTitle, title
	OutputDebug,current window not recognized. try to parse directory from title: %title%`n
	If InStr(title, ":\")>1
	{	
		local fstart, fend1, fend2, fend3, curDir
		fstart := InStr(title, ":\") -1
		if fstart <=0
			return
		
		
		fend1 := InStr(title, "]", fstart + 2)
		fend2 := InStr(title, " ", fstart + 2)
		fend3 := InStr(title, " - ", fstart + 2)
		
		local fname1, fname2, fname3
		fname1 := SubStr(title, fstart, fend1 - fstart)
		fname2 := SubStr(title, fstart, fend2 - fstart)
		fname3 := SubStr(title, fstart, fend3 - fstart)
		
		OutputDebug `nDialogGetPath1 fname1=%fname1%`nfname2=%fname2%`nfname3=%fname3%`n
		If FileExist(fname1) 
			curDir := fname1
		else if FileExist(fname2)
			curDir := fname2
		else if FileExist(fname3)
			curDir := fname3
		else
			return
		
		
		If InStr(FileExist(curDir), "D")<=0
		{
			fend := 0
			OutputDebug DialogGetPath2 returns %curDir%`nfend=%fend%`n
			fend := InStr(curDir, "\", false,-1)
			curDir := SubStr(curDir, 1, fend)
			OutputDebug, DialogGetPath returns %curDir%`nfend=%fend%`n
			return curDir
		}
		else
			return curDir
	}
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_TC()
{
	curDir := FavMenu_GetCurrentTCDir()
	StringGetPos idx, curDir, \, R

	if (idx != -1) && StrLen(curDir) > 3
			StringMid name, curDir, idx+2, 256
	else	StringMid name, curDir, 1, 2

	return curDir
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_Explorer()
{
	global Favmenu_dlgHwnd, Favmenu_dlgInput
	tv := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "BaseBar", 0) 
	tv := Favmenu_FindWindowExID(tv, "ReBarWindow32", 0) 
	tv := Favmenu_FindWindowExID(tv, "SysTreeView32", 100)

	TV_Initialise( FavMenu_dlgHWND, tv )
	returnedPath := TV_GetPath()
	if returnedPath <> 
		return returnedPath 
   
	;Nothing was returned. Perhaps Vista    
	FavMenu_GetExplorerInput()

	If FavMenu_msctls_progress32
	{
		OutputDebug,FavMenu_msctls_progress32=%FavMenu_msctls_progress32%`n
		rebar := FavMenu_FindWindowExID(FavMenu_msctls_progress32, "Breadcrumb Parent", 0)
		bread := rebar
		rebar := FavMenu_FindWindowExID(rebar, "ToolbarWindow32", 0)
		
		ControlGetText, EditCtrlPath, , ahk_id %rebar%
		OutputDebug,EditCtrlPath=%EditCtrlPath%`n
		pos1 := InStr(EditCtrlPath, ":")
		If pos1
		{
			EditCtrlPath := SubStr(EditCtrlPath, pos1+2)
			OutputDebug,EditCtrlPath=%EditCtrlPath%`n
		}
	}
	Else
	{
		;MsgBox, Editcontrol %Favmenu_dlgInput%
		ControlGetText, EditCtrlPath, , ahk_id %Favmenu_dlgInput%
		;Msgbox, %EditCtrlPath%
	}
	return  %EditCtrlPath%
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_Console()
{
	WinGetActiveTitle,Title
	if InStr(Title, "} - Far ") > 1
	{
		;;FAR manager
		;;e.g.   {D:\wintools\FAR2} - Far 2.0.1777 x86 Administrator
		curDir := SubStr(Title, 2, InStr(Title, "}") - 2)
		OutputDebug,DialogGetPath_Console returns %curDir%
		return curDir
	}
	SendInput {HOME}echo {END}>c:\favmenu_contmp&echo `%cd`%>>c:\favmenu_contmp{ENTER}
	Sleep 100

	FileReadLine prev, c:\favmenu_contmp, 1
	FileReadLine curDir, c:\favmenu_contmp, 2
	FileDelete c:\favmenu_contmp
	
	if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
		SendInput %prev%
	
	return curDir
}

Favmenu_DialogGetPath_FreeCommander()
{
	local title
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	;~ if class="TfcForm"
	;~ {
		;~ ;;FreeCommander
		;~ Send,!g
		;~ Sleep 100
		;~ ControlGetText, path, TfcPathEdit
		;~ Send {ESC}
		;~ return path
	;~ }else ;;if class="FreeCommanderXE.SingleInst.1"
	;~ { ;;FreeCommanderXP
		;~ Send,!g
		;~ Sleep 100
		;~ ControlGetText, path, TfcPathEdit
		;~ Send {ESC}
		;~ return path
	;~ }
	WinActivate,ahk_id %Favmenu_dlgHwnd%
	Send,!g
	Sleep 300
	;;ControlGetText, fcpath, ahk_class TfcPathEdit
	Send,^c
	Send {ESC}
	return %Clipboard%
} 

FavMenu_DialogGetPath_Xplorer2()
{
	global FavMenu_dlgHwnd
	rebar := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "ReBarWindow32", 0) 
	toolwin := Favmenu_FindWindowExID(rebar, "ToolbarWindow32", 60160) 
	combo := Favmenu_FindWindowExID(toolwin, "ComboBox", 0)
		
	if (combo)
	{
		ControlGetText, result, ComboBox1, ahk_id %FavMenu_dlgHwnd%
		return result
	}
	
}

Favmenu_DialogGetPath_Emacs()
{
	;;TODO: ensure compatibility of XEmacs
  
	WinGetActiveTitle,Title

	;; cancel current thing if any
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; begging-of-line
	SendInput ^a

	;; set-mark
	if InStr(Title, " MicroEmacs")>1
	{
		;;tested on MicroEmacs-jasspa
		SendInput {Esc}{Space}
	}
	Else
	{
		SendInput ^+2  ;; C-@
	}
	;; move-end-of-line
	SendInput ^e

	;; kill-ring-save
	SendInput !w
	Sleep 100

	;; cancel find-file
	SendInput ^g

	resultP = %clipboard%
	;; OutputDebug,Clipboard content: %clipboard%
	StringReplace,curDir,resultP,/,\,All
	;; OutputDebug,Favmenu_DialogSetPath_Emacs returns: %curDir%
	return curDir
}
;--------------------------------------------------------------------------

Favmenu_DialogGetPath_BFF()
{
	global

	TV_Initialise( FavMenu_dlgHWND, FavMenu_dlgInput )
	return TV_GetPath()
}

FavMenu_DialogGetPath_OS()
{
	global Favmenu_dlgHwnd

	WM_USER = 0x400 
	CDM_FIRST := WM_USER + 100
	CDM_GETFOLDERPATH := CDM_FIRST + 0x0002

	bufID := RemoteBuf_Open(Favmenu_dlgHwnd, 256)
	adr := RemoteBuf_GetAdr(bufID)
	SendMessage CDM_GETFOLDERPATH, 256, adr,, ahk_id %Favmenu_dlgHwnd%
	textSize := errorlevel
	if (textSize <= 0)
		return

	VarSetCapacity(buf, 256, 0)
	RemoteBuf_Read(bufID, buf, 256)
	RemoteBuf_Close(bufID)

	VarSetCapacity(ansiString, textSize, 0)
	
	;Check if Windows returned unicode string. Sine drive letter is first char, it will be ANSI
	; so unicode can be check by comparing next char to 0
	if *(&buf+1) = 0
			return FavMenu_GetAnsiStringFromUnicodePointer(&buf)
	else	return buf
	
}

;--------------------------------------------------------------------------
FavMenu_DialogSetPath(path, bTab = false)
{
	global FavMenu_dlgType
	OutputDebug,FavMenu_DialogSetPath called with Favmenu_dlgType = %Favmenu_dlgType%`n

	if FavMenu_dlgType = TC
		FavMenu_DialogSetPath_TC(path, bTab)

	if FavMenu_dlgType contains OpenSave,Office03
		FavMenu_DialogSetPath_OS(path)	
	
	if FavMenu_dlgType = BFF
		FavMenu_DialogSetPath_BFF(path)
	
	if FavMenu_dlgType = Msys
		FavMenu_DialogSetPath_Msys(path, bTab)
	
	if FavMenu_dlgType = Console
		FavMenu_DialogSetPath_Console(path, bTab)

	if FavMenu_dlgType = Emacs
		FavMenu_DialogSetPath_Emacs(path)
	
	if FavMenu_dlgType = Explorer
		FavMenu_DialogSetPath_Explorer(path, bTab)
	
	If FavMenu_dlgType = FreeCommander
		FavMenu_DialogSetPath_FreeCommander(path, bTab)
	
	if FavMenu_dlgType = Cygwin
		FavMenu_DialogSetPath_Cygwin(path)
	
	if FavMenu_dlgType = GTK
		FavMenu_DialogSetPath_GTK(path)

	if FavMenu_dlgType = Xplorer2
		FavMenu_DialogSetPath_Xplorer2(path, bTab)
}

;--------------------------------------------------------------------------
FavMenu_DialogSetPath_TC(path, bTab = false)
{
	global 

	if (bTab)
		FavMenu_SendTCCommand(cm_OpenNewTab)
	
	WinActivate ahk_class TTOTAL_CMD

	FavMenu_SendTCCommand(cm_editpath)
	SendRaw, %path%
	Send, {ENTER}
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_GTK(path)
{
	OutputDebug,FavMenu_DialogSetPath_GTK called
	;; activate shortcut folder list 
;	SendInput,!r
;	Sleep 100
	;; activate the 3rd shortcut, to avoid 'Search' & 'Recent' (which prevents ctrl-l bringing up path entry)
;	SendInput {Down}{Down}
;	Sleep 100
	
	;;show the path entry
	SendInput,^l
	Sleep 100
	SendInput %path%  
	Sleep 100
	SendInput {End}{Enter}
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_Explorer(path, bTab = false)
{
	global
	
	If FavMenu_msctls_progress32
	{
		FavMenu_DialogSetPath_OS(path)
		Return
	}
	
	if (Favmenu_dlgInput = 0)
	{
		MsgBox To use FavMenu with Windows Explorer you must enable Address Bar.`nEnable it in View->Toolbars.
		return 
	}

	ControlSetText, ,%path%, ahk_id %Favmenu_dlgInput%
	ControlSend, ,{ENTER},ahk_id %Favmenu_dlgInput%
}

Favmenu_DialogSetPath_FreeCommander(path, bTab = false)
{
	WinActivate,ahk_id %Favmenu_dlgHwnd%
	if bTab
	{
		Send,^t
		Sleep,300
	}
	Send,!g
	Sleep 300
	;;ControlGetText, fcpath, ahk_class TfcPathEdit
	SendRaw,%path%
	Send {Enter}
}

FavMenu_DialogSetPath_Xplorer2(path, bTab = false)
{
	WinActivate, ahk_id %FavMenu_dlgHwnd%
	
	if (bTab)
	{
		SendInput,^{Ins}
	}
	
	Sleep 100
	
	SendInput, {F10}{HOME}+{END} ;;{DELETE}

	SendInput,%path%{ENTER}
	
	Sleep 100
	
}

;--------------------------------------------------------------------------
FavMenu_DialogSetPath_Msys(path, bTab = false)
{
	;;other front-ends: cmd, rxvt, mintty, conemu
	WinGetClass,klass,A
	path1 := RegExReplace(path, "\\$", "")
	OutputDebug,FavMenu_DialogSetPath_Msys called with klass=%klass%, path=%path1%
	
	If klass = Console_2_Main
	{
		OutputDebug,put clipboard content: "cd %path1%"
		;;Console2 has problems when SendInput (it would change : to ;)
		 Clipboard = cd "%path1%"
		SendInput, +{Insert}{Enter}
	}
	else
	{
		 SendInput cd "%path%"{ENTER}
	}
}

FavMenu_DialogSetPath_Console(path, bTab = false)
{
	global Favmenu_Options_IAppend

	WinGetActiveTitle,Title
	WinGetClass,class
	If class = "Console_2_Main")
	{
	    ;;Console2 has problems when SendInput (it would change : to ;)
	    Clipboard = cd /d "%path%"
	    SendInput, +{Insert}{Enter}
	}
	else if InStr(Title, "- Far ")>1
	{
		;; FAR manager  ;;TODO: support tabs (PanelTabs plugin)
		SendInput ^y    ;;clear command line
		SetKeyDelay,30  ;;FAR's auto-completion would make the keystroke not accurate
		SendInput cd /d %path%{ENTER}
		
	}
	Else
	{
		;StringLeft, drive, path, 2
		;SendInput, {HOME}echo {END}>c:\favmenu_contmp&%drive%&cd %path%&%Favmenu_Options_IAppend%{ENTER}
		;Sleep 100
		;FileReadLine prev, c:\favmenu_contmp, 1

		;if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
		;;	SendInput %prev%
		;FileDelete c:\favmenu_contmp
		
		SendInput cd /d %path%{ENTER}
	}
}

FavMenu_DialogSetPath_Emacs(path)
{
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; beginning-of-line, kill-line
	Sleep 100
	SendInput ^a^k
	Sleep 100
	
	SendInput %path%{ENTER}

	Sleep 100
}

FavMenu_DialogSetPath_Cygwin(path)
{
	OutputDebug,FavMenu_DialogSetPath_Cygwin called
	;;SendInput, cd ``cygpath -u '%path%'``{ENTER}
	SendInput, pushd '%path%'{ENTER}  ;;this works for mintty for cygwin & msys
	Sleep 100
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_OS(path)
{
	global 
	local d_text, d_f
	
	WinWaitActive ahk_id %FavMenu_dlgHWND%

	ControlGetFocus d_f, ahk_id %FavMenu_dlgHWND%
	ControlFocus, , ahk_id %FavMenu_dlgInput%

	Sleep 20
	if FavMenu_msctls_progress32
	{
        	ControlSend, ,{Space}, ahk_id %FavMenu_dlgInput%
		Sleep 20
		rebar := FavMenu_FindWindowExID(FavMenu_msctls_progress32, "ComboBoxEx32", 0)
		rebar := FavMenu_FindWindowExID(rebar, "ComboBox", 0)
		rebar := FavMenu_FindWindowExID(rebar, "Edit", 0)
		if rebar
		{
			Sleep 20
			ControlSetText, , %path%, ahk_id %rebar%
		ControlSend, ,{ENTER}, ahk_id %rebar%
		}
	}
	else
	{
		ControlGetText d_text, ,ahk_id %FavMenu_dlgInput%
		ControlSetText, , %path%, ahk_id %FavMenu_dlgInput%
		ControlSend, ,{ENTER}, ahk_id %FavMenu_dlgInput%
	}
	Sleep 20
	if (FavMenu_dlgType = "Office03")
		ControlFocus %d_f%, ahk_id %FavMenu_dlgHWND%
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_BFF( path )
{
	global

	BFFM_SETSELECTION := 0x400 + 102

	VarSetCapacity(wPath, StrLen( path ) * 2, 0)
	Favmenu_GetUnicodeString(wPath, path)

	bufID := RemoteBuf_Open(FavMenu_dlgHWND, 256)
	RemoteBuf_Write(bufId, Path , 256)
	adr := RemoteBuf_GetAdr(bufID)

	;SendMessage BFFM_SETSELECTION, 1, adr, ,ahk_class %FavMenu_dlgHWND%
	res := DllCall("SendMessageA"
         , "UInt", FavMenu_dlgHWND
         , "UInt", BFFM_SETSELECTION
         , "UInt", 1
         , "Uint", adr)

	RemoteBuf_Close( bufId )
}


;------------------------------------------------------------------------------------------------

FavMenu_GetSFLabel( sFolder )
{
	if (sFolder = "My Documents")
		return	Favmenu_GetResString("{450D8FBA-AD25-11D0-98A8-0800361B1103}")
	
	if (sFolder = "My Computer")
		return	Favmenu_GetResString("{20D04FE0-3AEA-1069-A2D8-08002B30309D}")

	if (sFolder = "My Network Places" )
		return	Favmenu_GetResString("{208D2C60-3AEA-1069-A2D7-08002B30309D}")
}

;--------------------------------------------------------------------------

FavMenu_GetResString( p_clsid )
{
	key = SOFTWARE\Classes\CLSID\%p_clsid%
	RegRead res, HKEY_LOCAL_MACHINE, %key%, LocalizedString
	
;get dll and resource id 
	StringGetPos idx, res, -, R
    StringMid, resID, res, idx+2, 256
	StringMid, resDll, res, 2, idx - 2
	resDll := FavMenu_ExpandEnvVars(resDll)
	
;get string from resource
	VarSetCapacity(buf, 256)
	hDll := DllCall("LoadLibrary", "str", resDll)
	Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)

	return buf
}

;------------------------------------------------------------------------------------------------
; Iterate through controls with the same class, find the one with ctrlID and return its handle
; Used for finding a specific control on a dialog

FavMenu_FindWindowExID(dlg, className, ctrlId)
{
	local ctrl, id

	ctrl = 0
	Loop
	{
		ctrl := DllCall("FindWindowEx", "uint", dlg, "uint", ctrl, "str", className, "uint", 0 )
		if (ctrlId = "0")
		{
			return ctrl
		}

		if (ctrl != "0")
		{
			id := DllCall( "GetDlgCtrlID", "uint", ctrl )
			if (id = ctrlId) 
				return ctrl				
		}
		else 
			return 0
	}
}

;------------------------------------------------------------------------------------------------
; Some API functions require a WCHAR string. 
;
Favmenu_GetUnicodeString(ByRef @unicodeString, _ansiString) 
{ 
   local len 

   len := StrLen(_ansiString) 
   VarSetCapacity(@unicodeString, len * 2 + 1, 0) 

   ; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/unicode_17si.asp 
   DllCall("MultiByteToWideChar" 
         , "UInt", 0             ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001 
         , "UInt", 0             ; dwFlags 
         , "Str", _ansiString    ; LPSTR lpMultiByteStr 
         , "Int", len            ; cbMultiByte: -1=null terminated 
         , "UInt", &@unicodeString ; LPCWSTR lpWideCharStr 
         , "Int", len)           ; cchWideChar: 0 to get required size 
} 

;------------------------------------------------------------------------------------------------
; Some API functions return a WCHAR string. 
;
FavMenu_GetAnsiStringFromUnicodePointer(_unicodeStringPt) 
{ 
   local len, ansiString 

   len := DllCall("lstrlenW", "UInt", _unicodeStringPt) 
   VarSetCapacity(ansiString, len, 0) 

   DllCall("WideCharToMultiByte" 
         , "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001 
         , "UInt", 0           ; dwFlags 
         , "UInt", _unicodeStringPt ; LPCWSTR lpWideCharStr 
         , "Int", len          ; cchWideChar: size in WCHAR values, -1=null terminated 
         , "Str", ansiString   ; LPSTR lpMultiByteStr 
         , "Int", len          ; cbMultiByte: 0 to get required size 
         , "UInt", 0           ; LPCSTR lpDefaultChar 
         , "UInt", 0)          ; LPBOOL lpUsedDefaultChar 

   Return ansiString 
}
