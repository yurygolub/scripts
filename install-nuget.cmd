@ECHO OFF

if not exist "C:\Tools\Nuget\" mkdir "C:\Tools\Nuget\"

if exist "C:\Tools\Nuget\nuget.exe" goto exit
set currentDirTemp=%cd%
cd /d "C:\Tools\Nuget\"
curl -OL https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
echo Nuget installed to '%cd%'

cd /d "%currentDirTemp%"

:exit
