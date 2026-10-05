$ErrorActionPreference = "SilentlyContinue"

$labRoot = "C:\Temp\SOC-Lab"
$now = Get-Date
New-Item -ItemType Directory -Path $labRoot -Force | Out-Null

$caseNumber = Get-Random -Minimum 100000 -Maximum 999999
$scenario = ($caseNumber % 9) + 1

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
        $logFile = "$labRoot\log_$caseNumber.txt"
        $response = Invoke-WebRequest -Uri "https://secure.eicar.org/eicar.com" -UseBasicParsing -TimeoutSec 5
        $plainText = [Text.Encoding]::ASCII.GetString($response.Content)
        $payload = "Set-Content -Path '$labRoot\Update_$caseNumber.exe.txt' -Value '$plainText' -Encoding ASCII -NoNewLine"


        "Suspicious file downloaded at $($now.ToString('HH:mm:ss')) on $($now.ToString('yyyy-MM-dd'))" | Add-Content -Path $logFile

        try {
            Start-Process -FilePath "powershell.exe" -ArgumentList @(
                "-NoProfile",
                "-WindowStyle", "Hidden",
                "-Command", $payload
            )
        }
        catch {
            <#Do this if a terminating exception happens#>
        }

    }

    8 {
        ## If 7zip is not on the device, install it
        if (-not( Test-Path "C:\Program Files\7-Zip\7z.exe")) {
            Invoke-WebRequest -Uri "https://github.com/ip7z/7zip/releases/download/26.03/7z2603-x64.exe" -OutFile "$labRoot\7zip.exe"
            Start-Process -FilePath "$labRoot\Google.log.exe" -ArgumentList @("/S") -WindowStyle Hidden -Wait
        }
        Set-Content -Path "$labRoot\Invoices_$caseNumber.txt" -Value 'Invoices of every employee in the company' -NONewLine
        $Data = @(
            [pscustomobject]@{ ID = 1; FirstName = "John"; LastName = "Doe"; Role = "Admin" }
            [pscustomobject]@{ ID = 2; FirstName = "Jane"; LastName = "Smith"; Role = "User" }
        )
        $Data | Export-Csv -Path "$labRoot\UsersInfo_$caseNumber.csv" -NoTypeInformation

        $cmdFile = "$labRoot\$caseNumber.cmd"

        ##CMD Block
        @'
@echo off

cd /d "C:\Temp\SOC-Lab"

echo.
echo Files Found:
dir *.txt *.csv
echo.

set "Pass=WW91d2lsbG5ldmVyZ2V0dGhlcGFzc3dvcmRIQUhBIQ=="

for /f "delims=" %%P in ('powershell.exe -NoProfile -Command "[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%Pass%'))"') do (
set "ZIP_PASS=%%P"
)

echo.

for %%F in (*.txt *.csv) do (
    "C:\Program Files\7-Zip\7z.exe" a -tzip "C:\Temp\SOC-Lab\%%~nF.zip" "%%F" -p%ZIP_PASS% -mem=AES256 && del "%%F"

    if errorlevel 1 (
        echo Error: Failed to Archive "%%F"
    ) else (
        echo Archived "%%F"
    )
)

echo.
'@ | Set-Content -Path $cmdFile -Encoding Ascii




        cmd.exe /d /c $cmdFile

        Start-Process -FilePath "cmd.exe" -ArgumentList @(
            "/c",
            "del `"$cmdFile`""
        ) -Wait

        Write-Host @"
Someone archived our important files and put password on them
Can you please help us figuring out the password?
"@

    }
    9 {
        $cmdFile = "$labRoot\$update_cache.cmd"
        @'
        @echo off
set "ROOT=C:\Temp\SOC-Lab"
set "A=Cac"
set "B=he"
set "COUNT=150"
set "Dir=%A%%B%"
mkdir "%ROOT%\%DIR%"

for /L %%I in (1,1,%COUNT%) do (
    echo Record! %%I. > "%ROOT%\%DIR%\cache_%%I.txt"
)
'@ | Set-Content -Path $cmdFile -Encoding Ascii
        cmd.exe /d /c $cmdFile

        Start-Process -FilePath "cmd.exe" -ArgumentList @(
            "/c",
            "del `"$cmdFile`""
        ) -Wait
    }
}

Write-Host ""
Write-Host "Simulation complete."
Write-Host "Artifacts may intentionally remain on the VM."
Write-Host "Do not rerun this case until you finish investigating it."
Write-Host "Send only the SOC Case ID to your SOC lead."
Write-Host ""
Write-Host ""
