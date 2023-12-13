# Infrastructure Automation Lab

This repo serves as the "answer key" and lesson plan for a 2-day hands-on infrastructure automation lab.
The goal of the lab is for students to fully automate the process of deploying a Proxmox VM to
VMWare Workstation. This serves two purposes: 
1. Gives students the ability to "spin up" a testing environment for future automation development
   and/or testing with PVE
2. Teaches students the skills they will need for future automation work

Tools Covered
- git, Docker, Packer, WSL, VMWare, PVE
- some Bash/PowerShell scripting, including the scripting of API calls

Labs
- create and use a git repository throughout
- create and deploy a containerized build environment
- create and run Packer configs for automating:
    - the installation of a Debian VM from an iso image
    - the installation of the Proxmox Virtualization Environment onto a Debian VM
- use the VMWare Workstation Pro API to clone and deploy a PVE environment
- explore the PVE GUI

Students should not have access to this repo until after the lab. Throughout the 2-day course, the
instructor is directed to provide specific components of this repo to students. The suggested method
for doing this is to create a "class repo" and add the shared components to it one by one,
allowing students to retrieve those files when they're needed.

## Prerequisites

Students should have the following installed and/or downloaded on their workstations:
- VMWare Workstation Pro 
    - "Pro" is required
- WSLv2
- Docker 
    - on the host or in WSL; though the answer key assumes Docker is on the host
- git
- a Debian iso
    - the offline installer, not the "netinst" version

# Suggested 2-Day Lesson Plan

## Day 1, Part 1 (3 hours)

1. Introductory material on infrastructure & infrastructure automation (<u>30m</u>)
    - Discussion / Q&A format; Could benefit from slides in a future iteration
        - What is "infrastructure"?
        - Why are we learning about infrastructure?
        - How do we automate impermanent infrastructure?
    - Introduce the labs
        - Tools we'll cover:
            - git, Docker, Packer, WSL, VMWare, PVE + some Bash/PowerShell scripting
        - What we'll accomplish:
            - create and deploy a containerized build environment
            - create and run Packer configs for automating:
                - the installation of a Debian VM from an iso image
                - the installation of the Proxmox Virtualization Environment onto a Debian VM
            - use the VMWare Workstation Pro API to clone and deploy a PVE environment
            - explore the PVE GUI
2. Familiarization video and demos for git (<u>30m</u>)
    - [Video](https://www.youtube.com/watch?v=HkdAHXoRtos) (12 minutes)
    - Demos:
        - creating a repo on GitHub or Gitlab
        - cloning the repo locally
        - making, staging, and committing changes
        - `git show` and `git restore`
        - `git push`
3. **Hands-On** (<u>15m</u>) 
    - Instruct students to create a repo on the platform of their choice
    - Students should clone the repo locally
    - When complete, instruct students to clone the class repo (which should currently be empty)
4. Break (<u>15m</u>)
5. Familiarization slides and demos for containerization and Docker: (<u>45m</u>)
    - [Video 1](https://www.youtube.com/watch?v=cjXI-yxqGTI) (8 minutes)
    - [Video 2](https://www.youtube.com/watch?v=gAkwW2tuIqE) (11 minutes)
    - Discuss the benefits of containerization and why students might want to containerize their
      build and test environments
    - Demos:
        - running a container
        - building a container image
6. **Hands-On** (<u>45m</u>)
    - Instruct students to create a `/build-env` directory in their local repo
    - Within that repo, they should create a Dockerfile for a build environment
    - Requirements for their image:
        - install Hashicorp Packer and Terraform
    - Students are free to install any other tools they find useful
    - Conclude by having a student demonstrate building and running their image

## Day 1, Part 2 (3 hours)

1. [Video introduction to Packer](https://youtu.be/OmQRpi3CSjU?feature=shared) (<u>30m</u>)
2. Discussion on Packer "internals" (<u>30m</u>)
    - Testing Understanding
        - Discussion points
            - How does Packer interact with virtualization platforms like AWS?
            - Does Packer itself understand how to 'talk' to various platforms? How does it understand
            the platform-specific mechanisms?
            - How can Packer's functionality be extended to new platforms?
        - By the end of the discussion, students should understand that:
            - Packer uses modular plugins to isolate the "integration logic" (how to create or
            manipulate resources within a given virtualization platform) from the "core logic" of
            Packer itself
            - The vast majority of plugins will be using the REST APIs exposed by various virtualization
            platforms and public cloud providers
    - Instruction
        - "Bare Metal" Considerations
            - When using Packer for the public cloud, you're generally starting from an image that
              already has an OS installed
            - When using Packer for a private cloud (like Workstation or PVE), you typically have to
              start by installing the OS
            - We will be using Packer to install an OS from an iso (the one students were
              instructed to download). This will create our "base image"
            - We will then use Packer to clone our base image and perform further customization
              (installing PVE)
        - VMWare Workstation Considerations
            - The official Packer plugin for VMWare Workstation is unusual in that it does **not** use
            API calls (even though the Pro version does have an API available)
            - Instead, the plugin runs VMWare executables on the local host
            - These labs still containerize the build environment, but the unusual plugin
            implementation requires us to implement some workarounds; The workarounds will be provided
            by the instructor so students may focus on the core tasks of the labs
3. Introduction to WSL (<u>30m</u>)
    - [Video 1](https://www.youtube.com/watch?v=-atblwgc63E) (10 minutes)
    - [Video 2](https://www.linkedin.com/learning/learning-windows-subsystem-for-linux-16134127/how-wsl-works)
      (5 minutes)
    - Discussion / Q&A
    - Have students open WSL on their own computers
        - guide them through running Linux GUI apps, calling Windows .exe's from Linux, etc.
4. **Hands-On** (<u>30m</u>)
    - Instructor-led walkthrough
    - Add `/build-env` from this repo to the class repo; Instruct students to `git pull`
    - Explain the purpose of the workarounds
        - `link-vmware-binaries.sh`
            - WSL distros are able to run Windows executables, but bc the Packer plugin will believe
              it is running on Linux, we need to link the vmware binaries without the ".exe"
            - We are also creating a dummy script at `/usr/lib/vmware/bin/vmware-vmx` to make sure
              the plugin knows which version of the VMWare driver to use
        - `link-vmware-configs.sh`
            - Similar to the binary linking; make sure the configs that the Packer plugin expects
              are in the right place (or appear to be)
            - `netmap.conf` won't exist by default, but we know what the contents need to be, so we
              simply create a basic version of it if it is not present
        - `prep-network.sh`
            - Packer will attempt to connect to VMs over VNC on the localhost. Because we actually
              want Packer to connect to VNC on the Windows host, we're going to use iptables to DNAT
              connections to Windows
        - `bashrc`
            - most of the provided profile is from WSL's "stock" Debian distro
            - at the bottom, we've added conditional commands to call our three scripts, as well as
              to add the VMWare executables to our PATH
    - Walk students through the "Building the Build Environment" section from the Answer Key below
5. Break (<u>15m</u>)
6. **Hands-On** (<u>15m</u>)
    - Instruct students to create a Debian VM in Workstation, using the iso they were instructed to
      download 
    - Before turning them loose, discuss the "why": Automating an installation from .iso 
      is a lot easier if you first understand the steps that are being automated
7. Packer Demo (<u>45m</u>)
    - Explain Debian "preseed" files
    - Pull up documentation
        - https://wiki.debian.org/DebianInstaller/Preseed
        - https://www.debian.org/releases/stable/example-preseed.txt
    - Explain how the planned Packer config will work
        - Uses VMWare commands to start the VM
        - Connects to the VM over VNC and types a "boot command"
        - The boot command will instruct the installing process to retrieve a preseed file that the
          Packer process is hosting over HTTP
        - The preseed file will contain all config information needed to installation
        - After the VM reboots, Packer can use "provisioners" to connect and perform additional
          installation steps
    - Screenshare and demonstrate `packer build .` for the debian VM in this repo

## Day 2, Part 1 (3 hours)

1. **Hands-On** (<u>2h</u>) 
    - Provide a trimmed-down version of `/packer/debian` to the class repo
        - Provide `debian.pkr.hcl`, but remove:
            - the values of `http_content`, `cpus`, `memory`, and `network`
            - the `provisioner` block
            - Point out to students that links to relevant docs are at the top of the file
        - Provide students with the "Preparation" block from "Packer > Building Debian" in the
          answer key
    - Have students create a packer build of Debian
        - stop this at the 90m mark
    - Conclude by: 
        - Having a student demonstrate their build
        - Get all students to the same stage
            - Add the full `/packer/debian` to the class repo
            - Instruct students to `git pull`
            - Instruct students to `packer build .`
            - Troubleshoot until all students have a successful, standardized build
2. Break (<u>15m</u>) 
3. **Hands-On** (<u>45m</u>) 
    - Instructor-led Walkthrough
    - Guide students through:
        - Manually cloning their packer-debian VM
        - Installing PVE on top of the new VM
            - Follow the steps in `install-pve-1.sh` and `install-pve-2.sh`, but execute manually
              while students follow along
    - Provide `packer/proxmox` to students
    - Walk them through the `packer build`
        - Don't forget the preparation steps in "Packer > Building Proxmox"
    - Ensure all students have a successful, standardized build

## Day 2, Part 2 (3 hours)

1. [Video](https://www.youtube.com/watch?v=nvNqfgojocs) Introduction to Terraform (<u>30m</u>) 
2. VMWare APIs (<u>30m</u>) 
    - Discussion / Explanation
        - The original intent of the lab was to deploy our final VM with Terraform, but the VMWare
          Workstation Terraform provider turned out to be buggy
        - Instead, we will make our own API calls
            - While more manual, this gives us a peek under the hood at what tools like Terraform
              and Packer are actually doing
    - Instructor Demo
        - Referencing the "Cloning Proxmox with the VMWare API" section below:
            - Configure credentials for the vmrest API
            - Start the API
        - Navigate to `http://localhost:8697`; vmrest runs an "API Explorer" in addition to the API
          itself 
        - Demonstrate the "GET VMS" API call from PowerShell. Explanation should include:
            - `Invoke-WebRequest`
            - Including Basic Authentication headers
            - the `ContentType` arg and meaning
            - how to interpret and work with the JSON response
                - `ConvertFrom-Json` and working with PowerShell objects
        - See examples in the `clone-vm.ps1` script
3. **Hands-On** (<u>1h</u>)  
    - Instruct students to create a PowerShell script that will: 
        - Clone the packer-proxmox VM
        - Register the new VM with Workstation
        - Turn the new VM on
    - After 30 minutes, ask for a volunteer to demonstrate their script
        - If no one has finished, that is fine. See how far they've managed to get
    - Pull up the script from this repo, explain it, and demonstrate it
4. Break (<u>15m</u>)  
5. **Hands-On** (<u>45m</u>)  
    - Guide students through connecting to their Proxmox VM from the Windows host's browser
    - Discuss Proxmox/VM networking and `vmbr` devices
    - Download the Alpine lxc template and deploy it
        - Why Alpine? The template is small and will download quickly
    - Demonstrate how to generate an API key and discuss how that will be used for Packer and
      Terraform automation
    - Explore any other aspects of PVE that come to mind, and take questions on any of the lab
      material 

# Lab "Answer Key"

## Building the Build Environment

```PowerShell
# NOTE: FROM THE BASE DIR, NOT FROM build-env/
# build the container
$tag = "niwamo/build-env:1.0" # you will probably want to use your own tag
docker build -t $tag -f ./build-env/Dockerfile .
# export the container
$tarPath = "$env:temp/build-env.tar"
docker export $(docker create $tag) --output=$tarPath
# import as a wsl distro
$wslDir = "$env:LOCALAPPDATA\wsl\build_env"
New-Item -ItemType Directory -Path $wslDir -Force
wsl.exe --import build-env $wslDir $tarPath
# open the distro
wsl -d build-env
```

## Packer

### Building Debian

**Note**: The following step assumes you have placed two items in an `iso` directory at the base of
the repo:
1. a debian iso
2. a "sha256sum" file with the iso hash

```Bash:Preparation
# from WSL in the base repo dir, set environment variables needed by the packer config
export REPO_DIR_WSL=$(pwd)
export REPO_DIR="C:$(pwd | grep -Po "(?<=/mnt/c).*" | sed 's/\//\\/g')"
export IDE_PATH="$REPO_DIR\\iso\\debian-12.2.0-amd64-DVD-1.iso"
export ISO_URL="file:$(find $REPO_DIR_WSL/iso/ -name "*.iso")"
export ISO_CHECKSUM="$(cat $(find $REPO_DIR_WSL/iso/ -name "*sum"))"
export LOCAL_IP=$(ip address show dev eth0 | grep -Po "(?<=inet\s)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
```

```Bash:Execution
# move to packer dir and run build
cd ./packer/debian
packer init .
packer build .
```

### Building Proxmox

```Bash
cd $REPO_DIR_WSL/packer/proxmox
# get the vmx path for our clone
vmx_path="$REPO_DIR\\packer\\debian\\output-debian\\packer-debian.vmx"
targetPath="$REPO_DIR_WSL/packer/debian/output-debian/packer-debian.vmx"
# create a dummy link to fool the packer plugin
ln -s $targetPath $vmx_path
# create the environment variable input for Packer
export VMX_PATH=$vmx_path
# run the build
packer build .
# remember to clean up the hacky symlink
```

## Cloning Proxmox with the VMWare API

```PowerShell
# back on the Windows host
# configure credentials for the API
& 'C:\Program Files (x86)\VMWare\VMWare Workstation\vmrest.exe' -C
# run the API - note, this will "hang", so you'll need a new shell for API calls
& 'C:\Program Files (x86)\VMWare\VMWare Workstation\vmrest.exe'
# in another shell
./vmrest-scripts/clone-vm.ps1
# note: you may need to reopen the VMWare GUI to see the new VM
# kill the vmrest terminal when you're done; no additional cleanup necessary
```

## To Clean Up

```PowerShell
wsl --unregister build-env
rm "$env:TEMP/build-env.tar"
rm -r "$env:LOCALAPPDATA\wsl\build_env"
# optionally, clean up docker
$tag = "niwamo/build-env:1.0" # needs to be same tag as before
$containerIds = (docker container ls -a | Select-String -Pattern "(\w+)(?=\s+$tag)").matches.value
if ($containerIds) {
    foreach ($container in $containerIds) {
        docker container rm $container
    }
}
$tag = ($tag | Select-String -Pattern ".*(?=:)").matches.value
$imageIds = (docker image ls -a | Select-String -Pattern "(?<=$tag\s+\S+\s+)\S+").matches.value
if ($imageIds) {
    foreach ($image in $imageIds) {
        docker image rm $image
    }
}
# optionally, 
#   - remove VMs from VMWare Workstation (use the GUI console)
#   - remove any new VM dirs in VMWare Workstation's default path
#   - remove the packer 'output-<vmname>' directories
```
