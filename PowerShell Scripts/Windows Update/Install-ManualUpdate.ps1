$Hosts = Get-Content -Path "$env:USERPROFILE\Documents\servers.txt" #"Path of the text file containing server names" 

$user = '' #'DomainName\username'
$pass = '' #'Password'
#$psexec = "$env:USERPROFILE\Documents\Modules\PSTools\PsExec.exe"   #Use this variable if psexec.exe is placed anywhere accept 'C:\windows\system32'
 
foreach ($hos in $Hosts) 
{
    
     $sysinfo= gwmi win32_operatingsystem -ComputerName $hos
     $Flavor= $sysinfo.Caption
     $Arch= $sysinfo.OsArchitecture

     if($Flavor -eq "Microsoft Windows Server 2008 R2*")
        {
            if($Arch -eq '64-bit')
            {
                $kb = "Windows6.1-KB2506143-x64.msu"
                $update = "\\$hos\C$\Temp\WinUpdate\$kb"
                psexec \\$hos -u $user -p $pass -i -d -s wusa /install $update /quiet /norestart 
            }
            elseif($Arch -eq '32-bit')
            {
                $kb = "Windows6.1-KB2506143-x86.msu"
                $update = "\\$hos\C$\Temp\WinUpdate\$kb"
                psexec \\$hos -u $user -p $pass -i -d -s wusa /install $update /quiet /norestart 
            }
        }
     else #Microsoft Windows Server 2008
        {
            if($arch -eq '64-bit')
            {
                $kb = "Windows6.0-KB2506146-x64.msu"
                $update = "\\$hos\C$\Temp\WinUpdate\$kb"
                psexec \\$hos -u $user -p $pass -i -d -s wusa /install $update /quiet /norestart 
            }
            elseif($Arch -eq '32-bit')
            {
                 $kb = "Windows6.0-KB2506146-x86.msu"
                $update = "\\$hos\C$\Temp\WinUpdate\$kb"
                psexec \\$hos -u $user -p $pass -i -d -s wusa /install $update /quiet /norestart 
            }
        }
}


#•Windows Server 2008 R2 SP1 
#•64-bit versions: Windows6.1-KB2506143-x64.msu

#•Windows Server 2008 Service Pack 2 
#•64-bit versions: Windows6.0-KB2506146-x64.msu
#•32-bit versions: Windows6.0-KB2506146-x86.msu


