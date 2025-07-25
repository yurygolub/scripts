param (
    [string] $MacAddr = '88-D7-F6-7B-D1-10'
)

$macByteArray = $MacAddr -split "[:-]" | ForEach-Object { [byte] "0x$_" }

[byte[]] $magicPacket = (, 0xFF * 6) + ($macByteArray * 16)

$udpClient = [System.Net.Sockets.UdpClient]::new()

try
{
    Write-Host "Broadcasting WOL packet with MAC: $MacAddr"
    $udpClient.Connect([System.Net.IPAddress]::Broadcast, 9)
    $null = $udpClient.Send($magicPacket, $magicPacket.Length)
}
finally
{
    $udpClient.Dispose()
}
