FROM microsoft/iis
# Import certificate and grant IIS access to it
#COPY ["./cert","/cert"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

RUN certutil -f -p password -importPFX c:\cert\Some-web.pfx; \
	takeown /f 'C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\*'; \
	icacls 'C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\*' /grant everyone:RX
# Add local integration folders which is mapped to integration folder using a drive on the host
RUN New-Item -Path 'C:\Data\Export\Some' -ItemType Directory;
RUN New-Item -Path 'C:\Data\Import\Some\ImportMe' -ItemType Directory;
RUN New-Item -Path 'C:\Data\Import\Some\Imported' -ItemType Directory;
RUN New-Item -Path 'C:\Data\Import\Some\Failed' -ItemType Directory;
RUN New-WebAppPool -Name 'Some AppPool'; \
	$AppPool = Get-Item 'IIS:\AppPools\Some AppPool'; \
	$AppPool.enable32BitAppOnWin64 = $True; \
	$AppPool.startMode = 'AlwaysRunning'; \
	$AppPool.processModel.loadUserProfile = $True; \
	$AppPool.processModel.idleTimeout = [TimeSpan]::FromMinutes(0); \
	$AppPool.recycling.periodicRestart.time = '00:00:00'; \
	$AppPool | Set-Item; \
	Set-ItemProperty 'IIS:\AppPools\Some AppPool' -Name recycling.periodicRestart.schedule -Value @{value='05:10:00'}; \
	New-Item -Path 'C:\Customer\wwwroot\Some' -ItemType Directory; \
	New-WebApplication -Site 'Default Web Site' -Name '__APPLICATIONNAME__' -PhysicalPath 'C:\Customer\wwwroot\Some' -ApplicationPool 'Some AppPool'; \
	Set-ItemProperty -Path 'IIS:\Sites\Default Web Site\__APPLICATIONNAME__' -Name preloadEnabled -Value $True
RUN New-WebAppPool -Name 'SomeServices AppPool'; \
	$AppPool = Get-Item 'IIS:\AppPools\SomeServices AppPool'; \
	$AppPool.enable32BitAppOnWin64 = $True; \
	$AppPool.startMode = 'AlwaysRunning'; \
	$AppPool.processModel.loadUserProfile = $True; \
	$AppPool.processModel.idleTimeout = [TimeSpan]::FromMinutes(0); \
	$AppPool.recycling.periodicRestart.time = '00:00:00'; \
	$AppPool | Set-Item; \
	Set-ItemProperty 'IIS:\AppPools\Some AppPool' -Name recycling.periodicRestart.schedule -Value @{value='05:10:00'}; \
	New-Item -Path 'C:\Customer\wwwroot\Services' -ItemType Directory; \
	New-WebVirtualDirectory -Site 'Default Web Site' -Name 'Services' -PhysicalPath 'C:\Customer\wwwroot\Services'; \
	New-Item -Path 'C:\Customer\wwwroot\Services\SomeServices' -ItemType Directory; \
	New-WebApplication -Site 'Default Web Site' -Name 'Services/SomeServices' -PhysicalPath 'C:\Customer\wwwroot\Services\SomeServices' -ApplicationPool 'SomeServices AppPool'; \
	Set-ItemProperty -Path 'IIS:\Sites\Default Web Site\Services\SomeServices' -Name preloadEnabled -Value $True
RUN Import-Module WebAdministration; \
	Set-ItemProperty -Path 'IIS:\Sites\Default Web Site\Services\SomeServices' -Name enabledProtocols -Value 'http,net.tcp'
#COPY ["./Some","/Customer/wwwroot/Some"]
#COPY ["./Services/SomeServices","/Customer/wwwroot/Services/SomeServices"]
