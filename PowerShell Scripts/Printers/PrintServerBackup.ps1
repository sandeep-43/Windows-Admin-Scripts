# AUTHOR : Sandeep Singh
# DATE : 20/09/2017
# 
# COMMENT: 
# This script takes backup of print queues and sends a notification email to RSM team.
# For complete information, please read ReadMe.txt file.
#
# ==============================================================================================

$InputFile= "D:\PSbackup\PrintServers.txt"
#$OutputFile = ""
#$ErrorFile = ""
$LogFile = "D:\PSbackup\Print_Server_Backup_Logfile.log"

$Servers = Get-Content $InputFile
$Date = Get-Date
$n=$Null
$m=$Null
$BackedUpServers = $Null
$FailedServers = $Null
Add-Content -Value "[$Date]***********Starting backup of print servers in Latin America*************" -Path $LogFile
Foreach($Server in $Servers)
{
    $Date= Get-Date
    if(Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server)
    {
        $n = 1
        Add-Content -Value "[$Date] $n. Starting backup of $server" -Path $LogFile
        if(Test-Path "D:\PSbackup\Backup\$Server.cab")
        {
            Remove-Item -Path "D:\PSbackup\Backup\$Server.cab"
            $Date= Get-Date
            try
            {
                c:\windows\system32\spool\tools\printbrm.exe -s $Server -b -f "D:\PSbackup\Backup\$Server.cab" | Out-File $LogFile -Append
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
                c:\windows\system32\spool\tools\printbrm.exe -s $Server -b -f "D:\PSbackup\Backup\$Server.cab" | Out-File $LogFile -Append
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

$To= "CHLTU-DL-20000012544@xyz.com"
$Cc="venu.damodaran@xyz.com","narayanrao.vishnumolakala@xyz.com","sandeep.sekhar@xyz.com","sandeep.singh@xyz.com"
$From="ScriptNotification@xyz.com"
$Subject="Print Queues Backup in Latin America | Status Update"

if($FailedServers -eq $Null)
{
$EmailBody="Hi Team,`n
Backup of print queues for the following print servers has been completed :-`n
$BackedUpServers

Backup for all the print servers was successful.

Regards,
Script Notifier"
}

elseif($BackedUpServers -eq $Null)
{
$EmailBody="Hi Team,`n
Backup of print queues for the following print servers has failed :-`n
$FailedServers

Backup for all the print servers was unsuccessful.

Regards,
Script Notifier"
}

else
{
$EmailBody="Hi Team,`n
Backup of print queues for the following print servers has been completed :-`n
$BackedUpServers

`nBackup of print queues for the following print servers has failed :-`n
$FailedServers


Regards,
Script Notifier"
}
Send-MailMessage -to $To -cc $Cc -from $From -Subject $Subject -body $EmailBody -SmtpServer "smtp.xyz.com" 
