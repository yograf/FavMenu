;Old implementation of DialogGetPath witch doesn't use Remote Buffer but
; have problem with some virtual folders, like Desktop.. 
;--------------------------------------------------------------------------
; my recent documents
; desktop
;   my documents
;		<path of any depth>
;   my computer
;     <list of root's - must contain ":" in the name>
;		 <path of any depth>
;   my network places
;		 IGNORE THIS
;   <desktop folders>
;	....				 IGNORE DESKTOP FOLDERS FOR NOW
;	<desktop folders>
;--------------------------------------------------------------------------
FavMenu_DialogGetPath_OS2()
{
	global FavMenu_dlgHWND, CB_GETLBTEXT

	md := Favmenu_GetSFLabel("My Documents")
	mc := Favmenu_GetSFLabel("My Computer")
	np := Favmenu_GetSFLabel("My Network Places")


;take curently displayed item
	ControlGetText name, ComboBox1, ahk_id %FavMenu_dlgHWND%

;return if shell folder itself is selected
	if (name = md)
		return FavMenu_ConvertPseudoPath("%$PERSONAL%")

	if ( name = mc )
		return ":My Computer"
	
	if (name = np)
		return ":Desktop OR My Network Places"

	StringGetPos idx, name, :
	if !ErrorLevel
	{
		StringMid path, name, idx, 2
		return path
	}
	
;get all combo items
	VarSetCapacity(txt, 256)
	loop
	{
		txt =
		SendMessage, CB_GETLBTEXT, A_Index-1, &txt, ComboBox1, ahk_id %FavMenu_dlgHWND%
		aFolders_%A_Index% = %msg%%txt%

		StringGetPos idx, txt, :
		if !Errorlevel
			root := true

		if (txt = "") or (txt = name)
		{
			aFolders_count := A_Index
			break
		}
	}

;I got the names, find the path, by walking up
	path := name
	loop
	{
		aFolders_count -= 1
		if (aFolders_count = 0)
			return ":"

		folder := aFolders_%aFolders_count%
		if (folder = np) 
			return ":Desktop OR My Network Places"

		
		if (root)
			StringGetPos idx, folder,:
		else 
			StringGetPos idx, folder, %md%
		

		if (ErrorLevel)
		    path = %folder%\%path%
		else 
		{
			if (root)
			{
				 StringMid drv, folder, idx, 2
				 path = %drv%\%path%	
			}
			else path := FavMenu_ConvertPseudoPath("%$PERSONAL%") . "\" . path
			
			break
		}		
	}
	return path
}

;--------------------------------------------------------------------------------

FavMenu_DialogSetPath_BFF( path )
{
	global
	TV_Initialise( FavMenu_dlgHWND, FavMenu_dlgInput )
	TV_SetPath( path )
}