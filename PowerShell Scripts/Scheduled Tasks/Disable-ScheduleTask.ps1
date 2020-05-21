$InputFile="C:\Temp\Servers.txt"
$Computers = Get-Content $InputFile
$TaskName = "WSUS_Installation_*"
$OutputFile = "C:\Temp\Output_ScheduledTask_SBAServers_v2.csv"

Foreach($Computer in $Computers)
{
    if(Test-Connection $Computer -Count 1)
    {
        $Status = Get-ScheduledTask -CimSession $Computer
        
        if($Status.TaskName -like $TaskName) #Check if task exists
        {
            $ScheduledTaskStatus = Get-ScheduledTask -CimSession $Computer -TaskName $TaskName

            if($ScheduledTaskStatus.State -ne 'Disabled') #Check if task status is Ready
            {
                try
                {
                    Disable-ScheduledTask -CimSession $Computer -TaskName $TaskName
           
                    $prop= @{
                                "Server Name"= $Computer;
                                "Task Status"= "Disabled successfully"
                            }        
                }
                catch
                {
                    $prop= @{
                                "Server Name"= $Computer;
                                "Task Status"= "Error while disabling"
                            } 
                }
            }
            else
            {
                $prop= @{
                            "Server Name"= $Computer;
                            "Task Status"= "Already disabled"
                        }
            }
        }
        else
        {
            $prop= @{
                            "Server Name"= $Computer;
                            "Task Status"= "Task not scheduled"
                    }
        }
    }
    else
    {
        $prop= @{
                        "Server Name"= $Computer;
                        "Task Status"= "Server not reachable"
                }
    }

    $obj = New-Object -TypeName psobject -Property $prop
    Write-Output $obj | Select "Server Name", "Task Status" | Export-csv $OutputFile -Append -NoTypeInformation
}
                    