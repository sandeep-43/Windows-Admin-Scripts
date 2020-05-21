## ------------------------------------------------------------------
## PowerShell Script To Automate Windows Update
## Script should be executed with "Administrator" Privilege
## Re-written by Sandeep Singh
## Dated 14 July 2017
## ------------------------------------------------------------------
$LogFile= "C:\Scripts\PS_WindowsUpdate.log"
$Date=Get-Date
Write-Output "[$Date] Starting to execute the script." | Out-File $LogFile -Append
$ErrorActionPreference = "SilentlyContinue"
If ($Error) 
{
	$Error.Clear()
}
#$Today = Get-Date

$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$Session = New-Object -ComObject Microsoft.Update.Session

$Date=Get-Date
Write-Host
Write-Host "Initialising and Checking for Applicable Updates. Please wait ..." -ForeGroundColor "Yellow"
Write-Output "[$Date] Initialising and Checking for Applicable Updates." | Out-File $LogFile -Append

$Result = $Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

If ($Result.Updates.Count -EQ 0) 
{
    $Date=Get-Date
	Write-Host "There are no applicable updates for this computer." -ForegroundColor "Yellow"
    Write-Output "[$Date] There are no applicable updates for this computer." | Out-File $LogFile -Append
}
Else 
{
	#$ReportFile = $Env:ComputerName + "_Report.txt"
	#If (Test-Path $ReportFile) {
    #		Remove-Item $ReportFile
	#}
	#New-Item $ReportFile -Type File -Force -Value "Windows Update Report For Computer: $Env:ComputerName`r`n" | Out-Null
	#Add-Content $ReportFile "Report Created On: $Today`r"
	#Add-Content $ReportFile "==============================================================================`r`n"
	
	#Add-Content $ReportFile "List of Applicable Updates For This Computer`r"
	#Add-Content $ReportFile "------------------------------------------------`r"
	
    $Date=Get-Date
    Write-Host "Preparing List of Applicable Updates For This Computer ..." -ForeGroundColor "Yellow"
    Write-Output "[$Date]Preparing List of Applicable Updates For this Computer"| Out-File $LogFile -Append
    $Date=Get-Date
    Write-Output "[$Date]List of Applicable Updates For This Computer :" | Out-File $LogFile -Append
    
    For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) 
    {
		$DisplayCount = $Counter + 1
    	$Update = $Result.Updates.Item($Counter)
		$UpdateTitle = $Update.Title
		#Add-Content $ReportFile "`t $DisplayCount -- $UpdateTitle"
        Write-Output "$DisplayCount -- $UpdateTitle" | Out-File $LogFile -Append
	}
	$Counter = 0
	$DisplayCount = 0

	#Add-Content $ReportFile "`r`n"
    $Date=Get-Date
	Write-Host "Initialising Download of Applicable Updates ..." -ForegroundColor "Yellow"
	Write-Output "[$Date] Initialising Download of Applicable Updates" | Out-File $LogFile -Append
    #Add-Content $ReportFile "Initialising Download of Applicable Updates"
	#Add-Content $ReportFile "------------------------------------------------`r"
	$Downloader = $Session.CreateUpdateDownloader()
	$UpdatesList = $Result.Updates
	For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) 
    {
        $Date=Get-Date
		$UpdateCollection.Add($UpdatesList.Item($Counter)) | Out-Null
		$ShowThis = $UpdatesList.Item($Counter).Title
		$DisplayCount = $Counter + 1
		#Add-Content $ReportFile "`t $DisplayCount -- Downloading Update $ShowThis `r"
        Write-Output "[$Date] $DisplayCount -- Downloading Update $ShowThis " | Out-File $LogFile -Append
		$Downloader.Updates = $UpdateCollection
		$Track = $Downloader.Download()
        $Date=Get-Date
		If (($Track.HResult -EQ 0) -AND ($Track.ResultCode -EQ 2)) 
        {
			#Add-Content $ReportFile "`t Download Status: SUCCESS"
            Write-Output "[$Date] Download Status: SUCCESS" | Out-File $LogFile -Append
		}
		Else 
        {
			#Add-Content $ReportFile "`t Download Status: FAILED With Error -- $Error()"
            Write-Output "[$Date] Download Status: FAILED With Error -- $Error()" | Out-File $LogFile -Append
			$Error.Clear()
			#Add-content $ReportFile "`r"
		}	
	}

	$Counter = 0
	$DisplayCount = 0
    $Date=Get-Date
	Write-Host "Starting Installation of Downloaded Updates ..." -ForegroundColor "Yellow"
    Write-Output "[$Date] Starting Installation of Downloaded Updates" | Out-File $LogFile -Append
	#Add-Content $ReportFile "`r`n"
	#Add-Content $ReportFile "Installation of Downloaded Updates"
	#Add-Content $ReportFile "------------------------------------------------`r"
	$Installer = New-Object -ComObject Microsoft.Update.Installer
	For ($Counter = 0; $Counter -LT $UpdateCollection.Count; $Counter++) 
    {
        $Date=Get-Date
		$Track = $Null
		$DisplayCount = $Counter + 1
		$WriteThis = $UpdateCollection.Item($Counter).Title
		#Add-Content $ReportFile "`t $DisplayCount -- Installing Update: $WriteThis"
        Write-Output "[$Date] $DisplayCount -- Installing Update: $WriteThis" | Out-File $LogFile -Append
		$Installer.Updates = $UpdateCollection
        
		Try 
        {
			$Date=Get-Date
            $Track = $Installer.Install()
			#Add-Content $ReportFile "`t Update Installation Status: SUCCESS"
            Write-Output "[$Date] Update Installation Status: SUCCESS" | Out-File $LogFile -Append
		}
		Catch 
        {
            $Date=Get-Date
			[System.Exception]
			#Add-Content $ReportFile "`t Update Installation Status: FAILED With Error -- $Error()"
            Write-Output "[$Date] Update Installation Status: FAILED With Error -- $Error()" | Out-File $LogFile -Append
			$Error.Clear()
			#Add-content $ReportFile "`r"
		}	
	}
}