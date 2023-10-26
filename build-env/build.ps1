Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 1.1.1.1

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install packer and terraform 
choco install packer terraform -y

New-Item -ItemType Directory C:\repo
New-Item -ItemType Directory C:\vmware

Add-Content -Value '$env:Path += ";C:\vmware"' -Path C:\Users\ContainerAdministrator\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

