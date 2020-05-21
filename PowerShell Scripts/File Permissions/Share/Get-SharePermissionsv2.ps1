function Get-SharePermissions{

param(
[CmdletBinding()]
[Parameter(Mandatory=$true)]
[string]$ComputerName
)

BEGIN{}

PROCESS{
$shares= Get-WmiObject -Class win32_share -cn $ComputerName
$temp = Get-WmiObject -Class win32_share -cn $computername | Select -ExpandProperty Type #to check type of share

if(($temp -eq '0' ) -or ($temp -eq '2147483648'))
{
    
    foreach($share in $shares.Name)
    {
    
        $sha=Get-WMIObject -Class Win32_LogicalShareSecuritySetting -Filter "name='$Share'"  -ComputerName $computername
        $sha
       # foreach($s in $sha)
       # {
        #    Write-Output $s.Name, $s.Accountname # Out-file C:\Users\ssingh4\Documents\sharepermissions.csv

       # }
    }
    }
}
}

END{}


Get-SharePermissions