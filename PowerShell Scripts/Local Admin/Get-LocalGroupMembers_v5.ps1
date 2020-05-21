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
$InputFile = "$env:USERPROFILE\Documents\servers.txt"
$OutputFile = "$env:USERPROFILE\Documents\CHHC_Local_Admin_Group_Members.csv"

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
                $item.PartComponent –match “.+Domain\=(.+)\,Name\=(.+)$”  > $nul 
                $Member=$matches[1].trim('"') + “\” + $matches[2].trim('"') 
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

$computers = Get-Content $InputFile
foreach($computer in $computers)
{
    Get-LocalGroupMembers -ComputerName $computer | Export-csv $OutputFile -append -NotypeInformation
}
