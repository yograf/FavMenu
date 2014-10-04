FavMenu_SetTrayMenu(submenu)
{
	global FavMenu_trayMenu, Favmenu_standalone

	FavMenu_trayMenu := submenu
	if (Favmenu_standalone)
	{
		FavMenu_trayMenu := "Tray"
		Menu, %FavMenu_trayMenu%, icon, res\enable.ico
		Menu, %FavMenu_trayMenu%, NoStandard
		Menu, %FavMenu_trayMenu%, Tip, TC Fav Menu
	}

	Menu, %FavMenu_trayMenu%, add, Show Menu, FavMenu_TrayDefaultDispatch
	Menu, %FavMenu_trayMenu%, add, Setup,	FavMenu_trayDispatch
	Menu, %FavMenu_trayMenu%, add, Disable,	FavMenu_trayDispatch
	Menu, %FavMenu_trayMenu%, add

	Menu, %FavMenu_trayMenu%, add, Help,	FavMenu_trayDispatch
	Menu, %FavMenu_trayMenu%, add, About,	FavMenu_trayDispatch
	Menu, %FavMenu_trayMenu%, add

	if (Favmenu_standalone)
	{
		Menu, %FavMenu_trayMenu%, Default, Show Menu
		Menu, %FavMenu_trayMenu%, Click, 1

		Menu, %FavMenu_trayMenu%, add, Reload,	FavMenu_trayDispatch 
		Menu, %FavMenu_trayMenu%, add, Exit,	FavMenu_trayDispatch
	}

	Menu, %FavMenu_trayMenu%, UseErrorLevel
}

;---------------------------------------------------------------------------------
;Show the menu from the tray
;
FavMenu_TrayDefault()
{
	local t
	Send, !{ESC}
	Sleep 50

	t := FavMenu_Options_menupos
	FavMenu_Options_menupos = 1
	FavMenu_Create()
	FavMenu_Options_menupos := t
}

FavMenu_TrayDefaultDispatch:
	FavMenu_TrayDefault()
return

;---------------------------------------------------------------------------------

FavMenu_TrayHandler()
{
	global 
	local msg

	if A_ThisMenuItem contains Enable,Disable
		gosub FavMenu_OnOffHotkey

	if ( A_ThisMenuItem = "Setup" ) && (!setup_visible)
		Setup_Create()
	
	if ( A_ThisMenuItem = "Reload" )
		Reload

	if ( A_ThisMenuItem = "About" )
	{
		msg :=
		msg := msg . Favmenu_title . "  " . Favmenu_version . "`n`n`n"
		msg := msg . "Created by:`t`t    Miodrag Milic`n"

		msg := msg . "e-mail:`t`t miodrag.milic@gmail.com`n`n`n"

		msg := msg . "code.r-moth.com`nwww.r-moth.com`nr-moth.deviantart.com`n`n"
		msg := msg . "Jun 2006`n"
		MsgBox 48, About, %msg%
	}

	if ( A_ThisMenuItem = "Exit" )
		ExitApp

	if ( A_ThisMenuItem = "Help" )
		Run FavMenu.html.
}

FavMenu_trayDispatch:
 FavMenu_TrayHandler()
return

;---------------------------------------------------------------------------------

FavMenu_FindCommander()
{
	global FavMenu_fmIni, FavMenu_fmExe

	RegRead FavMenu_fmExe, HKEY_CURRENT_USER, Software\Ghisler\Total Commander, InstallDir
	RegRead FavMenu_fmIni, HKEY_CURRENT_USER, Software\Ghisler\Total Commander, IniFileName

	FavMenu_fmExe = %FavMenu_fmExe%\TotalCmd.exe

	if (FileExist(FavMenu_fmExe)) && (FileExist(FavMenu_fmIni))
	return true

	EnvGet COMMANDER_PATH, COMMANDER_PATH
	if (COMMANDER_PATH != "")
	{
		FavMenu_fmExe = %COMMANDER_PATH%\TotalCmd.exe
		FavMenu_fmIni = %COMMANDER_PATH%\wincmd.ini
	
		if (FileExist(FavMenu_fmExe)) && (FileExist(FavMenu_fmIni))
		return true
	}
 
	return false
}

;-----------------------------------------------------------------------------------

FavMenu_GetConfigData()
{
	global

	;get required
	IniRead FavMenu_fmExeEnv, %Favmenu_configFile%, TcFavMenu, tcExe, & 
	IniRead FavMenu_fmIniEnv, %Favmenu_configFile%, TcFavMenu, tcIni, &
	IniRead FavMenu_fmKey, %Favmenu_configFile%, TcFavMenu, tcKey, &
	FavMenu_fmExe := FavMenu_ExpandEnvVars(FavMenu_fmExeEnv)
	FavMenu_fmIni := FavMenu_ExpandEnvVars(FavMenu_fmIniEnv)

	;get on/off hotkey
	IniRead FavMenu_Options_OnOffKey,		%Favmenu_configFile%, TcFavMenu, OnOffKey,		&

	;get apperiance
	IniRead Favmenu_Options_MenuPos,		%Favmenu_configFile%, TcFavMenu, MenuPos,		2
	IniRead FavMenu_Options_Editor,			%Favmenu_configFile%, TcFavMenu, Editor,		Editor.exe
	IniRead FavMenu_Options_ShowEditor,		%Favmenu_configFile%, TcFavMenu, ShowEditor,	1
	IniRead FavMenu_Options_ShowTCFolders,	%Favmenu_configFile%, TcFavMenu, ShowTCFolders,	1
	IniRead FavMenu_Options_ShowAddDirs,	%Favmenu_configFile%, TcFavMenu, ShowAddDirs,	1

	;get integration
	IniRead Favmenu_Options_IOpenSave,		%Favmenu_configFile%, TcFavMenu, IOpenSave,		1
	IniRead Favmenu_Options_IBFF,			%Favmenu_configFile%, TcFavMenu, IBFF,			1
	IniRead Favmenu_Options_IConsole,		%Favmenu_configFile%, TcFavMenu, IConsole,		1
	IniRead Favmenu_Options_IAppend,		%Favmenu_configFile%, TcFavMenu, IAppend,		dir /w /oGN
	IniRead Favmenu_Options_IExplorer,		%Favmenu_configFile%, TcFavMenu, IExplorer,		1
	IniRead Favmenu_Options_ITC,			%Favmenu_configFile%, TcFavMenu, ITC,			1
	IniRead Favmenu_Options_ISystem,		%Favmenu_configFile%, TcFavMenu, ISystem,		1

	IniRead Favmenu_Options_IEmacs,			%Favmenu_configFile%, TcFavMenu, IEmacs,		1
	IniRead Favmenu_Options_IFAR,			%Favmenu_configFile%, TcFavMenu, IFAR,			1
	IniRead Favmenu_Options_ICygwin,		%Favmenu_configFile%, TcFavMenu, ICygwin,		1
	IniRead Favmenu_Options_IGTK,			%Favmenu_configFile%, TcFavMenu, IGTK,			1
	IniRead Favmenu_Options_IFreeCommander,	%Favmenu_configFile%, TcFavMenu, IFreeCommander,	1
	IniRead Favmenu_Options_IMsys,			%Favmenu_configFile%, TcFavMenu, IMsys,			1
 	IniRead Favmenu_Options_IXplorer2,		%Favmenu_configFile%, TcFavMenu, IXplorer2,		1

	if (FavMenu_fmExe = "&") || (FavMenu_fmIni = "&") || (FavMenu_fmKey = "&")
		return false
	else	
		return true
}

;-----------------------------------------------------------------------------------
FavMenu_SaveConfigData()
{
	global

	;tab 1
	IniWrite %FavMenu_fmExeEnv%, %Favmenu_configFile%, TcFavMenu, tcExe
	IniWrite %FavMenu_fmIniEnv%, %Favmenu_configFile%, TcFavMenu, tcIni
	IniWrite %FavMenu_fmKey%,	 %Favmenu_configFile%, TcFavMenu, tcKey

	;tab 2
	IniWrite %FavMenu_Options_ShowEditor%,	  %Favmenu_configFile%, TcFavMenu, ShowEditor
	IniWrite %FavMenu_Options_Editor%,		  %Favmenu_configFile%, TcFavMenu, Editor
	IniWrite %Favmenu_Options_ShowTCFolders%, %Favmenu_configFile%, TcFavMenu, ShowTCFolders
	IniWrite %Favmenu_Options_MenuPos%,		  %Favmenu_configFile%, TcFavMenu, MenuPos
	IniWrite %FavMenu_Options_OnOffKey%,	  %Favmenu_configFile%, TcFavMenu, OnOffKey
	IniWrite %FavMenu_Options_ShowAddDirs%,	  %Favmenu_configFile%, TcFavMenu, ShowAddDirs

	;tab 3
	IniWrite %Favmenu_Options_IOpenSave%,	%Favmenu_configFile%, TcFavMenu, IOpenSave
	IniWrite %Favmenu_Options_IBFF%,		%Favmenu_configFile%, TcFavMenu, IBFF
	IniWrite %Favmenu_Options_IConsole%,	%Favmenu_configFile%, TcFavMenu, IConsole
	IniWrite %Favmenu_Options_IAppend%,		%Favmenu_configFile%, TcFavMenu, IAppend
	IniWrite %Favmenu_Options_IExplorer%,	%Favmenu_configFile%, TcFavMenu, IExplorer
	IniWrite %Favmenu_Options_ITC%,			%Favmenu_configFile%, TcFavMenu, ITC
	IniWrite %Favmenu_Options_ISystem%,		%Favmenu_configFile%, TcFavMenu, ISystem
}

;-----------------------------------------------------------------------------------
; Check if required config enteries are there.
;
FavMenu_CheckConfigData()
{
	global
	local reset

	
	if (! FileExist(FavMenu_fmExe) ) 
	{
		MsgBox Total Commander not found.`nClick OK for Setup.
		reset := true
	}

	if ( !reset && !FileExist(FavMenu_fmIni)  ) 
	{
		MsgBox INI not found.`nClick OK for Setup.
		reset := true
	}
	
	if (reset)
	{
		Setup_Create()
	}
}