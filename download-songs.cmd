@echo off

@if not exist yt-dlp.exe (
    curl -OL https://github.com/yt-dlp/yt-dlp/releases/download/2023.03.04/yt-dlp.exe
)

set /p urls="Input url(s): "
set /p output="Output path(empty for current folder: "%cd%"): "

yt-dlp -f m4a -o "%output%%%(artist)s - %%(track)s.%%(ext)s" --embed-metadata %urls%
