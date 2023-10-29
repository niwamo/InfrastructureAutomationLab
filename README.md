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
```

## Packer

### Building Debian

```Bash
# before we move dirs, set environment variables needed by the packer config
export REPO_DIR_WSL=$(pwd)
export REPO_DIR="C:$(pwd | grep -Po "(?<=/mnt/c).*" | sed 's/\//\\/g')"
export IDE_PATH="$REPO_DIR\\iso\\debian-12.2.0-amd64-DVD-1.iso"
export LOCAL_IP=$(ip address show dev eth0 | grep -Po "(?<=inet\s)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
# move to packer dir and run build
cd ./packer/debian
packer init .
packer build .
```

### Building Proxmox

```Bash
# get the vmx path for our clone
vmx_path="$REPO_DIR\\packer\\debian\\output-debian\\packer-debian.vmx"
targetPath="$REPO_CIR_WSL/packer/debian/output-debian/packer-debian.vmx"
# create a dummy link to fool the packer plugin
ln -s $targetPath $vmx_path
export VMX_PATH=$vmx_path
# run the build
packer build .
```

## Cloning Proxmox with the VMWare API

```PowerShell
# back on the Windows host
& 'C:\Program Files (x86)\VMWare\VMWare Workstation\vmrest.exe' -C
& 'C:\Program Files (x86)\VMWare\VMWare Workstation\vmrest.exe'
# in new pane -->
./vm-scripts/clone-vm.ps1
```

## Troubleshooting

```PowerShell:troubleshooting commands used in making this lab
get-nettcpconnection | where {($_.State -eq "Listen")} | `
    select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,@{
            Name="Process";
            Expression={(Get-Process -Id $_.OwningProcess).ProcessName}
        } | ft
gwmi win32_process | where name -match vmware-vmx
strace -f -o /tmp/strace.log cmd
lsof
```