;----------------------------------------------------------------------------------
; Favmenu will call this function whenever it needs to send selected path to the FM
; This will only happen if Setup->Integration->System checkbox is ON.
;
; ARGUMENTS:	path, open in new tab/window flag
;
; NOTES:		This function is separated so AutoHotKey users are able to rewrite
;				it for file managers other then Total Commander or Windows Explorer
;				
FavMenu_FM_Open( p_path, p_tab )
{
	global 

	if FavMenu_fmExe contains TotalCmd.exe
		return FavMenu_FM_OpenTc( p_path, p_tab )   
		
	FavMenu_FM_OpenExplorer( p_path )
}

;--------------------------------------------------------------------------

FavMenu_FM_OpenExplorer( p_path )
{
	global
	local a, b, exPID, einput

	a := WinExist("ahk_class ExploreWClass")
	b := WinExist("ahk_class CabinetWClass")
	if a
			c = ExploreWClass
	else	c = CabinetWClass

	if (!a or !b)
		return FavMenu_FM_Run(p_path)
	
;	Windows Explorer exists (this will be executed if Explorer is File Manager
	WinActivate ahk_class %c%
	FavMenu_DialogSetPath_Explorer( p_path )
}

;--------------------------------------------------------------------------

FavMenu_FM_OpenTc(p_path, p_tab)
{	
	global FavMenu_fmExe, cm_editpath

	if not WinExist("ahk_class TTOTAL_CMD")
		 FavMenu_FM_Run()
	FavMenu_DialogSetPath_TC(p_path, p_tab)	
}

;--------------------------------------------------------------------------
; Run the file manager with given arguments (defaults to nothing)
;
FavMenu_FM_Run( arg = "" )
{
	global FavMenu_fmExe

	Run %FavMenu_fmExe% %arg%, , ,PID
	WinWait ahk_pid %PID%, ,1	;this second is added cuz of AHK bug with explorer
}
