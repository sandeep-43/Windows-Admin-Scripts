$InputFile= Get-Content "$env:USERPROFILE\Documentsp\Servers.txt"
$OutputFile = "$env:USERPROFILE\Documents\DCREPORT.csv"

$Servers= $InputFile
foreach($ComputerName in $Servers)
{
    if(Get-WmiObject -Class win32_operatingsystem -ComputerName $ComputerName)
    {
        $cpu=gwmi win32_processor -cn $ComputerName | Measure-Object DeviceID
        #$cu=gwmi win32_processor -cn $ComputerName
        $ld=Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -cn $ComputerName
        $os=Get-WmiObject -Class Win32_OperatingSystem -cn $ComputerName

        $prop= @{
                    "Server"= $ComputerName;
                    "Status"= "ONLINE";
                    "Service Pack"= $os.ServicePackMajorVersion;
                    "CPU Count"= $cpu.Count;
                    #"Total CPU Speed"= ($cpu.Count)*($cu.MaximumClockSpeed | ?{$_.DeviceID -eq "CPU1"})
                    
                }
    }
    else
    {
         $prop= @{
                    "Server"= $ComputerName;
                    "Status"= "OFFLINE";  
                    "Service Pack"= "OFFLINE";
                    "CPU Count"= "OFFLINE";
                   # "Total CPU Speed"="OFFLINE"
                   } 
    }
    $obj=New-Object -TypeName PSObject -Property $prop
    Write-Output $obj | Select "Server","Status", "Service Pack", "CPU Count" <#, "Total CPU Speed" #> | Export-csv $OutputFile -Append -NoTypeInformation
}