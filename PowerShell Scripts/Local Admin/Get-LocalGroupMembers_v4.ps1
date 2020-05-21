# ==============================================================================================
# 
# NAME: Get-LocalGroupMembers
# 
# AUTHOR: Ben Baird
# DATE  : 8/12/2011

# Re-written by : Sandeep Singh
# DATE : 25/08/2017
# 
# COMMENT: 
# Given a machine name, retrieves a list of members in
# the specified group.
# ==============================================================================================
$InputFile = Get-Content "$env:USERPROFILE\Documents\servers.txt"
$OutputFile = "$env:USERPROFILE\Documents\Temp2.csv"
$ErrorFile = "$env:USERPROFILE\Documents\Error File for Local Admin.txt"

function Get-LocalGroupMembers
{
	param(
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[Alias("Name")]
		[string]$ComputerName,
		[string]$GroupName = "Administrators"
	)
	
	begin {}
	
	process
	{
		# If the account name of the computer object was passed in, it will
		# end with a $. Get rid of it so it doesn't screw up the WMI query.
		$ComputerName = $ComputerName.Replace("`$", '')

		# Initialize an array to hold the results of our query.
		$arr = @()

		$wmi = Get-WmiObject -ComputerName $ComputerName -Query `
			"SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$GroupName'`""

		# Parse out the username from each result and append it to the array.
		if ($wmi -ne $null)
		{
			foreach ($item in $wmi)
			{
		#		$arr += ($item.PartComponent.Substring($item.PartComponent.IndexOf(',') + 1).Replace('Name=', '').Replace("`"", ''))
                $Member= ($item.PartComponent -split '=')[2].trim()
                $Member
                $Member = $Member.REPLACE("""","")
                $hash = @{
                            ComputerName=$ComputerName;
                            Members=$Member
                          }
                $obj=New-Object -TypeName PSobject -Property $hash
                    write-output $obj 
			}
		}

#	 
#		
	}
	
	end{}
}

$computers = $InputFile
foreach($computer in $computers)
{
    if(gwmi win32_operatingsystem -cn $computer)
    {
        Get-LocalGroupMembers -ComputerName $computer <#| Out-File $OutputFile -append #> | Export-csv $OutputFile -append -NotypeInformation
    }
    else
    {
        Add-Content -Value "$computer is not accessible" -Path $ErrorFile 
    }
}
