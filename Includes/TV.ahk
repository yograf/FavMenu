;Interface:	
;	TV_Initialise( hParent, hTV )		- First call this so other functions are able to work
;	TV_SetPath( path )					- Set the location of selected item in the TreeView hierarchy
;	TV_GetPath()						- Get the location of selected item in the TreeView hierarchy
;	TV_Select( item )					- Select the item
;	TV_Expand( item )					- Expand the item
;	TV_GetTxt( item )					- Get the item text
;	TV_FindChild( parent, text, mode )	- Find the child of the parent containing (1) or beinq equal (0) to the given text
;	TV_FindDrive( drive )				- Find the "drive" item of My Computer


TV_Initialise( hwParent, hwTV )
{
	global 

	TV_hwHost		:= hwParent
	TV_hwTV			:= hwTV 

	;API MESSAGES
	if !TV_Initialised
	{
		TVE_EXPAND		= 2

		TVM_EXPAND		= 0x1102
		TVM_GETITEM		= 0x110C
		TVM_GETNEXTITEM = 0x110A
		TVM_SELECTITEM  = 4363

		TVGN_ROOT		= 0
		TVGN_NEXT		= 1
		TVGN_CHILD		= 4
		TVGN_PARENT		= 3
		TVGN_CARET		= 9

		TVIF_STATE		= 8
		TVIS_SELECTED	= 2

		TV_Initialised := true
	}
}

;----------------------------------------------------------------------------------------- 
; Set the location of selected item in the TreeView hierarchy
;
;	Returns: true on success false on failure
;
TV_SetPath( path )
{
	global TV_hwTV

	StringLeft drive, path, 2
	
	parent := TV_FindDrive( drive )
	TV_Expand( parent )

	loop, Parse, path, \
	{
		;skip drive, I already set this
		if (A_Index = 1)
			 continue 

		
		child := TV_FindChild(parent, A_LoopField)

		if (child = 0)
			return 0

		parent := child		

		;it appers that when expanding drive it needs more time
		if (A_Index = 2)
			TV_Expand( parent, 200)
		else
			TV_Expand( parent )

	}

	return TV_Select(parent)
}


TV_Select( item )
{
	global
	SendMessage TVM_SELECTITEM, TVGN_CARET, item, ,ahk_id %TV_hwTV% 
	return %ErrorLevel%
}

;----------------------------------------------------------------------------------------- 

TV_Expand( item, waitTime=50 )
{
	global
	SendMessage TVM_EXPAND, TVE_EXPAND, item, ,ahk_id %TV_hwTV% 
	Sleep %waitTime%	;allow it to expand
	return %ErrorLevel%
}

;----------------------------------------------------------------------------------------- 

TV_FindDrive( drive )
{
	global TV_hwTV, TVGN_ROOT, TVM_GETNEXTITEM

	myComputer := TV_GetResString("{20D04FE0-3AEA-1069-A2D8-08002B30309D}")

	;get root 
	SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %TV_hwTV% 
	root = %ErrorLevel% 
	
	hwMC := TV_FindChild( root, myComputer ) 
	TV_Expand( hwMC )

	return TV_FindChild( hwMC, drive, 1 )
}

;----------------------------------------------------------------------------------------- 
; Find child by its text. Start searching from the given item
;
;	Returns: Item handle if search text is found or zero otherwise
;
TV_FindChild( p_start, p_txt, p_mode=0 )
{
	global TV_hwHost, TV_hwTV, TVM_GETITEM, TVM_GETNEXTITEM, TVGN_CHILD, TVGN_NEXT

	;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 128) 
	bufAdr  := RemoteBuf_GetAdr(bufID) 

	;Copy items name to the host adr space
	; so I can compare strings there, without transfering them here 
	r_txt	 := RemoteBuf_Open(TV_hwHost, 128)
	r_txtAdr := RemoteBuf_GetAdr( text )
	RemoteBuf_Write( r_txt, txt, strlen(txt) )

	r_sTV    := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr := RemoteBuf_GetAdr(r_sTV) 

	VarSetCapacity(sTV,   40, 1)    ;10x4 = 40 
	InsertInteger(0x011,  sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	InsertInteger(bufAdr, sTV, 16)  ;set txt pointer 
	InsertInteger(127,    sTV, 20)  ;set txt size 


	;get first child
	SendMessage TVM_GETNEXTITEM, TVGN_CHILD, p_start, ,ahk_id %TV_hwTV% 
	child = %ErrorLevel% 
	loop
	{
		;set TVITEM item handle 
		InsertInteger(child, sTV, 4)    
	    RemoteBuf_Write(r_sTV, sTV, 40)		

		;get the text
		SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 
		VarSetCapacity(txt, 128, 1)
	    RemoteBuf_Read(bufID, txt, 64 ) 

		if (p_mode=0)
			if (txt = p_txt)
				break
		
		if (p_mode=1)
			 if InStr(txt, p_txt)
				break


		;get next sybiling
		SendMessage TVM_GETNEXTITEM, TVGN_NEXT, child, ,ahk_id %TV_hwTV% 
		child = %ErrorLevel% 
		if (child=0)
			break
	}

	RemoteBuf_Close( r_sTV )
	RemoteBuf_Close( r_txt )
	RemoteBuf_Close( bufID )

	return %child%
}


;----------------------------------------------------------------------------------------- 
; Get the text of the item with given handle
;
TV_GetTxt( itemHandle )
{
	global TV_hwHost, TV_hwTV, TVM_GETITEM

	;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 128) 
	bufAdr  := RemoteBuf_GetAdr(bufID) 

	r_sTV	 := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr := RemoteBuf_GetAdr(r_sTV) 

	VarSetCapacity(sTV,   40, 1)    ;10x4 = 40 
	InsertInteger(0x011,  sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	InsertInteger(bufAdr, sTV, 16)  ;set txt pointer 
	InsertInteger(127,    sTV, 20)  ;set txt size 

	;set TVITEM item handle 
    InsertInteger(itemHandle, sTV, 4)    
    RemoteBuf_Write(r_sTV, sTV, 40)

	;get the text
    SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 

	;read from remote buffer
	VarSetCapacity(txt, 128, 1)
    RemoteBuf_Read(bufID, txt, 64 ) 

	RemoteBuf_Close( bufID )
	RemoteBuf_Close( r_sTV )

	return txt
}

;----------------------------------------------------------------------------------------- 
; Get the location of selected item in the TreeView hierarchy
;
;	Returns: item1\item2...\...\selected_item
;
TV_GetPath() 
{ 
   global TV_hwHost, TV_hwTV, TVM_GETITEM, TVM_GETNEXTITEM, TVGN_PARENT, TVGN_NEXT, TVGN_ROOT, TVGN_CARET

   ;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 64) 
	bufAdr   := RemoteBuf_GetAdr(bufID) 

	r_sTV   := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr   := RemoteBuf_GetAdr(r_sTV) 

	;get root 
	SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %TV_hwTV% 
	root = %ErrorLevel% 
    
	;get current selection 
	SendMessage TVM_GETNEXTITEM, TVGN_CARET, 0, ,ahk_id %TV_hwTV% 
	item = %ErrorLevel% 

	VarSetCapacity(sTV,   40, 1)     ;10x4 = 40 
	InsertInteger(0x011,   sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	InsertInteger(bufAdr,  sTV, 16)  ;set txt pointer 
	InsertInteger(127,     sTV, 20)  ;set txt size 
    
	VarSetCapacity(txt, 64, 1) 

	loop 
	{ 
      ;set TVITEM item handle 
      InsertInteger(item, sTV, 4)    
      RemoteBuf_Write(r_sTV, sTV, 40) 

      ;send tv_getitem message 
      SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 

      ;read from remote buffer and append the path 
      RemoteBuf_Read(bufID, txt, 64 ) 

      ;check for the drive 
      StringGetPos i, txt, : 
      if i > 0 
      { 
         StringMid txt, txt, i, 2 
         epath = %txt%\%epath% 
         break 
      } 
      else 
         epath = %txt%\%epath% 

      ;get parent
      SendMessage TVM_GETNEXTITEM, TVGN_PARENT, item, ,ahk_id %TV_hwTV% 
      item = %ErrorLevel% 
      if (item = root) 
         break 
   } 

	RemoteBuf_Close( bufID ) 
	RemoteBuf_Close( r_sTV ) 

	StringLeft epath, epath, strlen(epath)-1 
	return epath 
} 

;----------------------------------------------------------------------------------------- 

TV_GetResString( p_clsid )
{
	key = SOFTWARE\Classes\CLSID\%p_clsid%
	RegRead res, HKEY_LOCAL_MACHINE, %key%, LocalizedString
	
;get dll and resource id 
	StringGetPos idx, res, -, R
    StringMid, resID, res, idx+2, 256
	StringMid, resDll, res, 2, idx - 2
	resDll := TV_ExpandEnvVars(resDll)
	
;get string from resource
	VarSetCapacity(buf, 256)
	hDll := DllCall("LoadLibrary", "str", resDll)
	Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)

	return buf
}

;----------------------------------------------------------------------------------------- 

TV_ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

;----------------------------------------------------------------------------------------- 