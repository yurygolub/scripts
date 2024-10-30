function Get-RedirectedUrl
{
    param (
        [Parameter(Mandatory = $true)]
        [uri] $Url,
        [uri] $Referer
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
        [string] $DownloadUrl,

        [Parameter(Mandatory = $true)]
        [string] $OutPath
    )

    if ([System.AppDomain]::CurrentDomain.FriendlyName -eq 'pwsh')
    {
        $curlExec = 'curl'
    }
    else
    {
        $curlExec = 'curl.exe'
    }

    Write-Host "Downloading '$OutPath' from '$DownloadUrl'"
    if (Get-Command $curlExec -ErrorAction Ignore -Type Application)
    {
        & $curlExec -L $DownloadUrl -o $OutPath
        Write-Host
    }
    else
    {
        Invoke-WebRequest $DownloadUrl -OutFile $OutPath
    }
}

function Add-ForSpecifiedPath
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Value,

        [Parameter(Mandatory = $true)]
        [EnvironmentVariableTarget] $VariableTarget
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
