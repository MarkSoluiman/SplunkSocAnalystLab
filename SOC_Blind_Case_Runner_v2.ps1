$ErrorActionPreference = "SilentlyContinue"

$labRoot = "C:\Temp\SOC-Lab"
$now = Get-Date
New-Item -ItemType Directory -Path $labRoot -Force | Out-Null

$caseNumber = Get-Random -Minimum 100000 -Maximum 999999
$scenario = ($caseNumber % 7) + 1

Write-Host ""
Write-Host "SOC LAB CASE ID: SOC-$caseNumber"
Write-Host "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Generating telemetry..."
Write-Host ""

switch ($scenario) {

    1 {
        $cmdFile = "$labRoot\updater_$caseNumber.cmd"
        $logFile = "$labRoot\run_$caseNumber.log"
        $valueName = "OneDriveUpdate_$caseNumber"

        @"
@echo off
echo SOC-LAB case $caseNumber ran at %DATE% %TIME% as %USERNAME%>>"$logFile"
"@ | Set-Content -Path $cmdFile -Encoding ASCII

        Start-Process -FilePath "reg.exe" -ArgumentList @(
            "add",
            "HKCU\Software\Microsoft\Windows\CurrentVersion\Run",
            "/v", $valueName,
            "/t", "REG_SZ",
            "/d", "`"$cmdFile`"",
            "/f"
        ) -WindowStyle Hidden -Wait
    }

    2 {
        $taskName = "WindowsUpdate_$caseNumber"
        $cmdFile = "$labRoot\task_$caseNumber.cmd"
        $logFile = "$labRoot\task_run_$caseNumber.log"

        @"
@echo off
echo SOC-LAB scheduled task $caseNumber ran at %DATE% %TIME%>>"$logFile"
"@ | Set-Content -Path $cmdFile -Encoding ASCII

        Start-Process -FilePath "schtasks.exe" -ArgumentList @(
            "/Create",
            "/SC", "MINUTE",
            "/MO", "30",
            "/TN", $taskName,
            "/TR", "`"$cmdFile`"",
            "/F"
        ) -WindowStyle Hidden -Wait

        Start-Sleep -Seconds 2

        Start-Process -FilePath "schtasks.exe" -ArgumentList @(
            "/Run",
            "/TN", $taskName
        ) -WindowStyle Hidden -Wait
    }

    3 {
        $marker = "$labRoot\report_$caseNumber.txt"

        $payload = @"
Set-Content -Path '$marker' -Value 'SOC-LAB case $caseNumber'
try {
    Invoke-WebRequest -UseBasicParsing -Method Head -Uri 'https://Google.com/' -TimeoutSec 5 | Out-Null
} catch {}
"@

        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($payload))

        Start-Process -FilePath "powershell.exe" -ArgumentList @(
            "-NoProfile",
            "-WindowStyle", "Hidden",
            "-EncodedCommand", $encoded
        ) -WindowStyle Hidden -Wait
    }

    4 {
        $src = "$labRoot\invoice_$caseNumber.txt"
        $dst = "$labRoot\archive_$caseNumber.txt"

        Set-Content -Path $src -Value "SOC-LAB training data $caseNumber"

        Start-Process -FilePath "certutil.exe" -ArgumentList @(
            "-encode",
            $src,
            $dst
        ) -WindowStyle Hidden -Wait

        Start-Sleep -Seconds 2
        Remove-Item $src -Force -ErrorAction SilentlyContinue
    }

    5 {
        $cfg = "$labRoot\config_$caseNumber.ini"
        Set-Content -Path $cfg -Value @(
            "[SOC-LAB]",
            "Case=$caseNumber",
            "Mode=Training"
        )

        Start-Process -FilePath "attrib.exe" -ArgumentList @(
            "+h",
            $cfg
        ) -WindowStyle Hidden -Wait

        Start-Process -FilePath "reg.exe" -ArgumentList @(
            "add",
            "HKCU\Software\SOC-Lab\Config",
            "/v", "LastRun_$caseNumber",
            "/t", "REG_SZ",
            "/d", $cfg,
            "/f"
        ) -WindowStyle Hidden -Wait
    }

    6 {
        $outFile = "$labRoot\host_inventory_$caseNumber.txt"

        Start-Process -FilePath "cmd.exe" -ArgumentList @(
            "/c",
            "whoami /all > `"$outFile`" & echo.>>`"$outFile`" & ipconfig /all >>`"$outFile`" & echo.>>`"$outFile`" & tasklist >>`"$outFile`" & echo.>>`"$outFile`" & net user >>`"$outFile`" & echo.>>`"$outFile`" & arp -a >>`"$outFile`""
        ) -WindowStyle Hidden -Wait
    }

    7 {
        $logFile="$labRoot\log_$caseNumber.txt"
        $response= Invoke-WebRequest -Uri "https://secure.eicar.org/eicar.com" -UseBasicParsing -TimeoutSec 5
        $plainText=[Text.Encoding]::ASCII.GetString($response.Content)
        $payload="Set-Content -Path '$labRoot\Update_$caseNumber.exe.txt' -Value '$plainText' -Encoding ASCII -NoNewLine"


"Suspicious file downloaded at $($now.ToString('HH:mm:ss')) on $($now.ToString('yyyy-MM-dd'))" | Add-Content -Path $logFile

try {
    Start-Process -FilePath "powershell.exe" -ArgumentList @(
    "-NoProfile",
    "-WindowStyle","Hidden",
    "-Command", $payload
    )
}
catch {
    <#Do this if a terminating exception happens#>
}

    }
}

Write-Host ""
Write-Host "Simulation complete."
Write-Host "Artifacts may intentionally remain on the VM."
Write-Host "Do not rerun this case until you finish investigating it."
Write-Host "Send only the SOC Case ID to your SOC lead."
Write-Host ""
