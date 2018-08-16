$where = select-string -Path "$Psscriptroot\Parameters\pr1*" -Pattern "from"
$where = $where -replace "(.+)from:"
$to = select-string -Path "$Psscriptroot\Parameters\pr1*" -Pattern "to"
$to = $to -replace "(.+)to:"
Copy-Item -path $where  -Recurse -Destination "$to" -Force