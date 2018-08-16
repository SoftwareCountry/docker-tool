$foldername = dir $PsScriptRoot\Release -exclude *.y*
"-------------------------------------------------------------------------------"
"=== List of folders "
$foldername.Name
"-------------------------------------------------------------------------------"
while($profilename -notlike "exit") {
	$profilename = Read-Host("Please enter profile name or its serial number")
	$foldername.Name | %	{
		if($_ -like $profilename) {
			$dockerpath = "$PsScriptRoot\Release\$profilename"
			break
		}	
	}
	if ($q -eq 1){break}
	"Incorrect profile name or number, type 'exit' to return."	
}
$t = 0
$fromdocker = @{}
$dockerfile = Get-Content -path $dockerpath\dockerfile
for ($i =0 ; $i -lt $dockerfile.Length; $i++){
	if ($dockerfile[$i] -like "*FROM *"){
		$fromdocker[$t] = $dockerfile[$i]
		$t++
	}
}
#$fromdocker = $fromdocker -split "#"
if ($fromdocker.Length -eq 1){
	for ($i = 0; $i -lt $fromdocker.Length; $i++){   

		$newvalue += $fromdocker.Values[$i] -creplace "AS(.+)" -replace "#"
	}
	if ($newvalue[0] -ne $newvalue[1] -and $newvalue.Length -gt 1){
		"_____________________________________________"
		"WARNING: two different images will be created"
		"_____________________________________________"
	}
}
$imagename = Read-Host("Please enter image name")
docker build -t $imagename $dockerpath
$imagerep = docker images --format "{{.Repository}}"
$tagname = Get-Content $PsScriptRoot\Release\$profilename\dockerfile
$tagname = $tagname[0] -replace "(.+)AS "
$tagname = $tagname.ToLower()
$imageid = docker images --format "{{.ID}}"
$newname1 = $imagename + "/" + $tagname
if ($imagerep -contains "<none>"){
	$secondtagname = Get-Content $PsScriptRoot\Release\$profilename\dockerfile | Select-String -pattern "AS" -CaseSensitive
	$secondtagname = $secondtagname[1] -replace "(.+)AS "
	$secondtagname = $secondtagname.ToLower()
	$newname2 = $imagename + "/" + $secondtagname
	docker tag $imageid[1] $newname1
	docker tag $imagename $newname2
}
else{
	docker tag $imagename $newname1
}
$rmi = docker rmi $imagename
pause