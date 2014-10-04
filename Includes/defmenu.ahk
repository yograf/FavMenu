CreateDefaultMenu(fileName="")
{

	if filename=
		fileName := "menu.ini"
	FileDelete %filename%

FileAppend, 
(LTRIM %
	[DirMenu]
	menu1=System32
	cmd1=cd %$SYSTEM%
	icon1=Icons\inherit2.ico
	menu2=My Documents
	cmd2=cd %$PERSONAL%
	icon2=Icons\folio000.ico
	menu3=-
	menu4=C Drive
	cmd4=cd c:\
	icon4=Icons\ar-open0.ico
	menu5=D drive
	cmd5=cd d:\
	icon5=Icons\ar-open0.ico
	menu6=-
	menu7=-Utilities
	icon7=Icons\db000000.ico
	menu8=Notepad
	cmd8=%SYSTEMROOT%\Notepad
	icon8=Icons\pen00000.ico
	menu9=Command Line c:\
	cmd9=cmd /K c:& cd \
	icon9=Icons\sans0000.ico
	menu10=--
	menu11=-Command Line
	icon11=Icons\serif000.ico
	menu12=-README
	icon12=Icons\bubble00.ico
	menu13=Command line items should be run
	cmd13=readme.doc
	menu14=while console is active application
	cmd14=readme.doc
	menu15=See readme.txt for more details
	cmd15=FavMenu.html
	menu16=--
	menu17=Show Explorer Process
	cmd17=tasklist | findstr "explorer"
	menu18=Show system info
	cmd18=systeminfo
	menu19=-
	menu20=Clear Screen
	cmd20=cls
	icon20=Icons\doc-new0.ico
	menu21=--
	menu22=-
	menu23=-Internet
	icon23=Icons\recurse-blue.ico
	menu24=AutoHotKey Homepage
	cmd24=www.autohotkey.com
	menu25=Google
	cmd25=www.google.com
	menu26=-
	menu27=someDude@somePlace.com
	cmd27=mailto:someDude@somePlace.com
	icon27=Icons\person00.ico
	menu28=--
	), %A_ScriptDir%\%fileName%
}