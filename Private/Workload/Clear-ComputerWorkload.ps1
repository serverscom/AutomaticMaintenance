function Clear-ComputerWorkload {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [ref]$DestinationHostLock
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = {0}' -f $ComputerName)
        Write-Debug -Message ('$DestinationHostLock: {0}' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: {0}' -f $DestinationHostLock.Value)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName {0}' -f $ComputerName)
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f $ComputerMaintenanceConfiguration)

        Write-Debug -Message ('switch ({0})' -f $ComputerMaintenanceConfiguration.Type)
        switch ($ComputerMaintenanceConfiguration.Type) {
            'HV-SCVMM' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message '$SourceFilter = Get-HVSCVMMWorkloadFilter -WorkloadPair $WorkloadPair'
                    $SourceFilter = Get-HVSCVMMWorkloadFilter -WorkloadPair $WorkloadPair
                    Write-Debug -Message ('$DestinationFilter = Get-HVSCVMMWorkloadFilter -ComputerName ''{0}'' -Path ''{1}''' -f $WorkloadPair.DestinationName, $WorkloadPair.DestinationPath)
                    $DestinationFilter = Get-HVSCVMMWorkloadFilter -ComputerName $WorkloadPair.DestinationName -Path $WorkloadPair.DestinationPath

                    Write-Debug -Message ('Clear-ComputerWorkloadHVSCVMM -ComputerName {0} -DestinationVMHostName {1} -DestinationVMHostPath {2} -DestinationVMHostLock {3} -SourceFilter {4} -DestinationFilter {5} -MaxParallelMigrations {6}' -f $ComputerName, $WorkloadPair.DestinationName, $WorkloadPair.DestinationPath, $DestinationHostLock.Value, $SourceFilter, $DestinationFilter, $WorkloadPair.MaxParallelMigrations)
                    Clear-ComputerWorkloadHVSCVMM -ComputerName $ComputerName -DestinationVMHostName $WorkloadPair.DestinationName -DestinationVMHostPath $WorkloadPair.DestinationPath -DestinationVMHostLock $DestinationHostLock -SourceFilter $SourceFilter -DestinationFilter $DestinationFilter -MaxParallelMigrations $WorkloadPair.MaxParallelMigrations
                }
            }
            'HV-Vanilla' {
                # TODO
            }
            'SCDPM' {
                # TODO
            }
            'Generic' {
                $false # Generic hosts have no workload to migrate
            }
        }

        Write-Debug -Message ('$DestinationHostLock: {0}' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: {0}' -f $DestinationHostLock.Value)

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