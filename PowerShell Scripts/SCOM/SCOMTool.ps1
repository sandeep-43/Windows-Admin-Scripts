﻿######### Muliple Servers In MM #######
######### Written by Sandeep Singh #######
######### Date : 15 July 2017 #######

[void][Reflection.Assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')




function Main {
	Param ([String]$Commandline)
	if((Call-MainForm_psf) -eq 'OK')
	{
		
	}
	
	$global:ExitCode = 0 #Set the exit code for the Packager
}



#region Source: MainForm.psf
function Call-MainForm_psf
{
	
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	
    
    [System.Windows.Forms.Application]::EnableVisualStyles()
	$MainForm = New-Object 'System.Windows.Forms.Form'
	$timebox = New-Object 'System.Windows.Forms.TextBox'
	$labelSandeepSingh = New-Object 'System.Windows.Forms.Label'
	$reasonbox = New-Object 'System.Windows.Forms.TextBox'
	$pathbox = New-Object 'System.Windows.Forms.TextBox'
	$buttonClear = New-Object 'System.Windows.Forms.Button'
	$buttonStartMaintenanceMode = New-Object 'System.Windows.Forms.Button'
	$labelReason = New-Object 'System.Windows.Forms.Label'
	$labelTimemin = New-Object 'System.Windows.Forms.Label'
	$labelEnterFilePath = New-Object 'System.Windows.Forms.Label'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	
	
	$MainForm_Load={
	}
	
	$pathbox_TextChanged={
	}
	
	$timebox_TextChanged = {
	}
	
	$reasonbox_TextChanged = {
	}
	
    $buttonStartMaintenanceMode_Click= {
		
		$check = Test-Path "C:\SCOM"		
		If ($check -eq $false)
		{
			New-Item "C:\SCOM" -type directory
		}
		
		$check2 = Test-Path $pathbox.Text
		if ($check2 -eq $false)
		{
			[void][System.Windows.Forms.MessageBox]::Show('Incorrect File Name or File Location', 'Alert')
		}
		else
		{
			if ($pathbox.Text -ne '' -and $timebox.Text -ne '')
			{
				$filepaths = Get-Content $pathbox.Text
				$time = $timebox.Text
				$starttime = Get-Date
				$endtime = $startTime.AddMinutes($time)
                $OutputFile= "\\clarianteu\dfs\Business Services\IT\ITOperation-Teams (DESZ)\SaS\04 ToolPoint\SCOM_MM\Logs\SCOM_MM_logs.log"

                Import-Module OperationsManager #"\\deszmfs2.clarianteu.en.clariant.com\IT\ITOperation-Teams\SaS\04 ToolPoint\SCOM_MM\OperationsManager\operationsmanager.psd1"
                New-SCOMManagementGroupConnection CHHCMOMG.ent.clariant.com

                $user=$env:username
				foreach ($server in $filepaths)
				{
					
					$currenttime=Get-Date
                    $Instances = Get-SCOMClassInstance -name $server;
                    foreach($Instance in $Instances)
                    {
                        if($Instance.InMaintenanceMode -eq 1)
                        {
                            $answer = [System.Windows.Forms.MessageBox]::Show("The server $server is already in maintenance mode, do you want to extend the maintenance mode?",'Alert','YesNo','Error')
                            if($answer -eq 'Yes' )
                            {
                                
                                $MMEntry = Get-SCOMMaintenanceMode -Instance $Instance
                                Set-SCOMMaintenanceMode -MaintenanceModeEntry $MMEntry -EndTime $endTime 
                                #Start-SCOMMaintenanceMode -Instance $Instance -Reason "PlannedOther" -EndTime $endTime -Comment $reasonbox.Text
					            Write-Output "[$(Get-Date)] - Maintenance Mode extended for $server by user : $user by $time minutes"  | Out-File $OutputFile -Append
                            }
                            else
                            {
                                [void][System.Windows.Forms.MessageBox]::Show('Skipping to next server', 'Alert')
                                Write-Output "[$(Get-Date)] - Maintenance Mode already started for $server , user : $user chose to skip extending the manitenance mode time"  | Out-File $OutputFile -Append
                            }
				        }
                        else
                        {
					        Start-SCOMMaintenanceMode -Instance $Instance -Reason "PlannedOther" -EndTime $endTime -Comment $reasonbox.Text
					        Write-Output "[$(Get-Date)] - Maintenance Mode started for $server by user : $user for $time minutes"  | Out-File $OutputFile -Append
                        }
                    }
				}
				
				[void][System.Windows.Forms.MessageBox]::Show('Maintenance Mode Started', 'Alert')
			}
			else
			{
				if ($pathbox.Text -eq '')
				{
					[void][System.Windows.Forms.MessageBox]::Show('Enter File Path', 'Alert') 
				}
				elseif ($timebox.Text -eq '')
				{
					[void][System.Windows.Forms.MessageBox]::Show('Enter Time (in Minutes)', 'Alert') 
				}
			}
		}
	}
	
	
	$buttonClear_Click={
		
		if ($pathbox.Text -eq '' -and $timebox.Text -eq '' -and $reasonbox.Text -eq '')
		{
			[void][System.Windows.Forms.MessageBox]::Show('All fields are empty', 'Alert')
		}
		else
		{
			$pathbox.clear()
			$timebox.Clear()
			$reasonbox.Clear()
		}
	}
	
	
	

	$Form_StateCorrection_Load=
	{
		
		$MainForm.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		
		$script:MainForm_timebox = $timebox.Text
		$script:MainForm_reasonbox = $reasonbox.Text
		$script:MainForm_pathbox = $pathbox.Text
	}

	
	$Form_Cleanup_FormClosed=
	{
		try
		{
			$timebox.remove_TextChanged($timebox_TextChanged)
			$reasonbox.remove_TextChanged($reasonbox_TextChanged)
			$pathbox.remove_TextChanged($pathbox_TextChanged)
			$buttonClear.remove_Click($buttonClear_Click)
			$buttonStartMaintenanceMode.remove_Click($buttonStartMaintenanceMode_Click)
			$MainForm.remove_Load($MainForm_Load)
			$MainForm.remove_Load($Form_StateCorrection_Load)
			$MainForm.remove_Closing($Form_StoreValues_Closing)
			$MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	$MainForm.SuspendLayout()
	
	$MainForm.Controls.Add($timebox)
	$MainForm.Controls.Add($labelSandeepSingh)
	$MainForm.Controls.Add($reasonbox)
	$MainForm.Controls.Add($pathbox)
	$MainForm.Controls.Add($buttonClear)
	$MainForm.Controls.Add($buttonStartMaintenanceMode)
	$MainForm.Controls.Add($labelReason)
	$MainForm.Controls.Add($labelTimemin)
	$MainForm.Controls.Add($labelEnterFilePath)
	$MainForm.AutoScaleDimensions = '6, 13'
	$MainForm.AutoScaleMode = 'Font'
	$MainForm.ClientSize = '398, 266'
	$MainForm.FormBorderStyle = 'FixedSingle'
	$MainForm.MaximizeBox = $False
	$MainForm.Name = 'MainForm'
	$MainForm.StartPosition = 'CenterScreen'
	$MainForm.Text = 'SCOM MM Tool V1.0'
	$MainForm.add_Load($MainForm_Load)
	
	$timebox.Location = '100, 74'
	$timebox.Name = 'timebox'
	$timebox.Size = '285, 20'
	$timebox.TabIndex = 2
	$timebox.add_TextChanged($timebox_TextChanged)
	
	$labelSandeepSingh.AutoSize = $True
	$labelSandeepSingh.Location = '299, 244'
	$labelSandeepSingh.Name = 'labelSandeepSingh'
	$labelSandeepSingh.Size = '92, 13'
	$labelSandeepSingh.TabIndex = 8
	$labelSandeepSingh.Text = ' ©Sandeep Singh'
	
	$reasonbox.Location = '100, 106'
	$reasonbox.Multiline = $True
	$reasonbox.Name = 'reasonbox'
	$reasonbox.Size = '286, 68'
	$reasonbox.TabIndex = 3
	$reasonbox.add_TextChanged($reasonbox_TextChanged)
	
	$pathbox.Location = '100, 43'
	$pathbox.Name = 'pathbox'
	$pathbox.Size = '286, 20'
	$pathbox.TabIndex = 1
	$pathbox.add_TextChanged($pathbox_TextChanged)
	
	$buttonClear.Location = '220, 200'
	$buttonClear.Name = 'buttonClear'
	$buttonClear.Size = '165, 23'
	$buttonClear.TabIndex = 5
	$buttonClear.Text = 'Clear'
	$buttonClear.UseVisualStyleBackColor = $True
	$buttonClear.add_Click($buttonClear_Click)
	
	$buttonStartMaintenanceMode.Location = '12, 200'
	$buttonStartMaintenanceMode.Name = 'buttonStartMaintenanceMode'
	$buttonStartMaintenanceMode.Size = '165, 23'
	$buttonStartMaintenanceMode.TabIndex = 4
	$buttonStartMaintenanceMode.Text = 'Start Maintenance Mode'
	$buttonStartMaintenanceMode.UseVisualStyleBackColor = $True
	$buttonStartMaintenanceMode.add_Click($buttonStartMaintenanceMode_Click)
	
	$labelReason.AutoSize = $True
	$labelReason.Location = '12, 109'
	$labelReason.Name = 'labelReason'
	$labelReason.Size = '50, 13'
	$labelReason.TabIndex = 2
	$labelReason.Text = 'Reason :'
	
	$labelTimemin.AutoSize = $True
	$labelTimemin.Location = '12, 77'
	$labelTimemin.Name = 'labelTimemin'
	$labelTimemin.Size = '61, 13'
	$labelTimemin.TabIndex = 1
	$labelTimemin.Text = 'Time (min) :'
	
    $labelEnterFilePath.AutoSize = $True
	$labelEnterFilePath.Location = '12, 46'
	$labelEnterFilePath.Name = 'labelEnterFilePath'
	$labelEnterFilePath.Size = '82, 13'
	$labelEnterFilePath.TabIndex = 0
	$labelEnterFilePath.Text = 'Enter File Path :'
	$MainForm.ResumeLayout()
	
	
	$InitialFormWindowState = $MainForm.WindowState
	
	$MainForm.add_Load($Form_StateCorrection_Load)
	$MainForm.add_FormClosed($Form_Cleanup_FormClosed)
	$MainForm.add_Closing($Form_StoreValues_Closing)
	
	return $MainForm.ShowDialog()

}


function Get-ScriptDirectory
	{
		[OutputType([string])]
		param ()
		if ($hostinvocation -ne $null)
		{
			Split-Path $hostinvocation.MyCommand.path
		}
		else
		{
			Split-Path $script:MyInvocation.MyCommand.Path
		}
	}
	
[string]$ScriptDirectory = Get-ScriptDirectory
	
	
	
Main ($CommandLine)
