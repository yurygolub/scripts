@ECHO OFF

setx DOTNET_CLI_TELEMETRY_OPTOUT 1 /m

where /Q dotnet
if errorlevel 1	(
    @if not exist dotnet-sdk-7.0.304-win-x64.exe curl -OL https://download.visualstudio.microsoft.com/download/pr/2ab1aa68-3e14-401a-b106-833d66fa992b/060457e640f4095acf4723c4593314b6/dotnet-sdk-7.0.304-win-x64.exe
	dotnet-sdk-7.0.304-win-x64.exe /install /passive
)

exit
