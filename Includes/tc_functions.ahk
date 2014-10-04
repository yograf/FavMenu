;--------------------------------------------------------------------------
; set left and right panel and return source
;
FavMenu_GetTCPanels( ByRef pLeft, ByRef pRight)
{
	WinGetTitle, tcTitle, ahk_class TTOTAL_CMD
 	if tcTitle not contains 6.5 AND tcTitle not contains 7.0
   	{
		ControlGetText pLeft,  TPathPanel1, ahk_class TTOTAL_CMD
		ControlGetText pRight, TPathPanel2, ahk_class TTOTAL_CMD
	}
	else
	{
		ControlGetText pLeft,  TMyPanel5, ahk_class TTOTAL_CMD
		ControlGetText pRight, TMyPanel9, ahk_class TTOTAL_CMD
	}

	StringReplace pLeft, pLeft, *.*
	StringReplace pRight, pRight, *.*
}

;---------------------------------------------------------------------------

FavMenu_GetCurrentTCDir()
{
	WinGetActiveTitle,tcTitle
	Loop,10 {
		ControlGetText path, TMyPanel%A_Index%, ahk_class TTOTAL_CMD
		StringRight, tail, path, 1
		IfEqual, tail, >
		{
			FileAppend, found file path on TMyPanel%A_Index%: %path%`n,*
			src = %path%
			break
		} 
	  }

	StringReplace src, src, >
	return src
}

;---------------------------------------------------------------------------

FavMenu_AddTCPanels( ByRef pLeft, ByRef pRight)
{
	cnt := 0
	b_same := % pLeft = pRight

	; add left panel dir to the menu

	StringGetPos e, pLeft, \, R
	StringGetPos idx, pLeft, \, R, 1
	if (idx != -1) and (idx != 2)
		StringMid pLeft, pLeft, idx+2, e-idx-1, 
	Menu Favmenu_sub1, add,   &1   %pLeft% , FavMenu_FullMenuHandlerDispatch
	cnt += 1
		
	; If they are not the same, add right panel
	if (! b_same)
	{
		StringGetPos e, pRight, \, R
		StringGetPos idx, pRight, \, R, 1
		if (idx != -1) and (idx != 2)
			StringMid pRight, pRight, idx+2, e-idx-1
		Menu Favmenu_sub1, add,   &2   %pRight% , FavMenu_FullMenuHandlerDispatch
		cnt += 1
	}

	; add separator 
	Menu Favmenu_sub1, add

	return cnt + 1
}

;---------------------------------------------------------------------------

FavMenu_SendTCCommand(cmd, wait=1)
{
	if (wait)
		SendMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
	else
		PostMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
}
