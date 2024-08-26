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

function Save-File
{
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DownloadUrl,

        [Parameter(Mandatory = $true)]
        [string]
        $OutPath
    )

    Write-Host "Downloading '$OutPath' from '$DownloadUrl'"
    if (Get-Command curl -ErrorAction Ignore -Type Application)
    {
        curl -L $DownloadUrl -o $OutPath
        Write-Host
    }
    else
    {
        Invoke-WebRequest $DownloadUrl -OutFile $OutPath
    }
}

$ErrorActionPreference = 'Stop'

$ytdlpCommand = Get-Command -ErrorAction Ignore -Type Application yt-dlp
if ($ytdlpCommand)
{
    $installationPaths = (Get-Item $ytdlpCommand.Path).Directory.Parent.FullName
    if ($installationPaths -isnot [string])
    {
        $ytdlpPath = $installationPaths[0]
    }
    else
    {
        $ytdlpPath = $installationPaths
    }

    Write-Warning "ytdlp already installed: '$ytdlpPath'"

    $question = 'Do you want to check for newer version?'
    $choices = '&Yes', '&No'

    $checkVersion = $Host.UI.PromptForChoice($null, $question, $choices, 1)

    if ($checkVersion -eq 1)
    {
        return
    }

    $currentVersion = yt-dlp --version

    $baseUrl = 'https://github.com/yt-dlp/yt-dlp/releases'
    $redirected = Get-RedirectedUrl "$baseUrl/latest"
    $tagName = Split-Path $redirected -Leaf

    if ($currentVersion -ne $tagName)
    {
        Write-Host "Current version: $currentVersion. Available version: $tagName"

        $question = "Do you want to install '$tagName'?"
        $choices = '&Yes', '&No'
    
        $reinstall = $Host.UI.PromptForChoice($null, $question, $choices, 1)

        if ($reinstall -eq 1)
        {
            return
        }
    }

    $tempDir = 'temp'
    $null = New-Item -Type Directory $tempDir -Force

    $ytdlpFileName = 'yt-dlp.exe'
    $outputPath = Join-Path $tempDir $ytdlpFileName

    if (!(Test-Path -Path $outputPath))
    {
        $downloadUrl = "$baseUrl/download/$tagName/$ytdlpFileName"
        Save-File -DownloadUrl $downloadUrl -OutPath $outputPath
    }

    Copy-Item $outputPath $ytdlpCommand.Path

    Remove-Item -Recurse -Force $tempDir

    Write-Host
}
