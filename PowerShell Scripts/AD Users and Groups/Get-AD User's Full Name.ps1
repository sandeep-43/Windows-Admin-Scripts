## To find username

$users=gc $env:USERPROFILE\Documents\users.txt
foreach($user in $users)
{
    try
    {
    Get-ADUser -Identity $user -server domain.com | select @{l="Full Name";e={$_.GivenName+" "+$_.Surname}} #| out-file $env:USERPROFILE\Documents\Users_Result.txt -Append
    }

    catch
    {
        Write-Output "Not found"  #| out-file $env:USERPROFILE\Documents\Users_Result.txt -Append
    }
}