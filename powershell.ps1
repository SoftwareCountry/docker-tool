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
$name = Read-Host("Please enter container name")
docker create -t -i --name $name $imagename bash
docker ps -a --format "table {{.Names}}\t{{.ID}}"
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
docker exec $containername apt update
docker exec $containername apt install -y apt-utils ca-certificates curl apt-transport-https sudo

#misunderstanding of the text
#docker exec $containername curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
#docker exec $containername curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list

docker exec $containername sudo apt-get update
docker exec $containername sudo apt-get install -y powershell
#$exec = docker exec -it $containername /bin/bash apt update apt install apt-utils ca-certificates curl apt-transport-https sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
#$version = cat /etc/issue.net
#$version
<#apt install apt-utils ca-certificates curl apt-transport-https sudo
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update
sudo apt-get install -y powershell #>
pause