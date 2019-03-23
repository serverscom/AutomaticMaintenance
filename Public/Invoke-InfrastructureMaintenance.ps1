function Invoke-InfrastructureMaintenance {
    #Requires -Version 3.0
    #Requires -Modules SplitOutput, SimpleTextLogger

    [CmdletBinding()]
    Param (
        [string]$LogErrorFilePath = $ModuleWideLogErrorFilePath,
        [string]$LogFilePathTemplate = $ModuleWideLogFilePathTemplate,
        [string]$LogMutexName = $ModuleWideTextLogMutexName,
        [switch]$DebugLog = $ModuleWideDebugLog
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$LogErrorFilePath = ''{0}''' -f $LogErrorFilePath)
        Write-Debug -Message ('$LogFilePathTemplate = ''{0}''' -f $LogFilePathTemplate)

        Write-Debug -Message ('$ModuleWideFailOnPreviousFailure : ''{0}''' -f $ModuleWideFailOnPreviousFailure)
        Write-Debug -Message 'if ($ModuleWideFailOnPreviousFailure)'
        if ($ModuleWideFailOnPreviousFailure) {
            Write-Debug -Message ('$LogErrorFileExistence = Test-Path -Path ''{0}''' -f $LogErrorFilePath)
            $LogErrorFileExistence = Test-Path -Path $LogErrorFilePath
            Write-Debug -Message ('$LogErrorFileExistence: {0}' -f $LogErrorFileExistence)
            Write-Debug -Message 'if ($LogErrorFileExistence)'
            if ($LogErrorFileExistence) {
                Write-Debug -Message ('$LogErrorFileContent = Get-Content -Path ''{0}''' -f $LogErrorFilePath)
                $LogErrorFileContent = Get-Content -Path $LogErrorFilePath
                Write-Debug -Message ('$LogErrorFileContent: ''{0}''' -f [string]$LogErrorFileContent)
                Write-Debug -Message 'if ($LogErrorFileContent)'
                if ($LogErrorFileContent) {
                    $Message = ('Error log file {0} is not empty. To ignore this, set the module configuration variable $ModuleWideFailOnPreviousFailure to $false.' -f $LogErrorFilePath)
                    $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ApplicationException' -ArgumentList $Message), 'FileIsNotEmpty', [System.Management.Automation.ErrorCategory]::InvalidData, $null)))
                }
            }
        }
        else {
            try {
                Write-Debug -Message ('$null = Clear-Content -Path ''{0}''' -f $LogErrorFilePath)
                $null = Clear-Content -Path $LogErrorFilePath
            }
            catch {
                Write-Debug -Message 'if ($_.Exception -isnot [System.Management.Automation.ItemNotFoundException])'
                if ($_.Exception -isnot [System.Management.Automation.ItemNotFoundException]) {
                    Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }

        Write-Debug -Message '$List = Get-ComputerList'
        $List = Get-ComputerList
        Write-Debug -Message ('$List: ''{0}''' -f [string]$List)

        Write-Debug -Message 'if ($List)'
        if ($List) {
            foreach ($ComputerName in $List) {
                Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
                Write-Debug -Message ('$LogFilePath = ''{0}'' -f ''{1}''' -f $LogFilePathTemplate, $ComputerName)
                $LogFilePath = $LogFilePathTemplate -f $ComputerName
                Write-Debug -Message ('$LogFilePath = ''{0}''' -f $LogFilePath)

                Write-Debug -Message ('$LogScriptBlock = [scriptblock]::Create((''Write-SimpleTextLog -Path ''''{{0}}'''' -MutexName ''''{{1}}'''''' -f {0}, {1}))' -f $LogFilePath, $LogMutexName)
                $LogScriptBlock = [scriptblock]::Create(('Write-SimpleTextLog -Path ''{0}'' -MutexName ''{1}''' -f $LogFilePath, $LogMutexName))
                Write-Debug -Message ('$LogScriptBlock = {0}' -f [string]$LogScriptBlock)

                Write-Debug -Message ('$DebugLog: ''{0}''' -f [string]$DebugLog)
                Write-Debug -Message 'if ($DebugLog)'
                if ($DebugLog) {
                    Write-Debug -Message ('$CurrentDebugPreference = ''{0}''' -f $global:DebugPreference)
                    $CurrentDebugPreference = $global:DebugPreference
                    Write-Debug -Message '$global:DebugPreference = ''Continue'''
                    $global:DebugPreference = 'Continue'
                    Write-Debug -Message ('Invoke-ComputerMaintenance -ComputerName ''{0}'' 5>&1 | Split-Output -ScriptBlock {{{1}}} -Mode Debug' -f $ComputerName, $LogScriptBlock)
                    Invoke-ComputerMaintenance -ComputerName $ComputerName 5>&1 | Split-Output -ScriptBlock $LogScriptBlock -Mode Debug
                }
                else {
                    Write-Debug -Message '$CurrentDebugPreference = $null'
                    $CurrentDebugPreference = $null
                    Write-Debug -Message ('Invoke-ComputerMaintenance -ComputerName ''{0}''' -f $ComputerName)
                    Invoke-ComputerMaintenance -ComputerName $ComputerName
                }
            }
        }

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('Invoke-ErrorProcessing -ErrorRecord $_ -Path ''{0}''' -f $LogErrorFilePath)
        Invoke-ErrorProcessing -ErrorRecord $_ -Path $LogErrorFilePath

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }
    finally {
        Write-Debug -Message ('ENTER FINALLY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$CurrentDebugPreference = ''{0}''' -f $CurrentDebugPreference)
        Write-Debug -Message 'if ($CurrentDebugPreference)'
        if ($CurrentDebugPreference) {
            Write-Debug -Message ('$global:DebugPreference = ''{0}''' -f $CurrentDebugPreference)
            $global:DebugPreference = $CurrentDebugPreference
        }

        Write-Debug -Message ('EXIT FINALLY {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}