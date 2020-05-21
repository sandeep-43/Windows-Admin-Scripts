#
#'===================================================================
#' DISCLAIMER: _NTFS-Permissions
#'-------------------------------------------------------------------
#' 
#' Microsoft
#' 
#'===================================================================
#

Clear
New-Item -ItemType directory -Path C:\Temp -ErrorAction SilentlyContinue
New-Item -ItemType directory -Path C:\Temp\NTFS-Permissions -ErrorAction SilentlyContinue
Import-Module ActiveDirectory
Clear
$PSVersionTable.PSVersion
Write-host " "
Write-host "NTFS Permissions Script." 
Write-host " "
Write-host " "
Write-host " "
Write-host " Script will generate 1 file:"
Write-host " "
Write-host "  C:\Temp\NTFS-Permissions\CurrentDate --- CurrentTime ServerName-Share - NTFS-Permissions.csv"
Write-host "  ------ Contains permissions assigned at the folder level"
Write-host " "
Write-host " "
Write-host " "
Write-host "Please enter the name of the server & share name which you want to gather NTFS permission information:"
Write-host " "
Write-host "Format should be \\ServerName\ShareName"
Write-host " "
$RootPath = Read-Host 'Enter \\ServerName\Sharename '
# $RootPath = "\\<Server-name>\<share-name>"
Write-host " "
Write-host " "
Write-host "     Processing NTFS Permissions for $RootPath"
Write-host " "
Write-host " "

$Date = (Get-Date -format "dd-MM-yyyy---HH-mm")

$Servername = $RootPath.split("\")
$Servername = $Servername[2] + "-" + $Servername[3]

$OutFile = "C:\Temp\NTFS-Permissions\$Date - $Servername - NTFS-Permissions.csv"

$Header = "FolderPath,GroupName,AccessControlType,IsInherited,FileSystemRights"

Del $OutFile -ErrorAction SilentlyContinue

Add-Content -Value $Header -Path $OutFile 

$Folders = dir $RootPath -Recurse -ErrorAction SilentlyContinue | where {$_.PsIsContainer} 
# $Folders = Get-ChildItem -Directory $RootPath -Recurse -ErrorAction SilentlyContinue -Force  

foreach ($Folder in $Folders) {
	$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  } -ErrorAction SilentlyContinue
	Foreach ($ACL in $ACLs ){
		$TempFolderName = $Folder.fullname -replace ",", "^"
		$OutInfo =  $TempFolderName + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.FileSystemRights | where-object {$ACL.IdentityReference -notlike "BUILTIN\Administrators" -and $ACL.IdentityReference -notlike "*AUTHORITY\SYSTEM*" -and $ACL.IdentityReference -notlike "CREATOR*OWNER"}
		if ( $_.access -like 'ENT\*') { Add-Content -Value $OutInfo -Path $OutFile }
		 Add-Content -Value $OutInfo -Path $OutFile
	}}

(Get-Content $OutFile) | Foreach-Object {$_ -replace " Synchronize", ""} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "268435456", "FullControl"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-536805376", "ReadWriteExecuteDelete"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-1610612736", "ReadAndExecuteExtended"} | Set-Content $OutFile

Write-host "------------------------------------------------------- "
Write-host " "

