#!/bin/bash 

mkdir /vmware

vmwareDir='/mnt/c/Program Files (x86)/VMWare/VMWare Workstation'
binaries=$(ls "$vmwareDir"/*.exe | cut -d '/' -f 7 | cut -d '.' -f 1)

for bin in $binaries;
do
    ln -s "$vmwareDir"/$bin.exe /vmware/$bin
done

mkdir -p /usr/lib/vmware/bin
cat << EOF > /usr/lib/vmware/bin/vmware-vmx
#!/bin/bash
>&2 echo VMWare Workstation 10.
EOF
chmod +x /usr/lib/vmware/bin/vmware-vmx
