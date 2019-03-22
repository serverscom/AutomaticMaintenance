function Get-ComputerList {
    #Requires -Version 3.0

    [CmdletBinding()]
    [OutputType([string[]])]

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message '$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration'
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f [string]$ComputerMaintenanceConfiguration)
        Write-Debug -Message '$ComputersToProcess = $ComputerMaintenanceConfiguration | Where-Object -FilterScript {$_.DoNotProcess -ne $true}'
        $ComputersToProcess = $ComputerMaintenanceConfiguration | Where-Object -FilterScript {$_.DoNotProcess -ne $true}
        Write-Debug -Message ('$ComputersToProcess: {0}' -f [string]$ComputersToProcess)
        Write-Debug -Message '($ComputersToProcess).Name'
        $ComputerHostNames = ($ComputersToProcess).Name
        Write-Debug -Message ('$ComputerHostNames: {0}' -f [string]$ComputerHostNames)

        Write-Debug -Message '$ComputerHostNames'
        $ComputerHostNames

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: throw $_)' -f $MyInvocation.MyCommand.Name)
        throw $_

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}