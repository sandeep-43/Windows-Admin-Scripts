$ErrorActionPreference='SilentlyContinue'

#A cmdlet is there which can fetch domains also, need to search for that.
$domains="domain1.com","domain2.com","domain3.com","domain4.com","domain5.com"
$OutFile="$env:USERPROFILE\Documents\Workstation_OUs.csv"
$servers= gc $env:USERPROFILE\Documents\servers.txt
foreach ($server in $servers)
{
    foreach($domain in $domains)
    {
        Get-ADComputer -identity $server -server $domain | export-csv $OutFile -Append -NoTypeInformation
    }
}