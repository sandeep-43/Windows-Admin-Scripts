#2008 64 bit

$servers=Get-Content $env:USERPROFILE\Documents\WMF\Servers_2008_64bit.txt

foreach($server in $servers)
{
    psexec "\\$server" -u "username" -p "password" wusa "\\$server\c$\Temp\WinUpdate\Windows6.0-KB2506146-x64.msu" /quiet /norestart
}