#to calculate warranty remaining and send email notification for the same from an excel file

$rows= import-csv C:\temp\warrantyStatus.csv
$localtime=get-date
foreach($row in $rows)
{
    $warranty= $row.lastdate
    $difference=new-timespan -start $localtime -end $warranty
    if($difference.Days -lt 0)
    {
        $body = "Warranty Expired for $($row.Name)"
    }
    elseif ($difference.Days -eq 0)
    {
        $body= "Warranty of $($row.name) expired today"
    }
    elseif ($difference.Days -le 7 -and $difference -gt 0)
    {
        $body= "Warranty of $($row.name) is expiring this week"
    }
    $body | out-file C:\temp\warrantyresult.txt -Append
}
$EmailBody= gc C:\temp\warrantyresult.txt
Send-MailMessage -to "abc@xyz.com"  -from "ScriptNotificatio@xyz.com" -Subject "Out Of Warranty Status" -SmtpServer "smtp.xyz.com" -attachments "C:\temp\warrantyresult.txt"
Remove-Item C:\temp\warrantyresult.txt

   