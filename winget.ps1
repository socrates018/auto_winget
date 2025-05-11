if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

<#
.SYNOPSIS
One-time winget upgrade script with automatic execution policy handling

.DESCRIPTION
- Sets execution policy temporarily for this session
- Requests admin elevation via UAC
- Runs winget upgrade with silent flags
- Creates completion log
#>

# Temporarily allow script execution for this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force




# Main upgrade command
try {
    winget upgrade --all --accept-package-agreements --accept-source-agreements --silent --include-unknown --force --disable-interactivity
    $status = "Success"
} catch {
    $status = "Failed: $_"
}

# Create verification log
$logPath = "$env:PUBLIC\winget_upgrade_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
@"
Winget Upgrade Report
---------------------
Date: $(Get-Date)
Status: $status
User: $env:USERNAME
Machine: $env:COMPUTERNAME

Available Upgrades Before Run:
$(winget list --upgrade-available)
"@ | Out-File $logPath

# Show completion message
Write-Host @"
Upgrade process completed with status: $status
Verification log created at: $logPath
(Press any key to close)
"@ -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')