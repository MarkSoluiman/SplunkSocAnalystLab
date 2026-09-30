$ErrorActionPreference = "SilentlyContinue"

Write-Host "Cleaning SOC lab artifacts..."

$runPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if (Test-Path $runPath) {
    $props = (Get-ItemProperty -Path $runPath).PSObject.Properties |
        Where-Object { $_.Name -like "OneDriveUpdate_*" }
    foreach ($p in $props) {
        Remove-ItemProperty -Path $runPath -Name $p.Name -Force -ErrorAction SilentlyContinue
    }
}

Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object { $_.TaskName -like "WindowsUpdate_*" } |
    Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

Remove-Item -Path "HKCU:\Software\SOC-Lab" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Temp\SOC-Lab" -Recurse -Force -ErrorAction SilentlyContinue

Get-ChildItem -Path "C:\Temp" -Force -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "invoice_*.txt" -or
        $_.Name -like "archive_*.txt" -or
        $_.Name -like "soc_run_*.txt" -or
        $_.Name -like "soc_task_*.txt"
    } |
    Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "SOC lab cleanup complete."
