###################################################################
## Objective  : PS Script to fetch BitLocker Information
## Written by : Sandeep Singh
## Dated      : 27 July 2017
###################################################################


$InputFile = "$env:USERPROFILE\Documents\Computers.txt"
$OutputFile = "$env:USERPROFILE\Documents\BitLocker_Output.csv"

function getBitInfo  # To format output of manage-bde.exe
{
    BEGIN
    {
        #Build the base object
        $bitObj = New-Object -TypeName PSObject -Property @{ComputerName="";LockStatus="";Size="";BitLockerVersion="";ConversionStatus="";PercentageEncrypted="";EncryptionMethod="";ProtectionStatus="";IdentificationField="";KeyProtectors=""}

    }
    PROCESS
    {
        #If the line contains the name, pull it out and store it
        if($_ -match 'Computer Name')
        {
            $name = ($_ -split ":")[1].trim()
            $bitObj.ComputerName = $name
        }

        #If the line contains the status pull that out.
        if($_ -match 'Lock Status:')
        {
            $status = ($_ -split ":")[1].trim()
            $bitObj.LockStatus = $status
        }

        if($_ -match 'Size:')
        {
            $size = ($_ -split ":")[1].trim()
            $bitObj.Size = $size
        }

        
        if($_ -match 'BitLocker Version:')
        {
            $BitLockerVersion = ($_ -split ":")[1].trim()
            $bitObj.BitLockerVersion = $BitLockerVersion
        }

        if($_ -match 'Conversion Status:')
        {
            $ConversionStatus = ($_ -split ":")[1].trim()
            $bitObj.ConversionStatus = $ConversionStatus
        }

        if($_ -match 'Percentage Encrypted:')
        {
            $PercentageEncrypted = ($_ -split ":")[1].trim()
            $bitObj.PercentageEncrypted = $PercentageEncrypted
        }

        if($_ -match 'Encryption Method:')
        {
            $EncryptionMethod = ($_ -split ":")[1].trim()
            $bitObj.EncryptionMethod = $EncryptionMethod
        }

        if($_ -match 'Protection Status:')
        {
            $ProtectionStatus = ($_ -split ":")[1].trim()
            $bitObj.ProtectionStatus = $ProtectionStatus
        }

        if($_ -match 'Identification Field:')
        {
            $IdentificationField = ($_ -split ":")[1].trim()
            $bitObj.IdentificationField = $IdentificationField
        }
        
        if($_ -match 'Error:')
        {
            $bitObj.LockStatus = "Error"
            $bitObj.Size = "Error"
            $bitObj.BitLockerVersion = "Error"
            $bitObj.ConversionStatus = "Error"
            $bitObj.PercentageEncrypted = "Error"
            $bitObj.EncryptionMethod = "Error"
            $bitObj.ProtectionStatus = "Error"
            $bitObj.IdentificationField = "Error"
            $bitObj.KeyProtectors = "Error"
            

            
        }
    }
    END
    {
        #write out the completed object
        Write-Output $bitObj | Select ComputerName,LockStatus,Size,BitLockerVersion,ConversionStatus,PercentageEncrypted,EncryptionMethod,ProtectionStatus,IdentificationField ,KeyProtectors
    }
}

$computers = Get-Content $InputFile
foreach($computer in $computers)
{
    manage-bde.exe -status c: -computername $computer | getBitInfo | Export-csv $OutputFile -Append -NoTypeInformation
}