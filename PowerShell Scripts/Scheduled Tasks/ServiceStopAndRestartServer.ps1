#Script is scheduled to start @00:10 AM from Task Scheduler
#Server should reboot at 00:15 AM 

$Service1 = "wuauserv"
$Service2 = "BITS"
$Status1=Get-service | ?{$_.Name -like $Service1}
$Status2=Get-service | ?{$_.Name -like $Service2} 

if($Status1.Status -eq 'Running'-and $Status2.Status -eq 'Running')
{
    try
    {
        Stop-Service -Name $Service1 
        Stop-Service -Name $Service2
        $EverythingIsFine='TRUE'
    }
    catch
    {
        $EverythingIsFine='FALSE'   #In case the services do not stop properly
    }

    if($EverythingIsFine -eq 'TRUE')
    {
        Restart-Computer -Force
    }
    elseif($EverythingIsFine -eq 'FALSE')
    {
        $Body="Hi Team,`n`nPlease be informed that services didn't stop in timely manner, request you to check manually and proceed with restart.`n`nRegards,`nScript Notifier`n(On Behalf Of Server Team)"
    }
}

elseif($Status1 -eq 'Stopped'-and $Status2 -eq 'Stopped')
{
    Restart-Computer -Force 
}  

else
{
    $Body="Hi Team,`n`nPlease be informed that services didn't stop in timely manner, request you to check manually and proceed with restart.`n`nRegards,`nScript Notifier`n(On Behalf Of Server Team)"
}

$To="sandeep.singh@xyz.com"#,"imran.ahmad@xyz.com","baneeshpal.singh@xyz.com","lalit.mohan@xyz.com","narayanrao.vishnumolakala@xyz.com"
#$Cc=""
$From="ScriptNotification@xyz.com"
$Subject="abc Failed to Restart"
Send-MailMessage -to $To <#-Cc $Cc#> -from $From -Subject $Subject -body $Body -SmtpServer "smtp.xyz.com" 