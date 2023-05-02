function Initialize-ComputerMaintenance {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [ref]$HostLock,
        [Parameter(Mandatory)]
        [ref]$DestinationHostLock,
        [switch]$SkipNotLockable,
        [switch]$SkipPreventivelyLocked,
        [string]$SkipPreventivelyLockedFullyQualifiedErrorId
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
        Write-Debug -Message ('$HostLock.Value: ''{0}''' -f $HostLock.Value)
        Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
        Write-Debug -Message ('$SkipNotLockable = ${0}' -f $SkipNotLockable)
        Write-Debug -Message ('$SkipPreventivelyLocked = ${0}' -f $SkipPreventivelyLocked)

        Write-Debug -Message '$CallerName = Get-LockCallerName'
        $CallerName = Get-LockCallerName
        Write-Debug -Message ('$CallerName = ''{0}''' -f $CallerName)

        try {
            Write-Debug -Message ('$HostLock.Value = Lock-HostResource -ComputerName ''{0}'' -CallerName ''{1}'' -Hard' -f $ComputerName, $CallerName)
            $HostLock.Value = Lock-HostResource -ComputerName $ComputerName -CallerName $CallerName -Hard
            Write-Debug -Message ('$HostLock: ''{0}''' -f $HostLock)
            Write-Debug -Message ('$HostLock.Value: ''{0}''' -f $HostLock.Value)
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

        Write-Debug -Message 'if ($HostLock.Value)'
        if ($HostLock.Value) {
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
                            $Message = ('Skipping the computer {0} because it is locked by other sources for more than {1} already and $SkipPreventivelyLocked is {2}.' -f $ComputerName, [string]$PreventiveLockThreshold, [string]$SkipPreventivelyLocked)
                            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.OperationCanceledException' -ArgumentList $Message), $SkipPreventivelyLockedFullyQualifiedErrorId, [System.Management.Automation.ErrorCategory]::OperationStopped, $null)))
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
                    Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}'' -Scope ''Script''' -f $PreClearVariable.Name, [string]$PreClearVariable.Value)
                    Set-Variable -Name $PreClearVariable.Name -Value $PreClearVariable.Value -Scope 'Script'
                }
            }

            Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
            Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
            Write-Debug -Message ('$ComputerWorkload = Clear-ComputerWorkload -ComputerName ''{0}'' -DestinationHostLock $DestinationHostLock' -f $ComputerName)
            $ComputerWorkload = Clear-ComputerWorkload -ComputerName $ComputerName -DestinationHostLock $DestinationHostLock
            Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
            Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
            Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)

            Write-Debug -Message ('$PostClearVariables = Invoke-CustomScriptBlockCommand -Mode ''PostClear'' -ComputerName ''{0}'' -Variables (Get-Variable | Where-Object -FilterScript {{$_ -is [System.Management.Automation.PSVariable]}})' -f $ComputerName)
            $PostClearVariables = Invoke-CustomScriptBlockCommand -Mode 'PostClear' -ComputerName $ComputerName -Variables (Get-Variable | Where-Object -FilterScript { $_ -is [System.Management.Automation.PSVariable] })
            Write-Debug -Message ('$PostClearVariables: ''{0}''' -f [string]$PostClearVariables)
            Write-Debug -Message 'if ($PostClearVariables)'
            if ($PostClearVariables) {
                foreach ($PostClearVariable in $PostClearVariables) {
                    Write-Debug -Message ('$PostClearVariable: ''{0}''' -f [string]$PostClearVariable)
                    Write-Debug -Message ('Set-Variable -Name ''{0}'' -Value ''{1}''  -Scope ''Script''' -f $PostClearVariable.Name, [string]$PostClearVariable.Value)
                    Set-Variable -Name $PostClearVariable.Name -Value $PostClearVariable.Value -Scope 'Script'
                }
            }

            Write-Debug -Message ('$ComputerWorkload: ''{0}''' -f [string]$ComputerWorkload)
            Write-Debug -Message '$ComputerWorkload'
            $ComputerWorkload
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