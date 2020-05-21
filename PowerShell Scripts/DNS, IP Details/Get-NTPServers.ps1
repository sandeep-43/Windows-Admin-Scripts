$servers = Get-content "C:\temp\servers.txt"

foreach ($server in $servers){
$ntps = w32tm /query /computer:$server /source
$obj=new-object psobject -property @{
    Server = $Server
    NTPSource = $ntps
    }
$obj | Out-file "c:\temp\NTPServers.txt" -append
}

