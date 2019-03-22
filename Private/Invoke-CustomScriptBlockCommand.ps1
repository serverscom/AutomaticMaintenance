function Invoke-CustomScriptBlockCommand {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [System.Management.Automation.PSVariable[]]$Variables,
        [string]$BaseFolderPath = $ModuleWideScriptBlocksFolderPath,
        [Parameter(Mandatory)]
        [ValidateSet('PreClear', 'PostClear', 'PostUpdate', 'PreRestore', 'PostRestore', 'Finally', 'Test')]
        [string]$Mode
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Variables: ''{0}''' -f [string]$Variables)
        Write-Debug -Message ('$BaseFolderPath = ''{0}''' -f $BaseFolderPath)
        Write-Debug -Message ('$Mode = ''{0}''' -f $Mode)

        Write-Debug -Message ('$ComputerConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName ''{0}''' -f $ComputerName)
        $ComputerConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
        Write-Debug -Message ('$ComputerConfiguration: ''{0}''' -f [string]$ComputerConfiguration)

        Write-Debug -Message ('$FileName = $ComputerConfiguration.(''{{0}}Commands'' -f ''{0}'')' -f $Mode)
        $FileName = $ComputerConfiguration.('{0}Commands' -f $Mode)
        Write-Debug -Message ('$FileName = ''{0}''' -f $FileName)

        Write-Debug -Message 'if ($FileName)'
        if ($FileName) {
            Write-Debug -Message ('$FilePath = Join-Path -Path ''{0}'' -ChildPath ''{1}''' -f $BaseFolderPath, $FileName)
            $FilePath = Join-Path -Path $BaseFolderPath -ChildPath $FileName
            Write-Debug -Message ('$FilePath = ''{0}''' -f $FilePath)

            Write-Debug -Message ('&''{0}'' -ComputerName ''{1}'' -Variables $Variables' -f $FilePath, $ComputerName)
            &$FilePath -ComputerName $ComputerName -Variables $Variables
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