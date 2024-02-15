function Invoke-WindowsUpdate {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [System.TimeSpan]$InstallUpdateThreshold = $ModuleWideInstallUpdateThreshold,
        [int]$Timeout = $ModuleWideInstallUpdateTimeout,
        [string]$TaskName = $ModuleWideInstallUpdateTaskName,
        [string]$TaskDescription = $ModuleWideInstallUpdateTaskDescription,
        [scriptblock]$Filter,
        [string]$DefaultFilterString = $ModuleWideInstallUpdateDefaultFilterString,
        [string]$Criteria = $ModuleWideUpdateSearchCriteria
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$InstallUpdateThreshold: ''{0}''' -f [string]$InstallUpdateThreshold)
        Write-Debug -Message ('$Timeout = {0}' -f $Timeout)
        Write-Debug -Message ('$TaskName = ''{0}''' -f $TaskName)
        Write-Debug -Message ('$TaskDescription = ''{0}''' -f $TaskDescription)
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)
        Write-Debug -Message ('$DefaultFilterString = ''{0}''' -f $DefaultFilterString)
        Write-Debug -Message ('$Criteria = ''{0}''' -f $Criteria)

        Write-Debug -Message ('$RemoteCimSession = New-CimSession -ComputerName ''{0}''' -f $ComputerName)
        $RemoteCimSession = New-CimSession -ComputerName $ComputerName
        Write-Debug -Message ('$RemoteCimSession: ''{0}''' -f (Out-String -InputObject $RemoteCimSession))

        if (-not $Filter) {
            Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName {0}' -f $ComputerName)
            $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
            Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f $ComputerMaintenanceConfiguration)
            Write-Debug -Message '$FilterString = $ComputerMaintenanceConfiguration.UpdateInstallFilter'
            $FilterString = $ComputerMaintenanceConfiguration.UpdateInstallFilter
            Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)
            Write-Debug -Message 'if (-not $FilterString)'
            if (-not $FilterString) {
                Write-Debug -Message '$FilterString = $DefaultFilterString'
                $FilterString = $DefaultFilterString
                Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)
            }
            Write-Debug -Message ('$Filter = [scriptblock]::Create(''{0}'')' -f $FilterString)
            $Filter = [scriptblock]::Create($FilterString)
            Write-Debug -Message ('$Filter: ''{0}''' -f $Filter)
        }

        [ScriptBlock]$UpdateScriptBlock = {
            $Searcher = New-Object -ComObject Microsoft.Update.Searcher
            $SearchResult = $Searcher.Search($Criteria).Updates

            $DesiredUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($Item in $SearchResult) {
                $Item = $Item | Where-Object -FilterScript $Filter
                if ($Item) {
                    $null = $Item.AcceptEula()
                    $null = $DesiredUpdates.Add($Item)
                }
            }

            if ($DesiredUpdates.Count -gt 0) {
                $Session = New-Object -ComObject Microsoft.Update.Session
                $Downloader = $Session.CreateUpdateDownloader()
                $Downloader.Updates = $DesiredUpdates
                $null = $Downloader.Download()

                $Installer = New-Object -ComObject Microsoft.Update.Installer
                $Installer.Updates = $DesiredUpdates
                $null = $Installer.Install()
            }
        }

        Write-Debug -Message ('$UpdateScriptBlock: {0}' -f $UpdateScriptBlock)

        Write-Debug -Message '$FilterString = $Filter.ToString()'
        $FilterString = $Filter.ToString()
        Write-Debug -Message ('$FilterString = ''{0}''' -f $FilterString)
        Write-Debug -Message ('$FilterScriptBlockString = ''$Filter = {{{{{{0}}}}}}'' -f ''{0}''' -f $FilterString)
        $FilterScriptBlockString = '$Filter = {{{0}}}' -f $FilterString
        Write-Debug -Message ('$FilterScriptBlockString = ''{0}''' -f $FilterScriptBlockString)

        Write-Debug -Message '$UpdateScriptBlockString = $UpdateScriptBlock.ToString()'
        $UpdateScriptBlockString = $UpdateScriptBlock.ToString()
        Write-Debug -Message ('$UpdateScriptBlockString = ''{0}''' -f $UpdateScriptBlockString)

        Write-Debug -Message ('$SearchScriptBlockString = ''$Criteria = ''''{{0}}'''''' -f ''{0}''' -f $Criteria)
        $SearchScriptBlockString = '$Criteria = ''{0}''' -f $Criteria
        Write-Debug -Message ('$SearchScriptBlockString = ''{0}''' -f $SearchScriptBlockString)

        Write-Debug -Message ('$JoinedScriptBlockString = ''{{0}};{{1}};{{2}}'' -f ''{0}'', ''{1}'', ''{2}''' -f $SearchScriptBlockString, $FilterScriptBlockString, $UpdateScriptBlockString)
        $JoinedScriptBlockString = '{0};{1};{2}' -f $SearchScriptBlockString, $FilterScriptBlockString, $UpdateScriptBlockString
        Write-Debug -Message ('$JoinedScriptBlockString = ''{0}''' -f $JoinedScriptBlockString)

        Write-Debug -Message ('$ConvertedScriptBlock = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(''{0}''))' -f $JoinedScriptBlockString)
        $ConvertedScriptBlock = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($JoinedScriptBlockString))
        Write-Debug -Message ('$ConvertedScriptBlock: ''{0}''' -f $ConvertedScriptBlock)

        Write-Debug -Message '$ExistingSheduledTasks = Get-ScheduledTask -CimSession $RemoteCimSession'
        $ExistingSheduledTasks = Get-ScheduledTask -CimSession $RemoteCimSession
        Write-Debug -Message ('$ExistingSheduledTasks: ''{0}''' -f ($ExistingSheduledTasks.TaskName -join ', '))

        Write-Debug -Message '$ScheduledTaskStateRunning = ''Running'''
        $ScheduledTaskStateRunning = 'Running'

        Write-Debug -Message 'foreach ($ExistingSheduledTask in $ExistingSheduledTasks)'
        foreach ($ExistingSheduledTask in $ExistingSheduledTasks) {
            Write-Debug -Message ('$ExistingSheduledTask: ''{0}''' -f (Out-String -InputObject $ExistingSheduledTask))
            Write-Debug -Message ('if ($ExistingSheduledTask.TaskName -eq ''{0}'')' -f $TaskName)
            if ($ExistingSheduledTask.TaskName -eq $TaskName) {
                Write-Debug -Message '$ScheduledTaskState = $ExistingSheduledTask.State.ToString()'
                $ScheduledTaskState = $ExistingSheduledTask.State.ToString()
                Write-Debug -Message ('$ScheduledTaskState = ''{0}''' -f $ScheduledTaskState)
                Write-Debug -Message 'if ($ScheduledTaskState -eq $ScheduledTaskStateRunning)'
                if ($ScheduledTaskState -eq $ScheduledTaskStateRunning) {
                    $Message = 'Task ''{0}'' is already running on host ''{1}'', task path: ''{2}''' -f $TaskName, $ComputerName, $ExistingSheduledTask.TaskPath
                    $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::ResourceExists, $null)))
                }
                else {
                    Write-Debug -Message 'Unregister-ScheduledTask -InputObject $ExistingSheduledTask -Confirm:$false'
                    Unregister-ScheduledTask -InputObject $ExistingSheduledTask -Confirm:$false
                }
            }
        }

        Write-Debug -Message ('$ScheduledTaskActionArgument = ''-NoLogo -NoProfile -NonInteractive -EncodedCommand {{0}}'' -f {0}' -f $ConvertedScriptBlock)
        $ScheduledTaskActionArgument = '-NoLogo -NoProfile -NonInteractive -EncodedCommand {0}' -f $ConvertedScriptBlock
        Write-Debug -Message ('$ScheduledTaskActionArgument = ''{0}''' -f $ScheduledTaskActionArgument)
        Write-Debug -Message '$RemoteCimsessionParams = @{ CimSession = $RemoteCimSession }'

        $RemoteCimsessionParams = @{
            CimSession = $RemoteCimSession
        }

        Write-Debug -Message ('$RemoteCimsessionParams: ''{0}''' -f (Out-String -InputObject $RemoteCimsessionParams))
        Write-Debug -Message ('$NewTaskActionParams = @{{ Execute = ''powershell''; Argument = ''{0}'' }}' -f $ScheduledTaskActionArgument)

        $NewTaskActionParams = @{
            Execute  = 'powershell'
            Argument = $ScheduledTaskActionArgument
        }

        Write-Debug -Message ('$NewTaskActionParams: ''{0}''' -f (Out-String -InputObject $NewTaskActionParams))
        Write-Debug -Message '$NewTaskPrincipalParams = @{ UserId = ''NT AUTHORITY\SYSTEM''; RunLevel = ''Highest''; Id = ''Author''; LogonType = ''ServiceAccount'' }'

        $NewTaskPrincipalParams = @{
            UserId    = 'NT AUTHORITY\SYSTEM'
            RunLevel  = 'Highest'
            Id        = 'Author'
            LogonType = 'ServiceAccount'
        }

        Write-Debug -Message ('$NewTaskPrincipalParams: ''{0}''' -f (Out-String -InputObject $NewTaskPrincipalParams))
        Write-Debug -Message '$NewTaskSettingSetParams: @{ Compatibility = ''Win8''; MultipleInstances = ''IgnoreNew''; DontStopIfGoingOnBatteries = $true; StartWhenAvailable = $true }'

        $NewTaskSettingSetParams = @{
            Compatibility              = 'Win8'
            MultipleInstances          = 'IgnoreNew'
            DontStopIfGoingOnBatteries = $true
            StartWhenAvailable         = $true
        }

        Write-Debug -Message ('$NewTaskSettingSetParams: ''{0}''' -f (Out-String -InputObject $NewTaskSettingSetParams))
        Write-Debug -Message ('$NewScheduledTaskParameters = @{{ Action = New-ScheduledTaskAction @NewTaskActionParams @RemoteCimsessionParams; Principal = New-ScheduledTaskPrincipal @NewTaskPrincipalParams @RemoteCimsessionParams; Settings = New-ScheduledTaskSettingsSet @NewTaskSettingSetParams @RemoteCimsessionParams; Description = ''{0}'' }}' -f $TaskDescription)

        $NewScheduledTaskParameters = @{

            Action      = New-ScheduledTaskAction @NewTaskActionParams @RemoteCimsessionParams
            Principal   = New-ScheduledTaskPrincipal @NewTaskPrincipalParams @RemoteCimsessionParams
            Settings    = New-ScheduledTaskSettingsSet @NewTaskSettingSetParams @RemoteCimsessionParams
            Description = $TaskDescription
        }

        Write-Debug -Message ('$NewScheduledTaskParameters: ''{0}''' -f (Out-String -InputObject $NewScheduledTaskParameters))

        Write-Debug -Message 'New-ScheduledTask @NewScheduledTaskParameters @RemoteCimsessionParams'
        $ScheduledTask = New-ScheduledTask @NewScheduledTaskParameters @RemoteCimsessionParams
        Write-Debug -Message ('$ScheduledTask: ''{0}''' -f (Out-String -InputObject $ScheduledTask))

        Write-Debug -Message ('$null = Register-ScheduledTask -TaskName ''{0}'' -TaskPath ''\'' -InputObject $ScheduledTask @RemoteCimsessionParams' -f $TaskName)
        $null = Register-ScheduledTask -TaskName $TaskName -TaskPath '\' -InputObject $ScheduledTask @RemoteCimsessionParams

        Write-Debug -Message ('$RegisteredTask = Get-ScheduledTask -TaskName ''{0}'' -CimSession $RemoteCimSession' -f $TaskName)
        $RegisteredTask = Get-ScheduledTask -TaskName $TaskName -CimSession $RemoteCimSession
        Write-Debug -Message ('$RegisteredTask: ''{0}''' -f (Out-String -InputObject $RegisteredTask))

        Write-Debug -Message 'Start-ScheduledTask -InputObject $RegisteredTask'
        Start-ScheduledTask -InputObject $RegisteredTask

        Write-Debug -Message '$InitialDateTime = Get-Date'
        $InitialDateTime = Get-Date
        Write-Debug -Message ('$InitialDateTime: ''{0}''' -f [string]$InitialDateTime)
        Write-Debug -Message 'do while ($RunningTask)'
        do {
            Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
            Start-Sleep -Seconds $Timeout

            Write-Debug -Message ('$RunningTask = Get-ScheduledTask -TaskName ''{0}'' -CimSession $RemoteCimSession | Where-Object -FilterScript {{ $_.State.ToString() -eq ''{1}'' }}' -f $TaskName, $ScheduledTaskStateRunning)
            $RunningTask = Get-ScheduledTask -TaskName $TaskName -CimSession $RemoteCimSession | Where-Object -FilterScript { $_.State.ToString() -eq $ScheduledTaskStateRunning }
            Write-Debug -Message ('$RunningTask: {0}' -f (Out-String -InputObject $RunningTask))
            Write-Debug -Message 'if ($RunningTask)'
            if ($RunningTask) {
                Write-Debug -Message '$CurrentDateTime = Get-Date'
                $CurrentDateTime = Get-Date
                Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                Write-Debug -Message ('$InitialDateTime: ''{0}''' -f [string]$InitialDateTime)
                Write-Debug -Message ('$InstallUpdateThreshold: ''{0}''' -f [string]$InstallUpdateThreshold)
                Write-Debug -Message '$InstallUpdateDateTimeThreshold = $InitialDateTime + $InstallUpdateThreshold'
                $InstallUpdateDateTimeThreshold = $InitialDateTime + $InstallUpdateThreshold
                Write-Debug -Message ('$InstallUpdateDateTimeThreshold: ''{0}''' -f [string]$InstallUpdateDateTimeThreshold)
                Write-Debug -Message 'if ($CurrentDateTime -gt $InstallUpdateDateTimeThreshold)'
                if ($CurrentDateTime -gt $InstallUpdateDateTimeThreshold) {
                    $Message = 'The task {0} @ host {1} has not finished in the allowed time ({2}).' -f $TaskName, $ComputerName, [string]$InstallUpdateThreshold
                    $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.TimeoutException' -ArgumentList $Message), 'TimeoutException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $null)))
                }
            }
        }
        while ($RunningTask)

        Write-Debug -Message 'Unregister-ScheduledTask -InputObject $RegisteredTask -Confirm:$false'
        Unregister-ScheduledTask -InputObject $RegisteredTask -Confirm:$false

        Write-Debug -Message '$RemoteCimSession.Close()'
        $RemoteCimSession.Close()

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