# Optional param
param (
    [string]$module = ""
)

# Load env
$envFilePath = Join-Path -Path $PSScriptRoot -ChildPath '.env'
$Config = @{}

# Dynamic config building
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | Where-Object { $_ -match '^\s*[^#]' -and $_ -match '=' } | ForEach-Object {
        $name, $value = $_.Split('=', 2)
        $name = $name.Trim()
        $value = $value.Trim(" `"'")

        # Recognizing pattern
        if ($name -match '^([a-zA-Z0-9_]+)_(PROJECT_DIR|MEASUREMENTS_DIR)$') {
            $modName = $Matches[1]
            $varType = $Matches[2]

            if (-not $Config.ContainsKey($modName)) {
                $Config[$modName] = @{}
            }

            if ($varType -eq 'PROJECT_DIR') {
                $Config[$modName].ProjectDir = $value
            } elseif ($varType -eq 'MEASUREMENTS_DIR') {
                $Config[$modName].MeasurementsDir = $value
            }
        }
    }
} else {
    Write-Host "Error: .env file not found at path $envFilePath" -ForegroundColor Red
    exit
}

# Check if any modules were loaded
if ($Config.Count -eq 0) {
    Write-Host "Error: No valid module definitions found in the .env file" -ForegroundColor Red
    exit
}

# Interactive selection menu
$Keys = $Config.Keys | Sort-Object
if ([string]::IsNullOrWhiteSpace($Module)) {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host " Select a module to test" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan

    for ($i = 0; $i -lt $Keys.Count; $i++) {
        Write-Host " [$($i + 1)] $($Keys[$i])" -ForegroundColor Cyan
    }

    $Choice = Read-Host "`nEnter number"
    $Index = [int]$Choice - 1

    if ($Index -ge 0 -and $Index -lt $Keys.Count) {
        $Module = $Keys[$Index]
    } else {
        Write-Host "Invalid choice. Closing script." -ForegroundColor Red
        exit
    }
} elseif (-not $Config.ContainsKey($Module)) {
    Write-Host "Module '$Module' does not exist in the .env file." -ForegroundColor Red
    exit
}

# Assign selected paths
$ProjectDir = $Config[$Module].ProjectDir
$MeasurementsDir = $Config[$Module].MeasurementsDir

Write-Host "`n>>> Starting tests for: $Module" -ForegroundColor Cyan

# Ensure the measurement folder exists
if (-not (Test-Path $MeasurementsDir)) {
    New-Item -ItemType Directory -Force -Path $MeasurementsDir | Out-Null
}

$TimeOutputFile = Join-Path -Path $MeasurementsDir -ChildPath 'angular_android_clean_build_times.log'

"--- Clean build time measurements Angular - $Module ---" | Out-File -FilePath $TimeOutputFile -Encoding UTF8
$TotalTime = 0

# Save original path and change working directory for angular commands
$OriginalLocation = Get-Location
Set-Location -Path $ProjectDir

# Limiting memory to match other scripts
$env:NODE_OPTIONS = "--max-old-space-size=4096"

# Environment preparation
Write-Host "`n>>> Preparing environment..." -ForegroundColor Magenta
if (Test-Path ".angular") { Remove-Item -Path ".angular" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue }
npm install | Out-Null
npx ng build --configuration production | Out-Null
npx cap sync android | Out-Null
Push-Location "android"
.\gradlew.bat assembleRelease | Out-Null
Pop-Location

for ($i = 1; $i -le 10; $i++) {
    Write-Host ("`n>>> Angular clean build starting iteration ${i} of 10...") -ForegroundColor Cyan

    # Cache cleanup
    Write-Host ">>> Cleaning Angular cache..." -ForegroundColor Magenta
    if (Test-Path ".angular") { Remove-Item -Path ".angular" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue }

    Write-Host ">>> Cleaning Android Gradle cache..." -ForegroundColor Magenta
    Push-Location "android"
    .\gradlew.bat clean | Out-Null
    Pop-Location

    # Rebuilding config
    Write-Host ">>> Checking dependencies..." -ForegroundColor Magenta
    npm install | Out-Null

    # Clean build
    Write-Host ">>> Building project..." -ForegroundColor Magenta
    $time = Measure-Command {
        npx ng build --configuration production 2>&1
        npx cap sync android 2>&1
        Push-Location "android"
        .\gradlew.bat assembleRelease 2>&1
        Pop-Location
    }

    $ms = [Math]::Round($time.TotalMilliseconds, 2)
    $TotalTime += $ms

    Write-Host ("Iteration: ${i}: $ms ms") -ForegroundColor Green
    $ms | Out-File -Append $TimeOutputFile -Encoding UTF8
}

$Average = [Math]::Round(($TotalTime / 10), 2)
'-----------------------------------------' | Out-File -Append $TimeOutputFile -Encoding UTF8
("Average: $Average ms") | Out-File -Append $TimeOutputFile -Encoding UTF8

Write-Host ("`nMeasurements completed. Results are located in:`n$MeasurementsDir") -ForegroundColor Yellow

# Restore original path
Set-Location -Path $OriginalLocation
