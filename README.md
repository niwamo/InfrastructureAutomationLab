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
# link vmware exe's
/repo/build-env/link-vmware-binaries.sh
export PATH="${PATH}:/vmware"
# trigger netmap
vmnetcfg
# change settings > okay > exit
/repo/build-env/link-vmware-configs.sh
```

## Running Packer

```Bash
# need iptables (output)

# need to create dummy license
touch /etc/vmware/license-ws-dummy
# from inside the container
cd /repo/packer/debian
packer init .
packer build .
```


# OUTPUT: DNAT       tcp  --  anywhere             anywhere             tcp dpt:5900 to:192.168.48.1:5900
# POSTROUTE: MASQUERADE  all  --  anywhere             anywhere             ADDRTYPE match src-type LOCAL dst-type UNICAST

# get-nettcpconnection | where {($_.State -eq "Listen")} | select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | ft
# gwmi win32_process | where name -match vmware-vmx

ide0:0.filename = "C:\Users\nwm\tmp\cyberopsinfra\iso\debian-12.2.0-adm64-DVD-1.iso"

iptables -t nat -A OUTPUT -o lo -p tcp -m tcp --dport 5900 -j DNAT --to-destination 10.0.3.22:5900
root@desk:/repo/packer/debian# iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL
--dst-type UNICAST -j MASQUERADE

strace lsof