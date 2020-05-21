
$servers = Get-Content Servers.txt

.\Get-IPDetails.ps1 -computername $servers | ft -autosize | Out-file IP-Details.txt

