Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Get-Service sshd
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
