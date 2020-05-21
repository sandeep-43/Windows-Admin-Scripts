
    $path=Get-Content "C:\temp\ACL\GroupMembers.txt"
    $outputFile="C:\temp\ACL\GroupMembersResults.csv"
    $ErrorFile="C:\temp\ACL\Error.txt"
    
    $ErrorActionPreference='SilentlyContinue'
        $domains= (Get-ADForest).domains
      
        foreach($domain in $domains)
        {
            
            
                foreach($acl in $path)
                {
        
                    if($Members=Get-ADGroupMember $acl -server $domain | Sort-Object Name)
                     # | Select-Object Name # , $acl #| Out-File "C:\temp\GroupMembersResults.txt" -append
        
                    {
                        foreach($Member in $Members)
                        {
                       
                                    $prop=@{
                                                "AD Group"= $ACL
                                                "Users"=$Member.Name 
                                            }
                            
                                            $obj=New-Object -TypeName PSobject -Property $prop
                                            write-output $obj | export-csv $outputFile -Append -notypeinformation
                        }
                    }
                 }
             }

