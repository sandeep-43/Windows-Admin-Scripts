###### To Fetch Security Groups for PS Verion 3.0 and above #####
#Set-ExecutionPolicy unrestricted -Scope CurrentUser
$ErrorActionPreference = "SilentlyContinue"
$paths=  Read-Host "\\ServerName\Drive\Folder"
$date=(Get-Date -Format "dd-MM-yyyy---HH-mm")
$OutFile= "C:\Temp\NTFS-Permissions\NTFSPermissions_$date.csv"
if(Test-Path $paths)
{
    foreach($path in $paths)
    {
        $folder=Get-childItem -path $path  -recurse -force | ?{$_.psiscontainer -eq 'TRUE'}
        foreach($fold in $folder)
        {
                
                $acls=($fold | get-acl ).Access
                $Owner=Get-acl | Select Owner
                foreach($acl in $acls)
                {
                        
                        $prop=@{
                                    "GroupName"=$acl.IdentityReference
                                    "Path"=$fold.FullName
                                    "FileSystemRights"=$ACL.FileSystemRights
                                    "IsInherited"=$ACL.IsInherited
                                    "Owner"=$Owner
                                }
                

               
        
                               $obj=New-Object -TypeName PSObject -Property $prop
                               Write-Output $obj | Select Path, GroupName, IsInherited,FileSystemRights,Owner | export-csv $OutFile -append -notypeinformation

         
                 }        
                
        }
    }
}

Else
{
    Write-warning "Path entered is incorrect. Please re-run the script !!!"
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

Write-Host "`nPress any key to exit ..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()