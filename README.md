## Building the Build Environment

```PowerShell
cd ./build-env
$image = "niwamo/build-env:1.0"
docker build -t $image .
docker run --rm -it --net=host -v $("//$((Get-Item ../ | select -ExpandProperty fullname).replace('\','/').replace(':','').trim().ToLower()):/repo") $image
```

## Running Packer

```Bash
# from inside the container
cd packer/debian
packer init .
```