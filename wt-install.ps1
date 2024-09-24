param (
    [bool] $Portable = $true,
    [string] $InstallPath
)

$ErrorActionPreference = 'Stop'

. .\functions.ps1

function Install-VCLibs
{
    $isVCLibsExist = $true
    $VCLibName = 'Microsoft.VCLibs.140.00.UWPDesktop'
    $currentShell = [System.AppDomain]::CurrentDomain.FriendlyName
    if ($currentShell -eq 'pwsh')
    {
        $command = "if (!(Get-AppxPackage $VCLibName)) { exit 1 }"
        $process = Start-Process PowerShell -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            $isVCLibsExist = $false
        }
    }
    else
    {
        if (!(Get-AppxPackage $VCLibName))
        {
            $isVCLibsExist = $false
        }
    }

    if ($isVCLibsExist)
    {
        Write-Host "'$VCLibName' already exists"
        return
    }

    $VCLibsAppx = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $VCLibsAppxPath = Join-Path $tempDir -ChildPath $VCLibsAppx
    if (!(Test-Path -Path $VCLibsAppxPath))
    {
        $VCLibsUrl = "https://aka.ms/$VCLibsAppx"
        Save-File -DownloadUrl $VCLibsUrl -OutPath $VCLibsAppxPath
    }

    Write-Host "Installing '$VCLibsAppx'"
    if ($currentShell -eq 'pwsh')
    {
        $command = "Add-AppxPackage $VCLibsAppxPath"
        $process = Start-Process PowerShell -WorkingDirectory $pwd -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            exit $process.ExitCode
        }
    }
    else
    {
        Add-AppxPackage $VCLibsAppxPath
    }

    Write-Host
}

function Install-WindowsTerminalBundle
{
    $wtName = 'Microsoft.WindowsTerminal'
    $currentShell = [System.AppDomain]::CurrentDomain.FriendlyName
    if ($currentShell -eq 'pwsh')
    {
        $command = "if (!(Get-AppxPackage $wtName)) { exit 1 }"
        $process = Start-Process PowerShell -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -eq 0)
        {
            $isWtExist = $true
        }
    }
    else
    {
        if (Get-AppxPackage $wtName)
        {
            $isWtExist = $true
        }
    }

    if ($isWtExist)
    {
        Write-Host "'$wtName' already exists"
        return
    }

    $baseUrl = 'https://github.com/microsoft/terminal/releases'
    $redirected = Get-RedirectedUrl "$baseUrl/latest"

    $tagName = Split-Path $redirected -Leaf

    $wtFileName = "${wtName}_$($tagName.Substring(1))_8wekyb3d8bbwe.msixbundle"

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $wtFilePath = Join-Path $tempDir -ChildPath $wtFileName

    if (!(Test-Path -Path $wtFilePath))
    {
        $downloadUrl = "$baseUrl/download/$tagName/$wtFileName"
        Save-File -DownloadUrl $downloadUrl -OutPath $wtFilePath
    }

    Write-Host "Installing '$wtName'"
    if ($currentShell -eq 'pwsh')
    {
        $command = "Add-AppxPackage $wtFilePath"
        $process = Start-Process PowerShell -WorkingDirectory $pwd -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            exit $process.ExitCode
        }
    }
    else
    {
        Add-AppxPackage $wtFilePath
    }

    Write-Host
}

function Install-WindowsTerminalPortable
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Tag,

        [Parameter(Mandatory = $true)]
        [string] $InstallPath
    )

    $wtName = 'Microsoft.WindowsTerminal'
    $tagNumber = $Tag.Substring(1)
    $wtFileName = "${wtName}_${tagNumber}_x64.zip"

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $wtFilePath = Join-Path $tempDir -ChildPath $wtFileName

    if (!(Test-Path -Path $wtFilePath))
    {
        $downloadUrl = "$baseUrl/download/$Tag/$wtFileName"
        Save-File -DownloadUrl $downloadUrl -OutPath $wtFilePath
    }

    Write-Host "Installing '$wtName'"

    Expand-Archive $wtFilePath -DestinationPath $tempDir

    $tempPath = Join-Path $tempDir -ChildPath "terminal-$tagNumber"

    $null = New-Item -Type Directory $InstallPath -Force
    Remove-Item -Recurse -Force "$InstallPath/*"
    Copy-Item -Recurse "$tempPath/*" $InstallPath
    Remove-Item -Recurse -Force $tempPath

    Write-Host
}

$baseUrl = 'https://github.com/microsoft/terminal/releases'

$wtCommand = Get-Command -ErrorAction Ignore -Type Application wt
if ($wtCommand)
{
    $installationPaths = (Get-Item $wtCommand.Path).Directory.FullName
    if ($installationPaths -isnot [string])
    {
        $wtPath = $installationPaths[0]
    }
    else
    {
        $wtPath = $installationPaths
    }

    Write-Warning "wt already installed: '$wtPath'"

    $question = 'Do you want to check for newer version?'
    $choices = '&Yes', '&No'

    $checkVersion = $Host.UI.PromptForChoice($null, $question, $choices, 1)

    if ($checkVersion -eq 1)
    {
        return
    }

    $redirected = Get-RedirectedUrl "$baseUrl/latest"
    $tagName = Split-Path $redirected -Leaf

    Write-Host "Available version: '$tagName'"

    $question = "Do you want to install '$tagName'?"
    $choices = '&Yes', '&No'

    $reinstall = $Host.UI.PromptForChoice($null, $question, $choices, 1)

    if ($reinstall -eq 0)
    {
        Install-WindowsTerminalPortable -Tag $tagName -InstallPath $wtPath
    }

    return
}

$question = 'How do you want to install WindowsTerminal?'
$choices = '&All users', '&Current user'

$scopeChoice = $Host.UI.PromptForChoice($null, $question, $choices, 1)

if ($scopeChoice -eq 0)
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Warning 'You have to run this script as admin'
        return
    }

    $defaultPath = $Env:ProgramFiles
    $scope = [EnvironmentVariableTarget]::Machine
}
elseif ($scopeChoice -eq 1)
{
    $defaultPath = $Env:LOCALAPPDATA
    $scope = [EnvironmentVariableTarget]::User
}

if ($Portable)
{
    if (!$InstallPath)
    {
        if (!($InstallPath = Read-Host "Input installation path. Default is [$defaultPath]"))
        {
            $InstallPath = $defaultPath
        }
    }

    if (!(Test-Path -Path $InstallPath))
    {
        Write-Warning "Invalid path '$InstallPath'"
        return
    }
    
    $destFolder = 'terminal'
    $destPath = Join-Path $InstallPath -ChildPath $destFolder

    $redirected = Get-RedirectedUrl "$baseUrl/latest"

    $tagName = Split-Path $redirected -Leaf

    Install-WindowsTerminalPortable -Tag $tagName -InstallPath $destPath

    Add-ForSpecifiedPath -Value $destPath -VariableTarget $scope
}
else
{
    Install-VCLibs

    Install-WindowsTerminalBundle
}
