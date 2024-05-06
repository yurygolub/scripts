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
