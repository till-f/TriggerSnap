Trigger Snap
============

Tool to take snapshot of screen region. Snapshots are automatically
saved to a file and stored in the clipboard.

Extra feature: paste textual clipboard content as plain text.


Instructions
------------

Get [AutoHotkey](https://www.autohotkey.com/).

Start "TriggerSnap.ahk".

Press `Windows` + `Space` to take a single screenshot.
Select region on screen or press `Escape` to cancel.

Press `Windows` + `Alt` + `Space` to prepare multiple screenshots.
Select region on screen or press `Escape` to cancel. 
Save as many screenshots as desired by pressing `Space` or press
`Escape` to cancel.

Press `Windows` + `PrintScreen` to scrape a document.
Follow instructions in popup. Press `Escape` to cancel.

Special feature (not related to screenshots):
Press `Windows` + `V` to paste the clipboard content as
plaint text (e.g. remove text formatting, hyperlinks, margins, ...)


Configuraiton
-------------

Edit TriggerSnap.ahk to change the shortcuts and the following settings:

 * imgBaseDir
   * Base directoy for saved snapshots. Can be an absolute path, otherwise it is relative to the script file.
   * Default value: `snap`
 * dateFormat
   * Date format used in the name of saved files.
   * Default value: `yyyy-MM-dd HH''''mm''''ss` (example: 2020-12-31 23'59'59)
 * askForName
   * Ask for a filename for every single screenshot.
   * Default value: `false`
 * captureMouse
   * Capture mouse cursor on single screenshots.
   * Default value: `true`
 * runAsAdmin
   * Run as administrator (required so that shortcuts work with priviledged app in the foreground).
   * Default value: `true`

For more details, see see https://www.autohotkey.com/docs/Tutorial.htm.
