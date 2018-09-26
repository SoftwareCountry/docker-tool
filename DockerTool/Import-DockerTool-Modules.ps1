Write-Host("Docker Tools modules installation")

"--- Elevating permissions..."
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
	Write-Host("--- Copying modules...")
	move-item $psscriptroot\Modules\* $env:WINDIR\system32\WindowsPowerShell\v1.0\Modules
	Write-Host("--- Trying to find installed modules... (if they are listed below, installation went just fine)")
	Get-Module -List *Docker*
pause