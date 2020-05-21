$Computers = Get-Content "C:\temp\servers.txt"
$OutputFile = "C:\temp\Output.txt"
$errorAction='SilentlyContinue'
foreach($computer in $computers)
{
    if(Test-Connection $computer -Count 1 -ErrorAction SilentlyContinue)
    {
        gwmi win32_networkadapterconfiguration -ComputerName $computer -ErrorAction SilentlyContinue| ?{$_.IPEnabled -eq 'TRUE'} | Select PSComputerName, DNSServerSearchOrder #| out-file $OutputFile -Append
    }
    else
    {
        Write-Output $computer | Out-File c:\temp\errorDNS.txt -Append
    }
}

