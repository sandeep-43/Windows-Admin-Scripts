#****************************************************************************************************
# Name : Check-OlderLogsFiles.ps1
# Written By : Sandeep Singh
# Date : 21 November, 2017
# Description : The script checks for log files older that defined threshold value and deletes
#               the files if found older than the thresold.
#               User must provide path of log files folder, path of log file and threshold value.
#****************************************************************************************************
$RootPath = "C:\Temp\Testing2"
$LogFilePath = "C:\Temp\Testing2\New Text Document (2).log"
$Threshold = 10  #Enter number of days here
$f = 0
$Date = Get-Date
Add-Content -Path $LogFilePath -Value "[$Date] *********Checking for log files older than $Threshold days*********"

Foreach ($Path in $RootPath)
{
    $Files = Get-ChildItem -Path $Path -Recurse -Include *.log |?{$_.PSIsContainer -eq $false}
    Foreach ($File in $Files)
    {
        $TimeStamp = (Get-Item -Path $File).LastWriteTime
        $CurrentDate = Get-Date
        $Difference = New-TimeSpan -start $TimeStamp -end $CurrentDate
        if($Difference.Days -ge $Threshold)
        {
            $Date = Get-Date
            Add-Content -Path $LogFilePath -Value "[$Date] Removing file $File"
            Remove-Item $File -Verbose 
            $f++
        }

    }
}
if($f -eq 0)
{
    $Date = Get-Date
    Add-Content -Path $LogFilePath -Value "[$Date] No file(s) older than $Threshold days were found"
}
$Date = Get-Date
Add-Content -Path $LogFilePath -Value "[$Date] *********Script completed*********"