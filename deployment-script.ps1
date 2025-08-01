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

    $nsmgr = New-Object System.Xml.XmlNamespaceManager($webConfig.NameTable)
    $nsmgr.AddNamespace("ns", $webConfig.DocumentElement.NamespaceURI)

    
    $aspNetCore = $webConfig.SelectSingleNode("//ns:aspNetCore", $nsmgr)

    if (-not $aspNetCore) {
        Write-Error "❌ aspNetCore element not found in web.config."
        return
    }

    
    $envVars = $aspNetCore.SelectSingleNode("ns:environmentVariables", $nsmgr)
    if (-not $envVars) {
        $envVars = $webConfig.CreateElement("environmentVariables", $webConfig.DocumentElement.NamespaceURI)
        $aspNetCore.AppendChild($envVars) | Out-Null
    }

    
    $existing = $envVars.SelectSingleNode("ns:environmentVariable[@name='ASPNETCORE_ENVIRONMENT']", $nsmgr)
    if (-not $existing) {
        $envVar = $webConfig.CreateElement("environmentVariable", $webConfig.DocumentElement.NamespaceURI)
        $envVar.SetAttribute("name", "ASPNETCORE_ENVIRONMENT")
        $envVar.SetAttribute("value", "Development")
        $envVars.AppendChild($envVar) | Out-Null
        Write-Host "✅ Set ASPNETCORE_ENVIRONMENT=Development in web.config"
    } else {
        Write-Host "ℹ️ ASPNETCORE_ENVIRONMENT already exists in web.config"
    }

    $webConfig.Save($webConfigPath)
} else {
    Write-Warning "⚠️ web.config not found at $webConfigPath"
}