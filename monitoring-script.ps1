$service_exe = "D:\Eurofins-Assessment\eShopOnWeb-Assessment\Monitor\dist\monitor.exe"
$service_name = "IISMonitor"

#Check service exist

$check = sc.exe query $service_name 2>$null | Select-String "SERVICE_NAME" | ForEach-Object { $_.ToString() } | Where-Object { $_ -match $service_name }

if ($check) {
    Write-Host "Service $service_name already exists. Removing it first..."
    & nssm stop $service_name
    & sc.exe delete $service_name
    Start-Sleep -Seconds 2
}

#Install Service

& nssm install $service_name $service_exe
& nssm set $service_name AppDirectory (Split-Path $service_exe)
& nssm set $service_name Start SERVICE_AUTO_START
& nssm set $service_name ObjectName "LocalSystem"
& nssm set $service_name AppExit Default Restart
& nssm set $service_name AppRestartDelay 300000

#Start

& nssm start $service_name

Write-Host "$service_name installed and started."