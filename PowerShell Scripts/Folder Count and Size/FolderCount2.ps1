Write-Host "This script gives count of folders.`n`nPlease place desired folder paths in C:\temp\fileserver.txt in \\serverFFQDN\Drive$ format."
Write-Host "`nPress any key to continue ..."

$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

$list=get-content c:\temp\fileserver.txt
foreach($server in $list)
{
    $count=(Get-ChildItem -path $server  | ?{$_.PSIsContainer -eq 'TRUE'}).count # | measure-object 
   
    $prop =@{
                "Folder Name"=$server
                "Count Of Folders"=$count
            }
    $obj=New-Object -TypeName PSObject -Property $prop
    write-output $obj | select "Folder Name","Count Of Folders" |export-csv c:\temp\FolderCount.csv -Append -notypeinformation

} 

Write-Host "`nResult is in C:\temp\FolderCount.csv"

Write-Host "`nPress any key to exit ..."

$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()