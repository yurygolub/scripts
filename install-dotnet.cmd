@ECHO OFF

if "%DOTNET_CLI_TELEMETRY_OPTOUT%" == "1" goto checkDotnet

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
	IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
	echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	set params= %*
	echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

	"%temp%\getadmin.vbs"
	del "%temp%\getadmin.vbs"
	exit /B

:gotAdmin
	pushd "%CD%"
	CD /D "%~dp0"
:--------------------------------------

echo set DOTNET_CLI_TELEMETRY_OPTOUT environment variable
setx DOTNET_CLI_TELEMETRY_OPTOUT 1 /m


:checkDotnet
where /Q dotnet
if errorlevel 1	(
	echo installing dotnet
	
    if not exist dotnet-sdk-7.0.304-win-x64.exe curl -OL https://download.visualstudio.microsoft.com/download/pr/2ab1aa68-3e14-401a-b106-833d66fa992b/060457e640f4095acf4723c4593314b6/dotnet-sdk-7.0.304-win-x64.exe
	
	dotnet-sdk-7.0.304-win-x64.exe /install /passive
	
	exit
)
