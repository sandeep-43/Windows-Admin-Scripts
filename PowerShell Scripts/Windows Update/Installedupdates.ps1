$InputObject = Read-host -Prompt "Insert Computername to get list of installed updates"
$Report = @()
$filename = "$env:Temp\Report_$(get-date -Uformat "%Y%m%d-%H%M%S").csv"
$InputObject | % {
   $objSession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Searcher",$_))
   $objSearcher= $objSession.CreateUpdateSearcher()
   $HistoryCount = $objSearcher.GetTotalHistoryCount()
   $colSucessHistory = $objSearcher.QueryHistory(0, $HistoryCount)
   Foreach($objEntry in $colSucessHistory | where {$_.ResultCode -eq '2'}) {
       $pso = "" | select Computer,Title,Date
       $pso.Title = $objEntry.Title
       $pso.Date = $objEntry.Date
       $pso.computer = $_
       $Report += $pso
       }
   $objSession = $null
   }
$Report | where { $_.Title -notlike 'Definition Update*'} | Export-Csv $filename -NoTypeInformation -UseCulture
ii $filename