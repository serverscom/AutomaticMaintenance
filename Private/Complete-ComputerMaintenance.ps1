function Complete-ComputerMaintenance {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [System.Object]$ComputerWorkload,
        [Parameter(Mandatory)]
        [ref]$DestinationHostLock
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
        Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)

        Write-Debug -Message ('$TestComputerResult = Test-Computer -ComputerName ''{0}''' -f $ComputerName)
        $TestComputerResult = Test-Computer -ComputerName $ComputerName
        Write-Debug -Message ('$TestComputerResult = ''{0}''' -f $TestComputerResult)
        Write-Debug -Message 'if ($TestComputerResult)'
        if ($TestComputerResult) {
            Write-Debug -Message ('$PreRestoreVariables = Invoke-CustomScriptBlockCommand -Mode ''PreRestore'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
            $PreRestoreVariables = Invoke-CustomScriptBlockCommand -Mode 'PreRestore' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
            Write-Debug -Message ('$PreRestoreVariables: ''{0}''' -f [string]$PreRestoreVariables)
            Write-Debug -Message 'if ($PreRestoreVariables)'
            if ($PreRestoreVariables) {
                foreach ($PreRestoreVariable in $PreRestoreVariables) {
                    Write-Debug -Message ('$PreRestoreVariable: ''{0}''' -f [string]$PreRestoreVariable)
                    Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}'' -Scope ''Script''' -f $PreRestoreVariable.Name, [string]$PreRestoreVariable.Value)
                    Set-Variable -Name $PreRestoreVariable.Name -Value $PreRestoreVariable.Value -Scope 'Script'
                }
            }

            Write-Debug -Message '$ComputerWorkload = $ComputerWorkload | Select-Object -Unique'
            $ComputerWorkload = $ComputerWorkload | Select-Object -Unique
            Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
            Write-Debug -Message 'if ($ComputerWorkload -or $ComputerWorkload -is [System.Array])'
            if ($ComputerWorkload -or $ComputerWorkload -is [System.Array]) {
                Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
                Write-Debug -Message ('Restore-ComputerWorkload -ComputerName ''{0}'' -DestinationHostLock $DestinationHostLock' -f $ComputerName)
                Restore-ComputerWorkload -ComputerName $ComputerName -DestinationHostLock $DestinationHostLock
            }

            Write-Debug -Message ('$PostRestoreVariables = Invoke-CustomScriptBlockCommand -Mode ''PostRestore'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
            $PostRestoreVariables = Invoke-CustomScriptBlockCommand -Mode 'PostRestore' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
            Write-Debug -Message ('$PostRestoreVariables: ''{0}''' -f [string]$PostRestoreVariables)
            Write-Debug -Message 'if ($PostRestoreVariables)'
            if ($PostRestoreVariables) {
                foreach ($PostRestoreVariable in $PostRestoreVariables) {
                    Write-Debug -Message ('$PostRestoreVariable: ''{0}''' -f [string]$PostRestoreVariable)
                    Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}'' -Scope ''Script''' -f $PostRestoreVariable.Name, [string]$PostRestoreVariable.Value)
                    Set-Variable -Name $PostRestoreVariable.Name -Value $PostRestoreVariable.Value -Scope 'Script'
                }
            }
        }
        else {
            $Message = 'Test-Computer ended unsuccessfully against {0}' -f $ComputerName
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.SystemException' -ArgumentList $Message), 'SystemException', [System.Management.Automation.ErrorCategory]::InvalidResult, $null)))
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