"--- Elevating permissions..."
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
	move-item $psscriptroot\Docker-Tools\* 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules'
pause