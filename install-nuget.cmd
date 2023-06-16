@if not exist "C:\Tools\Nuget\" mkdir "C:\Tools\Nuget\"

@if not exist "C:\Tools\Nuget\nuget.exe" (
	cd /d "C:\Tools\Nuget\"
	curl -OL https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
)
