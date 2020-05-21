#
#'===================================================================
#' DISCLAIMER: _ENT-Groups
#'-------------------------------------------------------------------
#' 
#' Microsoft
#' 
#'===================================================================
#

$RootPath = "C:\"


Clear
$startdate=get-date
New-Item -ItemType directory -Path C:\Temp -ErrorAction SilentlyContinue
New-Item -ItemType directory -Path C:\Temp\ENT-Groups -ErrorAction SilentlyContinue
Import-Module ActiveDirectory
Clear
$Servername = (gwmi win32_operatingsystem).CSName
#$PSVersionTable.PSVersion
Write-host " "
Write-host "NTFS Permissions (for ENT Groups) Script." 
Write-host " "
Write-host " "
Write-host " "
Write-host "Script will generate 1 file:"
Write-host " "
Write-host "C:\Temp\ENT-Groups\CurrentDate --- CurrentTime ServerName-Share - ENT-Groups.csv"
Write-host "------ Contains permissions assigned at the folder level"
Write-host " "
Write-host " "
Write-host " "
Write-host " "
#$RootPath = Read-Host 'Enter \\ServerName\Sharename '
Write-host "Processing NTFS Permissions (for ENT Groups) for $RootPath"
Write-host " "
Write-host " "

$Date = (Get-Date -format "dd-MM-yyyy---HH-mm")

#$Servername = $RootPath.split("\")
#$Servername = $Servername[2] + "-" + $Servername[3]

$OutFile = "C:\Temp\ENT-Groups\$Date - $Servername - ENT-Groups.csv"

$Header = "FolderPath,GroupName,AccessControlType,IsInherited,FileSystemRights"

Del $OutFile -ErrorAction SilentlyContinue

Add-Content -Value $Header -Path $OutFile 

$Folders = dir $RootPath -Recurse -ErrorAction SilentlyContinue | where {$_.PsIsContainer} 
# $Folders = Get-ChildItem -Directory $RootPath -Recurse -ErrorAction SilentlyContinue -Force  

foreach ($Folder in $Folders) {
	$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  } -ErrorAction SilentlyContinue
	Foreach ($ACL in $ACLs ){
		$TempFolderName = $Folder.fullname -replace ",", "^"
		$OutInfo =  $TempFolderName + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.FileSystemRights | where-object {$ACL.IdentityReference -like "ENT\*"}
		if ( -not ( $ACL.IsInherited )) { Add-Content -Value $OutInfo -Path $OutFile }
		# Add-Content -Value $OutInfo -Path $OutFile
	}}

(Get-Content $OutFile) | Foreach-Object {$_ -replace " Synchronize", ""} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "268435456", "FullControl"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-536805376", "ReadWriteExecuteDelete"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-1610612736", "ReadAndExecuteExtended"} | Set-Content $OutFile

Write-host "------------------------------------------------------- "
Write-host " "

$enddate= get-date
$diff=new-timespan -start $startdate -end $enddate | out-file "C:\Temp\ENT-Groups\$Date - $Servername - TimeTaken.txt"
Write-host "Completed...Press any key to EXIT"


$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
