#Get-ADGroupMember "SGJEL-WRC" -server ent.clariant.com | Select-Object Name | Sort-Object name

$users= Get-Content "C:\temp\acl\users.txt"
$DNS= "C:\temp\acl\DistinguishedNames.txt"

#find DN of users and put to a text file
foreach($user in $users)
{
    $dn=(Get-ADUser $user -Server domain1.com:3268).DistinguishedName #| Out-File $DNS -append
    Add-ADGroupMember -identity "SGJEL-EAR" -Members $dn -server domain2.com
}
