FavMenu_cOffice = bosa_sdm_Microsoft Office Word 11.0,bosa_sdm_Mso96,bosa_sdm_XL9

WM_SYSCOMMAND	= 0x112
WM_KEYDOWN		= 0x100
WM_APP			= 0x8000
WM_AHKSHOW		:= WM_APP + 0x100
SC_CLOSE		= 0xF060
CB_GETLBTEXT	= 0x148



Application_AddMessageHandler( WM_AHKSHOW,		"FavMenu_MessageMonitorDispatch")
Application_AddMessageHandler( WM_SYSCOMMAND,	"FavMenu_MessageMonitorDispatch")
Application_AddMessageHandler( WM_KEYDOWN,		"FavMenu_MessageMonitorDispatch")