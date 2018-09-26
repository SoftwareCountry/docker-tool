Write-Host "Docker Tool: Loading module 'Get-Docker-Compose'..." -ForeGroundColor Green

function Get-Docker-Compose
{

Param
(
	[string]$Template,
	[array]$Profiles=@(),
	[string]$Destination
)
	$Template = Get-Content -Path $Template | Out-string
	if([string]::IsNullOrEmpty($Profiles))
	{
		$location = Get-Location
		$profilefolders = dir -Path $location.Path -Exclude *.y*
		for ($i = 0; $i -lt $profilefolders.Length; $i++){
			$port = "80:8" + $i
			$ip = "172.16.200.0" + $i
			$newtemplate = $Template -replace "folder_name", $profilefolders.Name[$i] -replace "namespace", $profilefolders.Name[$i] -replace "port_place", $port -replace "ip_place", $ip
			$dockercompose += $newtemplate + "`r`n"
		}
	}
	if(-not ([string]::IsNullOrEmpty($Profiles))){
		for ($i = 0; $i -lt $Profiles.Length; $i++){
			$Profiles[$i] = $Profiles[$i] -replace "(.+)\\"
			}
		for ($i = 0; $i -lt $Profiles.Length; $i++){
			$port = "80:8" + $i
			$ip = "172.16.200.0" + $i
			$newtemplate = $Template -replace "folder_name", $Profiles[$i] -replace "namespace", $Profiles[$i] -replace "port_place", $port -replace "ip_place", $ip
			$dockercompose += $newtemplate + "`r`n"
		}
	}
	$dockercompose | out-file -FilePath $Destination\docker-composer.yaml -Encoding unicode
}