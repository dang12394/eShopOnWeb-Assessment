param (
    [string]$ZipPath = "C:\tools\app.zip",
    [string]$DeployPath = "C:\tools\eShop",
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

#Switch to Developer Mode
$webConfigPath = Join-Path $deployPath "web.config"

if (Test-Path $webConfigPath) {
    [xml]$webConfig = Get-Content $webConfigPath

    # Get the aspNetCore element
    $aspNetCore = $webConfig.configuration.'system.webServer'.aspNetCore

    if (-not $aspNetCore.environmentVariables) {
        $envVars = $webConfig.CreateElement("environmentVariables")
        $aspNetCore.AppendChild($envVars) | Out-Null
    }

    # Check if the env var already exists
    $existing = $aspNetCore.environmentVariables.environmentVariable |
        Where-Object { $_.name -eq "ASPNETCORE_ENVIRONMENT" }

    if (-not $existing) {
        $envVar = $webConfig.CreateElement("environmentVariable")
        $envVar.SetAttribute("name", "ASPNETCORE_ENVIRONMENT")
        $envVar.SetAttribute("value", "Development")
        $aspNetCore.environmentVariables.AppendChild($envVar) | Out-Null
    }

    $webConfig.Save($webConfigPath)
    Write-Host "✅ Set ASPNETCORE_ENVIRONMENT=Development in web.config"
} else {
    Write-Warning "⚠️ web.config not found at $webConfigPath"
}