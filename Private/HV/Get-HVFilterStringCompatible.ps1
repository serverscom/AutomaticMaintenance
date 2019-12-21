function Get-HVFilterStringCompatible {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    Param (
        [Parameter(Mandatory)]
        [PSCustomObject[]]$WorkloadPair,
        [Parameter(Mandatory)]
        [string]$PathPropertyName,
        [Parameter(Mandatory)]
        [string]$FilterPropertyName,
        [string]$Mode
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$WorkloadPair: ''{0}''' -f [string]$WorkloadPair)
        Write-Debug -Message ('$PathPropertyName = ''{0}''' -f $PathPropertyName)
        Write-Debug -Message ('$FilterPropertyName = ''{0}''' -f $FilterPropertyName)

        Write-Debug -Message '$Path = $WorkloadPair.$PathPropertyName'
        $Path = $WorkloadPair.$PathPropertyName
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)

        Write-Debug -Message ('$WorkloadPair.$FilterPropertyName: ''{0}''' -f $WorkloadPair.$FilterPropertyName)
        Write-Debug -Message 'if ($null -eq $WorkloadPair.$FilterPropertyName)'
        if ($null -eq $WorkloadPair.$FilterPropertyName) {
            Write-Debug -Message '$Filter = $WorkloadPair.Filter'
            $Filter = $WorkloadPair.Filter
        }
        else {
            Write-Debug -Message '$Filter = $WorkloadPair.$FilterPropertyName'
            $Filter = $WorkloadPair.$FilterPropertyName
        }
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)

        Write-Debug -Message ('Get-HVFilterString -Path ''{0}'' -Filter ''{1}'' -Mode ''{2}''' -f $Path, $Filter, $Mode)
        Get-HVFilterString -Path $Path -Filter $Filter -Mode $Mode

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