$allservers = Get-Content "C:\temp\dhcpservers_asia.txt"

foreach($server in $allservers)
{
  $scopes= Get-DhcpServerv4Scope -ComputerName $server 
  foreach($scope in $scopes.ScopeID)
  {
        $Statistics= Get-DhcpServerv4ScopeStatistics -ScopeId $scope -ComputerName $server
        $Stats= Get-DhcpServerv4Scope -ScopeId $scope -ComputerName $server
        $prop=@{
                    "DHCP Server" = $server
                    "Scope IP Address"=$scope
                    "Scope Name"=$Stats.Name
                    "Subnet"=$Stats.SubnetMask
                    "Scope State"=$Stats.State
                    "SuperScope Name"=$Stats.SuperscopeName
                    "Starting IP Address"=$Stats.StartRange
                    "Last IP Address"=$Stats.EndRange
                    "Total IP Addresses" = ($Statistics.Free) + ($Statistics.InUse)
                    "In Use IP Addresses"=$Statistics.InUse
                    "Free IP Addresses"=$Statistics.Free
                    "%age Used"=$Statistics.PercentageinUse
                    "%age Free"=(100 - $Statistics.PercentageInUse)
                    "Reserved IP Addresses"=$statistics.ReservedAddress
                    
                    
                }     

    
   $obj=New-Object -TypeName PSobject -Property $prop
   write-output $obj | Select-Object "DHCP Server", "Scope Name", "SuperScope Name","Scope State", "Scope IP Address", "Subnet",
   "Total IP Addresses", "In Use IP Addresses", "Free IP Addresses", "%age Used", "%age Free", "Reserved IP Addresses",
   "Starting IP Address", "Last IP Address" | export-csv "c:\temp\DHCPResults_Asia_Feb2017.csv" -Append -notypeinformation
  }
}