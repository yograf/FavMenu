# FavMenu2 patched version #

FavMenu2 stores a list of your favorite folders, and let you quickly
jump to them within system dialogs (Open/Save, Browse For Folder,
Office2003 dialogs), Console (cmd.exe), Windows Explorer and Total
Commander.

![screenshot](http://att.newsmth.net/nForum/att/TotalCommander/45716/754)

Original Author: Miodrag Milic

Download the orignal version: <http://www.totalcmd.net/plugring/TC_FavMenu2.html>

## About this fork ##

This version has the following enhancements:

* Fix support for Total Commander > 7.0
* Add support for GNU Emacs, XEmacs & MicroEmacs-jasspa
* Add support for mintty/rxvt on Cygwin/Msys (only SetPath, no GetPath)
* Add support for explorer & open/save dialog of Windows Vista/7
* Add support for 
* Add menu item 'Copy current path'
* Add menu item 'Command Prompt Here'
* For unsupported applications/dialogs, try to parse window title to get
  current path

If you have any question about this fork, please concat me <http://bitbucket.org/bamanzi>

## Usage ##

### Menu of your favorites folders & applications ###

You can create & edit a menu with Editor.exe. Possible menu items are:

 * a folder (command: `cd <path>`  for example: `cd D:\Documents`)
 * executable (command: `<path_to_exe>` for example: `notepad.exe` or `d:\tools\gfie\gfie.exe`)
   (in fact, any file could be added)

Note that environment variables could be used in command, for example:
`cd %APPDATA%\Google\Chrome`.

You can also use Total Commander's Directory Hotlist as the menu, just
set path of TC's `wincmd.ini` as FavMenu's menu definition ini file, in
`Setup->Configuration`.  In this case, You can use TC plugin path in the
command, for example: `cd \\\Uninstaller\` or `cd \\\Registry\HKEY_CURRENT_USER\Sofware`

### Bring up the menu ###

When you want to jump to one of your favorite folder, just bring up the
menu.  To do this, you need to set a system-wide hotkey in
`Setup->Configuration`.

If current application/dialog is supported by FavMenu, it would let the
application jump to the folder you clicked. Otherwise, it would open
that folder in the default file manager (which is configurable in
`Setup->Configuration`).

### Advanced Usage ###

**The menu**:
   
  * `Ctrl+Enter` on menu item: open properties dialog for the menu item
  * `Shift+Enter` on menu item: open selected folder in new tab (if target
    application supports this)
  * `Ctrl+Shift+Enter` on menu item: send path of selected item to active window

**Pseudo variables in path**:

FavMenu supports Total Commander's pseudo variables, such as `$DESKTOP`,
`$PERSONAL`, refer `Includes/pseudo.ahk` for detailed info.


 
