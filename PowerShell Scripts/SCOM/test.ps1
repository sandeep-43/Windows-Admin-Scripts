           $list= gc c:\temp\user.txt
            foreach($computer in $list)
            {
                if(gsv -ComputerName $computer| ?{$_.Name -eq 'healthservice'})
                {
                    $prop=@{
                                "Server Name"= $computer
                                "SCOM Installed"="TRUE"  
                            }
                }
                else
                {
                    $prop=@{
                                "Server Name"= $computer
                                "SCOM Installed"="FALSE"  
                            }
                }
                $obj=New-Object -TypeName PSobject -Property $prop
            write-output $obj #| export-csv test.csv -Append
            }

            
