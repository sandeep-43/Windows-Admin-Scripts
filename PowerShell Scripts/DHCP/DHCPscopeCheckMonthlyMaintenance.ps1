$allservers=Get-Content C:\temp\dhcpservers1.txt
foreach($server in $allservers)
{

    ForEach-Object{ Get-DhcpServerv4Scope -ComputerName $server | select-object ScopeId | Get-DhcpServerv4ScopeStatistics -cn $server | select @{l="Server";e={$server}}, @{l="Scope";e="ScopeID"}, @{l="Total IP Addresses";e={($_.Free) + ($_.InUse)}} , @{l="In Use IP Addresses";e="InUse"},  @{l="Free IP Addresses";e={$_.free}}, @{l="%age Used";e="PercentageInUse"}  ,  @{l="%age Free";e={100 -($_.PercentageInUse)}} | export-csv C:\temp\dhcpresults.csv -Append -NoTypeInformation  }

}
