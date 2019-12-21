function Test-WindowsUpdateNeeded {
    #Requires -Version 3.0

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [scriptblock]$Filter
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)

        Write-Debug -Message ('$Updates = Get-WindowsUpdateNeeded -ComputerName ''{0}'' -Filter {{{1}}}' -f $ComputerName, $Filter)
        $Updates = Get-WindowsUpdateNeeded -ComputerName $ComputerName -Filter $Filter
        Write-Debug -Message ('$Updates: ''{0}''' -f [string]$Updates.Title)

        Write-Debug -Message 'if ($Updates)'
        if ($Updates) {
            Write-Debug -Message '$true'
            $true
        }
        else {
            Write-Debug -Message '$false'
            $false
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