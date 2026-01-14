# ============================================================
# ClockSecondsChooser.ps1
# Windows System Tray Clock Seconds Chooser
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Dwm {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(
        IntPtr hwnd, int attr, ref int attrValue, int attrSize);
}
"@

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$regName = "ShowSecondsInSystemClock"

if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
$statusText = if ($currentValue -eq 1) { "HUIDIGE STATUS: AAN" } else { "HUIDIGE STATUS: UIT" }

# -----------------------------
# Form
# -----------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Klok – Seconden"
$form.Size = New-Object System.Drawing.Size(520,300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.KeyPreview = $true

# -----------------------------
# Dark / Light mode detectie
# -----------------------------
$themeKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$darkMode = (Get-ItemProperty -Path $themeKey -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme -eq 0

if ($darkMode) {
    $form.BackColor = [System.Drawing.Color]::FromArgb(32,32,32)
    $form.ForeColor = [System.Drawing.Color]::White
    $dark = 1
    [Dwm]::DwmSetWindowAttribute($form.Handle, 20, [ref]$dark, 4) | Out-Null
}

# -----------------------------
# Icoon
# -----------------------------
$BasePath = [AppDomain]::CurrentDomain.BaseDirectory
$iconPath = Join-Path $BasePath "clock.ico"

if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}


# -----------------------------
# Titel
# -----------------------------
$title = New-Object System.Windows.Forms.Label
$title.Text = "Windows systeemklok – seconden"
$title.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(30,25)
$form.Controls.Add($title)

# -----------------------------
# Status label
# -----------------------------
$status = New-Object System.Windows.Forms.Label
$status.Text = $statusText
$status.Font = New-Object System.Drawing.Font("Segoe UI",10)
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(30,65)
$form.Controls.Add($status)

# -----------------------------
# Info label
# -----------------------------
$info = New-Object System.Windows.Forms.Label
$info.Text = "Wil je seconden weergeven in de Windows systeemklok?"
$info.Size = New-Object System.Drawing.Size(460,40)
$info.Location = New-Object System.Drawing.Point(30,95)
$form.Controls.Add($info)

# -----------------------------
# Buttons
# -----------------------------
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}

$btnYes = New-Object System.Windows.Forms.Button
$btnYes.Text = "Ja  (Enter)"
$btnYes.Size = New-Object System.Drawing.Size(120,42)
$btnYes.Location = New-Object System.Drawing.Point(40,160)
$btnYes.Add_Click({
    Set-ItemProperty -Path $regPath -Name $regName -Type DWord -Value 1
    Restart-Explorer
    $form.Close()
})
$form.Controls.Add($btnYes)

$btnNo = New-Object System.Windows.Forms.Button
$btnNo.Text = "Nee"
$btnNo.Size = New-Object System.Drawing.Size(120,42)
$btnNo.Location = New-Object System.Drawing.Point(200,160)
$btnNo.Add_Click({
    Set-ItemProperty -Path $regPath -Name $regName -Type DWord -Value 0
    Restart-Explorer
    $form.Close()
})
$form.Controls.Add($btnNo)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Afsluiten  (Esc)"
$btnExit.Size = New-Object System.Drawing.Size(120,42)
$btnExit.Location = New-Object System.Drawing.Point(360,160)
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# -----------------------------
# Keyboard shortcuts
# -----------------------------
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") { $btnYes.PerformClick() }
    if ($_.KeyCode -eq "Escape") { $form.Close() }
})

# -----------------------------
# Show
# -----------------------------
[void]$form.ShowDialog()
