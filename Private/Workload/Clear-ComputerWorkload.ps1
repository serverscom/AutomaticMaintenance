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

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$DestinationHostLock: {0}' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: {0}' -f $DestinationHostLock.Value)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName {0}' -f $ComputerName)
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f $ComputerMaintenanceConfiguration)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration.Type: ''{0}''' -f $ComputerMaintenanceConfiguration.Type)
        Write-Debug -Message 'switch ($ComputerMaintenanceConfiguration.Type)'
        switch ($ComputerMaintenanceConfiguration.Type) {
            'HV-SCVMM' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

                    Write-Debug -Message ('$FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode ''{0}''' -f $_)
                    $FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode $_
                    Write-Debug -Message ('$FilterData = ''{0}''' -f $FilterData)
                    Write-Debug -Message '$SourceFilter = $FilterData.Source'
                    $SourceFilter = $FilterData.Source
                    Write-Debug -Message ('$SourceFilter = ''{0}''' -f $SourceFilter)
                    Write-Debug -Message '$DestinationFilter = $FilterData.Destination'
                    $DestinationFilter = $FilterData.Destination
                    Write-Debug -Message ('$DestinationFilter = ''{0}''' -f $DestinationFilter)

                    Write-Debug -Message ('Clear-ComputerWorkloadHVSCVMM -ComputerName {0} -DestinationVMHostName {1} -DestinationVMHostPath {2} -DestinationVMHostLock {3} -SourceFilter {{{4}}} -DestinationFilter {{{5}}} -MaxParallelMigrations {6}' -f $ComputerName, $WorkloadPair.DestinationName, $WorkloadPair.DestinationPath, $DestinationHostLock.Value, $SourceFilter, $DestinationFilter, $WorkloadPair.MaxParallelMigrations)
                    Clear-ComputerWorkloadHVSCVMM -ComputerName $ComputerName -DestinationVMHostName $WorkloadPair.DestinationName -DestinationVMHostPath $WorkloadPair.DestinationPath -DestinationVMHostLock $DestinationHostLock -SourceFilter $SourceFilter -DestinationFilter $DestinationFilter -MaxParallelMigrations $WorkloadPair.MaxParallelMigrations
                }
            }
            'HV-Vanilla' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

                    Write-Debug -Message ('$FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode ''{0}''' -f $_)
                    $FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode $_
                    Write-Debug -Message ('$FilterData = ''{0}''' -f $FilterData)
                    Write-Debug -Message '$SourceFilter = $FilterData.Source'
                    $SourceFilter = $FilterData.Source
                    Write-Debug -Message ('$SourceFilter = {{{0}}}' -f $SourceFilter)
                    Write-Debug -Message '$DestinationFilter = $FilterData.Destination'
                    $DestinationFilter = $FilterData.Destination
                    Write-Debug -Message ('$DestinationFilter = {{{0}}}' -f $DestinationFilter)

                    Write-Debug -Message '$PutInASubfolderExists = Get-Member -InputObject $WorkloadPair -Name ''PutInASubfolder'''
                    $PutInASubfolderAttribute = Get-Member -InputObject $WorkloadPair -Name 'PutInASubfolder'
                    Write-Debug -Message ('$PutInASubfolderAttribute: ''{0}''' -f $PutInASubfolderAttribute)
                    Write-Debug -Message 'if ($PutInASubfolderAttribute)'
                    if ($PutInASubfolderAttribute) {
                        Write-Debug -Message '$ClearComputerWorkloadHVVanillaParameters = @{PutInASubfolder = $WorkloadPair.PutInASubfolder}'
                        $ClearComputerWorkloadHVVanillaParameters = @{
                            PutInASubfolder = $WorkloadPair.PutInASubfolder
                        }
                    }
                    else {
                        Write-Debug -Message '$PutInASubfolderAttribute = Get-Member -InputObject $ComputerMaintenanceConfiguration -Name ''PutInASubfolder'''
                        $PutInASubfolderAttribute = Get-Member -InputObject $ComputerMaintenanceConfiguration -Name 'PutInASubfolder'
                        Write-Debug -Message 'if ($PutInASubfolderAttribute)'
                        if ($PutInASubfolderAttribute) {
                            Write-Debug -Message '$ClearComputerWorkloadHVVanillaParameters = @{PutInASubfolder = $ComputerMaintenanceConfiguration.PutInASubfolder}'
                            $ClearComputerWorkloadHVVanillaParameters = @{
                                PutInASubfolder = $ComputerMaintenanceConfiguration.PutInASubfolder
                            }
                        }
                    }
                    Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters: ''{0}''' -f ($ClearComputerWorkloadHVVanillaParameters | Out-String))

                    Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                    Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
                    Write-Debug -Message ('Clear-ComputerWorkloadHVVanilla -ComputerName ''{0}'' -DestinationVMHostName ''{1}'' -DestinationVMHostPath ''{2}'' -DestinationVMHostLock $DestinationHostLock -SourceFilter {{{3}}} -DestinationFilter {{{4}}} -MaxParallelMigrations {5} @ClearComputerWorkloadHVVanillaParameters' -f $ComputerName, $WorkloadPair.DestinationName, $WorkloadPair.DestinationPath, $SourceFilter, $DestinationFilter, $WorkloadPair.MaxParallelMigrations)
                    Clear-ComputerWorkloadHVVanilla -ComputerName $ComputerName -DestinationVMHostName $WorkloadPair.DestinationName -DestinationVMHostPath $WorkloadPair.DestinationPath -DestinationVMHostLock $DestinationHostLock -SourceFilter $SourceFilter -DestinationFilter $DestinationFilter -MaxParallelMigrations $WorkloadPair.MaxParallelMigrations @ClearComputerWorkloadHVVanillaParameters
                }
            }
            'SCDPM' {
                # TODO
            }
            'Generic' {
                Write-Debug -Message '$false'
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