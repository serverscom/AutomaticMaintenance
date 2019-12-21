function Get-HVSCVMMWorkloadFilter {
    #Requires -Version 3.0

    [CmdletBinding()]
    [OutputType([scriptblock])]
    Param (
        [Parameter(ParameterSetName = 'ByWLPair', Mandatory)]
        [PSCustomObject[]]$WorkloadPair,
        [Parameter(ParameterSetName = 'ByNamePath', Mandatory)]
        [string]$ComputerName,
        [Parameter(ParameterSetName = 'ByNamePath', Mandatory)]
        [string]$Path,
        [Parameter(ParameterSetName = 'ByWLPair')]
        [Parameter(ParameterSetName = 'ByNamePath')]
        [switch]$Destination
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)
        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$Destination: ''{0}''' -f $Destination)

        Write-Debug -Message 'if (-not $WorkloadPair)'
        if (-not $WorkloadPair) {
            Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName ''{0}''' -f $ComputerName)
            $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
            Write-Debug -Message ('$ComputerMaintenanceConfiguration: ''{0}''' -f [string]$ComputerMaintenanceConfiguration)
            Write-Debug -Message '$WorkloadConfiguration = $ComputerMaintenanceConfiguration.Workload'
            $WorkloadConfiguration = $ComputerMaintenanceConfiguration.Workload
            Write-Debug -Message ('$WorkloadConfiguration: ''{0}''' -f [string]$WorkloadConfiguration)
            Write-Debug -Message ('$WorkloadPair = $WorkloadConfiguration | Where-Object -FilterScript {{$_.Path -eq ''{0}''}}' -f $Path)
            $WorkloadPair = $WorkloadConfiguration | Where-Object -FilterScript {$_.Path -eq $Path}
        }
        Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

        Write-Debug -Message 'if ($Destination)'
        if ($Destination) {
            $WorkloadPairPath = $WorkloadPair.DestinationPath
            $WorkloadPairFilter = $WorkloadPair.DestinationFilter
        }
        else {
            $WorkloadPairPath = $WorkloadPair.Path
            $WorkloadPairFilter = $WorkloadPair.Filter
        }
        Write-Debug -Message ('$WorkloadPairPath = ''{0}''' -f $WorkloadPairPath)
        Write-Debug -Message ('$WorkloadPairFilter: ''{0}''' -f $WorkloadPairFilter)

        Write-Debug -Message ('$FilterPath = [System.IO.Path]::Combine(''{0}'', ''*'')' -f $WorkloadPairPath)
        $FilterPath = [System.IO.Path]::Combine($WorkloadPairPath, '*') # Join-Path cannot combine paths on a drive which does not exist on the machine
        Write-Debug -Message ('$FilterPath = ''{0}''' -f $FilterPath)
        Write-Debug -Message ('$FilterString = ''$_.Location -like ''''{{0}}'''''' -f ''{0}''' -f $FilterPath)
        $FilterString = '$_.Location -like ''{0}''' -f $FilterPath
        Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)


        Write-Debug -Message '$Filter = $WorkloadPairFilter'
        $Filter = $WorkloadPairFilter
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)
        Write-Debug -Message 'if ($Filter)'
        if ($Filter) {
            Write-Debug -Message ('$FilterString = ''{{0}} -and {{1}}'' -f ''{0}'', ''{1}''' -f $FilterString, $Filter)
            $FilterString = '{0} -and {1}' -f $FilterString, $Filter
        }
        Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)

        Write-Debug -Message ('[scriptblock]::Create(''{0}'')' -f $FilterString)
        [scriptblock]::Create($FilterString)

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