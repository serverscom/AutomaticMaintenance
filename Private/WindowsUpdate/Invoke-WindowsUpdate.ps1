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

        Write-Debug -Message '$Scheduler = New-Object -ComObject ''Schedule.Service'''
        $Scheduler = New-Object -ComObject 'Schedule.Service'
        Write-Debug -Message '$Task = $Scheduler.NewTask(0)'
        $Task = $Scheduler.NewTask(0)

        Write-Debug -Message '$RegistrationInfo = $Task.RegistrationInfo'
        $RegistrationInfo = $Task.RegistrationInfo
        Write-Debug -Message ('$RegistrationInfo.Description = ''{0}''' -f $TaskDescription)
        $RegistrationInfo.Description = $TaskDescription
        Write-Debug -Message '$RegistrationInfo.Author = ''SYSTEM'''
        $RegistrationInfo.Author = 'SYSTEM'

        Write-Debug -Message '$Settings = $Task.Settings'
        $Settings = $Task.Settings
        Write-Debug -Message '$Settings.Enabled = $true'
        $Settings.Enabled = $true
        Write-Debug -Message '$Settings.StartWhenAvailable = $true'
        $Settings.StartWhenAvailable = $true
        Write-Debug -Message '$Settings.Hidden = $false'
        $Settings.Hidden = $false

        Write-Debug -Message '$Action = $Task.Actions.Create(0)'
        $Action = $Task.Actions.Create(0)
        Write-Debug -Message '$Action.Path = ''powershell'''
        $Action.Path = 'powershell'
        Write-Debug -Message ('$Action.Arguments = ''-NoLogo -NoProfile -NonInteractive -EncodedCommand {{0}}'' -f ''{0}''' -f $ConvertedScriptBlock)
        $Action.Arguments = '-NoLogo -NoProfile -NonInteractive -EncodedCommand {0}' -f $ConvertedScriptBlock

        Write-Debug -Message '$Task.Principal.RunLevel = 1'
        $Task.Principal.RunLevel = 1

        Write-Debug -Message ('$Task.XmlText: {0}' -f [string]$Task.XmlText)

        Write-Debug -Message ('$Scheduler.Connect(''{0}'')' -f $ComputerName)
        $Scheduler.Connect($ComputerName)
        Write-Debug -Message '$RootFolder = $Scheduler.GetFolder(''\'')'
        $RootFolder = $Scheduler.GetFolder('\')
        Write-Debug -Message ('$RootFolder: ''{0}''' -f $RootFolder | Out-String)

        Write-Debug -Message ('$RunningTask = $Scheduler.GetRunningTasks(0) | Where-Object {{$_.Name -eq ''{0}''}}' -f $TaskName)
        $RunningTask = $Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName}
        Write-Debug -Message ('$RunningTask: {0}' -f [string]$RunningTask.Name)
        Write-Debug -Message 'if ($RunningTask)'
        if ($RunningTask) {
            $Message = 'Task {0} is already running (PID: {1}) @ host {2}' -f $TaskName, $RunningTask.EnginePID, $ComputerName
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $Message), 'InvalidOperationException', [System.Management.Automation.ErrorCategory]::ResourceExists, $null)))
        }

        Write-Debug -Message ('$null = $RootFolder.RegisterTaskDefinition(''{0}'', $Task, 6, ''SYSTEM'', $null, 1)' -f $TaskName)
        $null = $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, 'SYSTEM', $null, 1)
        Write-Debug -Message ('$null = $RootFolder.GetTask(''{0}'').Run(0)' -f $TaskName)
        $null = $RootFolder.GetTask($TaskName).Run(0)

        Write-Debug -Message '$InitialDateTime = Get-Date'
        $InitialDateTime = Get-Date
        Write-Debug -Message ('$InitialDateTime: ''{0}''' -f [string]$InitialDateTime)
        do {
            Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
            Start-Sleep -Seconds $Timeout

            Write-Debug -Message ('$RunningTask = $Scheduler.GetRunningTasks(0) | Where-Object {{$_.Name -eq ''{0}''}}' -f $TaskName)
            $RunningTask = $Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName}
            Write-Debug -Message ('$RunningTask: {0}' -f [string]$RunningTask.Name)
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