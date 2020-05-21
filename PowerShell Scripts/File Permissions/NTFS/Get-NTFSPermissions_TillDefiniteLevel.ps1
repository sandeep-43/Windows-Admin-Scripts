$ErrorActionPreference="SilentlyContinue"
New-Item -ItemType directory -Path C:\Temp -ErrorAction SilentlyContinue
New-Item -ItemType directory -Path C:\Temp\NTFS-Permissions -ErrorAction SilentlyContinue
$date=(Get-Date -Format "dd-MM-yyyy---HH-mm")
$OutFile = "C:\Temp\NTFS-Permissions\NTFS_Permissions_ServerName_$date.csv"

Function Get-ChildItemToDepth {
        Param(
                [CmdletBinding()]
                [Parameter(Mandatory=$True, HelpMessage="Enter path in \\<Server-name>\<share-name>")]
                [String]$Path,

                [String]$Filter = "*",
                
                [Parameter(Mandatory=$True, HelpMessage="Enter the levels required to be parsed")]
                [Byte]$ToDepth,

                [Byte]$CurrentDepth
             )
             
             if(Test-Path $Path)
             {
                    $CurrentDepth++

                    Get-ChildItem $Path -Filter $Filter | ?{ $_.PsIsContainer } | 
                    %{$Path = $_.FullName  
                    (Get-Acl $Path).Access | Select-Object @{n='Path';e={ $Path }}, IdentityReference, AccessControlType, FileSystemRights, IsInherited
                
                        If ($_.PsIsContainer) 
                        {
                            If ($CurrentDepth -le $ToDepth) 
                            {

                                # Callback to this function
                                Get-ChildItemToDepth -Path $_.FullName -Filter $Filter -ToDepth $ToDepth -CurrentDepth $CurrentDepth
                            }
                        }
                      }
                      
             }

             else
             {
                    Write-Warning "Path does not exist"

             }
             
}
get-childitemtodepth | Export-CSV $OutFile -NoTypeInformation

(Get-Content $OutFile) | Foreach-Object {$_ -replace ", Synchronize", ""} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "268435456", "FullControl"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-536805376", "ReadWriteExecuteDelete"} | Set-Content $OutFile
(Get-Content $OutFile) | Foreach-Object {$_ -replace "-1610612736", "ReadAndExecuteExtended"} | Set-Content $OutFile


Write-Host "`nScript completed... Press any key to exit !!!"
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()