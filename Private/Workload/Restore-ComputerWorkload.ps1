function Restore-ComputerWorkload {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [ref]$DestinationHostLock
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
        Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName ''{0}''' -f $ComputerName)
        $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerMaintenanceConfiguration: ''{0}''' -f [string]$ComputerMaintenanceConfiguration)

        Write-Debug -Message ('$ComputerMaintenanceConfiguration.Type: ''{0}''' -f $ComputerMaintenanceConfiguration.Type)
        Write-Debug -Message 'switch ($ComputerMaintenanceConfiguration.Type)'
        switch ($ComputerMaintenanceConfiguration.Type) {
            'HV-SCVMM' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

                    Write-Debug -Message ('$FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode ''{0}'' -Restore' -f $_)
                    $FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode $_ -Restore
                    Write-Debug -Message ('$FilterData: ''{0}''' -f $FilterData)
                    Write-Debug -Message '$SourceFilter = $FilterData.Source'
                    $SourceFilter = $FilterData.Source
                    Write-Debug -Message ('$SourceFilter = {{{0}}}' -f $SourceFilter)
                    Write-Debug -Message '$DestinationFilter = $FilterData.Destination'
                    $DestinationFilter = $FilterData.Destination
                    Write-Debug -Message ('$DestinationFilter = {{{0}}}' -f $DestinationFilter)

                    Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                    Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
                    Write-Debug -Message ('$null = Clear-ComputerWorkloadHVSCVMM -ComputerName ''{0}'' -DestinationVMHostName ''{1}'' -DestinationVMHostPath ''{2}'' -DestinationVMHostLock $DestinationHostLock -SourceFilter {{{3}}} -DestinationFilter {{{4}}} -MaxParallelMigrations {5}' -f $WorkloadPair.DestinationName, $ComputerName, $WorkloadPair.Path, $SourceFilter, $DestinationFilter, $WorkloadPair.MaxParallelMigrations)
                    $null = Clear-ComputerWorkloadHVSCVMM -ComputerName $WorkloadPair.DestinationName -DestinationVMHostName $ComputerName -DestinationVMHostPath $WorkloadPair.Path -DestinationVMHostLock $DestinationHostLock -SourceFilter $SourceFilter -DestinationFilter $DestinationFilter -MaxParallelMigrations $WorkloadPair.MaxParallelMigrations
                }
            }
            'HV-Vanilla' {
                foreach ($WorkloadPair in $ComputerMaintenanceConfiguration.Workload) {
                    Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

                    Write-Debug -Message ('$FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode ''{0}'' -Restore' -f $_)
                    $FilterData = Get-HVWorkloadFilter -WorkloadPair $WorkloadPair -Mode $_ -Restore
                    Write-Debug -Message ('$FilterData = ''{0}''' -f $FilterData)
                    Write-Debug -Message '$SourceFilter = $FilterData.Source'
                    $SourceFilter = $FilterData.Source
                    Write-Debug -Message ('$SourceFilter = {{{0}}}' -f $SourceFilter)
                    Write-Debug -Message '$DestinationFilter = $FilterData.Destination'
                    $DestinationFilter = $FilterData.Destination
                    Write-Debug -Message ('$DestinationFilter = {{{0}}}' -f $DestinationFilter)

                    Write-Debug -Message '$ClearComputerWorkloadHVVanillaParameters = @{}'
                    $ClearComputerWorkloadHVVanillaParameters = @{}
                    Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters: ''{0}''' -f ($ClearComputerWorkloadHVVanillaParameters | Out-String))

                    Write-Debug -Message 'if ($SourceFilter)'
                    if ($SourceFilter) {
                        Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters.Add(''SourceFilter'', {{{0}}})' -f $SourceFilter)
                        $ClearComputerWorkloadHVVanillaParameters.Add('SourceFilter', $SourceFilter)
                    }
                    Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters: ''{0}''' -f ($ClearComputerWorkloadHVVanillaParameters | Out-String))

                    Write-Debug -Message 'if ($DestinationFilter)'
                    if ($DestinationFilter) {
                        Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters.Add(''DestinationFilter'', {{{0}}})' -f $DestinationFilter)
                        $ClearComputerWorkloadHVVanillaParameters.Add('DestinationFilter', $DestinationFilter)
                    }
                    Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters: ''{0}''' -f ($ClearComputerWorkloadHVVanillaParameters | Out-String))

                    Write-Debug -Message ('$WorkloadPair.MaxParallelMigrations: ''{0}''' -f $WorkloadPair.MaxParallelMigrations)
                    Write-Debug 'if ($WorkloadPair.MaxParallelMigrations)'
                    if ($WorkloadPair.MaxParallelMigrations) {
                        Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters.Add(''MaxParallelMigrations'', {0})' -f $WorkloadPair.MaxParallelMigrations)
                        $ClearComputerWorkloadHVVanillaParameters.Add('MaxParallelMigrations', $WorkloadPair.MaxParallelMigrations)
                    }

                    Write-Debug -Message '$PutInASubfolderExists = Get-Member -InputObject $WorkloadPair -Name ''PutInASubfolder'''
                    $PutInASubfolderAttribute = Get-Member -InputObject $WorkloadPair -Name 'PutInASubfolder'
                    Write-Debug -Message ('$PutInASubfolderAttribute: ''{0}''' -f $PutInASubfolderAttribute)
                    Write-Debug -Message 'if ($PutInASubfolderAttribute)'
                    if ($PutInASubfolderAttribute) {
                        Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters.Add(''PutInASubfolder'', ${0})' -f $WorkloadPair.PutInASubfolder)
                        $ClearComputerWorkloadHVVanillaParameters.Add('PutInASubfolder', $WorkloadPair.PutInASubfolder)
                    }
                    else {
                        Write-Debug -Message '$PutInASubfolderAttribute = Get-Member -InputObject $ComputerMaintenanceConfiguration -Name ''PutInASubfolder'''
                        $PutInASubfolderAttribute = Get-Member -InputObject $ComputerMaintenanceConfiguration -Name 'PutInASubfolder'
                        Write-Debug -Message ('$PutInASubfolderAttribute: ''{0}''' -f $PutInASubfolderAttribute)
                        Write-Debug -Message 'if ($PutInASubfolderAttribute)'
                        if ($PutInASubfolderAttribute) {
                            Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters.Add(''PutInASubfolder'', ${0})' -f $ComputerMaintenanceConfiguration.PutInASubfolder)
                            $ClearComputerWorkloadHVVanillaParameters.Add('PutInASubfolder', $ComputerMaintenanceConfiguration.PutInASubfolder)
                        }
                    }
                    Write-Debug -Message ('$ClearComputerWorkloadHVVanillaParameters: ''{0}''' -f ($ClearComputerWorkloadHVVanillaParameters | Out-String))

                    Write-Debug -Message ('$DestinationHostLock: ''{0}''' -f $DestinationHostLock)
                    Write-Debug -Message ('$DestinationHostLock.Value: ''{0}''' -f $DestinationHostLock.Value)
                    Write-Debug -Message ('$null = Clear-ComputerWorkloadHVVanilla -ComputerName ''{0}'' -DestinationVMHostName ''{1}'' -DestinationVMHostPath ''{2}'' -DestinationVMHostLock $DestinationHostLock @ClearComputerWorkloadHVVanillaParameters' -f $WorkloadPair.DestinationName, $ComputerName, $WorkloadPair.Path)
                    $null = Clear-ComputerWorkloadHVVanilla -ComputerName $WorkloadPair.DestinationName -DestinationVMHostName $ComputerName -DestinationVMHostPath $WorkloadPair.Path -DestinationVMHostLock $DestinationHostLock @ClearComputerWorkloadHVVanillaParameters
                }
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