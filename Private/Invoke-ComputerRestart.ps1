function Invoke-ComputerRestart {
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

        Write-Debug -Message ('Restart-Computer -ComputerName {0} -Force -Wait -For PowerShell' -f $ComputerName)
        Restart-Computer -ComputerName $ComputerName -Force -Wait -For PowerShell
        <#
        Restart-Computer only works on computers running Windows and requires WinRM and WMI to shutdown a system, including the local system.
        Restart-Computer uses the Win32Shutdown method of the Windows Management Instrumentation (WMI) Win32_OperatingSystem class. This method requires the SeShutdownPrivilege privilege be enabled for the user account used to restart the machine.
        #>

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