function Restore-ComputerWorkload {
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

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName {0}' -f $ComputerName)
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f [string]$ComputerMaintenanceConfiguration)

        Write-Debug -Message ('switch ({0})' -f $ComputerMaintenanceConfiguration.Type)
        switch ($ComputerMaintenanceConfiguration.Type) {
            'HV-SCVMM' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message '$DestinationFilter = Get-HVSCVMMWorkloadFilter -WorkloadPair $WorkloadPair'
                    $DestinationFilter = Get-HVSCVMMWorkloadFilter -WorkloadPair $WorkloadPair
                    Write-Debug -Message ('$SourceFilter = Get-HVSCVMMWorkloadFilter -ComputerName ''{0}'' -Path ''{1}''' -f $WorkloadPair.DestinationName, $WorkloadPair.DestinationPath)
                    $SourceFilter = Get-HVSCVMMWorkloadFilter -ComputerName $WorkloadPair.DestinationName -Path $WorkloadPair.DestinationPath

                    Write-Debug -Message ('$null = Clear-ComputerWorkloadHVSCVMM -ComputerName {0} -DestinationVMHostName {1} -DestinationVMHostPath {2} -DestinationVMHostLock {3} -SourceFilter {4} -DestinationFilter {5} -MaxParallelMigrations {6}' -f $WorkloadPair.DestinationName, $ComputerName, $WorkloadPair.Path, $DestinationHostLock.Value, $SourceFilter, $DestinationFilter, $WorkloadPair.MaxParallelMigrations)
                    $null = Clear-ComputerWorkloadHVSCVMM -ComputerName $WorkloadPair.DestinationName -DestinationVMHostName $ComputerName -DestinationVMHostPath $WorkloadPair.Path -DestinationVMHostLock ([ref]$DestinationHostLock) -SourceFilter $SourceFilter -DestinationFilter $DestinationFilter -MaxParallelMigrations $WorkloadPair.MaxParallelMigrations
                }
            }
            'HV-Vanilla' {

            }
            'SCDPM' {

            }
            'Generic' {

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

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}