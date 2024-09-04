$ErrorActionPreference = 'Stop'

. .\functions.ps1

function Install-Notepad
{
    $npp = Get-ChildItem 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall' |
        Where-Object { $_.Name.Contains('Notepad++') }

    if ($npp)
    {
        Write-Host "'$($npp.GetValue('DisplayName')) - $($npp.GetValue('DisplayVersion'))' already installed"
        return
    }

    $baseUrl = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases'
    $redirected = Get-RedirectedUrl "$baseUrl/latest"

    $tagName = Split-Path $redirected -Leaf
    $nppInstaller = "npp.$($tagName.Substring(1)).Installer.exe"

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $nppInstallerPath = Join-Path $tempDir -ChildPath $nppInstaller
    if (!(Test-Path -Path $nppInstallerPath))
    {
        $downloadUrl = "$baseUrl/download/$tagName/$nppInstaller"
        Save-File -DownloadUrl $downloadUrl -OutPath $nppInstallerPath
    }

    & $nppInstallerPath

    Write-Host
}

function Install-Winget
{
    if (Get-Command -ErrorAction Ignore -Type Application winget)
    {
        Write-Host 'winget already installed'
        return
    }

    $isWingetExist = $true
    $wingetName = 'Microsoft.DesktopAppInstaller'
    $currentShell = [System.AppDomain]::CurrentDomain.FriendlyName
    if ($currentShell -eq 'pwsh')
    {
        $command = "if (!(Get-AppxPackage $wingetName)) { exit 1 }"
        $process = Start-Process PowerShell -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            $isWingetExist = $false
        }
    }
    else
    {
        if (!(Get-AppxPackage $wingetName))
        {
            $isWingetExist = $false
        }
    }

    if ($isWingetExist)
    {
        Write-Host "'$wingetName' already exists"
        return
    }

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $wingetBundle = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    $wingetBundlePath = Join-Path $tempDir -ChildPath $wingetBundle

    if (!(Test-Path -Path $wingetBundlePath))
    {
        $downloadUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/$wingetBundle"
        Save-File -DownloadUrl $downloadUrl -OutPath $wingetBundlePath
    }

    Write-Host "Installing '$wingetName'"
    if ($currentShell -eq 'pwsh')
    {
        $command = "Add-AppxPackage $wingetBundlePath"
        $process = Start-Process PowerShell -WorkingDirectory $pwd -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            exit $process.ExitCode
        }
    }
    else
    {
        Add-AppxPackage $wingetBundlePath
    }

    Write-Host
}

function Install-Git
{
    if (Get-Command -ErrorAction Ignore -Type Application git)
    {
        Write-Host 'git already installed'
        return
    }

    if (!(Get-Command -ErrorAction Ignore -Type Application winget))
    {
        Write-Host 'winget not installed'
        return
    }

    winget install --id Git.Git -e --source winget

    Write-Host
}

function Install-Choco
{
    if (Get-Command -ErrorAction Ignore -Type Application choco)
    {
        Write-Host 'choco already installed'
        return
    }

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + ";" + [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)

    Write-Host
}

function Install-ChocoPackage
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Package
    )

    if (!(Get-Command -ErrorAction Ignore -Type Application choco))
    {
        Write-Host 'choco not installed'
        return
    }

    if (choco list --limit-output --exact $Package)
    {
        Write-Host "choco package: '$Package' already installed"
        return
    }

    choco install $Package -y
}

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning 'You have to run this script as admin'
    return
}

Install-Notepad

Install-Winget

Install-Git

Install-Choco

Install-ChocoPackage make
Install-ChocoPackage delta
Install-ChocoPackage gitui
Install-ChocoPackage ilspy
Install-ChocoPackage neovim
