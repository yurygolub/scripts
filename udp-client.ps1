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

        $receiveTask.GetAwaiter().GetResult()

        $null = $SendUdpClient.SendAsync($result.Buffer, [System.Threading.CancellationToken]::None)
    }
}
finally
{
    $receiveUdpClient.Dispose()
    $sendUdpClient.Dispose()
    $receiveTask.Dispose()
}
