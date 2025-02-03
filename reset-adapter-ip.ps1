param 
(
    [Parameter(Position = 0, mandatory = $true)]
    [int] $InterfaceIndex
)

function Load 
{
    param(
        [scriptblock] $Function,
        [string] $Label,
        [Object[]] $ArgumentList
    )
    $job = Start-Job  -ScriptBlock $Function -ArgumentList $ArgumentList
    
    $symbols = @("⣾", "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽")
    $i = 0;
    while ($job.State -eq "Running") 
    {
        $symbol =  $symbols[$i]
        Write-Host -NoNewLine "`r$symbol $Label" -ForegroundColor Green
        Start-Sleep -Milliseconds 166
        $i++
        if ($i -eq $symbols.Count)
        {
            $i = 0;
        }
    }
    Remove-Job $job
    Write-Host -NoNewLine ("`r" + $job.Output)
}

Load -Label "Resetting Adapter $InterfaceIndex IP" -Function { Param($InterfaceIndex)
    Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -Confirm:$false
    Remove-NetRoute -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -Confirm:$false
    Set-NetIPInterface -InterfaceIndex $InterfaceIndex -Dhcp Enabled
    Get-NetAdapter -InterfaceIndex $InterfaceIndex | Disable-NetAdapter -Confirm:$false
    Get-NetAdapter -InterfaceIndex $InterfaceIndex | Enable-NetAdapter -Confirm:$false
    Start-Sleep 3
} -ArgumentList $InterfaceIndex

Get-NetIPConfiguration -Detailed -InterfaceIndex $InterfaceIndex
