Set-ExecutionPolicy remotesigned -force -scope CurrentUser

function Get-RSMAlertInfo{
    param(
    [CmdletBinding()]
    [Parameter(Mandatory=$True, HelpMessage="Input ComputerName or IP Address to query via WMI")]
    [Alias('cn')]
    [string]$ComputerName,

    [Parameter()]
    [string]$ErrorLogFilePath="$env:USERPROFILE\Documents\RSMAlertErrorLogFile.txt",

    [Parameter()]
    [string]$LogFilePath="$env:USERPROFILE\Documents\RSMAlertLogFile.txt",

    [Parameter()]
    [switch]$everything_is_ok= $True,

    [Parameter()]
    $date
    )

    BEGIN{
            $date=get-date

    
    }
    PROCESS{
            try
                {
                        gwmi win32_bios -ComputerName $ComputerName -ErrorAction Stop | Out-Null
                }
                catch
                {
                        Write-Warning "$ComputerName is not reachable"
                        Write-Output "$ComputerName is not reachable at $date" | out-file $ErrorLogFilePath -Append
                        $_ | out-file $ErrorLogFilePath -Append
                        Write-Output "***************************************" | out-file $ErrorLogFilePath -Append
                        $everything_is_ok=$False
                }

            if($everything_is_ok)
            {
                $cpu=gwmi win32_processor -cn $ComputerName
                $cs=Get-WmiObject -Class Win32_ComputerSystem -cn $ComputerName
                $ld=Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -cn $ComputerName
                $tz=Get-WmiObject -Class Win32_TimeZone -cn $ComputerName
                $os=Get-WmiObject -Class Win32_OperatingSystem -cn $ComputerName
                $bo=Get-WmiObject -Class Win32_bios -cn $ComputerName
                $ip=Get-WmiObject Win32_NetworkAdapterConfiguration -cn $ComputerName -Filter "IpEnabled = TRUE"
                $uptime=$os.converttodatetime($os.localdatetime)-$os.converttodatetime($os.lastbootuptime);
            
                $prop =@{
                                "Host Name"=$os.csname;
                                "OS Name"=$os.caption;
                                "Manufacturer"=$cs.Manufacturer;
                                "Model"=$cs.model;
                                "Bit Version"=$os.OSArchitecture;
                                "Service Pack"=$os.ServicePackMajorVersion;
                                "Install Date"=$os.converttodatetime($os.InstallDate);
                                "Last Boot Time"=$os.converttodatetime($os.LastBootUpTime);
                
                                "System Uptime" ="$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
                                "Time Zone"=$tz.Caption;
                                "Standard Name"=$tz.standardname;
                                "Daylight Name"=$tz.DaylightName;
                                "Local Date Time"=$os.converttodatetime($os.LocalDateTime);
                                "Bios Version"=$bo.SMBIOSBIOSVersion;
                                "Bios Name"=$bo.name;
                                "Processor Name"=$cpu.name;
                                "Number Of Cores" =$cpu.NumberOfCores;                  
                                "Number Of Enabled Core"=$cpu.NumberOfEnabledCore    ;          
                                "Number Of Logical Processors"=$cpu.NumberOfLogicalProcessors;
                                "Domain Name"=$cs.domain;
                                "Domain Role"=$cs.domainrole;
                                "RAM(GB)"="{0:n2}" -f ($cs.TotalPhysicalMemory/1GB) ;
                                "Build Number"=$os.buildnumber;
                                "Registered User"=$os.registereduser;
                                "Status"=$os.status;
                                "IP Address"=$ip.ipaddress;
                        }             
                       
                        $obj=New-Object -TypeName PSObject -Property $prop
                        Write-Output $obj | Select "Host Name","Domain Name", "OS Name", "Service Pack", "IP Address",
                        "Bit Version", "Install Date","Local Date Time","Last Boot Time", "System Uptime","Time Zone"#,
                        #  "Standard Name", # "Manufacturer", "Model", "Bios Name", "Bios Version","Processor Name", "Number Of Cores",
                        #  "Number Of Logical Processors","RAM(GB)", "Registered User", "Status"

                foreach($hdd in $ld)
                {
                    $prop2=@{
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
                        Write-Output $obj2 | select "Device ID","Volume Name","Total Space (GB)", "Free Space (GB)","Free Space (%)"
                }
             }
        }

    END{
            Write-Output "Details for $ComputerName fetched at $date" | out-file $LogFilePath -Append 
    }
}
    
Get-RSMAlertInfo

Write-Host "`nPress any key to exit ..."

$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
