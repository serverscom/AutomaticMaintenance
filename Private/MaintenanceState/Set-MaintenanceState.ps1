function Set-MaintenanceState {
    #Requires -Version 3.0
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [string]$Path = $ModuleWideMaintenanceLogFilePath,
        [string]$MutexName = $ModuleWideMaintenanceLogMutexName,
        [string]$Delimiter = $ModuleWideMaintenanceLogFileDelimiter
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)
    
    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$MutexName = ''{0}''' -f $MutexName)
        Write-Debug -Message ('$Delimiter = ''{0}''' -f $Delimiter)

        Write-Debug -Message '$GotMutex = $false'
        $GotMutex = $false
        Write-Debug -Message ('$GotMutex: ''{0}''' -f [string]$GotMutex)
        Write-Debug -Message ('$Mutex = New-Object -TypeName ''System.Threading.Mutex'' -ArgumentList ($true, ''{0}'', [ref]$GotMutex)' -f $MutexName)
        $Mutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList ($true, $MutexName, [ref]$GotMutex)
        Write-Debug -Message ('$Mutex: ''{0}''' -f $Mutex)
        Write-Debug -Message 'if (-not $GotMutex)'
        if (-not $GotMutex) {
            Write-Debug -Message '$null = $Mutex.WaitOne()'
            $null = $Mutex.WaitOne()
        }

        Write-Debug -Message '$CurrentMoment = Get-Date'
        $CurrentMoment = Get-Date
        Write-Debug -Message ('$CurrentMoment: ''{0}''' -f $CurrentMoment)
        Write-Debug -Message ('$Value = ''{{0}}{{1}}{{2}}{{1}}{{3}}'' -f {0}, {1}, {2}, {1}, {3}' -f $ComputerName, $Delimiter, $CurrentMoment.Ticks, $CurrentMoment)
        $Value = '{0}{1}{2}{1}{3}' -f $ComputerName, $Delimiter, $CurrentMoment.Ticks, $CurrentMoment
        Write-Debug -Message ('$Value = ''{0}''' -f $Value)

        Write-Debug -Message ('$null = Add-Content -Path ''{0}'' -Value ''{1}''' -f $Path, $Value)
        $null = Add-Content -Path $Path -Value $Value

        Write-Debug -Message '$Mutex.ReleaseMutex()'
        $Mutex.ReleaseMutex()
        Write-Debug -Message '$Mutex.Close()'
        $Mutex.Close()

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