$ErrorActionPreference="Continue"
gc C$env:USERPROFILE\Documents\servers.txt | %{gwmi win32_operatingsystem -Cn $_ | Export-Csv $env:USERPROFILE\Documents\ServersBit_2008_Servers.csv -Append -NoTypeInformation}
