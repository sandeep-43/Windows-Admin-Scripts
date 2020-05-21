#PS Script to change DNS IP's remotely

$Inputfile = "C:\temp\servers.txt"
$dnsservers =@("10.187.14.11","10.187.11.11","10.187.20.11","10.187.14.12")
$LogFile = "C:\temp\DNSLogFile.txt"

$computers = Get-Content $Inputfile
foreach($computer in $computers)
{
    if(Test-Connection $computer)
    {
        $DNSlist = $(get-wmiobject win32_networkadapterconfiguration -ComputerName $computer | where-object {$_.IPEnabled -eq "TRUE"}).dnsserversearchorder 
    #$priDNS = $DNSlist | select-object -first 1 
        Write-Output "Current DNS entries for $computer are $DNSlist" | Out-File $LogFile -Append
        Write-host "Changing DNS IP's on $computer" -b "Yellow" -foregroundcolor "black" 
        $change = get-wmiobject win32_networkadapterconfiguration -ComputerName $computer | where-object {$_.IPEnabled -eq "TRUE"} 
        $change.SetDNSServerSearchOrder($DNSservers) | out-null 
        $changes = $(get-wmiobject win32_networkadapterconfiguration -ComputerName $computer | where-object {$_.IPEnabled -eq "TRUE"}).dnsserversearchorder 
        Write-output "DNS entries for $computer have been changed to $changes" | Out-File $LogFile -Append
        Write-Output "------------------------------------" | Out-File $LogFile -Append
        Write-Warning "DNS IP's on $computer have been changed"
    }
    else
    {
        Write-Warning "$computer is not reachable"
        Write-Output "$computer is not reachable" | Out-File $LogFile -Append
        Write-Output "------------------------------------" | Out-File $LogFile -Append
    }
}