$image = @()
$imagerep = docker images --format "{{.Repository}}"
$imageid = docker images --format "{{.ID}}"
"_________________________________________"
"Your docker images:"
"_________________________________________"
docker images --format "table {{.Repository}}\t{{.ID}}"
"_________________________________________"
$dockerimage = @()
while($imagename -notlike "exit") {
	$imagename = Read-Host("Please enter image name or image id")
	$imagerep | %	{
		if($_ -like $imagename) {
			$dockerimage = docker history $imagename
			break
		}
	}
	$imageid | %	{
		if($_ -match $imagename) {
			$dockerimage = docker history $imagename
			break
		}
	}
	"Incorrect image name or id, type 'exit' to return."
}
$dockercount= $dockerimage.Length
for ($i = 1; $i -lt $dockercount; $i++){
	$dockerimage[$i]= $dockerimage[$i] -replace" (.+)"
}	
for ($i =1; $i -lt $dockercount; $i++){
	if ($dockerimage[$i] -match "<missing>"){
		$main = $i - 1
		break
	}
}
for ($i =1; $i -le $main; $i++){
	$run = "RUN "
	$t = 3
	$inspect = docker inspect $dockerimage[$i]
	$fromjson = $inspect | ConvertFrom-Json
	$nop = $fromjson.ContainerConfig.CMD | Select-String -SimpleMatch -pattern "#(nop) "
	$shell = $fromjson.ContainerConfig.CMD | Select-String -SimpleMatch -pattern "SHELL [powershell"
	$cmd = $fromjson.ContainerConfig.CMD | Select-String -SimpleMatch -pattern '"cmd"' -casesensitive
	$bin = $fromjson.ContainerConfig.CMD | Select-String -SimpleMatch -pattern "/bin/sh" -casesensitive
	$workdir = $fromjson.ContainerConfig.CMD | Select-String -SimpleMatch -pattern "WORKDIR" -casesensitive
	if ($nop -or $cmd){
		$run = $null
		$t += 1
	}
	if ($shell -or $bin -or $workdir){
		$t--
	}
	[array]$json +=$run + $fromjson.ContainerConfig.CMD[$t]
}
$dockercommands = docker inspect $dockerimage[$main] | Select-String -SimpleMatch -pattern '"RepoTags": ['-Context 0,1 | Out-String
$dockercommands=$dockercommands.Split('""')
$json += 'SHELL ["powershell", "-Command", "$ErrorActionPreference = ' + "'Stop';" + '"]'
$json += "FROM " + $dockercommands[3]
[array]::Reverse($json)
$json = $json -replace "<.+?>"
$json = $json -replace "#(......)"
for ($i = 0; $i -lt $json.Count; $i++){
	if (($json[$i] -match "New-WebAppPool") -or ($json[$i] -match "Add-WindowsFeature") -or ($json[$i] -match "certutil") -or ($json[$i] -match "Import-Module") -or ($json[$i] -match "Invoke*")){
		$json[$i] = $json[$i] -replace ";","; \@@@"
	}
}
$json = $json -split "@@@" 
$json = $json -replace ("\\\\", "\")
$json | Out-File dockerfile -Encoding utf8