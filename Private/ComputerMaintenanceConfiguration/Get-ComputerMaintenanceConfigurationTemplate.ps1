function Get-ComputerMaintenanceConfigurationTemplate {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$FilePath = $ModuleWideComputerMaintenanceConfigurationTemplatesFilePath
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$Name = ''{0}''' -f $Name)
        Write-Debug -Message ('$FilePath = ''{0}''' -f $FilePath)

        Write-Debug -Message ('$FileContent = (Get-Content -Path {0}) -join "`n" | ConvertFrom-Json' -f $FilePath)
        $FileContent = (Get-Content -Path $FilePath) -join "`n" | ConvertFrom-Json # https://github.com/PowerShell/PowerShell/issues/3424
        Write-Debug -Message ('$FileContent: {0}' -f [string]$FileContent.Name)

        Write-Debug -Message ('$FileContent | Where-Object -FilterScript {{$_.Name -eq ''{0}''}}' -f $Name)
        $FileContent | Where-Object -FilterScript {$_.Name -eq $Name}

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