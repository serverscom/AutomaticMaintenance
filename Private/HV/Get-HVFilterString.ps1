function Get-HVFilterString {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    Param (
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Filter,
        [ValidateSet('HV-SCVMM', 'HV-Vanilla')]
        [string]$Mode = 'HV-SCVMM'
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)
        Write-Debug -Message ('$Mode = ''{0}''' -f $Mode)

        Write-Debug -Message '$VMLocationPropertyName = switch ($Mode)'
        $VMLocationPropertyName = switch ($Mode) {
            'HV-SCVMM' {
                Write-Debug -Message 'Location'
                'Location'
            }
            'HV-Vanilla' {
                Write-Debug -Message 'Path'
                'Path'
            }
            Default {
                Write-Debug -Message 'Location'
                'Location'
            }
        }
        Write-Debug -Message ('$VMLocationPropertyName = ''{0}''' -f $VMLocationPropertyName)

        Write-Debug -Message ('$FilterPath = [System.IO.Path]::Combine(''{0}'', ''*'')' -f $Path)
        $FilterPath = [System.IO.Path]::Combine($Path, '*') # Join-Path cannot combine paths on a drive which does not exist on the machine
        Write-Debug -Message ('$FilterPath = ''{0}''' -f $FilterPath)
        Write-Debug -Message ('$FilterString = ''$_.{{0}} -like ''''{{1}}'''''' -f ''{0}'', ''{1}''' -f $VMLocationPropertyName, $FilterPath)
        $FilterString = ('$_.{0} -like ''{1}''' -f $VMLocationPropertyName, $FilterPath)
        Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)

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