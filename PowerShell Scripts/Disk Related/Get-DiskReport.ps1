$InputFile= Get-Content "$env:USERPROFILE\Documents\Servers.txt"
$OutputFile = "$env:USERPROFILE\Documents\DC_Disks_Report.csv"
$ErrorFile = "$env:USERPROFILE\Documents\DC_Errors_Servers.txt"

$Servers= $InputFile
foreach($ComputerName in $Servers)
{
    if(Get-WmiObject -Class win32_operatingsystem -ComputerName $ComputerName)
    {
        $ld=Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -cn $ComputerName
        foreach($hdd in $ld)
        {
            $prop2=@{
                        "Server"=$ComputerName;
                        "Device ID"=$hdd.deviceid;
                        "Volume Name"=$hdd.VolumeName;
                        "Free Space (GB)"="{0:n2}" -f ($hdd.freespace/1GB) ;
                        "Free Space (%)"="{0:p2}" -f ($hdd.freespace/$hdd.size) ;
                        "Total Space (GB)"="{0:n2}" -f ($hdd.size/1GB) ;
                    }
                    if(!($prop2."Volume Name" ))
                    {
                        $prop2."Volume Name"="Local Disk"
                    }
                        $obj2=New-Object -TypeName PSObject -Property $prop2
                Write-Output $obj2 | select "Server","Device ID","Volume Name","Total Space (GB)", "Free Space (GB)","Free Space (%)" | Export-Csv $OutputFile -Append -NoTypeInformation
        }
    }
    else
    {
        Add-Content -Value "$ComputerName is not accessible" -Path $ErrorFile 
    }
}