function Test-MaintenanceNeeded {
    #Requires -Version 3.0
    
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)
    
    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)

        Write-Debug -Message ('$IsMaintenanceNeeded = Test-WindowsUpdateNeeded -ComputerName ''{0}''' -f $ComputerName)
        $IsMaintenanceNeeded = Test-WindowsUpdateNeeded -ComputerName $ComputerName
        Write-Debug -Message ('$IsMaintenanceNeeded = ''{0}''' -f $IsMaintenanceNeeded)
        Write-Debug -Message '$IsMaintenanceNeeded'
        $IsMaintenanceNeeded

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