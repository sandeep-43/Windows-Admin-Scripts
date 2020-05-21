$Hosts = Get-Content -Path "$env:USERPROFILE\Documents\servers_2008_32bit.txt" #"Path of the text file containing server names" 
$ErrorLogFilePath = "C:\Temp\WinUpdate\Copy_Logs_Server200_32bit.txt" 
$VerbosePreference = "continue"


foreach ($hos in $Hosts) 
{         
        [switch]$everything_is_ok=$true
         
        try
        {
                $sysinfo= gwmi win32_operatingsystem -ComputerName $hos -ErrorAction Stop
                $date = Get-Date
        }
        catch
        {
                Write-Warning "$hos is not reachable"
                Write-Output "$hos is not reachable at $date" | out-file $ErrorLogFilePath -Append
                $_ | out-file $ErrorLogFilePath -Append
                Write-Output $("*" * 50) | out-file $ErrorLogFilePath -Append
                $everything_is_ok=$False
        } 

        if($everything_is_ok -eq $true)
        {
             #$Flavor= $sysinfo.Caption
             #$Arch= $sysinfo.OsArchitecture
         
             New-Item -path "\\$hos\c$\" -ItemType "Directory" -Name "Temp"
             New-Item -path "\\$hos\c$\Temp\" -ItemType "Directory" -Name "WinUpdate"

          <#   if($Flavor -eq "Microsoft Windows Server 2008 R2*")
                {
                    if($Arch -eq '64-bit')
                    { 
                        $kb = "Windows6.1-KB2506143-x64.msu"
                        Write-Verbose "Copying file on $hos"
                        Copy-Item -Path C:\temp\WinUpdate\$kb -Destination \\$hos\C$\Temp\WinUpdate 
                   } 
                    elseif($Arch -eq '32-bit')
                    {
                        $kb = "Windows6.1-KB2506143-x86.msu"
                        Write-Verbose "Copying file on $hos"
                        Copy-Item -Path C:\temp\WinUpdate\$kb -Destination \\$hos\C$\Temp\WinUpdate
                    }
                }

               else #Microsoft Windows Server 2008
                {
                    if($Arch -eq '64-bit')
                    { 
                        $kb = "Windows6.0-KB2506146-x64.msu"
                        Write-Verbose "Copying file on $hos"
                        Copy-Item -Path C:\temp\WinUpdate\$kb -Destination \\$hos\C$\Temp\WinUpdate
                    }
                    elseif($Arch -eq '32-bit')
                    {#>
                        $kb = "Windows6.0-KB2506146-x86.msu"
                        Write-Verbose "Copying file on $hos"
                        Copy-Item -Path C:\temp\WinUpdate\$kb -Destination \\$hos\C$\Temp\WinUpdate
                        Write-Verbose "Copied file successfully on $hos"
               #     }
               # }
         } 

 }
 
