

$path= Read-Host -Prompt "Enter the path where the server list is present"
if($path.length -eq 0)
{
Write-Host "Invalid path"
}
else
{
$text= Write-Host "The path to the file is $path"
$MyFile = Get-content $path 
$time=Read-Host -Prompt "Enter the time duration for the maintenance mode in minutes"
$reason= Read-Host "Enter a reason for maintenance mode"
Write-Host "$reason starts"
$startTime = [DateTime]::Now 
 $endTime = $startTime.AddMinutes($time)
foreach($srv in $MyFile) 
    { 
  $Class = get-SCOMclass | where-object {$_.Name -eq "Microsoft.Windows.Computer"}; 
 $Instance = Get-SCOMClassInstance -Class $Class | Where-Object {$_.name -eq $srv};
 

if($Instance.InMaintenanceMode -eq 1)
{
Write-Host "The server $srv is already in maintenance mode"

}
else
{ 
 Start-SCOMMaintenanceMode -Instance $Instance -Reason "PlannedOther" -EndTime $endTime -Comment "Scheduled SCOM Maintenance Window" 
Write-Host "Putting $srv in maintenance mode" 
 }
 }
}
