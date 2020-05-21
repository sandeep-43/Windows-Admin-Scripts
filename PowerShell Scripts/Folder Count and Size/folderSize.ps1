#Folder Size
Write-host "Hey! This script gives size of folders"
Write-host ""
Write-host ""
Write-host ""
Write-host ""
Write-host ""
Set-ExecutionPolicy unrestricted -scope CurrentUser

$folders= get-content c:\temp\sharepath.txt
foreach($folder in $folders)
{
    $size=(get-childitem $folder -recurse -force -ErrorAction SilentlyContinue| measure-object -Property length -sum)

    $prop=@{
                'Path'=$folder
                'Size'="{0:N2}" -f ($size.sum / 1MB) + " MB"
    }
    
        $obj=New-Object -TypeName PSObject -Property $prop
        Write-Output $obj | Select Path, Size | export-csv c:\temp\foldersize.csv -append -notypeinformation

}

Write-host "Completed..."
Write-host ""