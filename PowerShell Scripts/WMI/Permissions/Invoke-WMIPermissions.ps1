$InputFile ="C:\temp\NA-servers.txt"
#$ScriptPath = "$env:USERPROFILE\Documents"
$LogFile = "C:\temp\NA_LogFile.txt"

$computers= Get-Content $InputFile
foreach($computer in $computers)
{
    $date=Get-Date
    if(Test-Connection $computer -Count 1)
    { 
        try
        {
            .\Set-WmiNamespaceSecurity_v2.ps1 -namespace root -operation add -account "SERVER\Performance Monitor users" –permissions Enable,MethodExecute,RemoteAccess,ReadSecurity -computerName $computer
            Write-Output "[$date] WMI permissions have been set on $computer" | Out-File $LogFile -Append
        }
        catch
        {
            Write-Output "[$date] Error while setting WMI permissions on $computer" | Out-File $LogFile -Append
        }
    }
    else
    {
        
        Write-Output "[$date] Failed to connect to $computer" | Out-File $LogFile -Append
    }
}