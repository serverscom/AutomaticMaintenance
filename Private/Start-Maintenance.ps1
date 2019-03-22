function Start-Maintenance {
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

        Write-Debug -Message ('Invoke-WindowsUpdate -ComputerName {0}' -f $ComputerName)
        Invoke-WindowsUpdate -ComputerName $ComputerName

        Write-Debug -Message ('$null = Invoke-CustomScriptBlockCommand -Mode ''PostUpdate'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
        $null = Invoke-CustomScriptBlockCommand -Mode 'PostUpdate' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript {$_ -is [System.Management.Automation.PSVariable]})

        Write-Debug -Message ('$PendingReboot = Get-PendingReboot -ComputerName {0}' -f $ComputerName)
        $PendingReboot = Get-PendingReboot -ComputerName $ComputerName
        Write-Debug -Message ('$PendingReboot = {0}' -f $PendingReboot)
        Write-Debug -Message 'if ($PendingReboot)'
        if ($PendingReboot) {
            Write-Debug -Message ('Invoke-ComputerRestart -ComputerName {0}' -f $ComputerName)
            Invoke-ComputerRestart -ComputerName $ComputerName
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
}