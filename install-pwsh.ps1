$ErrorActionPreference = 'Stop'

. .\functions.ps1

function Install-Pwsh
{
    if (Get-Command -ErrorAction Ignore -Type Application pwsh)
    {
        Write-Host 'pwsh already installed'
        return
    }

    $baseUrl = 'https://github.com/PowerShell/PowerShell'
    $redirected = Get-RedirectedUrl "$baseUrl/releases/latest"

    $tagName = Split-Path $redirected -Leaf
    $pwshInstaller = "PowerShell-$($tagName.Substring(1))-win-x64.msi"

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $pwshInstallerPath = Join-Path $tempDir -ChildPath $pwshInstaller
    if (!(Test-Path -Path $pwshInstallerPath))
    {
        $downloadUrl = "$baseUrl/releases/download/$tagName/$pwshInstaller"
        Save-File -DownloadUrl $downloadUrl -OutPath $pwshInstallerPath
    }

    $pwshInstallLog = Join-Path $tempDir -ChildPath 'pwsh-install.log'
    msiexec.exe /package $pwshInstallerPath /log $pwshInstallLog
}

Install-Pwsh
