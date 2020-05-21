
           $list= gc "c:\temp\SCOM\Servers.txt"
            foreach($computer in $list)
            {
               try
               {
                     if(gsv -ComputerName $computer | ?{$_.Name -eq 'healthservice'})
                     {
                        $prop=@{
                                    "Server Name"= $computer
                                    "SCOM Installed"="TRUE"  
                                }
                       # $err | out-file "c:\temp\SCOM\ErrorFile.txt" -Append
                     }
                    
                     else
                     {
                        $prop=@{
                                    "Server Name"= $computer
                                    "SCOM Installed"="FALSE"  
                                }
                        #$err | 
                     }
                
                    $obj=New-Object -TypeName PSobject -Property $prop
                    write-output $obj | export-csv "c:\temp\SCOM\ScomCheck2.csv" -Append -notypeinformation
                }
                catch
                {
                    $_ | out-file "c:\temp\SCOM\ErrorFile.txt" -Append
                   Write-Output "------------------------------------------"  | out-file "c:\temp\SCOM\ErrorFile.txt" -Append
                }
            }

            
