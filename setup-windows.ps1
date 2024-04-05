if (Get-Service DiagTrack -ErrorAction Ignore)
{
    Stop-Service DiagTrack
    Set-Service DiagTrack -StartupType Disabled
}

$appExpTaskPath = '\Microsoft\Windows\Application Experience\'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'Microsoft Compatibility Appraiser'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'ProgramDataUpdater'
Disable-ScheduledTask -TaskPath $appExpTaskPath -TaskName 'StartupAppTask'

if (Get-Command dotnet -ErrorAction Ignore -Type Application)
{
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)
    return
}

# Uninstall 3D Viewer:
Get-AppxPackage Microsoft.Microsoft3DViewer | Remove-AppxPackage

# Uninstall 3D Builder:
Get-AppxPackage *3dbuilder* | Remove-AppxPackage

# Uninstall Calendar and Mail:
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage

# Uninstall Alarms and Clock:
Get-AppxPackage *windowsalarms* | Remove-AppxPackage

# Uninstall Office:
Get-AppxPackage *officehub* | Remove-AppxPackage

# Uninstall Get Help
Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage

# Uninstall Get Started:
Get-AppxPackage *getstarted* | Remove-AppxPackage

# Uninstall Skype:
Get-AppxPackage *skypeapp* | Remove-AppxPackage

# Uninstall Groove Music:
Get-AppxPackage *zunemusic* | Remove-AppxPackage

# Uninstall Maps:
Get-AppxPackage *windowsmaps* | Remove-AppxPackage

# Uninstall Microsoft Solitaire Collection:
Get-AppxPackage *solitairecollection* | Remove-AppxPackage

# Uninstall Money:
Get-AppxPackage *bingfinance* | Remove-AppxPackage

# Uninstall Movies & TV:
Get-AppxPackage *zunevideo* | Remove-AppxPackage

# Uninstall News:
Get-AppxPackage *bingnews* | Remove-AppxPackage

# Uninstall OneNote:
Get-AppxPackage *onenote* | Remove-AppxPackage

# Uninstall People:
Get-AppxPackage Microsoft.People | Remove-AppxPackage

# Uninstall Phone Companion:
Get-AppxPackage *windowsphone* | Remove-AppxPackage

# Uninstall Photos:
Get-AppxPackage *photos* | Remove-AppxPackage

# Uninstall Sports:
Get-AppxPackage *bingsports* | Remove-AppxPackage

# Uninstall Store:
Get-AppxPackage *windowsstore* | Remove-AppxPackage

# Uninstall Voice Recorder:
Get-AppxPackage *soundrecorder* | Remove-AppxPackage

# Uninstall Weather:
Get-AppxPackage *bingweather* | Remove-AppxPackage

# Uninstall Xbox:
Get-AppxPackage *xboxapp* | Remove-AppxPackage
