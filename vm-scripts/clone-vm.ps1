# input vars
$username = "tfuser"
$password = "Passw0rd!"
$vmToClone = "packer-proxmox"
$baseURI = "http://localhost:8697/api"

# generate auth header
$auth = $username + ':' + $password
$encodedAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($auth))
$authString = "Basic $encodedAuth"

function Invoke-VMRest {
    param(
        [string]$uri,
        [hashtable]$headers,
        [string]$method = "Get",
        [string]$body = $null 
    )
    if ($body) {
        $response = Invoke-WebRequest -Uri $uri -H $headers -Method $method `
            -ContentType 'application/vnd.vmware.vmw.rest-v1+json' -Body $body
    } else {
        $response = Invoke-WebRequest -Uri $uri -H $headers -Method $method
    }
    $char = $response.RawContentStream.ToArray()
    $str = [Text.Encoding]::UTF8.GetString($char)
    return $str
}

# get list of VMs
$response = Invoke-VMRest -uri "$baseURI/vms" -headers @{Authorization = $authString}
$vmList = $response | ConvertFrom-Json
$parentId = $vmList | Where-Object {$_.path -match $vmToClone} | Select-Object -ExpandProperty id

# clone the parent
$response = Invoke-VMRest -uri "$baseURI/vms" -headers @{Authorization = $authString} `
    -method POST `
    -body $(@{
        name = "proxmox-vm"
        parentId = $parentId
    } | ConvertTo-Json)
$vmId = $response | ConvertFrom-Json | Select-Object -ExpandProperty id

# get list of VMs (again)
$response = Invoke-VMRest -uri "$baseURI/vms" -headers @{Authorization = $authString}
$vmList = $response | ConvertFrom-Json
$vmPath = $vmList | Where-Object {$_.id -eq $vmId} | Select-Object -ExpandProperty path

# register our VM
$response = Invoke-VMRest -uri "$baseURI/vms/registration" -headers @{Authorization = $authString} `
    -method POST `
    -body $(@{
        name = "proxmox-vm"
        path = $vmPath
    } | ConvertTo-Json)

# turn our VM on
$response = Invoke-VMRest -uri "$baseURI/vms/$vmId/power" -headers @{Authorization = $authString} `
    -method PUT -body "on"