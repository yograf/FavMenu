Properties_Create()
{
	global 
	;title

	Gui, %Properties_GUI%:Add, Text,	x16  y5   w80  h16	vProperties_sTitle,										Title 
	Gui, %Properties_GUI%:Add, Edit,	x16	 y22  w200 h18	vProperties_eTitle 

	;nav buttons
	Gui, %Properties_GUI%:Add, Button,	x255 y23  w15  h15	gProperties_OnNavClickDispatch  +0x8000,				  <
	Gui, %Properties_GUI%:Add, Button,	x270 y23  w15  h15	vProperties_btnUp gProperties_OnNavClickDispatch +0x8000, >

	;path
	Gui, %Properties_GUI%:Add, Text,	x16  y55  w80  h16,															&Command
	Gui, %Properties_GUI%:Add, Edit,	x16  y72  w270 h20	vProperties_eCommand,

	;icon
	Gui, %Properties_GUI%:Add, Text,	x16  y102 w80  h16,															Ico&n
	Gui, %Properties_GUI%:Add, Picture, x46  y102 w12  h12	vProperties_picIcon BackgroundTrans AltSubmit 
	Gui, %Properties_GUI%:Add, Edit,	x17	 y119 w248 h20	vProperties_eIcon,
   	Gui, %Properties_GUI%:Add, Button,	x267 y121 w18  h17	gProperties_OnBrowseClickDispatch +0x8000,				..  

	Gui, %Properties_GUI%:Add, Button,	x16  y155 w104 h22	gProperties_OnSaveClickDispatch +0x8000,				&Save
	Gui, %Properties_GUI%:Font, underline s8, Arial
	Gui, %Properties_GUI%:Add, Text,	x228 y158 w104 h19	gProperties_OnOpenMenuClick,							Change item

	
	Gui	 %Properties_GUI%:+LastFound
	Properties_hwnd := WinExist() + 0
		
	;call start event
	DllCall("SendMessage", "uint", Properties_hwnd, "uint", WM_AHKSHOW, "uint", 0, "uint", 0)

	;show the window
	Gui, %Properties_GUI%:Show, x370 y313 h185 w299, Properties

	Properties_visible := true
}

Properties_OnOpenMenuClick:
	Favmenu_Create()
return
;-----------------------------------------------------------------------------------

Properties_OnSaveClick()
{
	global
	local txt, prefix, q, idx

	Gui, %Properties_GUI%:Submit, NoHide
	
	GuiControlGet txt, , Properties_sTitle

	;check if the user specified - as a first char and add ALT 060 if so
	StringLeft idx, Properties_eTitle, 1
	if idx = -
		Properties_eTitle := ">" . Properties_eTitle

	if txt = Submenu Title
		prefix = -

	if FavMenu_IsQuoted(Properties_eCommand)
		q = "

	IniWrite, %prefix%%Properties_eTitle%, %FavMenu_fmIni%, DirMenu, menu%Properties_mnuCnt%
	IniWrite, %q%%Properties_eCommand%%q%, %FavMenu_fmIni%, DirMenu, cmd%Properties_mnuCnt%
	IniWrite, %Properties_eIcon%, %FavMenu_fmIni%, DirMenu, icon%Properties_mnuCnt%

	WinSetTitle *** Properties
}

Properties_OnSaveClickDispatch:
	Properties_OnSaveClick()
return

;-----------------------------------------------------------------------------------

Properties_OnKeyDown(wparam, lparam)
{

	if (wparam = 27)
		Properties_Close()

	if (wparam = 13)
	{
		ControlGetFocus focus
		if focus = Edit1
		{
			ControlFocus Edit2
			Send {END}
		}
		
		if focus = Edit2
		{
			ControlFocus Edit3
			Send {END}
		}
		
		if focus = Edit3
			ControlFocus Button4

		if focus = Button4
		{
			ControlSend Button4, {Space}
			Sleep 20
			ControlFocus Edit1
		}
	}

  
	if wparam in 37,39
	  if GetKeyState("CTRL")
   			Properties_OnNavClick(wparam)
}

;-----------------------------------------------------------------------------------

Properties_OnBrowseClick()
{
	global Properties_picIcon

	FileSelectFile, picIcon, 3, , Select Icon, Icons (*.ico)
	if Errorlevel = 1
		return
	GuiControl, Text, Properties_picIcon, %picIcon%
	GuiControl, Text, Properties_eIcon,   %picIcon%
}

Properties_OnBrowseClickDispatch:
	Properties_OnBrowseClick()
return

;-----------------------------------------------------------------------------------

Properties_Close()
{
	global

	if !Properties_visible
		return

	Properties_visible := false
	Gui, %Properties_GUI%:Destroy
}

;-----------------------------------------------------------------------------------

Properties_Show()
{
	global
	local c


	IniRead, mnu, %FavMenu_fmIni%, DirMenu, menu%Properties_mnuCnt%, & 
	IniRead, cmd, %FavMenu_fmIni%, DirMenu, cmd%Properties_mnuCnt%,%A_space%
	IniRead, ico, %FavMenu_fmIni%, DirMenu, icon%Properties_mnuCnt%,%A_space%


	StringLeft c, mnu, 1
	if c = -
	{
			StringMid mnu, mnu, 2
			GuiControl, ,Properties_sTitle, Submenu Title
	}
	else 	GuiControl, ,Properties_sTitle, Title

	GuiControl, Text, Properties_eTitle,	%mnu%
	GuiControl, Text, Properties_eCommand,	%cmd%
	GuiControl, Text, Properties_eIcon,		%ico%
	GuiControl, Text, Properties_picIcon,	%ico%
}

;-----------------------------------------------------------------------------------

Properties_OnNavClick(key=0)
{
	global FavMenu_fmIni, Properties_mnuCnt

	WinSetTitle Properties

 Properties_lblStart:
	tmp := Properties_mnuCnt

	
	if  (A_GuiControl = "Properties_btnUp") || key = 39
		 tmp += 1
	else tmp -= 1

	IniRead, mnu, %FavMenu_fmIni%, DirMenu, menu%tmp%, &

	if (mnu = "&") 
	
		return

	Properties_mnuCnt := tmp

	if (mnu = "-") or (mnu = "--")
		goto Properties_lblStart


	Properties_Show()
}

Properties_OnNavClickDispatch:
	Properties_OnNavClick()
return