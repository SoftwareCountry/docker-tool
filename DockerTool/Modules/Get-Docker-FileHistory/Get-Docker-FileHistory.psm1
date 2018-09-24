Write-Host "Loading module 'Get-Docker-FileHistory'..." -ForeGroundColor Green
function Get-Docker-FileHistory{
	[CmdletBinding()]
	param(
	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$image,

	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$destination
)
$history = docker history $image
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
#$list = [System.Collections.Generic.List[System.Object]]($dockerfile)
#$list
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
#$dockerfile[$i] = $dockerfile[$i] -replace "     ","%%%"
#$dockerfile = $dockerfile -split "\|" 
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
	#$dockerfile[$i]
}
$newdockerfile | Out-File $destination\dockerfile -Encoding utf8
}
export-modulemember -function Get-Docker-FileHistory
pause