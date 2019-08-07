function Invoke-ErrorProcessing {
    #Requires -Version 3.0
    #Requires -Modules SimpleTextLogger

    Param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$LogMutexName = $ModuleWideErrorLogMutexName
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ErrorRecord: {0}' -f $ErrorRecord)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)

        $StringBuilder = New-Object -TypeName 'System.Text.StringBuilder'
        [void]$StringBuilder.AppendLine('Exception.Message: {0}' -f $ErrorRecord.Exception.Message)
        [void]$StringBuilder.AppendLine('InvocationInfo.PositionMessage: {0}' -f $ErrorRecord.InvocationInfo.PositionMessage)
        [void]$StringBuilder.AppendLine('ScriptStackTrace: {0}' -f $ErrorRecord.ScriptStackTrace)
        [void]$StringBuilder.AppendLine('Exception.ScriptStackTrace: {0}' -f $ErrorRecord.Exception.ScriptStackTrace)
        [void]$StringBuilder.AppendLine('TargetObject: {0}' -f $ErrorRecord.TargetObject)
        [void]$StringBuilder.AppendLine('FullyQualifiedErrorId: {0}' -f $ErrorRecord.FullyQualifiedErrorId)
        [void]$StringBuilder.AppendLine('CategoryInfo.Category: {0}' -f $ErrorRecord.CategoryInfo.Category)
        [void]$StringBuilder.AppendLine('CategoryInfo.Activity: {0}' -f $ErrorRecord.CategoryInfo.Activity)
        [void]$StringBuilder.AppendLine('CategoryInfo.Reason: {0}' -f $ErrorRecord.CategoryInfo.Reason)
        [void]$StringBuilder.AppendLine('CategoryInfo.TargetName: {0}' -f $ErrorRecord.CategoryInfo.TargetName)
        [void]$StringBuilder.AppendLine('CategoryInfo.TargetType: {0}' -f $ErrorRecord.CategoryInfo.TargetType)
        $ErrorMessage = $StringBuilder.ToString()

        Write-Debug -Message ('Write-SimpleTextLog -Path ''{0}'' -Message ''{1}'' -MutexName ''{2}''' -f $Path, $ErrorMessage, $LogMutexName)
        Write-SimpleTextLog -Path $Path -Message $ErrorMessage -MutexName $LogMutexName

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