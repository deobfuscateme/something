# requires admin
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Install-Silent {
    param (
        [string]$url,
        [string]$args = "/quiet /norestart",
        [string]$name = "installer.exe"
    )
    $path = "$env:TEMP\$name"
    Invoke-WebRequest -Uri $url -OutFile $path
    Start-Process -FilePath $path -ArgumentList $args -Wait
    Remove-Item $path -Force
}

function Winget-Install {
    param ([string]$pkg)
    winget install --id $pkg --accept-source-agreements --accept-package-agreements -e
}

function Log {
    param ([string]$text)
    Write-Host "[+] $text" -ForegroundColor Cyan
}

# make sure winget exists
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Log "Winget not found, installing App Installer from MS Store"
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\appinstaller.msixbundle"
    Start-Process -FilePath "powershell" -ArgumentList "Add-AppxPackage -Path `"$env:TEMP\appinstaller.msixbundle`"" -Wait -NoNewWindow
}

# === start installing core programs ===
Log "Installing development tools"
Install-Silent "https://nodejs.org/dist/latest-v20.x/node-v20.13.1-x64.msi"
Install-Silent "https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe" "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1 Include_doc=0 Include_tcltk=0 Include_pip=1 Include_symbols=0 Include_debug=0"
Winget-Install "Git.Git"

Log "Installing browsers and general tools"
$general = @(
    "Google.Chrome",
    "Spotify.Spotify",
    "Valve.Steam",
    "RARLab.WinRAR",
    "7zip.7zip",
    "Notepad++.Notepad++",
    "Brave.Brave",
    "Mozilla.Firefox",
    "LibreWolf.LibreWolf",
    "OBSProject.OBSStudio",
    "VideoLAN.VLC",
    "Microsoft.PowerToys",
    "qBittorrent.qBittorrent",
    "Microsoft.PowerShell",
    "Obsidian.Obsidian",
    "dotPDN.License",
    "ILSpy.ILSpy"
)

foreach ($pkg in $general) {
    Winget-Install $pkg
}

Log "Installing dev utilities"
Winget-Install "VSCodium.VSCodium"
Winget-Install "Microsoft.VisualStudioCode"
Winget-Install "Postman.Insomnia"
Winget-Install "pnpm.pnpm"
Winget-Install "WiresharkFoundation.Wireshark"
Winget-Install "Oracle.JavaRuntimeEnvironment"
Winget-Install "EclipseAdoptium.Temurin.8.JRE"

Log "Installing Discords"
Winget-Install "Discord.Discord"
Install-Silent "https://discord.com/api/download/canary?platform=win" "/S" "discordcanary.exe"

Log "Installing utilities and misc"
$misc = @(
    "ShareX.ShareX.Dev",
    "StartAllBack.StartAllBack",
    "SuperF4.SuperF4",
    "WOmic.WOmic",
    "Fishstar.Fishstrap",
    "SystemInformer.SystemInformer",
    "HendrikMp3tag.Mp3tag",
    "HxD.HxD",
    "Flow-Launcher.Flow-Launcher",
    "D7WizTree.WizTree",
    "AutoHotkey.AutoHotkey",
    "AutoHotkey.AutoHotkey.v2",
    "Signal.Signal",
    "Fiddler.FiddlerClassic",
    "PrismLauncher.PrismLauncher",
    "LegacyLauncher.LegacyLauncher"
)
foreach ($pkg in $misc) {
    Winget-Install $pkg
}

# === nvidia app (optional) ===
Log "Installing NVIDIA App (manual URL)"
Install-Silent "https://international.download.nvidia.com/nvapp/NVIDIA-app_latest.exe" "/S" "nvidiaapp.exe"

# === directx and vcredist ===
Log "Installing DirectX"
Install-Silent "https://download.microsoft.com/download/1/1/5/11534770-cb16-49ba-97d9-59e175b0e7b5/directx_Jun2010_redist.exe" "/Q /T:$env:TEMP\dx" "dxsetup.exe"
Start-Process "$env:TEMP\dx\DXSETUP.exe" -ArgumentList "/silent" -Wait

Log "Installing VC Redists"
$vc2015_2022_x64 = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vc2015_2022_x86 = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
Install-Silent $vc2015_2022_x64
Install-Silent $vc2015_2022_x86

# === vencord setup ===
Log "Installing Vencord on Discord Stable"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Vencord/Installer/main/install.ps1" -OutFile "$env:TEMP\vencord.ps1"
powershell -ExecutionPolicy Bypass -File "$env:TEMP\vencord.ps1"

Log "Downloading Vencord config"
$venDest = "$env:APPDATA\Vencord\settings"
New-Item -ItemType Directory -Force -Path $venDest
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/deobfuscateme/something/main/vencord/config.json" -OutFile "$venDest\config.json"

# === winrar reg ===
Log "Placing rarreg.key into WinRAR folder"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/deobfuscateme/something/main/rarreg.key" -OutFile "C:\Program Files\WinRAR\rarreg.key"

# === obs config ===
Log "Downloading OBS config"
$obsDest = "$env:APPDATA\obs-studio"
Invoke-WebRequest -Uri "https://github.com/deobfuscateme/something/archive/refs/heads/main.zip" -OutFile "$env:TEMP\obs.zip"
Expand-Archive -Path "$env:TEMP\obs.zip" -DestinationPath "$env:TEMP\obs"
Copy-Item "$env:TEMP\obs\something-main\obs-studio\*" -Destination "$obsDest" -Recurse -Force

# === pirate software ===
$pirateFolder = "$env:USERPROFILE\Desktop\pirate"
New-Item -ItemType Directory -Force -Path $pirateFolder
$pirateLinks = @(
    "https://files.1progs.ru/wp-content/uploads/2024/12/Soundpad-4.0.9.rar",
    "https://files.1progs.ru/wp-content/uploads/2024/04/Uninstall-Tool-3.7.4.5725.rar",
    "https://files.1progs.ru/wp-content/uploads/2025/05/CCleaner-Professional-Plus-6.36.rar",
    "https://files.1progs.ru/wp-content/uploads/2025/06/IObit-Driver-Booster-Pro-12.5.0.597.rar",
    "https://files.1progs.ru/wp-content/uploads/2023/09/HTTP-Debugger-Pro-9.12.rar",
    "https://cloud.mail.ru/public/8GQo/enYewdcjS"
)

foreach ($url in $pirateLinks) {
    $name = Split-Path $url -Leaf
    Invoke-WebRequest -Uri $url -OutFile "$pirateFolder\$name"
}

# === extract with password ===
Log "Extracting archives with password 1progs"
$archives = Get-ChildItem "$pirateFolder\*.rar"
foreach ($file in $archives) {
    $outDir = "$pirateFolder\$($file.BaseName)"
    New-Item -ItemType Directory -Force -Path $outDir
    & "C:\Program Files\WinRAR\WinRAR.exe" x -p1progs -o+ "$($file.FullName)" "$outDir\"
}

# === enable WSL ===
Log "Enabling WSL"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
