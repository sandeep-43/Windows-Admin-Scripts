$servers = gc "$env:USERPROFILE\Documents\servers.txt"
$ids="id1","id2","id3","id4","id5"
$OutFile="$env:USERPROFILE\Documents\ProfileExistenceCheck.csv"

foreach($server in $servers)
{
    if(gwmi win32_operatingsystem -cn $server)
    {
        foreach($id in $ids)
        {
            if(test-path \\$server\c$\users\$id)
            {
                $prop=@{
                        "Server Name"=$server
                        "User Profile Found"="Yes"
                        "User ID"=$id
                        }
               # Write-Output @{l="Server Name";e="$server"},@{l="USer Profile Found";e="Yes"},@{l="ID";e="$id"}
            }
            else
            {
                 $prop=@{
                        "Server Name"=$server
                        "User Profile Found"="No"
                        "User ID"=$id
                        }
                #Write-Output @{l="Server Name";e="$server"},@{l="USer Profile Found";e="No"},@{l="ID";e="$id"}
            }
            $obj=New-Object -TypeName PSObject -Property $prop
            Write-Output $obj | Select "Server Name", "User Profile Found", "User ID" | Export-Csv $OutFile -Append -NoTypeInformation
        }
    }
    else
    {
         $prop2=@{
                        "Server Name"=$server
                        "User Profile Found"="Server Not Reachable / Access Denied"
                        "User ID"="Server Not Reachable / Access Denied"              
                 }
        $obj2=New-Object -TypeName PSObject -Property $prop2
            Write-Output $obj2 | Select "Server Name", "User Profile Found", "User ID" | Export-Csv $OutFile -Append -NoTypeInformation
    }
}


