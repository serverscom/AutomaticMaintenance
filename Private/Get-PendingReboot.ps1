function Get-PendingReboot {
    #Requires -Version 3.0
    #Requires -Modules PendingReboot

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $ErrorActionPreference = 'Stop'
    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName: {0}' -f [string]$ComputerName)

        Write-Debug -Message ('$PendingReboot = Test-PendingReboot -ComputerName ''{0}'' -SkipConfigurationManagerClientCheck -Detailed' -f $ComputerName)
        $PendingReboot = Test-PendingReboot -ComputerName $ComputerName -SkipConfigurationManagerClientCheck -Detailed
        Write-Debug -Message ('$PendingReboot: ''{0}''' -f [string]$PendingReboot)

        Write-Debug -Message '$PendingReboot.IsRebootPending'
        $PendingReboot.IsRebootPending

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