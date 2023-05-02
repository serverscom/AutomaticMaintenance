function Invoke-ComputerMaintenance {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [int]$PreventiveLockTimeout = $ModuleWidePreventiveLockTimeout,
        [System.TimeSpan]$PreventiveLockThreshold = $ModuleWidePreventiveLockThreshold,
        [string]$SkipPreventivelyLockedFullyQualifiedErrorId = $ModuleWideSkipPreventivelyLockedFullyQualifiedErrorId,
        [switch]$SkipNotLockable = $ModuleWideSkipNotLockable,
        [switch]$SkipPreventivelyLocked = $ModuleWideSkipPreventivelyLocked,
        [switch]$EnableMaintenanceLog = $ModuleWideEnableMaintenanceLog
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$PreventiveLockTimeout = {0}' -f $PreventiveLockTimeout)
        Write-Debug -Message ('$PreventiveLockThreshold: ''{0}''' -f [string]$PreventiveLockThreshold)
        Write-Debug -Message ('$SkipNotLockable = ${0}' -f $SkipNotLockable)
        Write-Debug -Message ('$SkipPreventivelyLocked = ${0}' -f $SkipPreventivelyLocked)
        Write-Debug -Message ('$EnableMaintenanceLog = ${0}' -f $EnableMaintenanceLog)

        Write-Debug -Message ('$IsMaintenanceAllowed = Test-MaintenanceAllowed -ComputerName ''{0}''' -f $ComputerName)
        $IsMaintenanceAllowed = Test-MaintenanceAllowed -ComputerName $ComputerName
        Write-Debug -Message ('$IsMaintenanceAllowed = ${0}' -f $IsMaintenanceAllowed)
        Write-Debug -Message 'if ($IsMaintenanceAllowed)'
        if ($IsMaintenanceAllowed) {
            Write-Debug -Message '$HostLock = $null'
            $HostLock = $null
            Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
            Write-Debug -Message '$DestinationHostLock = $null'
            $DestinationHostLock = $null
            Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
            Write-Debug -Message ('$PendingReboot = Test-PendingReboot -ComputerName ''{0}'' -Detailed' -f $ComputerName)
            $PendingReboot = Test-PendingReboot -ComputerName $ComputerName -Detailed
            Write-Debug -Message ('$PendingReboot: ''{0}''' -f $PendingReboot)
            Write-Debug -Message ('$PendingReboot.PendingFileRenameOperationsValue: ''{0}''' -f [string]$PendingReboot.PendingFileRenameOperationsValue)
            Write-Debug -Message ('$PendingReboot.ComponentBasedServicing: ''{0}''' -f $PendingReboot.ComponentBasedServicing)
            Write-Debug -Message 'if ($PendingReboot.ComponentBasedServicing)'
            if ($PendingReboot.ComponentBasedServicing) {
                # Sometimes, when CBS requires reboot, search for updates hangs up. Therefore, we need to reboot the machine first.
                Write-Debug -Message ('$ComputerWorkload = Initialize-ComputerMaintenance -ComputerName ''{0}'' -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:${1} -SkipPreventivelyLocked:${2} -SkipPreventivelyLockedFullyQualifiedErrorId ''{3}''' -f $ComputerName, $SkipNotLockable, $SkipPreventivelyLocked, $SkipPreventivelyLockedFullyQualifiedErrorId)
                $ComputerWorkload = Initialize-ComputerMaintenance -ComputerName $ComputerName -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:$SkipNotLockable -SkipPreventivelyLocked:$SkipPreventivelyLocked -SkipPreventivelyLockedFullyQualifiedErrorId $SkipPreventivelyLockedFullyQualifiedErrorId
                Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)

                Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
                Write-Debug -Message 'if ($HostLock)'
                if ($HostLock) {
                    Write-Debug -Message ('Invoke-ComputerRestart -ComputerName ''{0}''' -f $ComputerName)
                    Invoke-ComputerRestart -ComputerName $ComputerName
                    Write-Debug -Message ('$IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName ''{0}''' -f $ComputerName)
                    $IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName $ComputerName
                    Write-Debug -Message ('$IsMaintenanceNeeded = ${0}' -f $IsMaintenanceNeeded)
                    if ($IsMaintenanceNeeded) {
                        Write-Debug -Message ('Start-Maintenance -ComputerName ''{0}'' -EnableMaintenanceLog:${1}' -f $ComputerName, $EnableMaintenanceLog)
                        Start-Maintenance -ComputerName $ComputerName -EnableMaintenanceLog:$EnableMaintenanceLog
                    }
                    Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                    Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                    Write-Debug -Message ('Complete-ComputerMaintenance -ComputerName ''{0}'' -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)' -f $ComputerName)
                    Complete-ComputerMaintenance -ComputerName $ComputerName -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)
                }
            }
            else {
                # Most frequent case: CBS does not prevent from searching for updates
                Write-Debug -Message ('$IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName ''{0}''' -f $ComputerName)
                $IsMaintenanceNeeded = Test-MaintenanceNeeded -ComputerName $ComputerName
                Write-Debug -Message ('$IsMaintenanceNeeded = ${0}' -f $IsMaintenanceNeeded)
                if ($IsMaintenanceNeeded) {
                    Write-Debug -Message ('$ComputerWorkload = Initialize-ComputerMaintenance -ComputerName ''{0}'' -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:${1} -SkipPreventivelyLocked:${2} -SkipPreventivelyLockedFullyQualifiedErrorId ''{3}''' -f $ComputerName, $SkipNotLockable, $SkipPreventivelyLocked, $SkipPreventivelyLockedFullyQualifiedErrorId)
                    $ComputerWorkload = Initialize-ComputerMaintenance -ComputerName $ComputerName -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:$SkipNotLockable -SkipPreventivelyLocked:$SkipPreventivelyLocked -SkipPreventivelyLockedFullyQualifiedErrorId $SkipPreventivelyLockedFullyQualifiedErrorId
                    Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                    Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
                    Write-Debug -Message 'if ($HostLock)'
                    if ($HostLock) {
                        Write-Debug -Message ('Start-Maintenance -ComputerName ''{0}'' -EnableMaintenanceLog:${1}' -f $ComputerName, $EnableMaintenanceLog)
                        Start-Maintenance -ComputerName $ComputerName -EnableMaintenanceLog:$EnableMaintenanceLog
                        Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                        Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                        Write-Debug -Message ('Complete-ComputerMaintenance -ComputerName ''{0}'' -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)' -f $ComputerName)
                        Complete-ComputerMaintenance -ComputerName $ComputerName -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)
                    }
                }
                else {
                    # If the machine does not need any updates, but just a reboot, let's reboot it.
                    Write-Debug -Message ('$PendingReboot.IsRebootPending: ''{0}''' -f $PendingReboot.IsRebootPending)
                    if ($PendingReboot.IsRebootPending) {
                        Write-Debug -Message ('$ComputerWorkload = Initialize-ComputerMaintenance -ComputerName ''{0}'' -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:${1} -SkipPreventivelyLocked:${2} -SkipPreventivelyLockedFullyQualifiedErrorId ''{3}''' -f $ComputerName, $SkipNotLockable, $SkipPreventivelyLocked, $SkipPreventivelyLockedFullyQualifiedErrorId)
                        $ComputerWorkload = Initialize-ComputerMaintenance -ComputerName $ComputerName -HostLock ([ref]$HostLock) -DestinationHostLock ([ref]$DestinationHostLock) -SkipNotLockable:$SkipNotLockable -SkipPreventivelyLocked:$SkipPreventivelyLocked -SkipPreventivelyLockedFullyQualifiedErrorId $SkipPreventivelyLockedFullyQualifiedErrorId
                        Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                        Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
                        Write-Debug -Message 'if ($HostLock)'
                        if ($HostLock) {
                            Write-Debug -Message ('Invoke-ComputerRestart -ComputerName ''{0}''' -f $ComputerName)
                            Invoke-ComputerRestart -ComputerName $ComputerName
                            Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
                            Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                            Write-Debug -Message ('Complete-ComputerMaintenance -ComputerName ''{0}'' -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)' -f $ComputerName)
                            Complete-ComputerMaintenance -ComputerName $ComputerName -ComputerWorkload $ComputerWorkload -DestinationHostLock ([ref]$DestinationHostLock)
                        }
                    }
                }
            }
        }

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$_.FullyQualifiedErrorId: ''{0}''' -f $_.FullyQualifiedErrorId)
        Write-Debug -Message ('if ($_.FullyQualifiedErrorId -ne ''{0}'')' -f $SkipPreventivelyLockedFullyQualifiedErrorId)
        if ($_.FullyQualifiedErrorId -ne $SkipPreventivelyLockedFullyQualifiedErrorId) {

            Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
            $PSCmdlet.ThrowTerminatingError($_)
        }

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
                Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''  -Scope ''Script''' -f $FinallyVariable.Name, [string]$ErrorHandlingVariable.Value)
                Set-Variable -Name $FinallyVariable.Name -Value $FinallyVariable.Value -Scope 'Script'
            }
        }

        Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
        Write-Debug -Message 'if ($HostLock)'
        if ($HostLock) {
            Write-Debug -Message 'Unlock-Resource -LockObject $HostLock'
            Unlock-Resource -LockObject $HostLock
        }
        Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
        Write-Debug -Message 'if ($DestinationHostLock)'
        if ($DestinationHostLock) {
            Write-Debug -Message 'Unlock-Resource -LockObject $DestinationHostLock'
            Unlock-Resource -LockObject $DestinationHostLock
        }

        Write-Debug -Message ('EXIT FINALLY {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}