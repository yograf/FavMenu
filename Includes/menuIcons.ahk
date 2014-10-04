/* p_menu            = "MenuName" (e.g., Tray, etc.) 
   p_item            = 1, ... 
   p_bm_unchecked, 
*/ 
FavMenu_AssignBitmap( p_menu, p_item, p_bm_unchecked) 
{ 
   static   h_menuDummy 
    
   if h_menuDummy= 
   { 
      Menu, menuDummy, Add 
      Menu, menuDummy, DeleteAll 
       
      Gui, 99:Menu, menuDummy 
      Gui, 99:Show, Hide, guiDummy 

      old_DetectHiddenWindows := A_DetectHiddenWindows 
      DetectHiddenWindows, on 

      Process, Exist 
      h_menuDummy := DllCall( "GetMenu", "uint", WinExist( "guiDummy ahk_class AutoHotkeyGUI ahk_pid " ErrorLevel ) ) 
      if FavMenu_ReportError( ErrorLevel or h_menuDummy = 0, "FavMenu_AssignBitmap: GetMenu", "h_menuDummy = " h_menuDummy ) 
         return, false 

      DetectHiddenWindows, %old_DetectHiddenWindows% 
       
      Gui, 99:Menu 
      Gui, 99:Destroy 
   } 
    
   Menu, menuDummy, Add, :%p_menu% 
    
   h_menu := DllCall( "GetSubMenu", "uint", h_menuDummy, "int", 0 ) 
   if FavMenu_ReportError( ErrorLevel or h_menu = 0, "FavMenu_AssignBitmap: GetSubMenu", "h_menu = " h_menu ) 
      return, false 

   success := DllCall( "RemoveMenu", "uint", h_menuDummy, "uint", 0, "uint", 0x400 ) 
   if FavMenu_ReportError( ErrorLevel or ! success,  "FavMenu_AssignBitmap: RemoveMenu", "success = " success ) 
      return, false 
   Menu, menuDummy, Delete, :%p_menu% 
    
   if ( p_bm_unchecked ) 
   { 
      hbm_unchecked := DllCall( "LoadImage" 
                           , "uint", 0 
                           , "str", p_bm_unchecked 
                           , "uint", 2                           ; IMAGE_ICON
                           , "int", 0 
                           , "int", 0 
                           , "uint", 0x10 | 0x20 )   ; LR_LOADFROMFILE|LR_LOADTRANSPARENT 
      if FavMenu_ReportError( ErrorLevel or ! hbm_unchecked, "FavMenu_AssignBitmap: LoadImage: unchecked", "hbm_unchecked = " hbm_unchecked ) 
         return, false 


	VarSetCapacity(sICONINFO, 20, 0) 	;4 + 2*4+ 2*4 = 20
	InsertInteger(1, sICONINFO, 0)


	res := DllCall( "GetIconInfo", "Uint", hbm_unchecked, "str", sICONINFO)
	if FavMenu_ReportError( ErrorLevel or ! res, "FavMenu_AssignBitmap: GetIconInfo: ", "res = " res ) 
       return, false 

	hbm_unchecked := ExtractInteger(sICONINFO, 16, true)
	
   } 


   success := DllCall( "SetMenuItemBitmaps" 
                     , "uint", h_menu 
                     , "uint", p_item-1 
                     , "uint", 0x400                              ; MF_BYPOSITION 
                     , "uint", hbm_unchecked 
                     , "uint", 0 ) 
   if FavMenu_ReportError( ErrorLevel or ! success, "FavMenu_AssignBitmap: SetMenuItemBitmaps", "success = " success ) 
      return, false 

   return, true 
} 

FavMenu_ReportError( p_condition, p_title, p_extra ) 
{ 
   if p_condition 
      MsgBox, 
         ( LTrim 
            [Error] %p_title% 
            EL = %ErrorLevel%, LE = %A_LastError% 
             
            %p_extra% 
         ) 
    
   return, p_condition 
} 

ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
{
	Loop %pSize%  ; Build the integer by adding up its bytes.
		result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
	if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
		return result  ; Signed vs. unsigned doesn't matter in these cases.
	; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
	return -(0xFFFFFFFF - result + 1)
}

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
{
	Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
		DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}
