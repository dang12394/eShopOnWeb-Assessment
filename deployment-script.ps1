param (
    [string]$ZipPath = "C:\tools\app.zip",
    [string]$DeployPath = "D:\Eurofins-Assessment\Demo-app\wwwroot\eShopOnWeb",
    [string]$SiteName = "eShopOnWeb"
)

# Unzip
if (Test-Path $DeployPath) {
    Remove-Item $DeployPath -Recurse -Force
}
New-Item -ItemType Directory -Path $DeployPath | Out-Null
Expand-Archive -Path $ZipPath -DestinationPath $DeployPath

# Set permissions
$identity = "IIS AppPool\DefaultAppPool"
$acl = Get-Acl $DeployPath
$permission = "$identity","Modify","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
Set-Acl -Path $DeployPath -AclObject $acl

# Check if site exists, create if not
Import-Module WebAdministration
if (-Not (Test-Path "IIS:\Sites\$SiteName")) {
    New-Website -Name $SiteName -PhysicalPath $DeployPath -Port 8080 -Force
}
else {
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath -Value $DeployPath
}