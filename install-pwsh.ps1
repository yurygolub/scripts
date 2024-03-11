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

function Install-Pwsh
{
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
        Write-Host "Downloading '$pwshInstaller' from '$downloadUrl'"
        curl.exe -L $downloadUrl -o $pwshInstallerPath
    }

    $pwshInstallLog = Join-Path $tempDir -ChildPath 'pwsh-install.log'
    msiexec.exe /package $pwshInstallerPath /log $pwshInstallLog
}

Install-Pwsh
