param(
    [Parameter(Mandatory = $true)]
    [int] $LocalPort,
    
    [Parameter(Mandatory = $true)]
    [int] $RemotePort,
    
    [Parameter(Mandatory = $true)]
    [string] $RemoteIP
)

$ErrorActionPreference = 'Stop'

$endPoint = [System.Net.IPEndPoint]::new(0, 0)
$receiveUdpClient = [System.Net.Sockets.UdpClient]::new($LocalPort)

$sendUdpClient = [System.Net.Sockets.UdpClient]::new()
$address = [System.Net.IPAddress]::Parse($RemoteIP)
$remoteEndPoint = [System.Net.IPEndPoint]::new($address, $RemotePort)
$sendUdpClient.Connect($remoteEndPoint)

try
{
    while ($true)
    {
        [byte[]] $buffer = $receiveUdpClient.Receive([ref] $endPoint)
        $null = $sendUdpClient.Send($buffer)
    }
}
finally
{
    $receiveUdpClient.Dispose()
    $sendUdpClient.Dispose()
}
