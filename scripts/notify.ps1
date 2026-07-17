<#
.SYNOPSIS
  Desktop-notification helper for the llm-wiki automation. Dot-source this file to
  get the Send-WikiNotification function.

.DESCRIPTION
  Send-WikiNotification pops a Windows toast. It tries BurntToast first (the intended
  path), falls back to a legacy NotifyIcon balloon if BurntToast is unavailable, and
  degrades to a no-op if neither works. It NEVER throws — a failed notification must
  not be able to fail an automation run.
#>

function Send-WikiNotification {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet("ok", "error")][string]$Level = "ok"
    )

    # Primary: BurntToast (modern Windows toast, survives after the process exits).
    try {
        if (Get-Module -ListAvailable -Name BurntToast) {
            Import-Module BurntToast -ErrorAction Stop
            New-BurntToastNotification -Text $Title, $Message -ErrorAction Stop
            return
        }
    } catch {
        # fall through to the balloon fallback
    }

    # Fallback: System.Windows.Forms NotifyIcon balloon tip. Works without any module,
    # but only while this process is alive, so we hold it briefly.
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $icon = if ($Level -eq "error") {
            [System.Windows.Forms.ToolTipIcon]::Error
        } else {
            [System.Windows.Forms.ToolTipIcon]::Info
        }
        $ni = New-Object System.Windows.Forms.NotifyIcon
        $ni.Icon = [System.Drawing.SystemIcons]::Information
        $ni.Visible = $true
        $ni.ShowBalloonTip(8000, $Title, $Message, $icon)
        Start-Sleep -Milliseconds 8500
        $ni.Dispose()
        return
    } catch {
        # Neither path worked; a missing notification is not fatal. Swallow it.
    }
}
