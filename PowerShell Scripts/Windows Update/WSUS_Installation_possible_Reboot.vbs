Set updateSession = CreateObject("Microsoft.Update.Session")

Set updateSearcher = updateSession.CreateupdateSearcher()

Counter = 0   ' Initialize Counter.

Dim objFSO, objFolder, objShell, objTextFile, objFile

Dim strDirectory, strFile, strText

 

Set WshShell = WScript.CreateObject("WScript.Shell")

Set WshSysEnv = WshShell.Environment("PROCESS")

strDirectory = WshSysEnv("TEMP")

 

strFile = "\WindowsUpdate_Installation.log"

 

' Create the logging file or append to it if it exists

Set objFSO = CreateObject("Scripting.FileSystemObject")

 

If objFSO.FileExists(strDirectory & strFile) Then

   Set objFolder = objFSO.GetFolder(strDirectory)

Else

   Set objFile = objFSO.CreateTextFile(strDirectory & strFile)

'   Wscript.Echo "Just created " & strDirectory & strFile

End If 

 

set objFile = nothing

set objFolder = nothing

' OpenTextFile Method needs a Const value

' ForAppending = 8 ForReading = 1, ForWriting = 2

Const ForAppending = 8

 

Set objTextFile = objFSO.OpenTextFile _
(strDirectory & strFile, ForAppending, True)

 

' Start the log...

objTextFile.WriteLine  vbCRLF & _
"__________________________________"

objTextFile.WriteLine NOW()

objTextFile.WriteLine "Searching for approved updates..." & vbCRLF

 

Set searchResult = _
updateSearcher.Search("IsInstalled=0 and Type='Software'")

 

objTextFile.WriteLine "List of applicable and approved items for this machine:"

 

For I = 0 To searchResult.Updates.Count-1

    Set update = searchResult.Updates.Item(I)

    objTextFile.WriteLine I + 1 & "> " & update.Title

Next

 

If searchResult.Updates.Count = 0 Then

     objTextFile.WriteLine "There are no applicable updates."

     WScript.Quit

End If

 

 

objTextFile.WriteLine  vbCRLF & "List of downloaded updates ready for install:"

 

 

For I = 0 To searchResult.Updates.Count-1

    Set update = searchResult.Updates.Item(I)

    If update.IsDownloaded Then

       objTextFile.WriteLine I + 1 & "> " & update.Title 

    End If

Next

 

 

Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")

 

 

For I = 0 To searchResult.Updates.Count-1

    set update = searchResult.Updates.Item(I)

    If update.IsDownloaded = true Then

       updatesToInstall.Add(update)

      Counter = Counter + 1   ' Increment Counter to count downloaded updates.   

    End If

Next

 

If Counter = 0 Then    ' If There are no downloaded updates...

     objTextFile.WriteLine  vbCRLF & _
        "There are no downloaded updates to install."

     WScript.Quit

End If

 

 

 

objTextFile.WriteLine  vbCRLF & _
"Installing updates..."

Set installer = updateSession.CreateUpdateInstaller()

installer.Updates = updatesToInstall

Set installationResult = installer.Install()

     

'Output results of install

objTextFile.WriteLine  vbCRLF & _
"Installation Result: " & _
installationResult.ResultCode 

objTextFile.WriteLine "Reboot Required: " & _ 
installationResult.RebootRequired & vbCRLF 

objTextFile.WriteLine "Listing of updates installed " & _
"and individual installation results:" 

     

For I = 0 to updatesToInstall.Count - 1

     objTextFile.WriteLine I + 1 & "> " & _
     updatesToInstall.Item(i).Title & _
     ": " & installationResult.GetUpdateResult(i).ResultCode         

Next

 

'reboot the machine, if needed

if installationResult.RebootRequired = true then

 

objTextFile.WriteLine  vbCRLF & _
"Reboot Required. Rebooting..."
 

sComputer = "." 

'next two lines by mvo:
WScript.Echo  vbCRLF & _
"Reboot Required. Rebooting..." 

'next four lines by mvo: Create Application Event Log Entry for Monitoring
set shell = WSCript.CreateObject("Wscript.Shell") 
'shell.Run "eventcreate /T WARNING /ID 22 /SO" +"ScheduledTaskPatchInstallationRestart" + "/L SYSTEM /D" +"Monitoring ignore next server restart, it is a planned restart from Security Update Installation"
'shell.Run "eventcreate /T WARNING /ID 22"
shell.Run "eventcreate /T WARNING /ID 22 /D IgnoreNextReboot_PlannedSecurityUpdateInstallation"

Set oWMI = GetObject("winmgmts:" _
  & "{impersonationLevel=impersonate,(Shutdown)}!\\" _
  & sComputer & "\root\cimv2")

 

Set colOperatingSystems = oWMI.ExecQuery _
  ("Select * from Win32_OperatingSystem")

For Each obj in colOperatingSystems

 Set oOS = obj :  Exit For

Next

' next line added by mdebasti
' wscript.sleep 32400000	'Sleep time of 9 hours

Const EWX_LOGOFF = 0

Const EWX_SHUTDOWN = 1

Const EWX_REBOOT = 2

Const EWX_FORCE = 4

Const EWX_POWEROFF = 8

'

'oOS.Win32shutdown EWX_WhatToDo

' FORCE a REBOOT = 6

oOS.Win32shutdown 6

 

End If

