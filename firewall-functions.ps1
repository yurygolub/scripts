function mynetsh
{
    param (
        [string] $DisplayName
    )

    Get-NetFirewallRule -DisplayName $DisplayName | ForEach-Object {
        $rule = $_

        $address = $rule | Get-NetFirewallAddressFilter
        $port = $rule | Get-NetFirewallPortFilter
        $application = $rule | Get-NetFirewallApplicationFilter
        [pscustomobject] @{
            DisplayName = $rule.DisplayName
            Description = $rule.Description
            Enabled = $rule.Enabled
            Direction = $rule.Direction
            Profile = $rule.Profile
            DisplayGroup = $rule.DisplayGroup
            LocalAddress = $address.LocalAddress
            RemoteAddress = $address.RemoteAddress
            Protocol = $port.Protocol
            LocalPort = $port.LocalPort
            RemotePort = $port.RemotePort
            EdgeTraversalPolicy = $rule.EdgeTraversalPolicy
            Program = $application.Program
            Action = $rule.Action
        }
    }
}
