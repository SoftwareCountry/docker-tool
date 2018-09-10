$image = @()
$imagerep = docker images --format "{{.Repository}}"
$imageid = docker images --format "{{.ID}}"
"_________________________________________"
"Your docker images:"
"_________________________________________"
docker images --format "table {{.Repository}}\t{{.ID}}"
"_________________________________________"
$dockerimage = @()
$p = "|"
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
if ($version -match "Ubuntu"){
	$version = $version.Remove(12)
}
if ($version -match "Debian"){
	$version = "Debian " + $version.Substring($version.Length -1, 1)
}

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
	}
	"Debian 8" {
		docker exec $containername apt-get update
		docker exec $containername apt-get install -y curl gnupg apt-transport-https sudo wget
		docker exec $containername wget https://packages.microsoft.com/keys/microsoft.asc
		docker exec $containername sudo apt-key add microsoft.asc
		docker exec $containername sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/debian/8/prod.list
		docker exec $containername sudo apt-get update
		docker exec $containername sudo apt-get install -y powershell
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