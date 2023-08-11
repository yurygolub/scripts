@echo off

set ytdlpUrl=https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp.exe

where /q yt-dlp
if %ERRORLEVEL% NEQ 0 curl -OL "%ytdlpUrl%"

set /p urls="Input url(s): "
set /p output="Output path(empty for current folder: "%cd%"): "

yt-dlp -f m4a -o "%output%%%(artist)s - %%(track)s.%%(ext)s" --embed-metadata %urls%
