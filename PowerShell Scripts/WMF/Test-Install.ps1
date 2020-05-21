# copy msu from s to d
Invoke-Command -ComputerName 


$hotfixes = get-childitem -path "$env:USERPROFILE\Documents\New folder" -include *.msu -recurse
foreach ($hotfix in $hotfixes) {

start-process wusa.exe -ArgumentList { <#"/quiet", #> "/norestart","$hotfix" } # -wait
}

C:\Windows\System32\wusa.exe