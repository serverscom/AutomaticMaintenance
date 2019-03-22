function Get-ComputerMaintenanceConfiguration {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'ByComputerName', Mandatory)]
        [string]$ComputerName,
        [Parameter(ParameterSetName = 'ByComputerName')]
        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$FilePath = $ModuleWideComputerMaintenanceConfigurationFilePath,
        [Parameter(ParameterSetName = 'ByFilter')]
        [scriptblock]$FilterScript,
        [switch]$NoRecurse
    )

    $ErrorActionPreference = 'Stop'
    
    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$PsCmdlet.ParameterSetName: ''{0}''' -f $PsCmdlet.ParameterSetName)
        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$FilePath = ''{0}''' -f $FilePath)
        Write-Debug -Message ('$FilterScript = {0}' -f $FilterScript)
        Write-Debug -Message ('$NoRecurse: ''{0}''' -f [string]$NoRecurse)

        Write-Debug -Message ('$FileContent = (Get-Content -Path {0}) -join "`n" | ConvertFrom-Json' -f $FilePath)
        $FileContent = (Get-Content -Path $FilePath) -join "`n" | ConvertFrom-Json # https://github.com/PowerShell/PowerShell/issues/3424
        Write-Debug -Message ('$FileContent: {0}' -f [string]$FileContent.Name)
        Write-Debug -Message '$GroupNames = $FileContent.Name | Group-Object'  
        $GroupNames = $FileContent.Name | Group-Object 
        Write-Debug -Message ('$GroupNames: ''{0}''' -f [string]$GroupNames.Name)
        Write-Debug '$UniqueNamesTest = $GroupNames | Where-Object -FilterScript {$_.Count -gt 1}'
        $UniqueNamesTest = $GroupNames | Where-Object -FilterScript {$_.Count -gt 1} 
        Write-Debug -Message ('$UniqueNamesTest: ''{0}''' -f [string]$UniqueNamesTest.Name )

        Write-Debug -Message 'if ($UniqueNamesTest)'
        if ($UniqueNamesTest) {
            $Message = 'The hosts config file contains duplicated host names: ''{0}''' -f [string]$UniqueNamesTest.Name 
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ApplicationException' -ArgumentList $Message), 'ApplicationException', [System.Management.Automation.ErrorCategory]::InvalidData, $null)))
        }

        Write-Debug -Message 'if ($ComputerName)'
        if ($ComputerName) {
            Write-Debug -Message ('[scriptblock]$FilterScript = {{$_.Name -eq ''{0}''}}' -f $ComputerName)
            [scriptblock]$FilterScript = {$_.Name -eq $ComputerName}
        }
        Write-Debug -Message ('$FilterScript = {0}' -f $FilterScript)

        Write-Debug -Message 'if ($FilterScript)'
        if ($FilterScript) {
            Write-Debug -Message ('$Configuration = $FileContent | Where-Object -FilterScript {0}' -f $FilterScript)
            $Configuration = $FileContent | Where-Object -FilterScript $FilterScript
        }
        else {
            Write-Debug -Message '$Configuration = $FileContent'
            $Configuration = $FileContent
        }
        Write-Debug -Message ('$Configuration: ''{0}''' -f [string]$Configuration)

        Write-Debug -Message 'if ($NoRecurse)'
        if ($NoRecurse) {
            Write-Debug -Message '$Configuration'
            $Configuration
        }
        else {
            Write-Debug -Message 'Resolve-ComputerMaintenanceConfiguration -Configuration $Configuration'
            Resolve-ComputerMaintenanceConfiguration -Configuration $Configuration
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