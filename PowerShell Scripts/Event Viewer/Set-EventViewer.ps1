$Source = “TestScript.ps1”
$LogName = "System"
$Date = Get-Date
if(-not $sourceExists)
{
    [system.diagnostics.EventLog]::CreateEventSource($Source, $LogName)
}
Write-EventLog -LogName $LogName -Source $Source -EventId 5360 -EntryType Information -Message "This script ran at $Date"
