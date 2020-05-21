# AUTHOR : Sandeep Singh
# DATE : 20/09/2017
# 
# COMMENT: 
# This script takes backup of print queues and sends a notification email to RSM team.
# For complete information, please read ReadMe.txt file.
#
# ==============================================================================================

$InputFile= "D:\DHCP Servers\DHCPServers.txt"
#$OutputFile = ""
#$ErrorFile = ""
$LogFile = "D:\DHCP Servers\DHCP_Server_Backup_Logfile.log"

$Servers = Get-Content $InputFile
$Date = Get-Date
$n=$Null
$m=$Null
$BackedUpServers = $Null
$FailedServers = $Null

Add-Content -Value "[$Date]***********Starting backup of DHCP servers in Latin America*************" -Path $LogFile
Foreach($Server in $Servers)
{
    $Date= Get-Date
    if(Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server)
    {
        $n = 1
        Add-Content -Value "[$Date] $n. Starting backup of $server" -Path $LogFile
        if(Test-Path "D:\DHCP Backup\Backup\DHCPDB_$Server")
        {
            Remove-Item -Path "D:\DHCP Backup\Backup\DHCPDB_$Server"
            $Date= Get-Date
            try
            {
                "D:\DHCP Backup\psexec.exe" \\$Server "\\$Server\C$\DHCP Backup\DHCPBackup.cmd"
                 Copy-Item -Path "\\$Server\C$\DHCP Backup\DHCPDB_$Server" -Destination "D:\DHCP Backup\Backup\DHCPDB_$Server"              
                 Add-Content -Value "[$Date] $n. Backup of $server is completed" -Path $LogFile
            }
            catch
            {
                Add-Content -Value "[$Date] $n. Error while taking backup of $server" -Path $LogFile
            }
        }
        else
        {
           $Date= Get-Date
            try
            {
                "D:\DHCP Backup\psexec.exe" \\$Server "\\$Server\C$\DHCP Backup\DHCPBackup.cmd"
                 Copy-Item -Path "\\$Server\C$\DHCP Backup\DHCPDB_$Server" -Destination "D:\DHCP Backup\Backup\DHCPDB_$Server"              
                 Add-Content -Value "[$Date] $n. Backup of $server is completed" -Path $LogFile
            }
            catch
            {
                Add-Content -Value "[$Date] $n. Error while taking backup of $server" -Path $LogFile
            } 
        }
        $BackedUpServers += "$n. $Server`n"
            $n++
        
     }
    else
    {
        $m=1
        Add-Content -Value "[$Date] $m. Failed to take backup of $server" -Path $LogFile
        $FailedServers += "$m. $Server`n"
        $m++
    }
}
$Date = Get-Date
Add-Content -Value "[$Date]***********Backup of print servers in Latin America has completed*************" -Path $LogFile

$To= "sandeep.singh@xyz.com" #
$From="ScriptNotification@xyz.com"
$Subject="DHCP Backup in Latin America | Status Update"

if($FailedServers -eq $Null)
{
$EmailBody="Hi Team,`n
Backup for the following DHCP servers has been completed :-`n
$BackedUpServers

Backup for all the DHCP servers was successful.

Regards,
Script Notifier"
}

elseif($BackedUpServers -eq $Null)
{
$EmailBody="Hi Team,`n
Backup for the following DHCP servers has failed :-`n
$FailedServers

Backup for all the DHCP servers was unsuccessful.

Regards,
Script Notifier"
}

else
{
$EmailBody="Hi Team,`n
Backup for the following DHCP servers has been completed :-`n
$BackedUpServers

`nBackup for the following DHCP servers has failed :-`n
$FailedServers


Regards,
Script Notifier"
}
Send-MailMessage -to $To -from $From -Subject $Subject -body $EmailBody -SmtpServer "smtp.xyz.com" 
