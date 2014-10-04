;**************************************************************************
;	Menu Editor
;	
;
;	Created by Midrag Milic !								Jun 2006
;	
;	code.r-moth.com			www.r-moth.com		r-moth.deviantart.com
;**************************************************************************

#NoTrayIcon
#SingleInstance force
	;prefixes: Editor, Tree
	EDITOR_Init()

	; create GUI
	Editor_Run()
return

;======================================================================================

EDITOR_Init( lastGUI=0, subMenu="", bStandalone=true )
{
	global


	Application_AddMessageHandler( 0x0112,	"Editor_MessageHandlerDispatch")	
	Application_AddMessageHandler( 0x0100,	"Editor_MessageHandlerDispatch") ;wm_keydown
	Application_AddMessageHandler( 0x0101,	"Editor_MessageHandlerDispatch") ;wm_keyup

	Editor_GUI := lastGui + 1
	Editor_standalone := bStandalone

	Editor_configFile := "Config.ini"
	Editor_title	  := "Menu Editor"
	Editor_version    := "2.0"


	; get the config
	if !Editor_GetConfigData()
		Editor_SetIniPath()		

	return lastGui + 1
}

;----------------------------------------------------------------------------------------------
Editor_Run()
{
	global
	
	Gui, %editor_GUI%:Default 


	if Editor_Options_HideTabs
		  Gui, %editor_GUI%:Add, Tab, X0 Y-30 h800 w800 gEditor_OnTabChangeDispatch vEditor_Tab,						Editor|Settings
	else  Gui, %editor_GUI%:Add, Tab, X0 Y0 h800 w800	Buttons 0x400 gEditor_OnTabChangeDispatch vEditor_Tab,		Editor|Settings
		

	; ---------------- tab 1
	Gui, %editor_GUI%:Font, s10, Verdana

	
	if Editor_Options_HideTabs
		 Gui, %editor_GUI%:Add,  Treeview,  X0 Y0  H490 W360 gTree_OnEvent AltSubmit -Lines -ReadOnly
	else Gui, %editor_GUI%:Add,  Treeview,  X0 Y20 H470 W360 gTree_OnEvent AltSubmit -Lines -ReadOnly

	Gui, %editor_GUI%:Font, s8, Verdana

	Gui, %editor_GUI%:Add,  Text,	 x16  y502 w170 h16,																Command 
	Gui, %editor_GUI%:Add,  Edit,	 x16  y520 w320 h20	vEditor_eCommand 
	
	Gui, %editor_GUI%:Add,  Text,	 x16  y552 w50  h20,																Icon
	Gui, %editor_GUI%:Add,  Edit,	 x16  y570 w320 h20	vEditor_eIcon ,  

	Gui, %editor_GUI%:Add,  Button,  x130 y611 w100 h22	gEditor_OnSaveDispatch 0x8000,									&Save 

	Gui, %editor_GUI%:Font, bold s9, Arial
	Gui, %editor_GUI%:Add, Text,	 x340 y522 w20  h20	0x10000 gEditor_OnBrowseClickDispatch vEditor_bCmd ,			>>
	Gui, %editor_GUI%:Add, Text,	 x340 y572 w20  h20	0x10000 gEditor_OnBrowseClickDispatch ,							>>
	Gui, %editor_GUI%:Font, norm

	; ----------------- tab 2
	Gui, %editor_GUI%:Tab, 2
 	Gui, %editor_GUI%:Font, s14, Verdana
	Gui, %editor_GUI%:Add, Text,	 x0 y30 w350 h30 Center , Options 
 	Gui, %editor_GUI%:Font, s9, Arial
	Gui, %editor_GUI%:Add, Checkbox, x36 y70  w300 h20	gEditor_OnOptionSetDispatch vEditor_Options_Backup,				Create backup before saving 
	Gui, %editor_GUI%:Add, Checkbox, x36 y110 w300 h20	gEditor_OnOptionSetDispatch vEditor_Options_CollapseOnMove,		Collapse submenus while moving
	Gui, %editor_GUI%:Add, Checkbox, x36 y130 w300 h20	gEditor_OnOptionSetDispatch vEditor_Options_ExpandOnStartup,	Expand all submenus on startup
	Gui, %editor_GUI%:Add, Checkbox, x36 y150 w300 h20	gEditor_OnOptionSetDispatch vEditor_Options_EditOnInsert,		Edit title on insert
	Gui, %editor_GUI%:Add, Checkbox, x36 y200 w300 h40	gEditor_OnOptionSetDispatch vEditor_Options_HideTabs,			Hide Tabs (requires restart)`nUse CTRL TAB to select hidden tabs
	Gui, %editor_GUI%:Add, Checkbox, x36 y240 w300 h20	gEditor_OnOptionSetDispatch vEditor_Options_EscExit,			Exit on ESC


	Gui, %editor_GUI%:Font, s14, Verdana
	Gui, %editor_GUI%:Add, Text,	 x0 y350 w350 h30	Center,															Shortcuts
 	Gui, %editor_GUI%:Font, s8, courier
	Gui, %editor_GUI%:Add, Edit,	 x0 y380 h300 w360	0x800 -0x10000 -0x200000 -E0x200 vEditor_NotesMemo 

	Gui	 %Editor_GUI%:+LastFound
	Editor_hwnd := WinExist() + 0


	Editor_root := Editor_CreateTree("FavMenu", 0)
	Gui,%editor_GUI%:Show, h644 w362, %Editor_title%                         v%Editor_version%
}

;----------------------------------------------------------------------------------------------

Editor_OnTabChange()
{
	global
	local msg


	if (Editor_tab != "Settings") 
	{
		GuiControl, ,Editor_Options_Backup,			 %Editor_Options_Backup%
		GuiControl, ,Editor_Options_CollapseOnMove,	 %Editor_Options_CollapseOnMove%
		GuiControl, ,Editor_Options_ExpandOnStartup, %Editor_Options_ExpandOnStartup%
		GuiControl, ,Editor_Options_EditOnInsert,	 %Editor_Options_EditOnInsert%
		GuiControl, ,Editor_Options_HideTabs,		 %Editor_Options_HideTabs%
		GuiControl, ,Editor_Options_EscExit,		 %Editor_Options_EscExit%

		msg := msg . "`n  (SHIFT)INSERT   - add (sub)menu item.`n" 
		msg := msg . "  DELETE          - delete (sub)menu`n"
		msg := msg . "  F2              - edit title`n"
		msg := msg . "  SHIFT Up/Down   - move (sub)menu item`n"
		msg := msg . "  ENTER           - move through edit fields`n"
		msg := msg . "  CTRL TAB        - next tab`n"
		msg := msg . "`n`n`n`n"
		msg := msg . "         Created by Miodrag Milic`n"
		msg := msg . "          miodrag.milic@gmail.com`n`n`n"
		msg := msg . "              code.r-moth.com`n"
		msg := msg . "               www.r-moth.com`n"
		msg := msg . "           r-moth.deviantart.com"

		GuiControl, , Editor_NotesMemo, %msg%
	}
}

Editor_OnTabChangeDispatch:
 Editor_OnTabChange()
return

;----------------------------------------------------------------------------------------------

Editor_OnOptionSet()
{
	global Editor_configFile, editor_GUI

	Gui, %editor_GUI%:Submit, NoHide

	StringMid, key, A_GuiControl, 16, 50
	value := %A_GuiControl%
	IniWrite %value%, %Editor_configFile%, EDITOR, %key%
}

Editor_OnOptionSetDispatch:
	Editor_OnOptionSet()
return

;----------------------------------------------------------------------------------------------

Editor_OnBrowseClick()
{
	global
	local tmp, c, txt

	if (A_GuiControl = "Editor_bCmd") 
	{
		ControlGetText tmp, Edit1
		StringLeft tmp, tmp, 2
		if (tmp = "cd")
		{
			FileSelectFolder, tmp
			tmp = cd %tmp%
		}
		else
			FileSelectFile, tmp, 3
	}
	else
			FileSelectFile, tmp, 3

	if Errorlevel = 1
		return

	c := TV_GetSelection()

	; don't edit root
	if (c = Editor_root)
			return

	; don't edit separators
	TV_GetText(txt, c)
	if txt = -
		return
	

	if (A_GuiControl = "Editor_bCmd") 
	{
		GuiControl, Text, Editor_eCommand, %tmp%
		Editor_aCommand%c% := tmp
	}
	else {
		GuiControl, Text, Editor_eIcon, %tmp%
		Editor_aIcon%c%	:= tmp
	}

	TV_Modify(c, "Bold")
}

Editor_OnBrowseClickDispatch:
	Editor_OnBrowseClick()
return

;----------------------------------------------------------------------------------------------

Editor_GetConfigData()
{
	global
	
	IniRead Editor_tcIni, %Editor_configFile%, TcFavMenu, tcIni, &
	Editor_tcIni := Editor_ExpandEnvVars(Editor_tcIni)
	
	if !FileExist(Editor_tcIni)
	{
		EnvGet Editor_tcIni, COMMANDER_PATH
		if (Editor_tcIni = "")
			return false
				
		Editor_tcIni = %Editor_tcIni%\wincmd.ini
		IniWrite %Editor_tcIni%, %Editor_configFile%, TCFavMenu, tcIni
	}

	IniRead Editor_Options_ExpandOnStartup, %Editor_configFile%, Editor, ExpandOnStartup,	0
	IniRead Editor_Options_Backup,			%Editor_configFile%, Editor, Backup,			1
	IniRead Editor_Options_CollapseOnMove,	%Editor_configFile%, Editor, CollapseOnMove,	0
	IniRead Editor_Options_EditOnInsert,	%Editor_configFile%, Editor, EditOnInsert,		1
	IniRead Editor_Options_HideTabs,		%Editor_configFile%, Editor, HideTabs,			0
	IniRead Editor_Options_EscExit,			%Editor_configFile%, Editor, EscExit,			0

	return true
}

;----------------------------------------------------------------------------------------------

Editor_SetIniPath()
{
	global

	MsgBox 16, %Editor_title%, Configuration is invalid. Click OK to select wincmd.ini
	FileSelectFile, Editor_tcIni, 3, , Select wincmd.ini, wincmd.ini
	if Errorlevel = 1
		ExitApp
	
	IniWrite %Editor_tcIni%, %Editor_configFile%, TCFavMenu, tcIni
}

;----------------------------------------------------------------------------------------------

Editor_OnSave(iType, item)
{
	global Editor_tcIni
	static i

	if iType in I,M
	{
		i += 1
		if iType = M
			pref = -
		else
			pref =

		; get the data from the item
		TV_GetText(mnu, item)
		cmd := Editor_aCommand%item%
		ico := Editor_aIcon%item%

		if Editor_IsQuoted(cmd)
			q = "

		; write data to the ini
		IniWrite %pref%%mnu%, %Editor_tcIni%, DirMenu, menu%i%
		if (cmd != "")
			IniWrite %q%%cmd%%q%, %Editor_tcIni%, DirMenu, cmd%i%
		if (ico != "")
		IniWrite %ico%, %Editor_tcIni%, DirMenu, icon%i%

		TV_Modify(item, "-Bold")
	}


	if iType = E
	{
		i += 1
		; just close the menu at the end
		IniWrite --, %Editor_tcIni%, DirMenu, menu%i%
	}

	if iType = !
		i = 0		
}

;------------

Editor_OnSaveLabel:
	Editor_OnSave(Editor_itemType, Editor_param)
return

;------------

Editor_OnSaveDispatch:
	
	if TV_GetCount() = 1
	{
		MsgBox 0, %Editor_Title%, You can not save an empty menu`nUse INSERT key to add menu item.
		return
	}
		
	GuiControl disable, Button1

	;if backup flag set, save the ini first
	if Editor_Options_Backup
		FileCopy %Editor_tcIni%, %Editor_tcIni%.bak, 1

	IniDelete %Editor_tcIni%, DirMenu
	Tree_MenuWalk(Editor_root, "Editor_OnSaveLabel", Editor_itemType, Editor_param)
	
	GuiControl enable, Button1
return

;----------------------------------------------------------------------------------------
; Walk the menu and rise events
; 
; root  - menu to iterate, can be simple item also
; label - event handler
; item_type - event handler argument 1	(type of call)
; param		- event handler argument 2  (item upon witch event is rised)
;
; EVENTS:
;	+  - Iteration start,			Param = root handle
;	M  - Menu is reached,			Param = menu handle 
;	I  - Iteam is raached,			Parem = item handle
;	E  - End of menu is reached		Parem = menu handle
;	!  - End of iteration			
;	
;	S  - root is not the menu 
;		   but the simple item		Param = item handle (i.e. root handle)
;
Tree_MenuWalk(root, label, ByRef item_type, ByRef param )
{
	global
	local n, t, p, c,		mnu, cmd, ico,		pref, bSetEnd, lastParent, rootsParent

	;if root is not the menu, just return with the item
	;Make this as special event "S" so to avoid "!" and "E" events for single items
	; and to return from the function as soon as possible
	if !TV_GetChild(root)
	{
		item_type := "S"
		param := root
		GoSub %label%
		return
	}

	; this will be exit condition. If we come to roots parent, stop walking.
	rootsParent := TV_GetParent(root)
	
	; start event for menus
	item_type := "+"
	param := root
	GoSub %label%

	lastParent := root
	c := root
	loop
	{
		c := TV_GetNext(c, "Full")
		TV_GetText(tmp, c)

		; Check if this item is submenu. If so, set the lastParent
		if ( TV_GetChild(c) )
		{	
			lastParent := c
			item_type := "M"

		}
		; not a submenu, it is normal item
		else 
			item_type := "I"

		param := c
		GoSub %label%		
	

		; Check if c is the last item in the current submenu
		; Do so by taking the next item and checking its parent.
		; If the parent is different then "lastParent" current item is 
		;  at the end of the its submenu. 
		n := TV_GetNext(c, "FULL")
		if (n)
		{
			p := TV_GetParent(n)
			if ( p != lastParent) 
			{	
				t := lastParent
				lastParent := p
			}
			else
				continue

			; It is the last child
			Loop
			{
				; rise "E" (end of menu) event 
				item_type := "E"
				param := t
				GoSub %label%

				t := TV_GetParent(t)
				if (t = rootsParent)
				{
					; rise "!" (end of walk) event
					item_type := "!"
					GoSub %label%
					return
				}
				if (p = t)
					break
			}
		}
		else

		Loop
		{
			 i += 1
			 ;this is the end of complite menu, so close all open submenus, if any
			 if (lastParent = root)
			 {
					item_type := "!"
					GoSub %label%
					return
			 }
			
 			 item_type := "E"
			 GoSub %label%
			 lastParent := TV_GetParent(lastParent)
		}	
	}
}

;---------------------------------------------------------------------------------------------
; Function that copies menu to the destination at Editor_copyDest global variable
; Tree_WalkMenu event handler 
;
Tree_CopyProc(iType, item)
{
	local c
	static lastParent

	if iType in +,S
	{
		lastParent := Editor_copyDest

		TV_GetText(txt, item)
		TV_Modify(Editor_copyDest, "", txt)

		Editor_aCommand%Editor_copyDest%	:= Editor_aCommand%item%
		Editor_aIcon%Editor_copyDest%		:= Editor_aIcon%item%

		Editor_aCommand%item% =
		Editor_aIcon%item%    =
	}

	if iType in I,M
	{
		TV_GetText(mnu, item)
	
		c := TV_Add(mnu, lastParent)
		Editor_aCommand%c%	:= Editor_aCommand%item%
		Editor_aIcon%c%		:= Editor_aIcon%item%

		;free memory
		Editor_aCommand%item% =
		Editor_aIcon%item%    =
				
		if iType = M
			lastParent := c
	}

	if iType = E
		lastParent := TV_GetParent(lastParent)	
}

;----------------------------------------------

Tree_CopyProcLabel:
	Tree_CopyProc(Editor_itemType, Editor_param)
return

;-----------------------------------------------------------------------------------------------
; create new item after the child "destc" with parent "destp" and copy the "source" menu into it
Tree_CopyItem(destc, destp, source)
{
	global 

	;create the holder and call the copy function
	Editor_copyDest := TV_Add("", destp , destc )
	Tree_MenuWalk(source, "Tree_CopyProcLabel", Editor_itemType, Editor_param)

	return Editor_copyDest
}

;----------------------------------------------------------------------------------------------

Tree_OnItemSelect(item_id)
{
	global

	
	if Editor_bSelfSelect
	{	
		Editor_bSelfSelect := false
		return
	}	

	Editor_prevSel := Editor_sel
	Editor_sel := item_id


	if GetKeyState("Shift") && (Editor_lastKey=38 || Editor_lastKey=40)
	 if (item_id != Editor_root)
	 {
	  	Editor_sel := Tree_ItemMove( Editor_prevSel, Editor_lastKey )
		Editor_prevSel := item_id
		
		Editor_bSelfSelect := true
		TV_Modify(Editor_sel, "Select Bold")
		return
	 }

	GuiControl, Text, Editor_eCommand, % Editor_aCommand%item_id%
	GuiControl, Text, Editor_eIcon, % Editor_aIcon%item_id%
}

;----------------------------------------------------------------------------------------------
; Move tree item up or down depending on flag 
; Up = 38, Down = 40
; 
; Do so by coping an item to the new positon and deleting old one
; Return handle of new item
;
Tree_ItemMove(item, flag)
{
	global
	local newc, newp, t, p, n

	if (item = Editor_root)
		return
	
	p := TV_GetPrev(item)
	n := TV_GetNext(item)

	; if moving down
	if (flag = 40)
	{
		; handle end of submenu
		if !n
		{
			newc := TV_GetParent(item)
			
			; check the end of the list
			if (newc = Editor_root)
				return

			if Editor_Options_CollapseOnMove
				TV_Modify(newc, "-Expand")

			newp := TV_GetParent(newc)
		}
		; somewhere in the middle 
		else 
		{
   			; if submenu, go into it
			t := TV_Get(n, "E")
			if (t = n)
			{
				newp := n
				newc := "First"
			}
			; not a submenu
			else
			{
				newc := n
				newp := TV_GetParent(n)
			}    
		}
	}

	; if moving up
	if (flag = 38)
	{
		;going up - handle start of the submenu
		if !p
		{
			t := TV_GetParent(item)
			if Editor_Options_CollapseOnMove
				TV_Modify(t, "-Expand")
																					  
			newc := TV_GetPrev(t)
																											  
			; handle start of the menu again
			if !newc
			{
				newp := TV_GetParent(t)
				newc := "First"
			}
			else
				newp := TV_GetParent(newc)
		}
		; somewhere in the middle
		else
		{
   			; if submenu is expanded, go into it
			t := TV_Get(p, "E")
			if (t = p)
			{
				newc := "First"
				newp := t
			}
			else
			{
				t := TV_GetPrev(p)
				;check the top of the list
				if !t
				{
					newc := "First"
					newp := TV_GetParent(p)				
				}
				else 
				{
					newc := t
					newp := TV_GetParent(newc)
				}
			}
		}
	}

	; newc - calculated child after witch "item" should be created. 
	; newp -  ... and its parent
	; item - item to be created
	newc := Tree_CopyItem(newc, newp, item)
	TV_Delete(item)
	return newc
}

;----------------------------------------------------------------------------------------------

Tree_OnKeyPress(v_key)
{
	global 
	local tp, sel

	Editor_lastKey := v_key
	
	;delete
	if v_key = 46
	{
		; use GetSelection instead Editor_sel since if key is pressed and hold
		;  Tree_OnSelect handler may not be called before delete to set the Editor_sel

		sel := TV_GetSelection()
		if (sel = Editor_root)
			return

		; is shift delete is pressed return - some problems with this combination
		if (GetKeyState("Shift"))
			return

		TV_Delete(sel)
		return
	}

	;insert
	if v_key = 45
	{
		
		tp := TV_GetParent(Editor_sel)
		if (Editor_sel = Editor_root)
			tp := Editor_root

		tp := TV_Add("__ new item __", tp, "Bold " . Editor_sel)
		if GetKeyState("Shift")
		{
			TV_Add("__ new item __", tp, "Bold First ")
			TV_Modify(tp,"Expand", "__ new subgroup __")
		}

		if (Editor_Options_EditOnInsert)
		{
			TV_Modify(tp, "Select")
			Send, {F2}
		}

		return
	}
}

;-----------------------------------------`-----------------------------------------------------

Tree_OnEvent:

	if (A_GuiEvent="S")
		Tree_OnItemSelect(A_EventInfo)

	if (A_GuiEvent="K")
		Tree_OnKeyPress(A_EventInfo)
return

;----------------------------------------------------------------------------------------------

Editor_CreateTree(title, level)
{	
	global
	local p_no, child, mnu, cmd, name, ico, parent
		
	p_no := level+1

    parent%p_no% := TV_ADD(title, parent%level%)
	parent := parent%p_no%
	Loop 
	{	

		;read next menu item 
		Editor_mnuCnt += 1
		IniRead, mnu, %Editor_tcIni%, DirMenu, menu%Editor_mnuCnt%, & 
		IniRead, cmd, %Editor_tcIni%, DirMenu, cmd%Editor_mnuCnt%, &
		IniRead, ico, %Editor_tcIni%, DirMenu, icon%Editor_mnuCnt%, &

		if (mnu = "&")
			break

		;is it separator ?
		if (mnu = "-")
     		goto Editor_childJump
		

		; "--" exit condition (end of submenu), return this item to the caller
		if (mnu = "--")
			return parent

		; if "-....." submenu, create it (recursion step)
		StringMid, c1, mnu, 1, 1 
		if (c1 = "-")
		{
			StringMid, name, mnu, 2, 100 
			child := Editor_CreateTree(name, level+1)
			if (ico != "&")
				Editor_aIcon%child%	:= ico
	
			else TV_Modify(child, "Icon100")
			
			if (Editor_Options_ExpandOnStartup)
				TV_Modify(child, "Expand")	
				
			tmp = %name% ;;; [%child%]
			TV_Modify(child, "", tmp)
			continue
		}


Editor_childJump:


		child := TV_Add(mnu, parent)

		tmp = %mnu% ;;; [%child%]
		TV_Modify(child, "", tmp)
	    
		if (cmd != "&")
			Editor_aCommand%child%	:= cmd

		if (ico != "&")
			Editor_aIcon%child%	:= ico


	}

	;expand root
	TV_Modify(parent, "Expand", title )

	return parent
}

;-----------------------------------------------------------------------------------

Editor_IsQuoted(str)
{
	StringLeft  sl, str, 1
	StringRight sr, str, 1
	if (sr = """") && (sl = sr)
		return true
	else 
		return false
}

;-----------------------------------------------------------------------------------

Editor_OnKeyUp(wparam, lparam)
{
	global 
	local c, txt, focused

	ControlGetFocus focused, A
	;If the user is editing title ENTER will be catched OnKeyUp event and NOT on KeyDown for some reason. 
	;After pressing ENTER TreeView will have focus. This will not happen if ENTER is pressed on TreeView 
	; since this will be catched in OnKeyDown and focus will be redirected to Edit1
	if (wparam=13 && focused = "SysTreeView321")
	{
		;If Edit2 is selecting TV don't do anything
		if (Editor_Edit2Send)
		{
			Editor_Edit2Send := false
			return
		}

		; check for - at the first char of the title
		TV_GetText( txt, TV_GetSelection() )
		if (Editor_prevText = txt)
			return

		StringLeft c, txt, 1
		if strLen(txt) > 1
			if c = -
				 c := " " . txt 
			else c := txt

		TV_Modify(TV_GetSelection(), "Bold", c)
		return
	}


	;get focused control
	if focused not contains Edit1,Edit2
		return

	;skip nonprintable chars
	if (wparam < 46) and (wparam !=8) and (wparam != 32)
		return
	;skip winkeys, function keys etc..
	if ((wparam>=112) and (wparam <= 123)) or (wparam = 92) or (wparam = 93)
		return

	;don't skip OEM keys (du no why... though.. TC don't support it)
	if (wparam>123) and NOT (wparam >=186 and wparam<= 222)
		return

	c := TV_GetSelection()

	; don't edit root
	if (c = Editor_root)
			return

	; don't edit separators
	TV_GetText(txt, c)
	if txt = -
		return

	ControlGetText txt, %focused%
	if focused = Edit1
	{
		Editor_aCommand%c% := txt
		TV_Modify(c, "Bold")
	}
			
	if focused = Edit2
	{
		Editor_aIcon%c%	:= txt
		TV_Modify(c, "Bold")
	}
}

;-----------------------------------------------------------------------------------

Editor_OnKeyDown(wparam, lparam)
{
	global
	local c, txt, focused


	; handle ESCAPE
	if (wparam = 27) && Editor_Options_EscExit
		Editor_Close()

	;get focused control
	ControlGetFocus focused, A

	;check ENTER 
	if wparam = 13
	{
		if focused = SysTreeView321
		{
			ControlFocus Edit1
			Send {END}
			return
		}	

		if focused = Edit1
		{
			ControlFocus Edit2
			Send {END}
			return
		}

		if focused = Edit2
		{
			Editor_Edit2Send := true
			ControlFocus SysTreeView321
			return
		}
	}
}

;-----------------------------------------------------------------------------------

Editor_Exit()
{
	global 
	local tmp

	; If user never open options page, controls will not be set so 
	;  submit will erase EscExit option. I need to save it before calling Submit
	tmp := Editor_Options_EscExit
	Gui %Editor_GUI%:Submit, NoHide
	Editor_Options_EscExit := tmp

	ControlGet b, Enabled,, Button1
	
	if (Editor_tab != "Editor")
		ExitApp
	
	if (!b)
		Tooltip Save is in progress.`n`nPlease wait until Save button is enabled again.
	else
		ExitApp

	;prevent closing

	return 1
}

;-----------------------------------------------------------------------------------

Editor_MessageHandler(wparam, lparam, msg, hwnd)
{
	global Editor_hwnd

	h := DllCall("GetParent", "uint", hwnd)

	if h = 0
		h := hwnd + 0
	
	if (h != Editor_hwnd)
		return
	
	if (msg = 0x100)
		return Editor_OnKeyDown(wparam, lparam)

	if (msg = 0x101)
		return Editor_OnKeyUp(wparam, lparam)
	
    ;WM_SYSCOMMAND & SC_CLOSE
	if (msg = 0x112 and wparam = 0xF060)
		return Editor_Close()
}

Editor_MessageHandlerDispatch:
	Editor_MessageHandler(Application_mWparam, Application_mLparam, Application_mMsg, Application_mHwnd)	
return

;-----------------------------------------------------------------------------------

Editor_Close()
{
	global 

	if (Editor_Standalone)
		Editor_Exit()
	else
	{
		Editor_mnuCnt := 0
		Gui %Editor_GUI%:Destroy

		;clean up arrays here
	}
}

Editor_ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

;-----------------------------------------------------------------------------------
#include includes\_Application.ahk