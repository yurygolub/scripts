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


# change date time format

# system wide
$regPath = 'HKCU:\Control Panel\International'
Set-ItemProperty -Path $regPath -Name 'sDate' -Value '-'
Set-ItemProperty -Path $regPath -Name 'sLongDate' -Value 'dddd, d MMMM, yyyy'
Set-ItemProperty -Path $regPath -Name 'sShortDate' -Value 'dd-MM-yyyy'
Set-ItemProperty -Path $regPath -Name 'sTimeFormat' -Value 'HH:mm:ss'
Set-ItemProperty -Path $regPath -Name 'sShortTime' -Value 'HH:mm'
Set-ItemProperty -Path $regPath -Name 'iDate' -Value 1
Set-ItemProperty -Path $regPath -Name 'iFirstDayOfWeek' -Value 0
Set-ItemProperty -Path $regPath -Name 'iTime' -Value 1
Set-ItemProperty -Path $regPath -Name 'iTLZero' -Value 1

# for process
$culture = Get-Culture

$culture.DateTimeFormat.DateSeparator = '-'
$culture.DateTimeFormat.FirstDayOfWeek = 'Monday'
$culture.DateTimeFormat.FullDateTimePattern = 'dddd, d MMMM, yyyy HH:mm:ss'
$culture.DateTimeFormat.LongDatePattern = 'dddd, d MMMM, yyyy'
$culture.DateTimeFormat.LongTimePattern = 'HH:mm:ss'
$culture.DateTimeFormat.ShortDatePattern = 'dd-MM-yyyy'
$culture.DateTimeFormat.ShortTimePattern = 'HH:mm'

Set-Culture $culture


Set-TimeZone -Id 'Belarus Standard Time'


# sync time
Start-Service -Name W32Time
w32tm.exe /resync /nowait
Stop-Service -Name W32Time


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
