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
			break
		}
	}
	$imageid | %	{
		if($_ -match $imagename) {
			break
		}
	}
	"Incorrect image name or id, type 'exit' to return."
}
"_________________________________________"
$name = Read-Host("Please enter container name")
"_________________________________________"
docker create -t -i --name $name $imagename /bin/sh
"_________________________________________"
docker ps -a --format "table {{.Names}}\t{{.ID}}"
"_________________________________________"
$containerid = docker ps -a --format "{{.ID}}"
while($containername -notlike "exit") {
	$containername = Read-Host("Please enter container id")
	$containerid | %	{
		if($_ -match $containername) {
			break
		}
	}
	"Incorrect container id, type 'exit' to return."
}
docker start $containername
$version = docker exec $containername cat /etc/issue.net
$version1 = docker exec $containername cat /etc/redhat-release
#$version2 = docker exec $containername cat /etc/issue
if ($version -match "Ubuntu"){
	$version = $version.Remove(12)
}
if ($version -match "Debian"){
	$version = "Debian " + $version.Substring($version.Length -1, 1)
}
if ($version1 -match "CentOS"){
	$version = $version1.Remove(6)
}
if ($version1 -match "openSUSE"){
	$version = "openSUSE"
}
if ($version1 -match "Red Hat"){
	$version = $version1.Remove(7)
}
if ($version1 -match "Fedora"){
	$version = "Fedora"
}
<#if ($version2 -match "Arch Linux"){
	$version = "Arch Linux"
}
if ($version2 -match "Kali"){
	$version = "Kali"
}
if ($version2 -match "Raspbian"){
	$version = "Raspbian"
}#>
switch ($version){
	"Ubuntu 16.04" {
		docker exec $containername apt update
		docker exec $containername apt install -y apt-utils ca-certificates curl apt-transport-https sudo
		docker exec $containername apt-get install wget
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername wget https://packages.microsoft.com/config/ubuntu/16.04/prod.list
		docker exec $containername cp prod.list ../etc/apt/sources.list.d/microsoft.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	"Ubuntu 14.04" {
		docker exec $containername apt update
		docker exec $containername apt install -y apt-utils ca-certificates curl apt-transport-https sudo
		docker exec $containername apt-get install wget
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername wget https://packages.microsoft.com/config/ubuntu/14.04/prod.list
		docker exec $containername cp prod.list ../etc/apt/sources.list.d/microsoft.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	"Ubuntu 18.04" {
		docker exec $containername apt update
		docker exec $containername apt install -y apt-utils ca-certificates curl apt-transport-https sudo
		docker exec $containername apt-get install -my wget gnupg
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/18.04/prod.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell-preview
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh-preview
____________________________________________________________"
		# Start PowerShell with command pwsh-preview
	}
	"Debian 9" {
		docker exec $containername apt-get update
		docker exec $containername apt-get install -y curl gnupg apt-transport-https sudo wget
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/debian/9/prod.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"

	}
	"Debian 8" {
		docker exec $containername apt-get update
		docker exec $containername apt-get install -y curl gnupg apt-transport-https sudo wget
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/debian/8/prod.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	"CentOS" {
		docker exec $containername yum update -y
		docker exec $containername yum install -y apt-utils ca-certificates curl apt-transport-https sudo wget
		docker exec $containername sudo curl -o /etc/yum.repos.d/microsoft.repo https://packages.microsoft.com/config/rhel/7/prod.repo
		docker exec $containername sudo yum install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	#need to register	
	<#"Red Hat"{
		docker exec $containername 
		docker exec $containername
		docker exec $conatinername
		docker exec $containername
	}#>

	#Of the two proposed solutions, you need to automatically select the second(?)
	"OpenSUSE"{
		docker exec $containername zypper install -y sudo wget
		docker exec $containername sudo wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername zypper ar https://packages.microsoft.com/rhel/7/prod/ rep
		docker exec $containername sudo zypper update -y
		docker exec $containername sudo zypper install powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	"Fedora"{
		docker exec $containername dnf install -y sudo
		docker exec $containername sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername curl -o /etc/yum.repos.d/microsoft.repo https://packages.microsoft.com/config/rhel/7/prod.repo
		docker exec $containername sudo dnf update -y
		docker exec $containername sudo dnf install -y compat-openssl10
		docker exec $containername sudo dnf install -y powershell
		docker exec $containername echo "
____________________________________________________________
		        Attention!!!
____________________________________________________________
     To run powershell, you must type pwsh
____________________________________________________________"
	}
	#with root can't do anything
	<#"Arch Linux"{
		docker exec $containername pacman -Sy
		docker exec $containername pacman -S -y sudo
		docker exec $containername
		docker exec $containername

	<#"Kali"{
		docker exec $containername apt-get install -y curl gnupg apt-transport-https sudo wget
		docker exec $containername
		docker exec $containername
		docker exec $containername

	#cant start Powershell
	"Raspbian"{
		docker exec $containername apt-get update
		docker exec $containername apt-get install -y curl gnupg apt-transport-https sudo wget
		docker exec $containername wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.3/powershell-6.0.3-linux-arm32.tar.gz
		docker exec $containername mkdir ~/powershell
		docker exec $containername tar -xvf ./powershell-6.0.3-linux-arm32.tar.gz -C ~/powershell
		# Start PowerShell with command ~/powershell/pwsh
	}	}#>
	default {
		"_________________________________________"
		"Your version of Linux distribution does not support powershell"
		"_________________________________________"
	}
}





#$exec = docker exec -it $containername /bin/bash apt update apt install apt-utils ca-certificates curl apt-transport-https sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
#$version = cat /etc/issue.net
#$version
<#apt install apt-utils ca-certificates curl apt-transport-https sudo
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update
sudo apt-get install -y powershell #>
#docker exec $containername curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list
pause