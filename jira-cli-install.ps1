$ErrorActionPreference = 'Stop'

. .\functions.ps1

function Install-JiraCli
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Tag,

        [Parameter(Mandatory = $true)]
        [string] $InstallPath
    )

    $tempDir = 'temp'
    $null = New-Item -Type Directory $tempDir -Force

    $archive = "jira_$($Tag.Substring(1))_windows_x86_64.zip"
    $outputPath = Join-Path $tempDir $archive

    if (!(Test-Path -Path $outputPath))
    {
        $downloadUrl = "$baseUrl/download/$Tag/$archive"
        Save-File -DownloadUrl $downloadUrl -OutPath $outputPath
    }

    Write-Host "Expanding '$outputPath' to '$InstallPath'"
    Expand-Archive $outputPath -DestinationPath $InstallPath -Force
    Remove-Item -Recurse -Force $tempDir
    Write-Host
}

$baseUrl = 'https://github.com/ankitpokhrel/jira-cli/releases'

$jiraCommand = Get-Command -ErrorAction Ignore -Type Application jira
if ($jiraCommand)
{
    $installationPaths = (Get-Item $jiraCommand.Path).Directory.Parent.FullName
    if ($installationPaths -isnot [string])
    {
        $jiraPath = $installationPaths[0]
    }
    else
    {
        $jiraPath = $installationPaths
    }

    Write-Warning "jira-cli already installed: '$jiraPath'"

    $question = 'Do you want to check for newer version?'
    $choices = '&Yes', '&No'

    $checkVersion = $Host.UI.PromptForChoice($null, $question, $choices, 1)

    if ($checkVersion -eq 1)
    {
        return
    }

    $currentVersion = (jira version).Trim('(', ')').Split(',')[0].Split('=')[1].Trim('"')

    $redirected = Get-RedirectedUrl "$baseUrl/latest"
    $tagName = Split-Path $redirected -Leaf
    $version = $tagName.Substring(1)

    if ($currentVersion -ne $version)
    {
        Write-Host "Current version: '$currentVersion'. Available version: '$version'"

        $question = "Do you want to install '$version'?"
        $choices = '&Yes', '&No'

        $reinstall = $Host.UI.PromptForChoice($null, $question, $choices, 1)

        if ($reinstall -eq 0)
        {
            Install-JiraCli -Tag $tagName -InstallPath $jiraPath
        }
    }
    else
    {
        Write-Host "Latest version is already installed: '$version'"
    }

    return
}

$title = 'This script will install jira-cli'
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
    $scope = [EnvironmentVariableTarget]::Machine
}
elseif ($scopeChoice -eq 1)
{
    $defaultPath = $Env:LOCALAPPDATA
    $scope = [EnvironmentVariableTarget]::User
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

$destFolder = 'jira-cli'
$destPath = Join-Path $inputPath -ChildPath $destFolder

$title = "Latest version of jira-cli will be installed to '$destPath'"
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

$jiraBin = Join-Path $destPath -ChildPath 'bin'

if (!(Test-Path -Path $jiraBin))
{
    Install-JiraCli -Tag $tagName -InstallPath $destPath
}

if (!$Env:JIRA_API_TOKEN)
{
    if (!($apiToken = Read-Host 'Input api token. Press enter to get it from clipboard' -MaskInput))
    {
        $apiToken = Get-Clipboard
    }

    $Env:JIRA_API_TOKEN = $apiToken

    [Environment]::SetEnvironmentVariable('JIRA_API_TOKEN', $apiToken, $scope)
}

Add-ForSpecifiedPath -Value $jiraBin -VariableTarget $scope

Write-Host 'Installation successfull'
