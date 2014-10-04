#IfWinActive ahk_class TTOTAL_CMD

Lbutton::		Favmenu_OnTCClick()
LButton up::	Click up

#IfWinActive

Favmenu_OnTCClick()
{
	global Favmenu_Options_MenuPos, Favmenu_TCFlag
 
	WinGetActiveTitle, tcTitle
	MouseGetPos X, Y, ,tcCtrl

	if tcTitle not contains 6.5,7.0
 	{
		if tcCtrl not contains TPathPanel1,TPathPanel2
		{
			Click down
			return
		}	
	}
	else
	{
		if tcCtrl not contains TMyPanel5,TMyPanel9
		{
			Click down
			return
		}
	}
	  	
	    

	if !Favmenu_TCFlag
	{
		Favmenu_TCFlag := true
		clkTime := A_TickCount
		Click down
	}
	else 
		if (A_TickCount - clkTime < 300)
		{
			Favmenu_TCFlag := false

			t := Favmenu_Options_MenuPos
			Favmenu_Options_MenuPos := 1
			FavMenu_Create()
			Favmenu_Options_MenuPos := t
		}
		else {
			clkTime := A_TickCount
			Click down
		}
}
