$InputFile= "$env:USERPROFILE\Documents\groups.txt"
$Groups=Get-Content $InputFile
foreach($Group in $Groups)
{
    try
    {
        Remove-ADGroupMember -identity $Group -Members "ptrommen" -confirm:$false -Verbose
    }
    catch
    {
        Write-Output "Error received while removing from Group $Group" | Out-File "$env:USERPROFILE\Documents\Groups_Error.txt" -Append
    }
}