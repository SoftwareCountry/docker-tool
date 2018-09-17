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
$create = docker create -t -i $imagename /bin/sh
docker start $create 
$version = docker exec $create cat /etc/issue.net 
$version1 = docker exec $create cat /etc/redhat-release
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
docker rm -f $create
switch ($version){
	"Ubuntu 16.04" {
		$dockerfle = 
"FROM ubuntu
RUN apt update
RUN apt install -y apt-utils ca-certificates curl apt-transport-https sudo
RUN apt-get install wget
RUN wget https://packages.microsoft.com/keys/microsoft.asc
RUN sudo apt-key add microsoft.asc
RUN wget https://packages.microsoft.com/config/ubuntu/16.04/prod.list
RUN cp prod.list ../etc/apt/sources.list.d/microsoft.list
RUN sudo apt-get update
RUN sudo apt-get install -y powershell" | Out-File -Encoding utf8 dockerfile
	}
	"Ubuntu 14.04" {
		$dockerfle = 
"FROM ubuntu
RUN apt update
RUN apt install -y apt-utils ca-certificates curl apt-transport-https sudo
RUN apt-get install wget
RUN wget https://packages.microsoft.com/keys/microsoft.asc
RUN sudo apt-key add microsoft.asc
RUN wget https://packages.microsoft.com/config/ubuntu/14.04/prod.list
RUN cp prod.list ../etc/apt/sources.list.d/microsoft.list
RUN sudo apt-get update
RUN sudo apt-get install -y powershell" | Out-File -Encoding utf8 dockerfile
	}
	"Ubuntu 18.04" {
		$dockerfle = 
"FROM ubuntu
RUN apt update
RUN apt install -y apt-utils ca-certificates curl apt-transport-https sudo
RUN apt-get install -my wget gnupg
RUN wget https://packages.microsoft.com/keys/microsoft.asc
RUN sudo apt-key add microsoft.asc
RUN sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/18.04/prod.list
RUN sudo apt-get update
RUN sudo apt-get install -y powershell-preview" | Out-File -Encoding utf8 dockerfile
	}
	"Debian 9" {
		$dockerfle = 
"FROM debian
RUN apt-get update
RUN apt-get install -y curl gnupg apt-transport-https sudo wget
RUN wget https://packages.microsoft.com/keys/microsoft.asc
RUN sudo apt-key add microsoft.asc
RUN sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/debian/9/prod.list
RUN sudo apt-get update
RUN sudo apt-get install -y powershell" | Out-File -Encoding utf8 dockerfile
	}
	"Debian 8" {
		$dockerfle = 
"FROM debian
RUN apt-get update
RUN apt-get install -y curl gnupg apt-transport-https sudo wget
RUN wget https://packages.microsoft.com/keys/microsoft.asc
RUN sudo apt-key add microsoft.asc
RUN sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/debian/8/prod.list
RUN sudo apt-get update
RUN sudo apt-get install -y powershell" | Out-File -Encoding utf8 dockerfile
	}
	"CentOS" {
		$dockerfle = 
"FROM centos
RUN yum update -y
RUN yum install -y apt-utils ca-certificates curl apt-transport-https sudo wget
RUN sudo curl -o /etc/yum.repos.d/microsoft.repo https://packages.microsoft.com/config/rhel/7/prod.repo
RUN sudo yum install -y powershell" | Out-File -Encoding utf8 dockerfile
	}
}
$name = Read-Host("Please enter new image name")
docker build -t $name .
pause