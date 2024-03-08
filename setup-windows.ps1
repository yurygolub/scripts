Stop-Service DiagTrack
Set-Service DiagTrack -StartupType Disabled

$appExpTaskPath = '\Microsoft\Windows\Application Experience\'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'Microsoft Compatibility Appraiser'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'ProgramDataUpdater'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'StartupAppTask'

[System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)
