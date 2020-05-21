
$HomeFolders = Get-ChildItem F:\Users
foreach ($HomeFolder in $HomeFolders) {
    $Path = $HomeFolder.FullName
    #$Path="$env:USERPROFILE\Documents"
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $HomeFolder.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}