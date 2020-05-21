#*******************************************************************************************************************
#PS Script to check for space in Recycle Bin and empty the Recycle Bin in case the value exeeds the threshold value*
#*******************************************************************************************************************
#
# Written By : Sandeep Singh
# Date : 18 November 2017
#
#
#


$Threshold = 50 #Please enter threshold value in GB

function Get-RecycleBin 
{
    (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() #|	Select-Object Name,Size,Path 
}


function Clear-RecylceBin
{
    [cmdletbinding(SupportsShouldProcess=$true)]
    param()
    (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | ForEach-Object {Remove-Item -LiteralPath $_.Path -Force -Recurse}
}

$SizeInKB = (Get-RecycleBin | Measure-Object -Property Size -Sum).Sum
$SizeinGB = $SizeInKB / 1GB

if($SizeinGB -gt $Threshold)
{
    Clear-RecycleBin
}

else
{
}