###### To Fetch Security Groups #####
Write-host "Fetching Security Groups..."
#Set-ExecutionPolicy remotesigned -Scope CurrentUser
$paths= Read-Host "\\ServerName\Drive\Folder"
$date=(Get-Date -Format "dd-MM-yyyy---HH-mm")
$OutFile= "C:\Temp\NTFS-Permissions\NTFSPermissions_$date.csv"

$Header = "GroupName,FileSystemRights,IsInherited,FolderPath" 


Del $OutFile -ErrorAction SilentlyContinue
Add-Content -Value $Header -Path $OutFile 

foreach($path in $paths)
{
	
    $folder=Get-childItem -path $path  -recurse -force | ?{$_.psiscontainer -eq 'TRUE'}
    foreach($fold in $folder)
    {
   
            $acls=(get-acl $fold.FullName).Access
   
            foreach($acl in $acls)
            {
               			

			$TempFolderName = $Fold.fullname -replace ",", "^"

			Write-output "$TempFolderName,$($acl.IdentityReference),$($acl.IsInherited),$($acl.FileSystemRights)" | out-file $outfile -append                   
		    }
    }
}

(Get-Content $OutFile) | Foreach-Object {$_ -replace ", Synchronize", ""} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "268435456", "FullControl"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-536805376", "ReadWriteExecuteDelete"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-1610612736", "ReadAndExecuteExtended"} | Set-Content $OutFile




#$To="sandeep.singh@xyz.com"
#$From="ScriptNotification@xyz.com"
#$Subject="DFS Groups in ServerName"
#$AttachmentsLocation=$OutFile#
#$EmailBody="Hi,`n`nThe script to fetch DFS groups is completed. Please find the list at $OutFile of the subjected server.`n`nRegards,`nScript Notifier`n(On Behalf Of Sandeep Singh)"

#Send-MailMessage -to $To  -from $From -Subject $Subject -body $EmailBody -SmtpServer "smtp.xyz.com" #-attachments $AttachmentsLocation