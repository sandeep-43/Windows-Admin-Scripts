### To check if there exists multiple partitions on a single disk or not ###

$computers=Get-content C:\temp\checkdrive.txt

foreach($computer in $computers)
{
    $wmi=gwmi win32_diskdrive -ComputerName $computer
       
    foreach($wm in $wmi)
    {
       $partitions=$wm.partitions
       if($partitions -eq 0)
       {
                $prop=@{
                        "Server Name"=$computer
                        "Disks"=$wm.deviceid -join ","
                        "Multiple Partitions"="False"
                        "Partitions"="Un-initialised Disk"
                       }
        }
        elseif($partitions -eq 1)
        {
        
                $prop=@{
                        "Server Name"=$computer
                        "Disks"=$wm.deviceid -join ","
                        "Multiple Partitions"="False"
                        "Partitions"=$wm.partitions -join ","
                       }
        
        }
        else
        {
                $prop=@{
                            "Server Name"=$computer
                            "Disks"=$wm.deviceid -join ","
                            "Multiple Partitions"="True"
                            "Partitions"=$wm.partitions -join ","
                           }
        }
    
        $obj= New-object -TypeName PSObject -Property $prop
        Write-Output $obj | Select "Server Name", "Disks", "Multiple Partitions","Partitions" |export-csv c:\temp\chkdisk.csv -NoTypeInformation -Append       
    }
}