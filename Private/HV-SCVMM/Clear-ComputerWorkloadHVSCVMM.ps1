function Clear-ComputerWorkloadHVSCVMM {
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
        [ref]$DestinationVMHostLock
    )

    $ErrorActionPreference = 'Stop'
    
    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = {0}' -f $ComputerName)
        Write-Debug -Message ('$DestinationVMHostName = {0}' -f $DestinationVMHostName)
        Write-Debug -Message ('$DestinationVMHostPath = {0}' -f $DestinationVMHostPath)
        Write-Debug -Message ('$SourceFilter = {0}' -f $SourceFilter)
        Write-Debug -Message ('$DestinationFilter = {0}' -f $DestinationFilter)
        Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
        Write-Debug -Message ('$DestinationVMHostLock: {0}' -f $DestinationVMHostLock)
        Write-Debug -Message ('$DestinationVMHostLock.Value: {0}' -f $DestinationVMHostLock.Value)

        Write-Debug -Message ('$DestinationVMHost = Resolve-SCVMHost -ComputerName {0}' -f $DestinationVMHostName)
        $DestinationVMHost = Resolve-SCVMHost -ComputerName $DestinationVMHostName
        Write-Debug -Message ('$DestinationVMHost: {0}' -f $DestinationVMHost.Name)

        Write-Debug -Message '$VMMServer = $DestinationVMHost.ServerConnection'
        $VMMServer = $DestinationVMHost.ServerConnection
        Write-Debug -Message ('$VMMServer: {0}' -f $VMMServer.Name)

        Write-Debug -Message '$CallerName = Get-LockCallerName'
        $CallerName = Get-LockCallerName
        Write-Debug -Message ('$CallerName = {0}' -f $CallerName)
        Write-Debug -Message ('$VMMServerLock = Lock-HostResource -ComputerName {0} -CallerName {1}' -f $VMMServer.Name, $CallerName)
        $VMMServerLock = Lock-HostResource -ComputerName $VMMServer.Name -CallerName $CallerName
        Write-Debug -Message ('$VMMServerLock: {0}' -f [string]$VMMServerLock)

        Write-Debug -Message ('$SourceVMHost = Get-SCVMHost -ComputerName {0} -VMMServer {1}' -f $ComputerName, $VMMServer.Name)
        $SourceVMHost = Get-SCVMHost -ComputerName $ComputerName -VMMServer $VMMServer
        Write-Debug -Message ('$SourceVMHost: {0}' -f $SourceVMHost.Name)

        Write-Debug -Message ('$SourceFilter: ''{0}''' -f $SourceFilter)
        Write-Debug -Message 'if ($SourceFilter)'
        if ($SourceFilter) {
            Write-Debug -Message ('$SourceVMs = Get-SCVirtualMachine -VMHost ''{0}'' | Where-Object -FilterScript {{{1}}}' -f $SourceVMHost.Name, $SourceFilter)
            $SourceVMs = Get-SCVirtualMachine -VMHost $SourceVMHost | Where-Object -FilterScript $SourceFilter
        }
        else {
            Write-Debug -Message ('$SourceVMs = Get-SCVirtualMachine -VMHost ''{0}''' -f $SourceVMHost.Name)
            $SourceVMs = Get-SCVirtualMachine -VMHost $SourceVMHost
        }
        Write-Debug -Message ('$SourceVMs: {0}' -f [string]$SourceVMs.Name)

        Write-Debug -Message 'if ($SourceVMs)'
        if ($SourceVMs) {
            if ($DestinationFilter) {
                Write-Debug -Message ('$DestinationVMs = Get-SCVirtualMachine -VMHost ''{0}'' | Where-Object -FilterScript {{{1}}}' -f $DestinationVMHost.Name, $DestinationFilter)
                $DestinationVMs = Get-SCVirtualMachine -VMHost $DestinationVMHost | Where-Object -FilterScript $DestinationFilter
                Write-Debug -Message ('$DestinationVMs: {0}' -f [string]$DestinationVMs.Name)
            }
            else {
                Write-Debug -Message ('$DestinationVMs = Get-SCVirtualMachine -VMHost ''{0}''' -f $DestinationVMHost.Name)
                $DestinationVMs = Get-SCVirtualMachine -VMHost $DestinationVMHost
                Write-Debug -Message ('$DestinationVMs: {0}' -f [string]$DestinationVMs.Name)
            }

            Write-Debug -Message 'if ($DestinationVMs.Name)'
            if ($DestinationVMs) {
                $Message = 'Unable to proceed: the destination server {0} should not contain any VMs, but it does ({1})' -f $DestinationVMHostName, [string]$DestinationVMs.Name
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::LimitsExceeded, $null)))
            }

            Write-Debug -Message ('$DestinationVMHostLock.Value: ''{0}''' -f [string]$DestinationVMHostLock.Value)
            Write-Debug -Message 'if (-not ($DestinationVMHostLock.Value))'
            if (-not ($DestinationVMHostLock.Value)) {
                Write-Debug -Message ('$DestinationVMHostLock.Value = Lock-HostResource -ComputerName {0} -CallerName {1}' -f $DestinationVMHostName, $CallerName)
                $DestinationVMHostLock.Value = Lock-HostResource -ComputerName $DestinationVMHostName -CallerName $CallerName
                Write-Debug -Message ('$DestinationHostLock: {0}' -f $DestinationHostLock)
                Write-Debug -Message ('$DestinationHostLock.Value: {0}' -f $DestinationHostLock.Value)
            }
            Write-Debug -Message ('$UnmigratableVMs = Move-SCVirtualMachineReliably -DestinationVMHost {1} -Path {2} -VM {3} -MaxParallelMigrations {4}' -f $SourceVMHost.Name, $DestinationVMHost.Name, $DestinationVMHostPath, [string]$SourceVMs.Name, $MaxParallelMigrations)
            $UnmigratableVMs = Move-SCVirtualMachineReliably -DestinationVMHost $DestinationVMHost -Path $DestinationVMHostPath -VM $SourceVMs -MaxParallelMigrations $MaxParallelMigrations
            Write-Debug -Message ('$UnmigratableVMs: {0}' -f [string]$UnmigratableVMs.Name)
            Write-Debug -Message 'if ($UnmigratableVMs)'
            if ($UnmigratableVMs) {
                Write-Debug -Message ('$VMMServerLock: ''{0}''' -f [string]$VMMServerLock)
                Write-Debug -Message 'if ($VMMServerLock)'
                if ($VMMServerLock) {
                    Write-Debug -Message ('Unlock-Resource -LockObject {0}' -f [string]$VMMServerLock)
                    Unlock-Resource -LockObject $VMMServerLock
                }

                $Message = 'Unable to proceed: unable to migrate some VMs ({0}) from host {1} to host {2}' -f [string]$UnmigratableVMs.Name, $ComputerName, $DestinationVMHostName
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::ResourceBusy, $null)))
            }
            
            Write-Debug -Message ([string]$true)
            $true
        }
        else {
            Write-Debug -Message ([string]$false)
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
    finally {
        Write-Debug -Message ('ENTER FINALLY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VMMServerLock: ''{0}''' -f [string]$VMMServerLock)
        Write-Debug -Message 'if ($VMMServerLock)'
        if ($VMMServerLock) {
            Write-Debug -Message ('Unlock-Resource -LockObject {0}' -f [string]$VMMServerLock)
            Unlock-Resource -LockObject $VMMServerLock
        }

        Write-Debug -Message ('EXIT FINALLY {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}