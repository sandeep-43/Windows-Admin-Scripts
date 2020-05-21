###### to get printer list ####
set-executionpolicy -remotesigned -force
$servers=get-content C:\temp\Printers\printservers.txt
foreach($server in $servers)
{
    gwmi win32_printer -cn $server | select Name, PortName, DriverName, @{l='Server';e={$server}} |
    export-csv "C:\temp\Printers\Printers-$server.csv" -NoTypeInformation
}
