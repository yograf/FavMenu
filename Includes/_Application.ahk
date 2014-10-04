Application_AddMessageHandler(msg, label) 
{ 
	global
	
	if !Application_aFlag_%label%
	{
		Application_hCount += 1 
		Application_aMsgHandlers_%Application_hCount% := label
		Application_aFlag_%label% := true
	}

	OnMessage(msg, "Application_MessageMonitor") 
} 

;-----------------------------------------------------------------------

Application_MessageMonitor(wparam, lparam, msg, hwnd) 
{ 
  global 
  local label

  Application_mMsg	  := msg
  Application_mHwnd	  := hwnd
  Application_mWparam := wparam
  Application_mLparam := lparam

  Loop, %Application_hCount%
  { 
	  GoSub % Application_aMsgHandlers_%A_Index%
  } 
} 