$TopPSScriptRoot=$PsScriptRoot
$profpath=${env:profiles}
if($profpath -eq $null) 
{
	$profpath=sl -path "$PSScriptRoot\Profiles"
}
$profiles =  dir $profpath -Exclude *.txt
$t = 0 
$profilenumber = @{}
$number = @{}
"-------------------------------------------------------------------------------"
"=== List of profiles "
"-------------------------------------------------------------------------------"
for($i = 0; $i -lt $profiles.Length; $i++){
	$i++
	$profilenumber[$t] = "$i." + $profiles.Name[$i-1]
	$number[$i] = $profilenumber[$t] -replace "[.].+$"
	$t++
	$i--
}
$profilenumber.Values
"-------------------------------------------------------------------------------"
while($profilename -notlike "exit") {
	$profilename = Read-Host("Please enter profile name or its serial number")
	$profiles | %	{
		if($_ -like $profilename) {
			$TopPSScriptRoot= sl -Path $PsscriptRoot\Profiles\$profilename
			break
		}	
	}
	for ($i = 1; $i -le $profilenumber.Count; $i++){
		if($profilename -like $number[$i]) {
			$wonumber = $profiles.Name[$i-1]
			$TopPSScriptRoot= sl -Path $PsscriptRoot\Profiles\$wonumber
			$q = 1
			break
		}
	}
	if ($q -eq 1){break}
	"Incorrect profile name or number, type 'exit' to return."	
}
$params =dir "$PSScriptRoot\Parameters"
$normalparams = $params.Name -Replace "[.].+$"
$paramnumber = @{}
$numberp = @{}
"-------------------------------------------------------------------------------"
"=== List of parameters "
"-------------------------------------------------------------------------------"
$t = 0
for($i = 0; $i -lt $params.Length; $i++){
	$paramnumber[$t] = "$i." + $params.Name[$i]
	$numberp[$i] = $paramnumber[$t] -replace "[.].+$"
	$t++
}
$paramnumber.Values
"-------------------------------------------------------------------------------"
while($paramname -notlike "exit") {
	$paramname = Read-Host("Please enter parameter name")
	foreach ($par in $params.Name){
		if ($paramname -like $par){
			$neededparam = $paramname
			$m = 1
			break
		}
	}
	for ($i = 0; $i -lt $paramnumber.Count; $i++){
		if($paramname -like $numberp[$i]) {
			$neededparam = $params.Name[$i]
			break
			$q = 1
		}
	}
	if ($m -eq 1 -or $q -eq 1){break}
	"Incorrect parameter name, type 'exit' to return."
}
$files =  dir $TopPSScriptRoot
$string = dir $TopPSScriptRoot -recurse -Force | % {$_ | select-string -Pattern "__"}  
$stringCount = $string | Measure-Object| %{$_.Count}
$massive = $string | Out-String -Stream
$normalmassive = @()
$normalmassive = $massive -split "(__)"
$lengthmassive=$normalmassive.Length
$neededmassive = @{}
$t = 0;
for ($i=0; $i -le ($lengthmassive-1); $i++){
	if($normalmassive[$i] -like "__"){
		$i++	
		$neededmassive[$t]=$normalmassive[$i]
		$t=$t+1
		$i--
	}
}
$texts = @()
$texts = $neededmassive.Values -replace "'.*"
$file = Get-Content "$PSScriptRoot\Parameters\$neededparam" | Out-String -Stream
$nonvaluefile = $file -replace "__"
$nonvaluefile = $nonvaluefile -replace "=(.+)"
$valuefile = $file -replace "(.+)="
if ($wonumber -eq $null){
	$docker = dir "$PsScriptRoot\Profiles\$profilename\dockerfile*" -recurse -Force |% {$_ | select-string -pattern " "} 
	$newname = $profilename
}
else { 
	$docker = dir "$PsScriptRoot\Profiles\$wonumber\dockerfile*" -recurse -Force |% {$_ | select-string -pattern " "}
	$newname = $wonumber
}
$neededparam = $neededparam -replace "[.].+$"
$newname = $neededparam + "_" + $newname
$foldername = dir $PsScriptRoot\Release
if ($foldername.Length -ne 1){
	for ($i = 0; $i -lt $foldername.Length;$i++){
		if ($foldername.Name[$i] -like $newname){
			$changefoldername = $foldername.Name[$i]
			Remove-Item -Path $Psscriptroot\Release\$changefoldername -Recurse -Force
		}
	}
}
else{
	if ($foldername.Name -like $newname){
		$changefoldername = $foldername.Name
		Remove-Item -Path $Psscriptroot\Release\$changefoldername -Recurse -Force
	}
}
$d = New-Item -Path $Psscriptroot\Release\$newname -ItemType Directory
$dockermassive = @()
$dockermassive = $docker -replace "(.+)[a-z]\:\d+:"
foreach($t in $file){
	if($t -match $null) {
		$result = $true
		break
	}
	else {
		$result = $false 
		break
	}
}
if ($texts -notlike $null){
	if($result -match $true){
		for ($i=0; $i -lt $texts.length ;$i++){
			for($k=0; $k -lt $file.Length; $k++){
				if ($nonvaluefile[$k] -ilike $texts[$i] ){
					$truestr=$valuefile[$k]
					break
				}
			}
		}
		$texts[1]= "__"+ $texts[1]+"__"
		$dockermassive = $dockermassive -replace ($texts[1],$truestr)	
		if ($wonumber -eq $null){
			$dockermassive[0] = $dockermassive[0] + " AS $profilename"
		}
		else {
			$dockermassive[0] = $dockermassive[0] + " AS $wonumber"
		}
		$dockermassive | out-file -FilePath $PsScriptRoot\Release\$newname\dockerfile -Encoding utf8 
	}
	else{
		"-------------------------------------------------------------------------------"
		"Your parameter file is empty"
		"Your dockerfile placeholder - " + $texts[1]
		"-------------------------------------------------------------------------------"
		$texts[1]= "__"+ $texts[1]+"__"
		$anothervalue = Read-Host("Please enter value for this placeholder: ")
		$dockermassive = $dockermassive -replace ($texts[1],$anothervalue)	
		if ($wonumber -eq $null){
			$dockermassive[0] = $dockermassive[0] + " AS $profilename"
		}
		else {
			$dockermassive[0] = $dockermassive[0] + " AS $wonumber"
		}
		if($texts -and $anothervalue){
			$dockermassive | out-file -FilePath $PsScriptRoot\Release\$newname\dockerfile -Encoding utf8
		}
	}
}
else {
	$dockermassive | out-file -FilePath $PsScriptRoot\Release\$newname\dockerfile -Encoding utf8
}