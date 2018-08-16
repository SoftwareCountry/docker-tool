$TopPSScriptRoot=$PsScriptRoot
$profpath=${env:profiles}
$templates =  dir -Path $PSScriptRoot\Profiles\* -Include *.txt
$t = 0 
$templatenumber = @{}
$number = @{}
"-------------------------------------------------------------------------------"
"=== List of templates "
"-------------------------------------------------------------------------------"
for($i = 0; $i -lt $templates.Length; $i++){
	$i++
	$templatenumber[$t] = "$i." + $templates.Name[$i-1]
	$number[$i] = $templatenumber[$t] -replace "[.].+$"
	$t++
	$i--
}
$templatenumber.Values
"-------------------------------------------------------------------------------"
while($templatename -notlike "exit") {
	$templatename = Read-Host("Please enter template name or its serial number")
	$templates.Name | %	{
		if($_ -like $templatename) {
			$template= Get-Content -Path $PsscriptRoot\Profiles\$templatename
			break
		}	
	}
	for ($i = 1; $i -le $templatenumber.Count; $i++){
		if($templatename -like $number[$i]) {
			$wonumber = $templates.Name[$i-1]
			$template= Get-Content -Path $PsscriptRoot\Profiles\$wonumber
			$q = 1
			break
		}
	}
	if ($q -eq 1){break}
	"Incorrect template name or number, type 'exit' to return."	
}
$profilefolders = dir -Path $PsscriptRoot\Release -Exclude *.y*
if ($template -notlike $null){
	$dockercompose = $template[0] + "`r`n" + $template[1] + "`r`n"
}
for ($i = 2; $i -lt $template.Length;$i++){
	$newtemplate += $template[$i] + "`r`n"
}
for ($i = 0; $i -lt $profilefolders.Length; $i++){
	$port = "80:8" + $i
	$ip = "172.16.200.0" + $i
	$compose = $newtemplate -replace "folder_name",$profilefolders.Name[$i] -replace "namespace", $profilefolders.Name[$i] -replace "port_place", $port -replace "ip_place", $ip
	$dockercompose += $compose + "`r`n"
}
$dockercompose | out-file -FilePath $PsScriptRoot\Release\docker-composer.yaml -Encoding unicode
pause