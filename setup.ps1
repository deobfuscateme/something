# elevate if not admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrator")) {
    Start-Process powershell -Verb runAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# helper: download & wait
function Install-Silent($url, $args = "/quiet", $out = "$env:TEMP\temp.exe") {
    Invoke-WebRequest -Uri $url -OutFile $out
    Start-Process -FilePath $out -ArgumentList $args -Wait
    Remove-Item $out -Force
}

# install Quadro T1000 driver
Install-Silent "https://us.download.nvidia.com/Windows/537.42/537.42-quadro-desktop-notebook-win10-win11-64bit-international-dch-whql.exe"

# install software using winget
$wingetApps = @(
    "OpenJS.NodeJS",
    "Git.Git",
    "Spotify.Spotify",
    "Google.Chrome",
    "Discord.Discord",
    "Discord.DiscordCanary",
    "Valve.Steam",
    "7zip.7zip",
    "RARLab.WinRAR",
    "OBSProject.OBSStudio",
    "Notepad++.Notepad++",
    "Brave.Brave",
    "VideoLAN.VLC",
    "Microsoft.PowerToys",
    "TranslucentTB.TranslucentTB",
    "Obsidian.Obsidian",
    "Signal.Signal",
    "qBittorrent.qBittorrent",
    "SuperF4.SuperF4",
    "SystemInformer.SystemInformer",
    "PowerShell.PowerShell",
    "FlowLauncher.FlowLauncher",
    "CheatEngine.CheatEngine",
    "VSCodium.VSCodium",
    "LibreWolf.LibreWolf",
    "Mozilla.Firefox",
    "MP3Tag.MP3Tag",
    "Fiddler.FiddlerClassic",
    "Insomnia.Insomnia",
    "WiresharkFoundation.Wireshark",
    "WizTree.WizTree",
    "AutoHotkey.AutoHotkey",
    "AutoHotkey.AutoHotkeyv2",
    "StartIsBack.StartAllBack"
)
foreach ($app in $wingetApps) {
    try { winget install --id $app -e --accept-package-agreements --accept-source-agreements } catch {}
}

# special installers
Install-Silent "https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe" "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1 Include_pip=1 Include_tcltk=0"
Install-Silent "https://aka.ms/vs/17/release/vc_redist.x64.exe"
Install-Silent "https://aka.ms/vs/17/release/vc_redist.x86.exe"
Install-Silent "https://download.microsoft.com/download/1/8/D/18D86821-1105-4C6B-9DF9-2280E5BBE28C/directx_Jun2010_redist.exe" "/Q /T:$env:TEMP\dx"
Start-Process "$env:TEMP\dx\DXSETUP.exe" -ArgumentList "/silent" -Wait

# fishstrap, hxd, ilspy, etc (example URLs, adjust if needed)
$manualInstalls = @{
    "https://github.com/fishfolk/fishstrap/releases/latest/download/fishstrap.exe" = "fishstrap.exe"
    "https://mh-nexus.de/downloads/HxDSetup.zip" = "HxDSetup.zip"
    "https://github.com/icsharpcode/ILSpy/releases/latest/download/ILSpy_binaries.zip" = "ILSpy.zip"
    "https://github.com/PrismLauncher/PrismLauncher/releases/latest/download/PrismLauncher-Windows-MSVC.zip" = "PrismLauncher.zip"
}
foreach ($url in $manualInstalls.Keys) {
    $out = "$env:TEMP\" + $manualInstalls[$url]
    Invoke-WebRequest $url -OutFile $out
}

# install vencord
Invoke-WebRequest "https://github.com/Vencord/Installer/releases/latest/download/VencordInstaller.exe" -OutFile "$env:TEMP\vencord.exe"
Start-Process "$env:TEMP\vencord.exe" -ArgumentList "/S" -Wait

# set vencord config
$vcSettings = "$env:APPDATA\Vencord\settings"
New-Item -Force -ItemType Directory -Path $vcSettings
Invoke-WebRequest -Uri "https://github.com/deobfuscateme/something/archive/refs/heads/main.zip" -OutFile "$env:TEMP\vc.zip"
Expand-Archive "$env:TEMP\vc.zip" -DestinationPath "$env:TEMP\vc"
Copy-Item "$env:TEMP\vc\something-main\vencord\*" $vcSettings -Recurse -Force

# winrar key
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/deobfuscateme/something/main/rarreg.key" -OutFile "C:\Program Files\WinRAR\rarreg.key"

# obs config
$obsPath = "$env:APPDATA\obs-studio"
Copy-Item "$env:TEMP\vc\something-main\obs-studio" -Destination "$obsPath" -Recurse -Force

# download pirate folder content
$pirate = "$env:USERPROFILE\Desktop\pirate"
New-Item -ItemType Directory -Force -Path $pirate
$pirateLinks = @(
    "https://files.1progs.ru/wp-content/uploads/2024/12/Soundpad-4.0.9.rar",
    "https://files.1progs.ru/wp-content/uploads/2024/04/Uninstall-Tool-3.7.4.5725.rar",
    "https://files.1progs.ru/wp-content/uploads/2025/05/CCleaner-Professional-Plus-6.36.rar",
    "https://files.1progs.ru/wp-content/uploads/2025/06/IObit-Driver-Booster-Pro-12.5.0.597.rar",
    "https://files.1progs.ru/wp-content/uploads/2023/09/HTTP-Debugger-Pro-9.12.rar",
    "https://cloud.mail.ru/public/8GQo/enYewdcjS"
)
foreach ($link in $pirateLinks) {
    $name = ($link -split '/' | Select-Object -Last 1)
    Invoke-WebRequest $link -OutFile "$pirate\$name"
}

# extract rar files (password: 1progs)
$rarFiles = Get-ChildItem $pirate -Filter *.rar
foreach ($file in $rarFiles) {
    $outFolder = "$pirate\$($file.BaseName)"
    Start-Process "C:\Program Files\WinRAR\WinRAR.exe" -ArgumentList "x -p1progs `"$($file.FullName)`" `"$outFolder\`"" -Wait
}

# install VMware manually
Invoke-WebRequest "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/17.6.3/24583834/windows/core/VMware-workstation-17.6.3-24583834.exe.tar" -OutFile "$env:TEMP\vmware.tar"
# tar extraction left to manual step or 7zip

# enable WSL and install Arch
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
wsl --install -d Arch
