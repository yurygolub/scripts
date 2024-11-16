param (
    [string] $OutPath,
    [string] $Urls,
    [switch] $DefaultName
)

$ErrorActionPreference = 'Stop'

if (!(Get-Command -ErrorAction Ignore -Type Application yt-dlp))
{
    Write-Host 'yt-dlp not installed'
    return
}

if (!$OutPath)
{
    $defaultPath = 'songs'
    if (!($OutPath = Read-Host "Choose output path. Default is [$defaultPath]"))
    {
        $OutPath = $defaultPath
    }
}

if (!$Urls -and !($Urls = Read-Host "Input URL(s)"))
{
    Write-Warning 'URL(s) not provided'
    return
}

$null = New-Item -Type Directory $OutPath -Force

if ($DefaultName)
{
    $currentLocation = $PWD
    Set-Location $OutPath
    try
    {
        yt-dlp -f m4a --embed-metadata $Urls.Split(" ")
    }
    finally
    {
        Set-Location $currentLocation
    }
}
else
{
    yt-dlp -f m4a -o "$OutPath/%(artist)s - %(track)s.%(ext)s" --embed-metadata $Urls.Split(" ")
}
