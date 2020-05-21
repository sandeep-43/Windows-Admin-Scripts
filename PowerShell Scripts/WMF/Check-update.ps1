$Hosts = Get-Content -Path "$env:USERPROFILE\Documents\servers.txt" #"Path of the text file containing server names" 
$ErrorLogFilePath = "C:\Temp\WinUpdate\Verification_Error_Logs.txt" 
$ValidationFile = "C:\Temp\Validatio_Status.csv"
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
             $Flavor= $sysinfo.Caption
             $Arch= $sysinfo.OsArchitecture
         
                if($Flavor -eq "Microsoft Windows Server 2008 R2*")
                {
                    if($Arch -eq '64-bit')
                    {
                        $kb = "Windows6.1-KB2506143-x64.msu"
                        Write-Verbose "Checking update on $hos"
                        $check = Get-HotFix -Id KB2506143 -ComputerName $hos
                        if(!$check)
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Not Found"} | Export-Csv $ValidationFile
                        }
                        else
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Installed Successfully"} | Export-Csv $ValidationFile
                        }
                    } 
                    elseif($Arch -eq '32-bit')
                    {
                        $kb = "Windows6.1-KB2506143-x86.msu"
                        Write-Verbose "Checking update on $hos"
                       $check = Get-HotFix -Id KB2506143 -ComputerName $hos
                        if(!$check)
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Not Found"} | Export-Csv $ValidationFile
                        }
                        else
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Installed Successfully"} | Export-Csv $ValidationFile
                        }
                    }
                }
             else #Microsoft Windows Server 2008
                {
                    if($Arch -eq '64-bit')
                    {
                        $kb = "Windows6.0-KB2506146-x64.msu"
                        Write-Verbose "Checking update on $hos"
                        $check = Get-HotFix -Id KB2506143 -ComputerName $hos
                        if(!$check)
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Not Found"} | Export-Csv $ValidationFile
                        }
                        else
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Installed Successfully"} | Export-Csv $ValidationFile
                        }
                    }
                    elseif($Arch -eq '32-bit')
                    {
                        $kb = "Windows6.0-KB2506146-x86.msu"
                        Write-Verbose "Checking update on $hos"
                        $check = Get-HotFix -Id KB2506143 -ComputerName $hos
                        if(!$check)
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Not Found"} | Export-Csv $ValidationFile
                        }
                        else
                        {
                            Write-Output @{l="Server Name";e="$hos"}, @{l="Update Status"; e="Installed Successfully"} | Export-Csv $ValidationFile
                        }
                    }
                }
         }

 }
 
