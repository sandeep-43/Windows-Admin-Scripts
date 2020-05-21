$InputFile = "$env:USERPROFILE\xyz\CriticalGroups.txt"
$CurrentFolder = "$env:USERPROFILE\xyz\CurrentStatus"
$PreviousFolder = "$env:USERPROFILE\xyz\PreviousStatus"
$LogFile = "$env:USERPROFILE\xyz\LogFile.log"
$ChangeDetected = $false

$Groups = Get-Content $InputFile
$Domains = (Get-ADForest).domains

#Fetching current members in critical groups mentioned in input file

Foreach($Group in $Groups)
{
    
    Add-Content -Value "[$(Get-Date)] Fetching current members of group [$Group]" -Path $LogFile
    Foreach($Domain in $Domains)
    {
        if(Get-ADGroupMember -Identity $Group -Server $Domain) #Checking domain of the critical group
        {
            $Dom = $Domain
        }
    }    
    $CurrentMembers_Temp = (Get-ADGroupMember -Identity $Group -Server $Dom).Name 
    if(! $CurrentMembers_Temp)
    {
        Add-Content -Value "[$(Get-Date)] No members found in the [$Group] group." -Path $LogFile
    }
    else
    {
        Add-Content -Value "[$(Get-Date)] Found [$($CurrentMembers.Count)] members in the [$Group] group" -Path $LogFile
        $CurrentMembers_Temp | Out-File "$CurrentFolder\$Group.txt"
    }
    
}

#Comparing the membership and detecting the change!!!
    
Foreach($Group in $Groups)
{
    if(Test-Path -Path "$PreviousFolder\$Group.txt")
    {
        $PreviousMembers = Get-Content "$PreviousFolder\$Group.txt"
        $CurrentMembers = Get-Content "$CurrentFolder\$Group.txt"
    
        $ComparedMembers = Compare-Object -ReferenceObject $PreviousMembers -DifferenceObject $CurrentMembers 
        if (-not $ComparedMembers) 
        { 
            $FinalRemovedMembers = "NIL"
            $FinalAddedMembers = "NIL"
            Add-Content -Value "[$(Get-Date)] No difference(s) found in group [$Group]" -Path $LogFile 
        } 
        else 
        {
            $ChangeDetected = $true
            $RemovedMembers = ($ComparedMembers |  Where-Object { $_.SideIndicator -eq '<=' }).InputObject 
            if (-not $RemovedMembers) 
            { 
                $FinalRemovedMembers = "NIL"
                Add-Content -Value "[$(Get-Date)] No members have been removed from group [$Group] since last check" -Path $LogFile
            } 
            else 
            { 
            
                Add-Content -Value "[$(Get-Date)] Found [$($RemovedMembers.Count)] members that have been removed since last check" -Path $LogFile
                $TempRemovedMembers += "$RemovedMembers, "
                $FinalRemovedMembers = $TempRemovedMembers.TrimEnd(", ")
            } 
        
            $AddedMembers = ($ComparedMembers |  Where-Object { $_.SideIndicator -eq '=>' }).InputObject 
            if (-not $AddedMembers) 
            { 
                $FinalAddedMembers = "NIL"
                Add-Content -Value "[$(Get-Date)] No members have been added in group [$Group] since last check" -Path $LogFile
            } 
            else 
            { 
                Add-Content -Value "[$(Get-Date)] Found [$($AddedMembers.Count)] members that have been added in group [$Group] since last check" -Path $LogFile
                $TempAddedMembers += "$AddedMembers, "
                $FinalAddedMembers = $TempAddedMembers.TrimEnd(", ")
            }
        }
        #Replace the old file with new one
        Copy-Item -Path "$CurrentFolder\$Group.txt" -Destination "$PreviousFolder\$Group.txt" -Force
    
        $prop = @{
                    "Group Name "= $Group
                    "Change In Membership Detected" = $ChangeDetected
                    "Members Added" = $FinalAddedMembers
                    "Members Removed" = $FinalRemovedMembers
             }
    }
    else
    {
        Add-Content -Value "[$(Get-Date) The file [$PreviousFolder\$Group.txt] does not exist yet. This must be the first run. Dumping all members into it..." -Path $LogFile
        Copy-Item -Path "$CurrentFolder\$Group.txt" -Destination "$PreviousFolder\$Group.txt" -Force
        $prop = @{
                    "Group Name "= $Group
                    "Change In Membership Detected" = "First Run"
                    "Members Added" = "First Run"
                    "Members Removed" = "First Run"
             }
    }

    $Obj = New-Object -TypeName psobject -Property $prop
}
$Object = $Obj | Select "Group Name", "Change In Membership Detected", "Members Added", "Members Removed"
$Object

<#
.SYNOPSIS
Send an email with an object in a pretty table
.DESCRIPTION
Send email
.PARAMETER InputObject
Any PSOBJECT or other Table
.PARAMETER Subject
The Subject of the email
.PARAMETER To
The To field is who receives the email
.PARAMETER From
The From address of the email
.PARAMETER CSS
This is the Cascading Style Sheet that will be used to Style the table
.PARAMETER SmtpServer
The SMTP relay server
.EXAMPLE
PS C:\> Send-HtmlEmail -InputObject (Get-process *vmware* | select CPU, WS) -Subject "This is a process report"
An example to send some process information to email recipient
.NOTES
NAME        :  Send-HtmlEmail
VERSION     :  1.1.0   
LAST UPDATED:  01/03/2013
AUTHOR      :  Milo
.INPUTS
None
.OUTPUTS
None
#> 

function Send-HTMLEmail {
#Requires -Version 2.0
[CmdletBinding()]
 Param 
   ([Parameter(Mandatory=$True,
               Position = 0,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Please enter the Inputobject")]
    $InputObject,
    [Parameter(Mandatory=$True,
               Position = 1,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Please enter the Subject")]
    [String]$Subject,    
    [Parameter(Mandatory=$False,
               Position = 2,
               HelpMessage="Please enter the To address")]    
    [String[]]$To = "user@domain.com",
    [String]$From = "Admin@domain.com",    
    [String]$CSS,
    [String]$SmtpServer ="smtprelay.domain.com"
   )#End Param

if (!$CSS)
{
    $CSS = @"
        <style type="text/css">
            table {
    	    font-family: Verdana;
    	    border-style: dashed;
    	    border-width: 1px;
    	    border-color: #FF6600;
    	    padding: 5px;
    	    background-color: #FFFFCC;
    	    table-layout: auto;
    	    text-align: center;
    	    font-size: 8pt;
            }

            table th {
    	    border-bottom-style: solid;
    	    border-bottom-width: 1px;
            font: bold
            }
            table td {
    	    border-top-style: solid;
    	    border-top-width: 1px;
            }
            .style1 {
            font-family: Courier New, Courier, monospace;
            font-weight:bold;
            font-size:small;
            }
            </style>
"@
}#End if

$HTMLDetails = @{
    Title = $Subject
    Head = $CSS
    }
    
$Splat = @{
    To         =$To
    Body       ="Hi Team,<br><br>Please find the report for change detection of critical RSM/DC groups below :<br><br>$($InputObject | ConvertTo-Html @HTMLDetails) <br>Regards,<br>Script Administrator"
    Subject    =$Subject
    SmtpServer =$SmtpServer
    From       =$From
    BodyAsHtml =$True
    }
    Send-MailMessage @Splat
    
}#

#$abc = Get-Service
Send-HTMLEmail -InputObject $Object -To "Sandeep.singh@xyz.com" -Subject TestEmail -SmtpServer smtp.xyz.com -From ScriptNotification@xyz.com 