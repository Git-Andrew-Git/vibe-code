# PowerShell script to launch Godot project from VSCode
# This script attempts to locate the Godot executable automatically.
# It first searches the VSCode extensions directory for any 'godot*.exe'.
# If none is found, it falls back to a conventional install location.

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Search VSCode extensions for Godot executable
$extensionDir = Join-Path $env:USERPROFILE ".vscode\extensions"
$foundExe = Get-ChildItem -Path $extensionDir -Recurse -Filter "godot*.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1

if ($foundExe) {
    $godotPath = $foundExe.FullName
} else {
    # Fallback to typical install location – update if your path differs
    $godotPath = "C:\Program Files\Godot\Godot_v4.7-stable_win64.exe"
}

if (-Not (Test-Path $godotPath)) {
    Write-Error "Godot executable not found at $godotPath. Please ensure Godot is installed or update the fallback path in run_godot.ps1."
    exit 1
}

# Launch Godot editor with the project directory
& "$godotPath" "-e" "--path" "$projectRoot"

