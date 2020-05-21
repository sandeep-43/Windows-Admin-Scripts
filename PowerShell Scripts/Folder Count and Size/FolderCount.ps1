get-content fileserver.txt  | foreach{Get-ChildItem -path $_  -recurse| 
?{$_.PSIsContainer -eq 'TRUE'} | measure-object | select Count} | export-csv FolderCount.csv