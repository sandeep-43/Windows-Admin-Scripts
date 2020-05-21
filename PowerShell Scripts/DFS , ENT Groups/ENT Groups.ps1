###### To Fetch ENT Security Groups #####
#$ErrorActionPreference='SilentlyContinue'
Set-ExecutionPolicy unrestricted -Scope CurrentUser
$startdate=get-date
Write-host "Fetching ENT Groups..."
$paths= Get-content C:\temp\serverlist.txt
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
                    $prop=@{
                                "ACL"=$acl.IdentityReference
                                "Path"=$fold.FullName
                            }
                }
	        }
                        
                           $obj=New-Object -TypeName PSObject -Property $prop
                           Write-Output $obj | Select Path, ACL | export-csv "c:\temp\ENTgroups_serverlist2.csv" -append -notypeinformation

         
                     
                
    }
}
$enddate= get-date
$diff=new-timespan -start $startdate -end $enddate | out-file c:\temp\TimeTaken_ENTGroups.txt
Write-host "Completed...Press any key to EXIT"


$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
