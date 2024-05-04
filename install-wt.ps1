param (
    [switch]$Portable,
    [string]$InstallPath
)

function Get-RedirectedUrl
{
    param (
        [Parameter(Mandatory = $true)]
        [uri]$Url,
        [uri]$Referer
    )

    $request = [Net.WebRequest]::CreateDefault($Url)
    if ($Referer)
    {
        $request.Referer = $Referer
    }

    $response = $request.GetResponse()

    if ($response -and $response.ResponseUri.OriginalString -ne $Url)
    {
        Write-Verbose "Found redirected url '$($response.ResponseUri)'"
        $result = $response.ResponseUri.OriginalString
    }
    else
    {
        Write-Warning 'No redirected url was found, returning given url.'
        $result = $Url
    }

    $response.Dispose()

    return $result
}

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
        Write-Host "Downloading '$VCLibsAppx' from '$VCLibsUrl'"
        curl.exe -L $VCLibsUrl -o $VCLibsAppxPath
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

function Add-ForSpecifiedPath
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [EnvironmentVariableTarget]$VariableTarget
    )

    $currentPath = [Environment]::GetEnvironmentVariable('Path', $VariableTarget)
    if (!($currentPath -split ';' -contains $Value))
    {
        $question = "Do you want to add '$Value' to Path?"
        $choices = '&Yes', '&No'

        $addToPath = $Host.UI.PromptForChoice($null, $question, $choices, 1)
        if ($addToPath -eq 0)
        {
            [Environment]::SetEnvironmentVariable('Path', $currentPath + ";$Value", $VariableTarget)

            $Env:Path = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + ";" + [Environment]::GetEnvironmentVariable('Path',[EnvironmentVariableTarget]::User)
        }
    }
}

function Install-WindowsTerminal
{
    param (
        [switch]$Portable,
        [string]$InstallPath,
        [switch]$Machine
    )

    if (Get-Command -ErrorAction Ignore -Type Application wt.exe)
    {
        Write-Host 'WindowsTerminal already installed'
        return
    }

    $isWtExist = $true
    $wtName = 'Microsoft.WindowsTerminal'
    $currentShell = [System.AppDomain]::CurrentDomain.FriendlyName
    if ($currentShell -eq 'pwsh')
    {
        $command = "if (!(Get-AppxPackage $wtName)) { exit 1 }"
        $process = Start-Process PowerShell -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            $isWtExist = $false
        }
    }
    else
    {
        if (!(Get-AppxPackage $wtName))
        {
            $isWtExist = $false
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
    if ($Portable)
    {
        $wtFileName = "${wtName}_$($tagName.Substring(1))_x64.zip"
    }
    else
    {
        $wtFileName = "${wtName}_$($tagName.Substring(1))_8wekyb3d8bbwe.msixbundle"
    }

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $wtFilePath = Join-Path $tempDir -ChildPath $wtFileName

    if (!(Test-Path -Path $wtFilePath))
    {
        $downloadUrl = "$baseUrl/download/$tagName/$wtFileName"
        Write-Host "Downloading '$wtFileName' from '$downloadUrl'"
        curl.exe -L $downloadUrl -o $wtFilePath
    }

    Write-Host "Installing '$wtName'"
    if ($Portable)
    {
        if (!(Test-Path -Path $InstallPath))
        {
            Write-Warning "Invalid path '$InstallPath'"
            return
        }

        Expand-Archive $wtFilePath -DestinationPath $InstallPath

        $wtBin = Join-Path $InstallPath -ChildPath "terminal-$($tagName.Substring(1))"

        if ($Machine)
        {
            Add-ForSpecifiedPath -Value $wtBin -VariableTarget Machine
        }
        else
        {
            Add-ForSpecifiedPath -Value $wtBin -VariableTarget User
        }
    }
    else
    {
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
    }

    Write-Host
}

$ErrorActionPreference = 'Stop'

$question = 'How do you want to install WindowsTerminal?'
$choices = '&All users', '&Current user'

$choice = $Host.UI.PromptForChoice($null, $question, $choices, 1)

if ($choice -eq 0)
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Warning 'You have to run this script as admin'
        return
    }

    $defaultPath = $Env:ProgramFiles
}
elseif ($choice -eq 1)
{
    $defaultPath = "$Env:USERPROFILE\AppData\Local\"
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

    if ($choice -eq 0)
    {
        Install-WindowsTerminal -Portable -InstallPath $InstallPath -Machine
    }
    elseif ($choice -eq 1)
    {
        Install-WindowsTerminal -Portable -InstallPath $InstallPath
    }
}
else
{
    Install-VCLibs

    Install-WindowsTerminal
}
