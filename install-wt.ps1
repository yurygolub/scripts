function Get-RedirectedUrl
{
    param (
        [Parameter(Mandatory = $true)]
        [uri]$url,
        [uri]$referer
    )

    $request = [Net.WebRequest]::CreateDefault($url)
    if ($referer)
    {
        $request.Referer = $referer
    }

    $response = $request.GetResponse()

    if ($response -and $response.ResponseUri.OriginalString -ne $url)
    {
        Write-Verbose "Found redirected url '$($response.ResponseUri)'"
        $result = $response.ResponseUri.OriginalString
    }
    else
    {
        Write-Warning 'No redirected url was found, returning given url.'
        $result = $url
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

function Install-WindowsTerminal
{
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
    $wtBundle = "${wtName}_$($tagName.Substring(1))_8wekyb3d8bbwe.msixbundle"

    $tempDir = 'temp'
    $null = New-Item -Path $tempDir -Type Directory -Force

    $wtBundlePath = Join-Path $tempDir -ChildPath $wtBundle

    if (!(Test-Path -Path $wtBundlePath))
    {
        $downloadUrl = "$baseUrl/download/$tagName/$wtBundle"
        Write-Host "Downloading '$wtBundle' from '$downloadUrl'"
        curl.exe -L $downloadUrl -o $wtBundlePath
    }

    Write-Host "Installing '$wtName'"
    if ($currentShell -eq 'pwsh')
    {
        $command = "Add-AppxPackage $wtBundlePath"
        $process = Start-Process PowerShell -WorkingDirectory $pwd -NoNewWindow -PassThru -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        if ($process.ExitCode -ne 0)
        {
            exit $process.ExitCode
        }
    }
    else
    {
        Add-AppxPackage $wtBundlePath
    }

    Write-Host
}

$ErrorActionPreference = 'Stop'

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning 'You have to run this script as admin'
    return
}

Install-VCLibs

Install-WindowsTerminal
