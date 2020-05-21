$InputFile = Get-Content "$env:USERPROFILE\Documents\servers.txt"
$OutputFile = "$env:USERPROFILE\Documents\Check_Print_Mgmt_Role_ASIA.csv"
$ErrorFile = "$env:USERPROFILE\Documents\Error_File_ASIA.txt"

$Computers= $InputFile
Foreach($Computer in $Computers)
{
    if(Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer)
    {
        $Role= Get-WindowsFeature -ComputerName $Computer -Name Print-Services
    
        if($Role.InstallState -eq 'Installed')
        {
            $prop =  @{
                        "Server"= $Computer;
                        "IsInstalled"= "TRUE"
                       }
        }
        else
        {
            $prop =  @{
                        "Server"= $Computer;
                        "IsInstalled"= "FALSE"
                       }
        }
            $obj=New-Object -TypeName PsObject -Property $prop
           $obj | Select-Object Server, IsInstalled | Export-csv $OutputFile -Append -NoTypeInformation
    }
    else
    {
        Add-Content -Value "$Computer is not accessible" -Path $ErrorFile
    }
}

        