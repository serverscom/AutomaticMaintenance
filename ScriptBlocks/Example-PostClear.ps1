#Requires -Version 3.0
#Requires -Modules YourFavoriteMonitoringSystem, BetterCredentials

[CmdletBinding()]
Param (
    [Parameter(Mandatory)]
    [string]$ComputerName,
    [System.Management.Automation.PSVariable[]]$Variables,
    [string]$YourFavoriteMonitoringSystemUserName = 'AutoMaintenanceSvc',
    [string]$YourFavoriteMonitoringSystemComputerName = 'mon.example.com',
)

$ErrorActionPreference = 'Stop'

Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

try {
    Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

    $CallerName = ($Variables | Where-Object -FilterScript {$_.Name -eq 'CallerName'}).Value
    Write-Debug -Message ('$CallerName = ''{0}''' -f $CallerName)

    Write-Debug -Message ('$MonitoringHostName = (Get-ComputerMaintenanceConfiguration -ComputerName ''{0}'').MonitoringHostName' -f $ComputerName)
    $MonitoringHostName = (Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName).MonitoringHostName
    Write-Debug -Message ('$MonitoringHostName = ''{0}''' -f $MonitoringHostName)

    Write-Debug -Message ('$SavedCredential = BetterCredentials\Get-Credential -UserName {0} -Domain {1}' -f $YourFavoriteMonitoringSystemUserName, $YourFavoriteMonitoringSystemComputerName)
    $SavedCredential = BetterCredentials\Get-Credential -UserName $YourFavoriteMonitoringSystemUserName -Domain $YourFavoriteMonitoringSystemComputerName
    Write-Debug -Message ('$SavedCredential: {0}' -f $SavedCredential.UserName)

    Write-Debug -Message ('$YourFavoriteMonitoringSystemCredential = New-Object -TypeName ''System.Management.Automation.PSCredential'' -ArgumentList ({0}, $SavedCredential.Password)' -f $YourFavoriteMonitoringSystemUserName)
    $YourFavoriteMonitoringSystemCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ($YourFavoriteMonitoringSystemUserName, $SavedCredential.Password)
    Write-Debug -Message ('$YourFavoriteMonitoringSystemCredential: {0}' -f $YourFavoriteMonitoringSystemCredential.UserName)

    Write-Debug -Message ('$HostDowntime = New-YFMSHostDowntime -HostName {0} -ComputerName {1} -Credential {2} -Comment ''Automatic maintenance'' -Author ''{3}'' -AllServices' -f $MonitoringHostName, $YourFavoriteMonitoringSystemComputerName, $YourFavoriteMonitoringSystemCredential.UserName, $CallerName)
    $HostDowntime = New-YFMSHostDowntime -HostName $MonitoringHostName -ComputerName $YourFavoriteMonitoringSystemComputerName -Credential $YourFavoriteMonitoringSystemCredential -Comment 'Automatic maintenance' -Author $CallerName -AllServices
    Write-Debug -Message ('$HostDowntime: {0}' -f [string]$HostDowntime)

    $VariableNames = @(
        'YourFavoriteMonitoringSystemComputerName'
        'YourFavoriteMonitoringSystemCredential'
        'HostDowntime'
    )
    foreach ($VariableName in $VariableNames) {
        Get-Variable -Name $VariableName
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