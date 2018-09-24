Write-Host "Loading module 'Merge-Docker-File'..." -ForeGroundColor Green
function Merge-Docker-File{
[CmdletBinding()]
Param
([Parameter(
	Mandatory=$True,
	HelpMessage='Enter the full path to the profile')]
	[ValidateNotNullOrEmpty()]
	[array]$Profiles=@(),

[Parameter(
	Mandatory=$True,
	HelpMessage='Enter the full path to the params')]
	[ValidateNotNullOrEmpty()]
	[string]$Params,

[Parameter(
	Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$destination
)
$check = @{}
$dockermassive = @()
for ($z = 0; $z -lt $Profiles.Length; $z++){
	$Profile = $Profiles[$z]
	$TopPSScriptRoot= sl -Path $profile
	$string = dir $TopPSScriptRoot -recurse -Force | % {$_ | select-string -Pattern "__"}  
	$massive = $string | Out-String -Stream
	$normalmassive = @()
	$normalmassive = $massive -split "(__)"
	$neededmassive = @{}
	$t = 0;
	for ($i=0; $i -le ($normalmassive.Length-1); $i++){
		if($normalmassive[$i] -like "__"){
			$i++	
			$neededmassive[$t]=$normalmassive[$i]
			$t=$t+1
			$i--
		}
	}
	$texts = @()
	$texts = $neededmassive.Values -replace "'.*"
	$paramfile = Get-Content $params | Out-String -Stream
	$neededvalue = $paramfile -replace "=(.+)"
	$nonvalueparam = $paramfile -replace "__"
	$nonvalueparam = $nonvalueparam -replace "=(.+)"
	$valuefile = $paramfile -replace "(.+)="
	$docker = dir "$profile\dockerfile*" -recurse -Force |% {$_ | select-string -pattern " "} 
	$dockermassive = $docker -replace "(.+)[a-z]\:\d+:"
	$check[$z] = $dockermassive[0]
	$asprofile = $Profile -replace "(.+)\\"
	if ($dockermassive[0] -notmatch "AS"){
		$dockermassive[0] = $dockermassive[0] + " AS $asprofile"
		}
	foreach($t in $paramfile){
		if($t -match $null){
			$result = $true
			break
		} 
		else {
			$result = $false 
			break
		}
	}
	if($result -match $true){
		for ($i=0; $i -lt $texts.length ;$i++){
			for($k=0; $k -lt $paramfile.Length; $k++){
				if ($nonvalueparam[$k] -ilike $texts[$i] ){
					$truestr=$valuefile[$k]
				}
			}
		}
	}
	$truestr = $truestr -split (" ")
	$tyty = "__"+ $texts[1] + "__"
	$dockermassive = $dockermassive -replace ($tyty,$truestr)
	$summdocker += $dockermassive + "`n"
}<#
$newname = $params -replace "[.].+$"
$foldername = dir $PsScriptRoot\Release
for ($i = 0; $i -lt $Profiles.Length; $i++){
	$newname = $newname + "_" + $Profiles[$i]
}
if ($foldername.Length -ne 1){
	for ($i=0; $i -lt $foldername.Length;$i++){
		$changefoldername = $foldername.Name[$i]
		Remove-Item -Path $Psscriptroot\Release\$changefoldername -Recurse -Force
	}
}
else {
	$changefoldername = $foldername.Name
	Remove-Item -Path $Psscriptroot\Release\$changefoldername -Recurse -Force
}
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
	#>
for ($i = 0; $i -lt $summdocker.Length; $i++){
	if ($summdocker[$i] -cmatch "FROM "){
		$fromindex = $i
	}
}
if ($check[0] -like $check[1]){
	for ($t = $fromindex; $t -lt $summdocker.Length; $t++){
		if ($summdocker[$t] -cmatch "FROM "){
			$summdocker[$t] = "#" + $summdocker[$t]
		}
	}
}
<#for ($i = 0; $i -lt $summdocker.Length; $i++){
	if ($summdocker[$i].StartsWith(" ")){
		$summdocker[$i] = $summdocker[$i] -replace " .*?\s"
		}
}#>
#$1stprofile = Get-Content $PsScriptRoot\Profiles\$1stname\dockerfile
#$2dprofile = Get-Content $PsScriptRoot\Profiles\$2dname\dockerfile
#$summdocker = $summdocker.Trim()
if ($check[0] -like $check[1]){
	for ($i = 0; $i -lt $fromindex; $i++){
		for ($t = $fromindex; $t -lt $summdocker.Length; $t++){
			if ($summdocker[$i] -ceq $summdocker[$t]){
				$summdocker[$t] = "#" + $summdocker[$t]
			}
		}
	}
}
<#for ($i = $fromindex; $i -lt $summdocker.length; $i++){
	if ($summdocker[$i].StartsWith("#") -notlike $True -and $summdocker[$i].EndsWith("\") -like $True){
		$summdocker[$i] = "RUN " + $summdocker[$i]
	}
}
for ($i = 0; $i -lt $summdocker.length; $i++){
	$summdocker[$i].lastindexof("\")
}#>
#if ($summdocker[$i].lastindexof("\") -gt 0 -and $summdocker[$i].indexof("#") -lt 0){
$summdocker | out-file -FilePath $destination\dockerfile -Encoding utf8
}