param(
    [Parameter(Mandatory = $true)]
    [int] $LocalPort,

    [Parameter(Mandatory = $true)]
    [int] $RemotePort,

    [Parameter(Mandatory = $true)]
    [string] $RemoteIP
)

$ErrorActionPreference = 'Stop'

$receiveUdpClient = [System.Net.Sockets.UdpClient]::new($LocalPort)

$sendUdpClient = [System.Net.Sockets.UdpClient]::new()
$address = [System.Net.IPAddress]::Parse($RemoteIP)
$remoteEndPoint = [System.Net.IPEndPoint]::new($address, $RemotePort)
$sendUdpClient.Connect($remoteEndPoint)

try
{
    while ($true)
    {
        [System.Threading.Tasks.Task] $receiveTask = $receiveUdpClient.ReceiveAsync()
        while (-not $receiveTask.AsyncWaitHandle.WaitOne(100))
        {
        }

        $result = $receiveTask.GetAwaiter().GetResult()
        Write-Host 'Received'

        $null = $UdpClient.Send($result.Buffer, $result.Buffer.Length, $RemoteIP, $RemotePort)
        Write-Host 'Sent'
    }
}
finally
{
    $receiveUdpClient.Dispose()
    $sendUdpClient.Dispose()
    $receiveTask.Dispose()
}
