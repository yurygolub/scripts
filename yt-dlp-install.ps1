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

function Install-Ytdlp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        [Parameter(Mandatory = $true)]
        [string]$InstallPath
    )

    $tempDir = 'temp'
    $null = New-Item -Type Directory $tempDir -Force

    $ytdlpFileName = 'yt-dlp.exe'
    $outputPath = Join-Path $tempDir $ytdlpFileName

    if (!(Test-Path -Path $outputPath))
    {
        $downloadUrl = "$baseUrl/download/$Tag/$ytdlpFileName"
        Save-File -DownloadUrl $downloadUrl -OutPath $outputPath
    }

    Copy-Item $outputPath $InstallPath

    Remove-Item -Recurse -Force $tempDir

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

$ErrorActionPreference = 'Stop'

$baseUrl = 'https://github.com/yt-dlp/yt-dlp/releases'

$ytdlpCommand = Get-Command -ErrorAction Ignore -Type Application yt-dlp
if ($ytdlpCommand)
{
    $installationPaths = (Get-Item $ytdlpCommand.Path).Directory.FullName
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

    $redirected = Get-RedirectedUrl "$baseUrl/latest"
    $tagName = Split-Path $redirected -Leaf

    if ($currentVersion -ne $tagName)
    {
        Write-Host "Current version: '$currentVersion'. Available version: '$tagName'"

        $question = "Do you want to install '$tagName'?"
        $choices = '&Yes', '&No'

        $reinstall = $Host.UI.PromptForChoice($null, $question, $choices, 1)

        if ($reinstall -eq 0)
        {
            Install-Ytdlp -Tag $tagName -InstallPath $ytdlpPath
        }
    }
    else
    {
        Write-Host "Latest version is already installed: '$tagName'"
    }

    return
}

$title = 'This script will install yt-dlp'
$question = 'How do you want to install it?'
$choices = '&All users', '&Current user'

$scopeChoice = $Host.UI.PromptForChoice($title, $question, $choices, 1)

if ($scopeChoice -eq 0)
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Warning 'You have to run this script as admin'
        return
    }

    $defaultPath = $Env:ProgramFiles
}
elseif ($scopeChoice -eq 1)
{
    $defaultPath = "$Env:USERPROFILE\AppData\Local\"
}

if (!($inputPath = Read-Host "Input installation path. Default is [$defaultPath]"))
{
    $inputPath = $defaultPath
}

if (!(Test-Path -Path $inputPath))
{
    Write-Warning "Invalid path '$inputPath'"
    return
}

$destFolder = 'yt-dlp'
$destPath = Join-Path $inputPath -ChildPath $destFolder

$title = "Latest version of yt-dlp will be installed to '$destPath'"
$question = 'Are you sure you want to proceed?'
$choices = '&Yes', '&No'

$proceedDecision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($proceedDecision -eq 1)
{
    Write-Host 'Abort'
    return
}

$redirected = Get-RedirectedUrl "$baseUrl/latest"
$tagName = Split-Path $redirected -Leaf

Install-Ytdlp -Tag $tagName -InstallPath $destPath

if ($scopeChoice -eq 0)
{
    Add-ForSpecifiedPath -Value $destPath -VariableTarget Machine
}
elseif ($scopeChoice -eq 1)
{
    Add-ForSpecifiedPath -Value $destPath -VariableTarget User
}