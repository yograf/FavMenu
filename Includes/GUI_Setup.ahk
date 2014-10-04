Setup_Create()
{
	global 
	
	Gui, %Setup_GUI%:Add, Tab,		X0 Y0 h260 w500 +0x100 +0x300,						Configuration | Appearance | Integration | Help
	
	; --- tab 1
	Gui, %Setup_GUI%:Add, Text,		x23  y40  w250 h17,										File Manager ( exe )
	Gui, %Setup_GUI%:Add, Edit,		x23  y58  w260 h20	vSetup_eTcExe	
	Gui, %Setup_GUI%:Add, Text,		x23  y88 w250 h17,										Menu definition ( ini )
	Gui, %Setup_GUI%:Add, Edit,		x23  y105 w260 h20	vSetup_eTcIni

	Gui, %Setup_GUI%:Font, underline s8, Arial
	Gui, %Setup_GUI%:Add, Text,		x183  y128 w260 h20	gSetup_OnSampleMenuClick,			create sample menu
	Gui, %Setup_GUI%:Font, normal
	
	Gui, %Setup_GUI%:Font, bold
	Gui, %Setup_GUI%:Add, Text,		x286 y63  w13  h14	gSetup_OnBrowseClick vSetup_bExe,	>>
	Gui, %Setup_GUI%:Add, Text,		x286 y108 w13  h14	gSetup_OnBrowseClick,				>>
	Gui, %Setup_GUI%:Font, norm
	
	;hotkeys
	Gui, %Setup_GUI%:Add, Text,		x40  y170 w100 h20,										Menu Hotkey 
	Gui, %Setup_GUI%:Add, Hotkey,   x26  y190 w100 h30	vSetup_MenuHotkey,					^w

	Gui, %Setup_GUI%:Add, Text,		x180 y170 w90  h20,										On/Off Hotkey
	Gui, %Setup_GUI%:Add, Hotkey,	x170 y190 w100 h30	vSetup_OnOffKey


	; --- tab 2
	Gui, %Setup_GUI%:Tab, 2
	Gui, %Setup_GUI%:Add, GroupBox,	x16  y30  w270 h130,									  Content  
	Gui, %Setup_GUI%:Add, Checkbox, x26  y50  w250 h20	vSetup_cShowEditor,					Show editor at the bottom of the menu   
	Gui, %Setup_GUI%:Add, Edit,		x45  y72  w220 h20	vSetup_eEditor,		     
	Gui, %Setup_GUI%:Add, Checkbox, x26  y100 w250 h20  vSetup_cShowTCFolders,				Show current TC folders at the top of the menu
	Gui, %Setup_GUI%:Add, Checkbox, x26  y120 w250 h30  vSetup_cShowAddDirs,				Show "Add current directory"

	Gui, %Setup_GUI%:Add, GroupBox, x16  y170 w270 h70,										  Show menu at
	Gui, %Setup_GUI%:Add, Radio,	x26  y187 w60  h40  vSetup_MenuPos,						mouse position 
	Gui, %Setup_GUI%:Add, Radio,	x106 y187 w70  h40  Checked,							cursor position
	Gui, %Setup_GUI%:Add, Radio,	x176 y187 w100 h40,										center of the active window


	; --- tab 3
	Gui, %Setup_GUI%:Tab, 3
	Gui, %Setup_GUI%:Add, CheckBox, x20  y40  w260 h20	vSetup_IOpenSave	,				Open / Save dialogs									
	Gui, %Setup_GUI%:Add, CheckBox, x20  y60  w260 h30	vSetup_IBFF			,				Browse For Folders dialogs
	Gui, %Setup_GUI%:Add, CheckBox, x20  y90  w260 h20	vSetup_IConsole		,				Console (cmd.exe)
	Gui, %Setup_GUI%:Add, Text,		x40  y113 w160 h20						,				Append custom command :
	Gui, %Setup_GUI%:Add, Edit,		x180 y110 w120 h20	vSetup_IAppend		,				dir /w
	Gui, %Setup_GUI%:Add, CheckBox, x20  y135 w260 h20	vSetup_IExplorer 	,				Windows Explorer
	Gui, %Setup_GUI%:Add, CheckBox, x20  y152 w260 h30	vSetup_ITC			,				Total Commander
	Gui, %Setup_GUI%:Add, CheckBox, x20  y200 w260 h30	vSetup_ISystem		,				System   ( redirect to file manager )
	
	; --- tab 4
	Gui, %Setup_GUI%:Tab, 4
	Gui, %Setup_GUI%:Add, Text,		x20  y40 w260 h20						,	Ctrl + Enter: 
	Gui, %Setup_GUI%:Add, Text,		x40  y60 w260 h20						,	        Edit selected item
	Gui, %Setup_GUI%:Add, Text,       x20  y80 w260 h20                  ,   Shift + Enter: 
	Gui, %Setup_GUI%:Add, Text,       x40  y100 w260 h20                  ,          Open selected item in new tab
	Gui, %Setup_GUI%:Add, Text,       x20  y120 w260 h20                  ,   CTRL + SHIFT + Enter: 
	Gui, %Setup_GUI%:Add, Text,       x40  y140 w260 h20                  ,          Send path as text to the active window.
	
	; on all tabs
	Gui, %Setup_GUI%:Tab 
	Gui, %Setup_GUI%:Add, Button,	x106 y262 w90 h22	gSetup_OnSaveClickDispatch +0x8000,			&Save
	Gui, %Setup_GUI%:Add, StatusBar

	;remember handle
	Gui	 %Setup_GUI%:+LastFound
	Setup_hwnd := WinExist() + 0


	;call start event
	DllCall("SendMessage", "uint", Setup_hwnd, "uint", WM_AHKSHOW, "uint", 0, "uint", 0)
	
	Setup_visible := true
	Gui, %Setup_GUI%:Show, x487 y302 h320 w315, Setup
}


Setup_OnSampleMenuClick:
	MsgBox 1, Setup, This will create the sample menu (menu.ini) in program's directory.`nPress OK to do it!
	IfMsgBox Cancel
		return
	
	if FileExist("menu.ini")
	{
		MsgBox 1, Setup, Menu.ini already exist in the programs directory.`nOverwrite ?
		ifMsgBox Cancel
			return
	}

	CreateDefaultMenu()
	GuiControl, ,Setup_eTcIni, menu.ini
return

;-----------------------------------------------------------------------------------

Setup_OnBrowseClick:
	if (A_GuiControl = "Setup_bExe")
		FileSelectFile, tmp, 3, , Select File Manager, TotalCmd.exe;Explorer.exe 
	else
		FileSelectFile, tmp, 3, , Select Menu Definition, wincmd.ini;menu.ini
	
	if Errorlevel = 1
		return
	
	if (A_GuiControl = "Setup_bExe")
		GuiControl, Text, Setup_eTcExe, %tmp%
	else
		GuiControl, Text, Setup_eTcIni, %tmp%
return

;-----------------------------------------------------------------------------------

Setup_FixWinHotkeys()
{
	global 

	;if LWin/RWin was set manualy
	if Setup_MenuHotkey = SC15b
		Setup_MenuHotkey = LWin
	
	if Setup_MenuHotkey = SC15c
		Setup_MenuHotkey = RWin

	if Setup_OnOffKey = SC15b
		Setup_OnOffKey = LWin

	if Setup_OnOffKey = SC15c
		Setup_OnOffKey = RWin
}

;-----------------------------------------------------------------------------------

Setup_OnSaveClick()
{
	global
	local msg
	
	Gui %Setup_GUI%:Submit, NoHide

	FavMenu_fmExeEnv := Setup_eTcExe
	FavMenu_fmIniEnv := Setup_eTcIni

	FavMenu_fmExe := FavMenu_ExpandEnvVars(FavMenu_fmExeEnv)
	FavMenu_fmIni := FavMenu_ExpandEnvVars(FavMenu_fmIniEnv)

	if ( !FileExist(FavMenu_fmExe) )
		msg = EXE doesn't exist.`n
	
	if ( !FileExist(FavMenu_fmIni) )
		msg = %msg% INI doesn't exist.`n
	
	if ( Setup_MenuHotkey = "")
		msg = %msg% You must choose a menu hot key.`n
	
	if (msg != "")
	{
		MsgBox %msg%	
		return
	}


	Setup_FixWinHotkeys()

	;remove previous hotkey (it will not exist on first run, so use errorlevel to avoid error)
	Hotkey, %FavMenu_fmKey%,  ,UseErrorLevel Off
	Hotkey, %Favmenu_Options_OnOffKey%, ,UseErrorLevel Off

	; turn on the new hotkey
	FavMenu_fmKey := Setup_MenuHotkey
	Favmenu_Options_OnOffKey := Setup_OnOffKey
	Hotkey %FavMenu_fmKey%, FavMenu_MenuHotKey, On
	if (FavMenu_Options_OnOffKey != "")
		HotKey %FavMenu_Options_OnOffKey%, FavMenu_OnOffHotkey, On

	;everything is valid, set & save the data and destroy the window
	Favmenu_Options_MenuPos			:= Setup_MenuPos
	Favmenu_Options_ShowEditor		:= Setup_cShowEditor
	Favmenu_Options_Editor			:= Setup_eEditor
	Favmenu_Options_ShowTCFolders	:= Setup_cShowTCFolders
	Favmenu_Options_ShowAddDirs		:= Setup_cShowAddDirs

	;integration
	Favmenu_Options_IOpenSave		:= Setup_IOpenSave
	Favmenu_Options_IBFF			:= Setup_IBFF
	Favmenu_Options_IConsole		:= Setup_IConsole
	Favmenu_Options_IAppend			:= Setup_IAppend
	Favmenu_Options_IExplorer		:= Setup_IExplorer
	Favmenu_Options_ITC				:= Setup_ITC
	Favmenu_Options_ISystem			:= Setup_ISystem

	FavMenu_SaveConfigData()
	Setup_Close()
}

Setup_OnSaveClickDispatch:
	Setup_OnSaveClick()
return

;-----------------------------------------------------------------------------------

Setup_OnKeyDown(wparam, lparam)
{
  if (wparam = "27")
	Setup_Close()
}

;-----------------------------------------------------------------------------------

Setup_Show()
{
	global 
	local posButton


	; change existing configuration
	if ( FavMenu_GetConfigData() )
	{
		;tab 1
		GuiControl, Text, Setup_eTcExe,		%FavMenu_fmExeEnv% 
		GuiControl, Text, Setup_eTcIni,		%FavMenu_fmIniEnv%
		GuiControl, Text, Setup_MenuHotkey, %FavMenu_fmKey%
	
		
		SB_SetText("Change existing configuration")
		goto Setup_SetOptions
	}


	;running for the first time
	; no config -> try to find commander first
	if (! FavMenu_FindCommander() )
	{
		SB_SetText("Total Commander NOT found!  Using Windows Explorer instead. ")
		GuiControl, Text, Setup_eTcExe,	`%WINDIR`%\Explorer.exe
		GuiControl, Text, Setup_eTcIni, %A_ScriptDir%\menu.ini
		if !FileExist(A_ScriptDir . "\menu.ini")
			CreateDefaultMenu()
		goto Setup_SetOptions
	}

	; commander found, initialise configuration with found data
	GuiControl, Text, Setup_eTcExe, %FavMenu_fmExe% 
	GuiControl, Text, Setup_eTcIni, %FavMenu_fmIni%
	SB_SetText("First run: Total Commander found !")



 Setup_SetOptions:	

	;first radio button in Position section
	posButton := 6

	if FavMenu_Options_OnOffKey != &
		GuiControl,	, Setup_OnOffKey,	%FavMenu_Options_OnOffKey%

	GuiControl, , Setup_cShowEditor,	%FavMenu_Options_ShowEditor%
	GuiControl,	, Setup_cShowTCFolders, %FavMenu_Options_ShowTCFolders%
	GuiControl, , Setup_eEditor,		%FavMenu_Options_Editor%
	GuiControl, , Setup_cShowAddDirs,	%FavMenu_Options_ShowAddDirs%

	GuiControl, ,% "Button" . (Favmenu_Options_MenuPos + posButton - 1), 1


	;integration
	GuiControl, ,Setup_IOpenSave, %Favmenu_Options_IOpenSave%			
	GuiControl, ,Setup_IBFF,      %Favmenu_Options_IBFF%				
	GuiControl, ,Setup_IConsole,  %Favmenu_Options_IConsole%			
	GuiControl, ,Setup_IAppend,   %Favmenu_Options_IAppend%			
	GuiControl, ,Setup_IExplorer, %Favmenu_Options_IExplorer%			
	GuiControl, ,Setup_ITC,       %Favmenu_Options_ITC%				
	GuiControl, ,Setup_ISystem,	  %Favmenu_Options_ISystem%			


}

;-----------------------------------------------------------------------------------

Setup_Close()
{
	global 

	if !Setup_visible 
		return
	
	if !FavMenu_GetConfigData()
	{
		MsgBox No configuration. Program will exit.
		ExitApp
	}
    

	Setup_visible := false
	Gui, %Setup_GUI%:Destroy
}