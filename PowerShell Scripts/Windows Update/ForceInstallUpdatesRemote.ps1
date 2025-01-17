<#
.Synopsis
   	Force Install Updates on Remote Computer
.DESCRIPTION
   	Force Install Updates on Remote Computer using a scheduled task
.EXAMPLE
	InstallUpdates -Computer "server1.contoso.com" -User "Contoso\Administrator" -Password "Password"
.NOTES
   	Version 1.0 - Initial Script
   	Written by Darryl van der Peijl
   	Date: 30.05.2014

   	Use at own risk
#>

Function InstallUpdates {
param($Computer,$User,$Password)

$SecurePassword = ConvertTo-SecureString –String $Password –AsPlainText -Force
$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $User, $SecurePassword

Invoke-Command -ComputerName $Computer -credential $Credential -ScriptBlock {
#Get Date
$DateAndTime = (Get-Date -format ddMMMyyyy-HH.mm)
#Register Scheduled Task with Date
Register-ScheduledJob -Name "InstallUpdates $DateAndTime" -RunNow -ScriptBlock {
#Define update criteria.
$Criteria = "IsInstalled=0 and Type='Software'";`
#Search for relevant updates.
$Searcher = New-Object -ComObject Microsoft.Update.Searcher;`
$SearchResult = $Searcher.Search($Criteria).Updates;`
#Download updates.
$Session = New-Object -ComObject Microsoft.Update.Session;`
$Downloader = $Session.CreateUpdateDownloader();`
$Downloader.Updates = $SearchResult;`
$Downloader.Download();`
#Install updates.
$Installer = New-Object -ComObject Microsoft.Update.Installer;`
$Installer.Updates = $SearchResult;`
#Result -> 2 = Succeeded, 3 = Succeeded with Errors, 4 = Failed, 5 = Aborted
#$Result = $Installer.Install();`

} #End scheduledjob scriptblock
} #End Invoke Scriptlock
} #End Function

