#Requires -Version 3.0

$ModulePath = $PSScriptRoot
$ModuleName = ($MyInvocation.MyCommand.Name).Substring(0, ($MyInvocation.MyCommand.Name).Length - 5)

[string]$LogFileFolderPath = Join-Path -Path $env:SystemDrive -Childpath ('Logs\{0}' -f $ModuleName)
[string]$LogFileNameTemplate = '{0}-{1}-{2}.log' -f $ModuleName, '{0}', (Get-Date -Format 'yyyyMMdd')

[string]$ModuleWideLogFilePathTemplate = Join-Path -Path $LogFileFolderPath -ChildPath $LogFileNameTemplate
[string]$ModuleWideLogErrorFilePath = Join-Path -Path $LogFileFolderPath -ChildPath ('{0}-Error.log' -f $ModuleName)

[string]$ModuleWideComputerMaintenanceConfigurationFilePath = Join-Path -Path $ModulePath -Childpath ('{0}-Hosts.json' -f $ModuleName)
[string]$ModuleWideComputerMaintenanceConfigurationTemplatesFilePath = Join-Path -Path $ModulePath -Childpath ('{0}-Templates.json' -f $ModuleName)
[string]$ModuleWideScriptBlocksFolderPath = Join-Path -Path $ModulePath -ChildPath 'ScriptBlocks'

[bool]$ModuleWideDebugLog = $false
[string]$ModuleWideTextLogMutexName = '{0}Log' -f $ModuleName
[string]$ModuleWideErrorLogMutexName = '{0}ErrorLog' -f $ModuleName
[bool]$ModuleWideFailOnPreviousFailure = $true
[bool]$ModuleWideErrorXMLDump = $true
[int]$ModuleWideErrorXMLDumpDepth = 5

[bool]$ModuleWideEnableMaintenanceLog = $false
[string]$ModuleWideMaintenanceLogFilePath = Join-Path -Path $ModulePath -Childpath ('{0}-HostMaintenanceLog.log' -f $ModuleName)
[string]$ModuleWideMaintenanceLogMutexName = '{0}MaintenanceLogMutex' -f $ModuleName
[string]$ModuleWideMaintenanceLogFileDelimiter = ';'

[int]$ModuleWidePreventiveLockTimeout = 60
[System.TimeSpan]$ModuleWidePreventiveLockThreshold = New-Object -TypeName 'System.TimeSpan' -ArgumentList @(1, 0, 0)
[bool]$ModuleWideSkipPreventivelyLocked = $true
[bool]$ModuleWideSkipNotLockable = $true

[int]$ModuleWideInstallUpdateTimeout = 60
[System.TimeSpan]$ModuleWideInstallUpdateThreshold = New-Object -TypeName 'System.TimeSpan' -ArgumentList @(1, 0, 0)
[string]$ModuleWideInstallUpdateTaskName = 'AMWindowsUpdate'
[string]$ModuleWideInstallUpdateTaskDescription = 'Automatic Maintenance Windows Update Installer Task'
[string]$ModuleWideCheckUpdateDefaultFilterString = '$_.Title -notlike ''Definition Update for Windows Defender Antivirus *''' # Defender updates are released constantly and do not require reboot. If we would not exclude them, there would be constant useless workload movement.
[string]$ModuleWideInstallUpdateDefaultFilterString = '$_ -like ''*'''
[string]$ModuleWideUpdateSearchCriteria = 'IsInstalled=0 and IsHidden=0'

[bool]$ModuleWideHVVanillaPutInASubfolder = $true

foreach ($FunctionType in @('Private', 'Public')) {
    $Path = Join-Path -Path $ModulePath -ChildPath ('{0}\*.ps1' -f $FunctionType)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}

$Path = Join-Path -Path $ModulePath -ChildPath 'Config.ps1'
if (Test-Path -Path $Path -PathType Leaf) {
    . $Path
}