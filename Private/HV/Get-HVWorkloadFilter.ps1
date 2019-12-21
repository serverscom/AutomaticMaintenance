function Get-HVWorkloadFilter {
    [CmdletBinding()]
    [OutputType([hashtable])]
    Param (
        [Parameter(ParameterSetName = 'ByWLPair', Mandatory)]
        [PSCustomObject[]]$WorkloadPair,
        [Parameter(ParameterSetName = 'ByNamePath', Mandatory)]
        [string]$ComputerName,
        [Parameter(ParameterSetName = 'ByNamePath', Mandatory)]
        [string]$Path,
        [Parameter(ParameterSetName = 'ByWLPair')]
        [Parameter(ParameterSetName = 'ByNamePath')]
        [switch]$Restore,
        [string]$Mode
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)
        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$Restore: ''{0}''' -f $Restore)

        Write-Debug -Message 'if (-not $WorkloadPair)'
        if (-not $WorkloadPair) {
            Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName ''{0}''' -f $ComputerName)
            $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
            Write-Debug -Message ('$ComputerMaintenanceConfiguration: ''{0}''' -f [string]$ComputerMaintenanceConfiguration)
            Write-Debug -Message '$WorkloadConfiguration = $ComputerMaintenanceConfiguration.Workload'
            $WorkloadConfiguration = $ComputerMaintenanceConfiguration.Workload
            Write-Debug -Message ('$WorkloadConfiguration: ''{0}''' -f [string]$WorkloadConfiguration)
            Write-Debug -Message ('$WorkloadPair = $WorkloadConfiguration | Where-Object -FilterScript {{$_.Path -eq ''{0}''}}' -f $Path)
            $WorkloadPair = $WorkloadConfiguration | Where-Object -FilterScript { $_.Path -eq $Path }
        }
        Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)

        Write-Debug -Message 'if ($Restore)'
        if ($Restore) {
            Write-Debug -Message '$DestinationFilterPropertyName = ''RestoreDestinationFilter'''
            $DestinationFilterPropertyName = 'RestoreDestinationFilter'
            Write-Debug -Message '$SourcePathPropertyName = ''DestinationPath'''
            $SourcePathPropertyName = 'DestinationPath'
            Write-Debug -Message '$DestinationPathPropertyName = ''Path'''
            $DestinationPathPropertyName = 'Path'
        }
        else {
            Write-Debug -Message '$DestinationFilterPropertyName = ''DestinationFilter'''
            $DestinationFilterPropertyName = 'DestinationFilter'
            Write-Debug -Message '$SourcePathPropertyName = ''Path'''
            $SourcePathPropertyName = 'Path'
            Write-Debug -Message '$DestinationPathPropertyName = ''DestinationPath'''
            $DestinationPathPropertyName = 'DestinationPath'
        }
        Write-Debug -Message ('$DestinationFilterPropertyName = ''{0}''' -f $DestinationFilterPropertyName)
        Write-Debug -Message ('$SourcePathPropertyName = ''{0}''' -f $SourcePathPropertyName)
        Write-Debug -Message ('$DestinationPathPropertyName = ''{0}''' -f $DestinationPathPropertyName)

        Write-Debug -Message ('$SourceFilterString = Get-HVFilterStringCompatible -WorkloadPair $WorkloadPair -PathPropertyName ''{0}'' -FilterPropertyName ''SourceFilter'' -Mode ''{1}''' -f $SourcePathPropertyName, $Mode)
        $SourceFilterString = Get-HVFilterStringCompatible -WorkloadPair $WorkloadPair -PathPropertyName $SourcePathPropertyName -FilterPropertyName 'SourceFilter' -Mode $Mode
        Write-Debug -Message ('$SourceFilterString = ''{0}''' -f $SourceFilterString)
        Write-Debug -Message ('$DestinationFilterString = Get-HVFilterStringCompatible -WorkloadPair $WorkloadPair -PathPropertyName ''{0}'' -FilterPropertyName ''{1}'' -Mode ''{2}''' -f $DestinationPathPropertyName, $DestinationFilterPropertyName, $Mode)
        $DestinationFilterString = Get-HVFilterStringCompatible -WorkloadPair $WorkloadPair -PathPropertyName $DestinationPathPropertyName -FilterPropertyName $DestinationFilterPropertyName -Mode $Mode
        Write-Debug -Message ('$DestinationFilterString = ''{0}''' -f $DestinationFilterString)

        Write-Debug -Message ('@{{Source = ''{0}'', Destination = ''{1}''}}' -f $SourceFilterString, $DestinationFilterString)
        @{
            Source      = $SourceFilterString
            Destination = $DestinationFilterString
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