Write-Host "Loading module 'Get-Docker-File'..." -ForeGroundColor Green
function Get-Docker-File{
	[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$image,

	[Parameter(Mandatory=$False)]
	[ValidateNotNullOrEmpty()]
	[string]$destination,
	
	[Parameter(Mandatory=$False)]
	[switch]$json
)
	$history = docker history $image
	if(-not($json))
	{
		Write-Host ("Creating a dockerfile using the docker history...")
		for ($i =1; $i -lt $history.Length; $i++){
			if ($history[$i] -match "<missing>"){
				$main = $i - 1
				break
			}
		}
		$history= $history[$main] -replace" (.+)"
		$dockerfile = docker history $image --no-trunc --format "{{.CreatedBy}}"
		$powershell = $dockerfile | Select-String -SimpleMatch -pattern "powershell" -CaseSensitive
		$fromjson = docker inspect $history | ConvertFrom-Json
		$cmd = $dockerfile | Select-String -SimpleMatch -pattern "cmd" -CaseSensitive
		$from = $fromjson.RepoTags
		$from = "FROM " + $from
		$newdockerfile = $from
		if ($powershell){
			$powershell = $powershell[0] -replace ";(.+)"
			$powershell = '"' + $powershell -replace " ", '", "'
			$powershell = $powershell -replace '", "=", "', " = "
			$powershell = "SHELL [" + $powershell + ';"]'
			$newdockerfile += "`n" + $powershell 
		}
		$dockerfile = $dockerfile -replace "powershell(.+?);"
		if ($cmd){
			$cmd = $cmd[0] -replace "  (.+)"
		}
		if ($cmd -match "nop"){
			$cmd = $cmd -replace " #(.+)"
		}
		for ($i = 0; $i -lt $dockerfile.Length; $i++){
			if ($dockerfile[$i] -match "bin"){
				$dockerfile[$i] = $dockerfile[$i] -replace "(.+)-c " 
			}
			if ($dockerfile[$i] -match $cmd){
				$dockerfile[$i] = $dockerfile[$i] -replace $cmd
			}
			if ($dockerfile[$i] -notmatch "(nop)"){
				$dockerfile[$i] = "RUN " + $dockerfile[$i]
				$dockerfile[$i] = $dockerfile[$i] -replace "RUN  ","RUN "
			}
			if ($dockerfile[$i] -match "(nop)"){
				$dockerfile[$i] = $dockerfile[$i] -replace "\S+?\)" 
			}
			if (($dockerfile[$i] -match "New-WebAppPool") -or ($dockerfile[$i] -match "Add-WindowsFeature") -or ($dockerfile[$i] -match "certutil") -or ($dockerfile[$i] -match "Import-Module") -or ($dockerfile[$i] -match "Invoke*")){
				$dockerfile[$i] = $dockerfile[$i] -replace "; ","; \@@@"
			}
			if ($dockerfile[$i] -match "apply image" -or $dockerfile[$i] -match "install update" -or $dockerfile[$i] -cmatch "SHELL" -or $dockerfile[$i] -match "ADD" -or $dockerfile[$i] -match "COPY" -or $dockerfile[$i] -match '"$url"'){
				$dockerfile[$i] = $null
			}
		}
		$dockerfile += $powershell
		$dockerfile += $from
		[array]::Reverse($dockerfile)
		$dockerfile = $dockerfile -split "@@@"
		$newdockerfile = @()
		for ($i = 0; $i -lt $dockerfile.Length; $i++){
			if ($dockerfile[$i] -notlike $null){
				$newdockerfile = $newdockerfile += $dockerfile[$i]
			}
		}
		for ($i = 0; $i -lt $newdockerfile.Length; $i++){
			if ($newdockerfile[$i] -match "ProgressPreference" ){
				$newdockerfile[$i] = $newdockerfile[$i] -replace "(.+)'; "
			}
		}
		for ($i = 0; $i -lt $newdockerfile.Length; $i++){
			if ($newdockerfile[$i] -match "Invoke*"){
				$index = $i
				if ($newdockerfile[$index] -notmatch "RUN"){
					$newdockerfile[$index] = "RUN " + $newdockerfile[$index]
				}
			}
		}
	}
	if($json)
	{
		Write-Host ("Creating a dockerfile using json...")
		$dockercount= $history.Length
		for ($i = 1; $i -lt $dockercount; $i++){
			$history[$i]= $history[$i] -replace" (.+)"
		}
		for ($i =1; $i -lt $dockercount; $i++){
			if ($history[$i] -match "<missing>"){
				$main = $i - 1
				break
			}
		}
		for ($i =1; $i -le $main; $i++){
			$run = "RUN "
			$t = 3
			$inspect = docker inspect $history[$i]
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
			[array]$newdockerfile +=$run + $fromjson.ContainerConfig.CMD[$t]
		}
		$dockercommands = docker inspect $history[$main] | Select-String -SimpleMatch -pattern '"RepoTags": ['-Context 0,1 | Out-String
		$dockercommands=$dockercommands.Split('""')
		$newdockerfile += 'SHELL ["powershell", "-Command", "$ErrorActionPreference = ' + "'Stop';" + '"]'
		$newdockerfile += "FROM " + $dockercommands[3]
		[array]::Reverse($newdockerfile)
		$newdockerfile = $newdockerfile -replace "<.+?>"
		$newdockerfile = $newdockerfile -replace "#(......)"
		for ($i = 0; $i -lt $newdockerfile.Count; $i++){
			if (($newdockerfile[$i] -match "New-WebAppPool") -or ($newdockerfile[$i] -match "Add-WindowsFeature") -or ($newdockerfile[$i] -match "certutil") -or ($newdockerfile[$i] -match "Import-Module") -or ($newdockerfile[$i] -match "Invoke*")){
				$newdockerfile[$i] = $newdockerfile[$i] -replace ";","; \@@@"
			}
		}
		$newdockerfile = $newdockerfile -split "@@@" 
		$newdockerfile = $newdockerfile -replace ("\\\\", "\")
	}
	if(-not ([string]::IsNullOrEmpty($Destination))){
		$newdockerfile | Out-File $Destination\dockerfile -Encoding utf8
	}
	if([string]::IsNullOrEmpty($Destination)){
		$location = Get-Location
		$location = $location.Path
		$newdockerfile | Out-File $location\dockerfile -Encoding utf8
		}
}