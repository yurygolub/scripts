$ErrorActionPreference = 'Stop'

. .\functions.ps1

function Install-JiraCli
{
    param (
        [string] $Destination
    )

    $url = 'https://github.com/ankitpokhrel/jira-cli/releases/latest'
    $redirected = Get-RedirectedUrl $url

    $tagName = Split-Path $redirected -Leaf
    $archive = "jira_$($tagName.Substring(1))_windows_x86_64.zip"

    if (!(Test-Path -Path $archive))
    {
        $downloadUrl = "https://github.com/ankitpokhrel/jira-cli/releases/download/$tagName/$archive"

        Write-Host "Downloading '$archive' from '$downloadUrl'"
        Invoke-WebRequest $downloadUrl -OutFile $archive
    }

    Write-Host "Expanding '$archive' to '$Destination'"
    Expand-Archive $archive -DestinationPath $Destination -Force
    Remove-Item $archive
}

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

    $question = 'Do you want to update it?'
    $choices = '&Yes', '&No'

    $reinstall = $Host.UI.PromptForChoice($null, $question, $choices, 1)
    if ($reinstall -eq 0)
    {
        Install-JiraCli $jiraPath
    }

    return
}

$title = 'This script will install jira-cli'
$question = 'How do you want to install it?'
$choices = '&All users', '&Current user'

$choice = $Host.UI.PromptForChoice($title, $question, $choices, 1)

if ($choice -eq 0)
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Warning 'You have to run this script as admin'
        return
    }

    $defaultPath = $Env:ProgramFiles
    $scope = [EnvironmentVariableTarget]::Machine
}
elseif ($choice -eq 1)
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

$jiraBin = Join-Path $destPath -ChildPath 'bin'

if (!(Test-Path -Path $jiraBin))
{
    Install-JiraCli $destPath
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
