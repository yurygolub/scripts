Stop-Service DiagTrack
Set-Service DiagTrack -StartupType Disabled
Disable-ScheduledTask -TaskPath 'microsoft\windows\application experience' -TaskName 'Microsoft Compatibility Appraiser'
Disable-ScheduledTask -TaskPath 'microsoft\windows\application experience' -TaskName 'ProgramDataUpdater'
Disable-ScheduledTask -TaskPath 'microsoft\windows\application experience' -TaskName 'StartupAppTask'
