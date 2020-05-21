###### To Fetch ENT Security Groups #####
Write-host "Fetching ENT Groups..."
#Set-ExecutionPolicy remotesigned -Scope CurrentUser
$paths= "\\ServerName\Drive\Folder"

$OutFile= "$env:USERPROFILE\Documents\ENT_Groups_ServerName.csv"

$Header = "GroupName,FileSystemRights,IsInherited,FolderPath"

#Add-Content -Value $Header -Path $OutFile 

foreach($path in $paths)
{
	
    $folder=Get-childItem -path $path  -recurse -force | ?{$_.psiscontainer -eq 'TRUE'}
    foreach($fold in $folder)
    {
   
            $acls=($fold | get-acl ).Access
   
            foreach($acl in $acls)
            {
                if($acl.identityreference -like 'ENT\*')
                {
			

			$TempFolderName = $Fold.fullname -replace ",", "^"

			Write-output "$($acl.IdentityReference),$($acl.FileSystemRights),$($acl.IsInherited),$TempFolderName" | out-file $outfile -append  
                   
		  #	$prop=@{
                  #               "ACL"=$acl.IdentityReference
                  #               "Path"=$fold.FullName
                  #   	       }
                }

             #  else
             #  {
             #          $prop=@{
             #                    "ACL"="Not an ENT Group"
             #                    "Path"=$fold.FullName
             #                 }
             #  }
       
            #            $obj=New-Object -TypeName PSObject -Property $prop
            #            Write-Output $obj | Select Path, ACL | export-csv c:\users\ssingh4\desktop\ENTgroups.csv -append -notypeinformation

         
             }        
                
    }

(Get-Content $OutFile) | Foreach-Object {$_ -replace ", Synchronize", ""} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "268435456", "FullControl"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-536805376", "ReadWriteExecuteDelete"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-1610612736", "ReadAndExecuteExtended"} | Set-Content $OutFile

}


$To="sandeep.singh@xyz.com"
$From="ScriptNotification@xyz.com"
$Subject="DFS Groups in ServerName"
#$AttachmentsLocation=$OutFile
$EmailBody="Hi,`n`nThe script to fetch DFS groups is completed. Please find the list at $OutFile of the subjected server.`n`nRegards,`nScript Notifier`n(On Behalf Of Sandeep Singh)"

Send-MailMessage -to $To  -from $From -Subject $Subject -body $EmailBody -SmtpServer "smtp.xyz.com" #-attachments $AttachmentsLocation