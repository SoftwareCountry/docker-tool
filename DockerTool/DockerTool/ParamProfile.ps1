Param
([Parameter(Mandatory=$True)]
  [ValidateNotNullOrEmpty()]
  [string]$Profiles,

  [Parameter(Mandatory=$True)]
  [ValidateNotNullOrEmpty()]
  [string]$Params

)
$TopPSScriptRoot= sl -Path $PsscriptRoot\Profiles\$profiles
$string = dir $TopPSScriptRoot -recurse -Force | % {$_ | select-string -Pattern "__"}  
$massive = $string | Out-String -Stream
$normalmassive = @()
$normalmassive = $massive -split "(__)"
$neededname = @{}
$t = 0;
for ($i=0; $i -le ($normalmassive.Length-1); $i++){
	if($normalmassive[$i] -like "__"){
		$i++	
		$neededname[$t]=$normalmassive[$i]
		break
	}
}
$paramfile = Get-Content "$PSScriptRoot\Parameters\$params" | Out-String -Stream
$neededvalue = $paramfile -replace "=(.+)"
$nonvalueparam = $paramfile -replace "__"
$nonvalueparam = $nonvalueparam -replace "=(.+)"
$valueparam = $paramfile -replace "(.+)="
$docker = dir "$PsScriptRoot\Profiles\$profiles\dockerfile*" -recurse -Force |% {$_ | select-string -pattern " "} 
$dockermassive = @()
$dockermassive = $docker -replace "(.+)[a-z]\:\d+:"
foreach($t in $paramfile){
	if($t -match $null) {
		$result = $true
		break
	} 
	else {
		$result = $false 
	    break
	}
}
if($result -match $true){
	for ($i=0; $i -lt $neededname.length ;$i++){
		for($k=0; $k -lt $paramfile.Length; $k++){
			if ($nonvalueparam[$k] -ilike $neededname[$i] ){
				$truestr+=$valueparam[$k]
			}
		}
	}
	$truestr = $truestr -split (" ")
	[array]::Reverse($neededname)
	$appname = "__" + $neededname.Values + "__"
	$dockermassive = $dockermassive -replace ($appname,$truestr)
}	
$dockermassive | out-file -FilePath $PsScriptRoot\Release\Product\dockerfile -Encoding utf8
$foldername = dir $PsScriptRoot\Release\Product\Source
$changefoldername = $foldername.Name
for ($t =0; $t -lt $foldername.Length; $t++){
	for ($i=0; $i -lt $neededvalue.Length; $i++){
		if ($changefoldername[$t] -like $neededvalue[$i]){
			$truename = $changefoldername[$t]
			Rename-Item -Path $Psscriptroot\Release\Product\Source\$truename -NewName $valueparam[$i]
		}
	}
}