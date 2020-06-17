#Requires -Version 3.0
#Requires -Modules YourFavoriteMonitoringSystem

[CmdletBinding()]
Param (
    [Parameter(Mandatory)]
    [string]$ComputerName,
    [System.Management.Automation.PSVariable[]]$Variables
)

$ErrorActionPreference = 'Stop'

Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

try {
    Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

    # Put here code which you want to execute at the PreRestore step.

    # The example below enables back monitoring of the host in a fictional Your Favorite Monitoring System.
    # To remove the downtime from our host, we use a downtime object from the PostClear step ($HostDowntime).

    $HostDowntime = ($Variables | Where-Object -FilterScript {$_.Name -eq 'HostDowntime'}).Value
    Write-Debug -Message ('$HostDowntime: {0}' -f $HostDowntime)
    $YourFavoriteMonitoringSystemComputerName = ($Variables | Where-Object -FilterScript {$_.Name -eq 'YourFavoriteMonitoringSystemComputerName'}).Value
    Write-Debug -Message ('$YourFavoriteMonitoringSystemComputerName = ''{0}''' -f $YourFavoriteMonitoringSystemComputerName)
    $YourFavoriteMonitoringSystemCredential = ($Variables | Where-Object -FilterScript {$_.Name -eq 'YourFavoriteMonitoringSystemCredential'}).Value
    Write-Debug -Message ('$YourFavoriteMonitoringSystemCredential: {0}' -f $YourFavoriteMonitoringSystemCredential.UserName)

    Write-Debug -Message ('if ({0})' -f $HostDowntime)
    if ($HostDowntime) {
        Write-Debug -Message ('$null = Remove-YFMSDowntime -ComputerName {0} -Downtime $HostDowntime -Credential {1}' -f $YourFavoriteMonitoringSystemComputerName, $YourFavoriteMonitoringSystemCredential.UserName)
        $null = Remove-YFMSDowntime -ComputerName $YourFavoriteMonitoringSystemComputerName -Downtime $HostDowntime -Credential $YourFavoriteMonitoringSystemCredential
        Write-Debug -Message '$HostDowntime = $null'
        $HostDowntime = $null

        $VariableNames = @(
            'HostDowntime'
        )
        foreach ($VariableName in $VariableNames) {
            Get-Variable -Name $VariableName
        }
    }

    Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
}
catch {
    Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

    Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
    $PSCmdlet.ThrowTerminatingError($_)

    Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
}

Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)