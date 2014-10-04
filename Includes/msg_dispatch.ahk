FavMenu_MessageMonitor(wparam, lparam, msg, hwnd)
{
	global
	local h

	h := DllCall("GetParent", "uint", hwnd)

	if h = 0
		h := hwnd

	if (h = Properties_hwnd)
		 Properties_Monitor(wparam, lparam, msg)
	
	if (h = Setup_hwnd)
	 	 Setup_Monitor(wparam, lparam, msg)
}

FavMenu_MessageMonitorDispatch:
	FavMenu_MessageMonitor(Application_mWparam, Application_mLparam, Application_mMsg, Application_mHwnd)	
return

;--------------------`---------------------------------------------------------------

Properties_Monitor(wparam, lparam, msg)
{
	global

	if (msg = WM_KEYDOWN)
		return Properties_OnKeyDown(wparam, lparam)
	
	if (msg = WM_AHKSHOW)
		return Properties_Show()

	if (msg = WM_SYSCOMMAND and wparam = SC_CLOSE)
		return Properties_Close()
}

;-----------------------------------------------------------------------------------

Setup_Monitor(wparam, lparam, msg)
{

	global

	if (msg = WM_KEYDOWN)
		return Setup_OnKeyDown(wparam, lparam)

	if (msg = WM_AHKSHOW)
		return Setup_Show()

	if (msg = WM_SYSCOMMAND and wparam = SC_CLOSE)
		return Setup_Close()
}

;-----------------------------------------------------------------------------------