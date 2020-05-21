#Folder Size
$ErrorActionPreference='SilentlyContinue'
Set-ExecutionPolicy unrestricted -scope CurrentUser
Write-host ""
Write-host ""
Write-host "Hey! This script gives size of folders"
Write-host ""
Write-host ""
Write-host ""

$startdate=get-date
$folders= get-content c:\temp\sharepath.txt
foreach($folder in $folders)
{
    $size=(get-childitem $folder -recurse -force -ErrorVariable err| measure-object -Property length -sum)
    if($err -like "*Cannot find path*")
    {
        $prop=@{
                    'Path'=$folder
                    'Size'="Incorrect Server or HS"
                }
    }
    else
    {
        $prop=@{
                    'Path'=$folder
                    'Size'="{0:N2}" -f ($size.sum / 1MB) + " MB"
               }
     }
    
        $obj=New-Object -TypeName PSObject -Property $prop
        Write-Output $obj | Select Path, Size | export-csv c:\temp\foldersizeNA.csv -append -notypeinformation
     
}

$enddate= get-date
$diff=new-timespan -start $startdate -end $enddate | out-file c:\temp\TimeTaken.txt
Write-host "Completed...Press any key to EXIT"


$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()