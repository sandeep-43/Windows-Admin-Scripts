$InputFile ="C:\Temp\Patch Status\Servers.txt"
$OutputFile = "C:\Temp\Patch Status\Output.txt"
$ErrorFile = "C:\Temp\Patch Status\ErrorServer.txt"

$computers = Get-Content $InputFile

foreach($computer in $computers)
{
    if(Test-Connection $computer -Count 1)
    { 
        Get-HotFix -ComputerName $computer -Verbose | Sort-Object InstalledOn | Select-Object -Last 1 | Export-Csv $OutputFile -Append -NoTypeInformation
    }
    else
    {
        Write-Output "Failed to fetch hotfix on $computer" | Out-File $ErrorFile -Append
    }
}