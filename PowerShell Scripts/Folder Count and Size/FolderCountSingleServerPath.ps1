Write-Host "Hi ! This Script gives count of folders...`n"

$path=Read-Host "Please enter path for folder count (\\serverFQDN\Drive$) "
Get-ChildItem -path $path  | ?{$_.PSIsContainer -eq 'TRUE'} | measure-object | Select-Object -property count | fl