Write-Host "Loading module 'Split-Docker-File'..." -ForeGroundColor Green

function Split-Docker-File
{
[CmdletBinding()]
Param
(
	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$dockerfile,

	[Parameter(Mandatory=$False)]
	[ValidateNotNullOrEmpty()]
	[string]$destination
)
	$dockertext = Get-Content -path $dockerfile\dockerfile
	for ($i = 0; $i -lt $dockertext.Length; $i++){
		if ($dockertext[$i] -match "^From"){
			[array]$index += $i + "`r`n"
			[array]$from += $dockertext[$i] + "`r`n"
		}
	}
	for ($i = 1; $i -lt $index.Length; $i++){
		$index[$i]--
	}
	[array]$index += $dockertext.Length
	<#for ($i = 0; $i -lt $from.Length; $i++){
		[array]$as += $from[$i] -replace "FROM ",''
		[array]$as += $from[$i] -replace "FROM ",''
	}
	#>
	for ($i = 1; $i -lt $index.Length; $i++){
		$newdockerfiles = $dockertext[$index[$i-1]..$index[$i]]
		$index[$i]++
		if(-not ([string]::IsNullOrEmpty($Destination))){
			New-Item -ItemType Directory -Force -Path "$Destination\dockerfile$i"
			$newdockerfiles | Out-File $Destination\dockerfile$i\dockerfile -Encoding utf8
		}
		if([string]::IsNullOrEmpty($Destination)){
			$location = Get-Location
			$location = $location.Path
			New-Item -ItemType Directory -Force -Path "$location\dockerfile$i"
			$newdockerfiles | Out-File $location\dockerfile$i\dockerfile -Encoding utf8
		}
		
	}
}