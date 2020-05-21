$folder = "F:\H3"
$acls=Get-acl $folder
$folder2="F:\Hello"

$acls.Access | ft

$perm= @{
            FileSystemRights= "FullControl"
AccessControlType = "Allow"
IdentityReference = "BUILTIN\Administrators"
IsInherited       = "False"
InheritanceFlags  = "None"
PropagationFlags  = "None"
}

Set-Acl  -Path $folder2 -AclObject $acls
#foreach($acl in $acls)
#{

Get-acl $folder2