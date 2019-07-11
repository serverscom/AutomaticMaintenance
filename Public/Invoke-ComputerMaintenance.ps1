function Invoke-ComputerMaintenance {
    #Requires -Version 3.0
    #Requires -Modules ResourceLocker

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [int]$PreventiveLockTimeout = $ModuleWidePreventiveLockTimeout,
        [System.TimeSpan]$PreventiveLockThreshold = $ModuleWidePreventiveLockThreshold,
        [switch]$SkipNotLockable = $ModuleWideSkipNotLockable,
        [switch]$SkipPreventivelyLocked = $ModuleWideSkipPreventivelyLocked
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$PreventiveLockTimeout = {0}' -f $PreventiveLockTimeout)
        Write-Debug -Message ('$PreventiveLockThreshold: ''{0}''' -f [string]$PreventiveLockThreshold)
        Write-Debug -Message ('$SkipNotLockable: ''{0}''' -f $SkipNotLockable)
        Write-Debug -Message ('$SkipPreventivelyLocked: ''{0}''' -f $SkipPreventivelyLocked)

        Write-Debug -Message ('$IsMaintenanceAllowed = Test-MaintenanceAllowed -ComputerName ''{0}''' -f $ComputerName)
        $IsMaintenanceAllowed = Test-MaintenanceAllowed -ComputerName $ComputerName
        Write-Debug -Message ('$IsMaintenanceAllowed: ''{0}''' -f $IsMaintenanceAllowed)
        Write-Debug -Message 'if ($IsMaintenanceAllowed)'
        if ($IsMaintenanceAllowed) {
            Write-Debug -Message ('$IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName ''{0}''' -f $ComputerName)
            $IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName $ComputerName
            Write-Debug -Message ('$IsMaintenanceNeeded: ''{0}''' -f $IsMaintenanceNeeded)
            Write-Debug -Message 'if ($IsMaintenanceNeeded)'
            if ($IsMaintenanceNeeded) {
                Write-Debug -Message '$CallerName = Get-LockCallerName'
                $CallerName = Get-LockCallerName
                Write-Debug -Message ('$CallerName = ''{0}''' -f $CallerName)

                Write-Debug -Message '$HostLock = $null'
                $HostLock = $null
                try {
                    Write-Debug -Message ('$HostLock = Lock-HostResource -ComputerName ''{0}'' -CallerName ''{1}'' -Hard' -f $ComputerName, $CallerName)
                    $HostLock = Lock-HostResource -ComputerName $ComputerName -CallerName $CallerName -Hard
                    Write-Debug -Message ('$HostLock: ''{0}''' -f [string]$HostLock)
                }
                catch {
                    Write-Debug -Message ('$SkipNotLockable: ''{0}''' -f $SkipNotLockable)
                    if ($SkipNotLockable) {
                        Write-Debug -Message ('$_.CategoryInfo.Reason: ''{0}''' -f $_.CategoryInfo.Reason)
                        if ($_.CategoryInfo.Reason -ne 'TimeoutException') {
                            Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
                            $PSCmdlet.ThrowTerminatingError($_)
                        }
                    }
                    else {
                        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
                        $PSCmdlet.ThrowTerminatingError($_)
                    }
                }

                Write-Debug -Message 'if ($HostLock)'
                if ($HostLock) {
                    Write-Debug -Message '$InitialDateTime = Get-Date'
                    $InitialDateTime = Get-Date
                    Write-Debug -Message ('$InitialDateTime: ''{0}''' -f [string]$InitialDateTime)
                    do {
                        Write-Debug -Message ('$HostLockedPreventive = Test-HostResourceLock -ComputerName ''{0}'' -Type @(''Generic'', ''File'')' -f $ComputerName)
                        $HostLockedPreventive = Test-HostResourceLock -ComputerName $ComputerName -Type @('Generic', 'File')
                        Write-Debug -Message ('$HostLockedPreventive: ''{0}''' -f [string]$HostLockedPreventive)
                        Write-Debug -Message 'if ($HostLockedPreventive)'
                        if ($HostLockedPreventive) {
                            Write-Debug -Message '$CurrentDateTime = Get-Date'
                            $CurrentDateTime = Get-Date
                            Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                            Write-Debug -Message ('$InitialDateTime: ''{0}''' -f [string]$InitialDateTime)
                            Write-Debug -Message ('$PreventiveLockThreshold: ''{0}''' -f [string]$PreventiveLockThreshold)
                            Write-Debug -Message '$PreventiveLockDateTimeThreshold = $InitialDateTime + $PreventiveLockThreshold'
                            $PreventiveLockDateTimeThreshold = $InitialDateTime + $PreventiveLockThreshold
                            Write-Debug -Message ('$PreventiveLockDateTimeThreshold: ''{0}''' -f [string]$PreventiveLockDateTimeThreshold)
                            Write-Debug -Message 'if ($CurrentDateTime -gt $PreventiveLockDateTimeThreshold)'
                            if ($CurrentDateTime -gt $PreventiveLockDateTimeThreshold) {
                                Write-Debug -Message ('$SkipPreventivelyLocked: ''{0}''' -f $SkipPreventivelyLocked)
                                Write-Debug -Message 'if ($SkipPreventivelyLocked)'
                                if ($SkipPreventivelyLocked) {
                                    Write-Debug -Message 'return'
                                    return
                                }
                                else {
                                    $Message = ('Computer {0} is locked by other sources for more than {1} already' -f $ComputerName, [string]$PreventiveLockThreshold)
                                    $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.TimeoutException' -ArgumentList $Message), 'TimeoutException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $null)))
                                }
                            }
                            else {
                                Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $PreventiveLockTimeout)
                                Start-Sleep -Seconds $PreventiveLockTimeout
                            }
                        }
                        Write-Debug -Message 'while ($HostLockedPreventive)'
                    }
                    while ($HostLockedPreventive)

                    Write-Debug -Message ('$PreClearVariables = Invoke-CustomScriptBlockCommand -Mode ''PreClear'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
                    $PreClearVariables = Invoke-CustomScriptBlockCommand -Mode 'PreClear' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
                    Write-Debug -Message ('$PreClearVariables: ''{0}''' -f [string]$PreClearVariables)
                    Write-Debug -Message 'if ($PreClearVariables)'
                    if ($PreClearVariables) {
                        foreach ($PreClearVariable in $PreClearVariables) {
                            Write-Debug -Message ('$PreClearVariable: ''{0}''' -f [string]$PreClearVariable)
                            Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''' -f $PreClearVariable.Name, [string]$PreClearVariable.Value)
                            Set-Variable -Name $PreClearVariable.Name -Value $PreClearVariable.Value
                        }
                    }

                    Write-Debug -Message '$DestinationHostLock = $null'
                    $DestinationHostLock = $null
                    Write-Debug -Message ('$ComputerWorkload = Clear-ComputerWorkload -ComputerName {0} -DestinationHostLock {1}' -f $ComputerName, $DestinationHostLock)
                    $ComputerWorkload = Clear-ComputerWorkload -ComputerName $ComputerName -DestinationHostLock ([ref]$DestinationHostLock)
                    Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                    Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)

                    Write-Debug -Message ('$PostClearVariables = Invoke-CustomScriptBlockCommand -Mode ''PostClear'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
                    $PostClearVariables = Invoke-CustomScriptBlockCommand -Mode 'PostClear' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
                    Write-Debug -Message ('$PostClearVariables: ''{0}''' -f [string]$PostClearVariables)
                    Write-Debug -Message 'if ($PostClearVariables)'
                    if ($PostClearVariables) {
                        foreach ($PostClearVariable in $PostClearVariables) {
                            Write-Debug -Message ('$PostClearVariable: ''{0}''' -f [string]$PostClearVariable)
                            Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''' -f $PostClearVariable.Name, [string]$PostClearVariable.Value)
                            Set-Variable -Name $PostClearVariable.Name -Value $PostClearVariable.Value
                        }
                    }
            
                    Write-Debug -Message ('Start-Maintenance -ComputerName ''{0}''' -f $ComputerName)
                    Start-Maintenance -ComputerName $ComputerName
                    Write-Debug -Message ('Set-MaintenanceState -ComputerName ''{0}''' -f $ComputerName)
                    Set-MaintenanceState -ComputerName $ComputerName
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
                                Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''' -f $PreRestoreVariable.Name, [string]$PreRestoreVariable.Value)
                                Set-Variable -Name $PreRestoreVariable.Name -Value $PreRestoreVariable.Value
                            }
                        }

                        Write-Debug -Message '$ComputerWorkload = $ComputerWorkload | Select-Object -Unique'
                        $ComputerWorkload = $ComputerWorkload | Select-Object -Unique
                        Write-Debug -Message 'if ($ComputerWorkload -or $ComputerWorkload -is [System.Array])'
                        if ($ComputerWorkload -or $ComputerWorkload -is [System.Array]) {
                            Write-Debug -Message ('Restore-ComputerWorkload -ComputerName ''{0}''' -f $ComputerName)
                            Restore-ComputerWorkload -ComputerName $ComputerName -DestinationHostLock ([ref]$DestinationHostLock)
                        }

                        Write-Debug -Message ('$PostRestoreVariables = Invoke-CustomScriptBlockCommand -Mode ''PostRestore'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
                        $PostRestoreVariables = Invoke-CustomScriptBlockCommand -Mode 'PostRestore' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
                        Write-Debug -Message ('$PostRestoreVariables: ''{0}''' -f [string]$PostRestoreVariables)
                        Write-Debug -Message 'if ($PostRestoreVariables)'
                        if ($PostRestoreVariables) {
                            foreach ($PostRestoreVariable in $PostRestoreVariables) {
                                Write-Debug -Message ('$PostRestoreVariable: ''{0}''' -f [string]$PostRestoreVariable)
                                Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''' -f $PostRestoreVariable.Name, [string]$PostRestoreVariable.Value)
                                Set-Variable -Name $PostRestoreVariable.Name -Value $PostRestoreVariable.Value
                            }
                        }
                    }
                    else {
                        $Message = 'Test-Computer ended unsuccessfully against {0}' -f $ComputerName
                        $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.SystemException' -ArgumentList $Message), 'SystemException', [System.Management.Automation.ErrorCategory]::InvalidResult, $null)))
                    }
                }
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
    finally {
        Write-Debug -Message ('ENTER FINALLY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$FinallyVariables = Invoke-CustomScriptBlockCommand -Mode ''Finally'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
        $FinallyVariables = Invoke-CustomScriptBlockCommand -ComputerName $ComputerName -Mode 'Finally' -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
        Write-Debug -Message ('$FinallyVariables: ''{0}''' -f [string]$FinallyVariables)
        Write-Debug -Message 'if ($FinallyVariables)'
        if ($FinallyVariables) {
            foreach ($FinallyVariable in $FinallyVariables) {
                Write-Debug -Message ('$FinallyVariable: ''{0}''' -f [string]$FinallyVariable)
                Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''' -f $FinallyVariable.Name, [string]$ErrorHandlingVariable.Value)
                Set-Variable -Name $FinallyVariable.Name -Value $FinallyVariable.Value
            }
        }

        Write-Debug -Message 'if ($HostLock)'
        if ($HostLock) {
            Write-Debug -Message 'Unlock-Resource -LockObject $HostLock'
            Unlock-Resource -LockObject $HostLock
        }
        Write-Debug -Message 'if ($DestinationHostLock)'
        if ($DestinationHostLock) {
            Write-Debug -Message 'Unlock-Resource -LockObject $DestinationHostLock'
            Unlock-Resource -LockObject $DestinationHostLock
        }

        Write-Debug -Message ('EXIT FINALLY {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}