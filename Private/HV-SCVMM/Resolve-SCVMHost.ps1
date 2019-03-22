function Resolve-SCVMHost {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName ''{0}''' -f $ComputerName)
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: ''{0}''' -f [string]$ComputerMaintenanceConfiguration)
        
        Write-Debug -Message ('Get-SCVMHost -ComputerName ''{0}'' -VMMServer ''{1}''' -f $ComputerName, $ComputerMaintenanceConfiguration.VMMServerName)
        Get-SCVMHost -ComputerName $ComputerName -VMMServer $ComputerMaintenanceConfiguration.VMMServerName

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
        $PSCmdlet.ThrowTerminatingError($_)

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}