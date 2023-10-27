## Building the Build Environment

```PowerShell
# NOTE: FROM THE BASE DIR, NOT FROM build-env/
# build the container
$image = "niwamo/build-env:1.0"
docker build -t $image -f ./build-env/Dockerfile .
# export the container
$tarPath = "$env:temp/build-env.tar"
docker export $(docker create $image) --output=$tarPath
# import as a wsl distro
$wslDir = "$env:LOCALAPPDATA\wsl\build_env"
New-Item -ItemType Directory -Path $wslDir -Force
wsl.exe --import build-env $wslDir $tarPath
# open the distro
wsl -d build-env
# make the repo easily available in the distro
ln -s $(pwd) /repo
```

```bash
# from inside the container -->
# link vmware exe's
/repo/build-env/link-vmware-binaries.sh
export PATH="${PATH}:/vmware"
# trigger netmap
vmnetcfg
# in the GUI: change settings > okay > exit
/repo/build-env/link-vmware-configs.sh
# prep networking 
/repo/build-env/prep-network.sh
```

## Running Packer

```Bash
# before we move dirs, set environment variables needed by the packer config
# found a workaround for the first several; keeping temporarily for reference
#natNet=$(vmrun listHostNetworks | grep nat)
#ipBase=$(echo $natNet | awk -F " " '{print $5}' | grep -Po "(\d{1,3}\.){3}")
#export VM_IP="${ipBase}79"
#export VM_ROUTER="${ipBase}2"
#export VM_MASK=$(echo $natNet | awk -F " " '{print $6}')
export IDE_PATH="C:$(pwd | grep -Po "(?<=/mnt/c).*" | sed 's/\//\\/g')\\iso\\debian-12.2.0-amd64-DVD-1.iso"
export LOCAL_IP=$(ip address show dev eth0 | grep -Po "(?<=inet\s)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
# move to packer dir and run build
cd /repo/packer/debian
packer init .
packer build .
```

## Troubleshooting

```powershell:troubleshooting commands used in making this lab
get-nettcpconnection | where {($_.State -eq "Listen")} | select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | ft
gwmi win32_process | where name -match vmware-vmx
strace
lsof
```