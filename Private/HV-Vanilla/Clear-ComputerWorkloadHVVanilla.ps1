function Clear-ComputerWorkloadHVVanilla {
    #Requires -Version 3.0
    #Requires -Modules ResourceLocker

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [string]$DestinationVMHostName,
        [Parameter(Mandatory)]
        [string]$DestinationVMHostPath,
        [scriptblock]$SourceFilter,
        [scriptblock]$DestinationFilter,
        [int]$MaxParallelMigrations,
        [switch]$PutInASubfolder = $ModuleWideHVVanillaPutInASubfolder,
        [ref]$DestinationVMHostLock
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$DestinationVMHostName = ''{0}''' -f $DestinationVMHostName)
        Write-Debug -Message ('$DestinationVMHostPath = ''{0}''' -f $DestinationVMHostPath)
        Write-Debug -Message ('$SourceFilter = {{{0}}}' -f $SourceFilter)
        Write-Debug -Message ('$DestinationFilter = {{{0}}}' -f $DestinationFilter)
        Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
        Write-Debug -Message ('$PutInASubfolder = ${0}' -f $PutInASubfolder)
        Write-Debug -Message ('$DestinationVMHostLock: ''{0}''' -f $DestinationVMHostLock)
        Write-Debug -Message ('$DestinationVMHostLock.Value: ''{0}''' -f $DestinationVMHostLock.Value)

        Write-Debug -Message '$CallerName = Get-LockCallerName'
        $CallerName = Get-LockCallerName
        Write-Debug -Message ('$CallerName = ''{0}''' -f $CallerName)

        Write-Debug -Message ('$AllSourceVMs = Get-VM -ComputerName ''{0}''' -f $ComputerName)
        $AllSourceVMs = Get-VM -ComputerName $ComputerName
        Write-Debug -Message ('$AllSourceVMs: ''{0}''' -f [string]$AllSourceVMs.Name)

        Write-Debug -Message 'if ($SourceFilter)'
        if ($SourceFilter) {
            Write-Debug -Message ('$SourceVMs = $AllSourceVMs | Where-Object -FilterScript {{{0}}}' -f $SourceFilter)
            $SourceVMs = $AllSourceVMs | Where-Object -FilterScript $SourceFilter
        }
        else {
            Write-Debug -Message '$SourceVMs = $AllSourceVMs'
            $SourceVMs = $AllSourceVMs
        }
        Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs.Name)

        Write-Debug -Message 'if ($SourceVMs)'
        if ($SourceVMs) {
            Write-Debug -Message ('$AllDestinationVMs = Get-VM -ComputerName ''{0}''' -f $DestinationVMHostName)
            $AllDestinationVMs = Get-VM -ComputerName $DestinationVMHostName
            Write-Debug -Message ('$AllDestinationVMs: ''{0}''' -f [string]$AllDestinationVMs.Name)

            Write-Debug -Message ('$DestinationFilter = {{{0}}}' -f $DestinationFilter)
            Write-Debug -Message 'if ($DestinationFilter)'
            if ($DestinationFilter) {
                Write-Debug -Message ('$DestinationVMs = $AllDestinationVMs | Where-Object -FilterScript {{{0}}}' -f $DestinationFilter)
                $DestinationVMs = $AllDestinationVMs | Where-Object -FilterScript $DestinationFilter
            }
            else {
                Write-Debug -Message '$DestinationVMs = $AllDestinationVMs'
                $DestinationVMs = $AllDestinationVMs
            }
            Write-Debug -Message ('$DestinationVMs: ''{0}''' -f [string]$DestinationVMs.Name)

            Write-Debug -Message 'if ($DestinationVMs)'
            if ($DestinationVMs) {
                $Message = 'Unable to proceed: the destination server {0} should not contain any VMs, but it does ({1})' -f $DestinationVMHostName, [string]$DestinationVMs.Name
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::LimitsExceeded, $null)))
            }

            Write-Debug -Message ('$DestinationVMHostLock.Value: ''{0}''' -f [string]$DestinationVMHostLock.Value)
            Write-Debug -Message 'if (-not ($DestinationVMHostLock.Value))'
            if (-not ($DestinationVMHostLock.Value)) {
                Write-Debug -Message ('$DestinationVMHostLock.Value = Lock-HostResource -ComputerName {0} -CallerName {1}' -f $DestinationVMHostName, $CallerName)
                $DestinationVMHostLock.Value = Lock-HostResource -ComputerName $DestinationVMHostName -CallerName $CallerName
                Write-Debug -Message ('$DestinationVMHostLock: ''{0}''' -f $DestinationVMHostLock)
                Write-Debug -Message ('$DestinationVMHostLock.Value: ''{0}''' -f $DestinationVMHostLock.Value)
            }
            Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs.Name)

            Write-Debug -Message ('$DestinationVMHost = Get-VMHost -ComputerName ''{0}''' -f $DestinationVMHostName)
            $DestinationVMHost = Get-VMHost -ComputerName $DestinationVMHostName
            Write-Debug -Message ('$DestinationVMHost: ''{0}''' -f $DestinationVMHost)
            Write-Debug -Message ('$UnmigratableVMs = Move-VMReliably -DestinationVMHost $DestinationVMHost -Path ''{0}'' -VM $SourceVMs -MaxParallelMigrations {1} -PutInASubfolder:${2}' -f $DestinationVMHostPath, $MaxParallelMigrations, $PutInASubfolder)
            $UnmigratableVMs = Move-VMReliably -DestinationVMHost $DestinationVMHost -Path $DestinationVMHostPath -VM $SourceVMs -MaxParallelMigrations $MaxParallelMigrations -PutInASubfolder:$PutInASubfolder
            Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
            Write-Debug -Message 'if ($UnmigratableVMs)'
            if ($UnmigratableVMs) {
                $Message = 'Unable to proceed: unable to migrate some VMs ({0}) from host {1} to host {2}' -f [string]$UnmigratableVMs.Name, $ComputerName, $DestinationVMHostName
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::ResourceBusy, $null)))
            }

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