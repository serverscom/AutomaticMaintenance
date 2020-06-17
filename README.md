# AutomaticMaintenance
The purpose of the module is to orchestrate Windows update installation and related tasks on a bunch of network hosts.
The module implements the following workflow:
1. Checks if maintenance is needed for a computer.
2. Removes all workload from that host.
3. Performs maintenance tasks (updates installation).
4. Reboots the host, if needed.
5. Tests, if the host works correctly after the reboot.
6. Moves the workload back.
7. Proceeds to the next host.

The process is single-treaded, all hosts are processed one by one.

The main function you need from this module is [**Invoke-InfrastructureMaintenance**](docs/Invoke-InfrastructureMaintenance.md) — this function is designed to be put it into Task Scheduler on a host whist has network access to all hosts specified in the main configuration file (see below). The task should run under an account which is a local administrator on all these hosts.

Under the hood, **Invoke-InfrastructureMaintenance** uses another function to actually perform maintenance on each host — [**Invoke-ComputerMaintenance**](docs/Invoke-ComputerMaintenance.md). If you want to use an external orchestration/configuration management system (Ansible, Puppet etc.), configure it to execute **Invoke-ComputerMaintenance**, not **Invoke-InfrastructureMaintenance**.

## Update detection and installation
**Invoke-ComputerMaintenance** uses the standard Windows Update API to detect and install updates. That means that to make updates available for a host, you have to make them available at WSUS or use direct connection to Microsoft Update. But you can exclude some updates from installation/detection:
* Use the `UpdateInstallFilter` configuration attribute (or the `$ModuleWideInstallUpdateDefaultFilterString` module configuration variable) to specify filter for updates installation.
* Use the `UpdateCheckFilter` configuration attribute (or the `$ModuleWideCheckUpdateDefaultFilterString` module configuration variable) to specify filter for updates detection.

If the detection process (**Test-WindowsUpdateNeeded**) finds available updates, the host maintenance process will start. Otherwise, **Invoke-ComputerMaintenance** skips to the next host.

There's no built-in way to install a specific update, but it is possible by leveraging step commands (see below), since you can execute custom commands and scripts there.

## Host types
While the module can potentially support machines with various type of workloads, currently there are only two supported types:
* **HV-SCVMM** - for stand-alone hypervisors (yes, *not* fail-over clusters) managed by SCVMM. Workload movement is provided by the [SCVMReliableMigration](https://github.com/FozzyHosting/SCVMReliableMigration) module.
* **Generic** - hosts of this type do not need any specific actions to move workload and the only purpose to perform maintenance on them, using this module, is to prevent a situation when all hosts supporting a service are down at the same time.

Note, that failover cluster support was never the goal while developing the module. While it could be incorporated as a workload type, failover clusters have their own [maintenance orchestration mechanism](https://docs.microsoft.com/en-us/windows-server/failover-clustering/cluster-aware-updating) and can already be serviced in a fully-automated manner.

The module does not specify type-specific modules as requirements, since you might use it for one type of hosts but not for another. Just bear in mind that you still will need those modules to service particular types of hosts.

## Configuration
The module's main configuration file `AutomaticMaintenance-Hosts.json` contains a list of hosts to process. Read more about the configuration [here](docs-additional/Configuration.md).

## Plug-ins (Step commands)
You can run your custom scripts in between of the maintenance steps specified above. You can even pass variables from one of them to another!
Read more about this awesome concept [here](docs-additional/Step-Commands.md).

## Error processing
All the module's functions but **Invoke-InfrastructureMaintenance** process errors by raising a terminating exception. **Invoke-InfrastructureMaintenance** writes an error message and a stack trace into an error log (see below).

By default, if you run **Invoke-InfrastructureMaintenance** and there is an error log from a previous crash, it will stop. You can configure this behaviour with the `$ModuleWideFailOnPreviousFailure` variable.

## Exported functions
* [Get-ComputerMaintenanceConfiguration](docs/Get-ComputerMaintenanceConfiguration.md)
* [Invoke-ComputerMaintenance](docs/Invoke-ComputerMaintenance.md)
* [Invoke-InfrastructureMaintenance](docs/Invoke-InfrastructureMaintenance.md)

## Log files
There are three types log files:
* An error log file (`AutomaticMaintenance-Error.log`).
* Debug log files: Invoke-ComputerMaintenance function will write all executed commands into separate log-files - one per host (`AutomaticMaintenance-<Host Name>-<Current Date>.log`).
* Maintenance track log file. Its main purpose is to let you keep a track of when which host has been maintained (`AutomaticMaintenance-HostMaintenanceLog.log`).

## Dependencies
The module depends on the following modules:
* [PendingReboot](https://github.com/bcwilhite/PendingReboot) - To detect if a reboot is required after updates installation.
* [ResourceLocker](https://github.com/FozzyHosting/ResourceLocker) - To let other automation know that the host is about to reboot. Also it is used to prevent reboots while the host is used by some other functions/scripts.
* [SimpleTextLogger](https://github.com/FozzyHosting/SimpleTextLogger) - To log actions and errors.
* [SplitOutput](https://github.com/exchange12rocks/SplitOutput) - To log debug output.

### HV-SCVMM
For the `HV-SCVMM` type, the module uses [SCVMReliableMigration](https://github.com/FozzyHosting/SCVMReliableMigration) to migrate workload between hosts.

## Module-wide variables
There are several variables defined in the .psm1-file, which are used by the module's functions as default values for parameters:

* `[string]$LogFileFolderPath` - Specifies the path to a folder where debug and error log files will be placed.
* `[string]$LogFileNameTemplate` - Defines a template used for debug log file names.
* `[string]$ModuleWideLogFilePathTemplate` - Default value for **Invoke-InfrastructureMaintenance**'s `-LogFilePathTemplate` parameter.
* `[string]$ModuleWideLogErrorFilePath` - Default value for **Invoke-InfrastructureMaintenance**'s `-LogErrorFilePath` parameter.

* `[string]$ModuleWideComputerMaintenanceConfigurationFilePath` - Default value for **Get-ComputerMaintenanceConfiguration**'s `-FilePath` parameter.
* `[string]$ModuleWideComputerMaintenanceConfigurationTemplatesFilePath` - A path to the templates file.
* `[string]$ModuleWideScriptBlocksFolderPath` - A path to the folder where files for step commands are located.

* `[bool]$ModuleWideDebugLog` - Default value for **Invoke-InfrastructureMaintenance**'s `-DebugLog` parameter.
* `[string]$ModuleWideTextLogMutexName` - Default value for **Invoke-InfrastructureMaintenance**'s `-LogMutexName` parameter.
* `[string]$ModuleWideErrorLogMutexName` - The name of a mutex used to access an error log file object.
* `[bool]$ModuleWideFailOnPreviousFailure` - Default value for **Invoke-InfrastructureMaintenance**'s `-FailOnPreviousFailure` parameter.
* `[bool]$ModuleWideErrorXMLDump` - Enables an additional error dump in the XML format: the error object exports through the `Export-CliXml` cmdlet.
* `[int]$ModuleWideErrorXMLDumpDepth` - When `$ModuleWideErrorXMLDump` is set to `$true`, use this variable to tune the object's depth.

* `[string]$ModuleWideMaintenanceLogFilePath` - A path to the maintenance track log file.
* `[string]$ModuleWideMaintenanceLogMutexName` - The name of a mutex used to access the maintenance track log file object.
* `[string]$ModuleWideMaintenanceLogFileDelimiter` - A delimiter used to split columns in the maintenance track log file.

* `[int]$ModuleWidePreventiveLockTimeout` - Default value for **Invoke-ComputerMaintenance**'s `-PreventiveLockTimeout` parameter.
* `[System.TimeSpan]$ModuleWidePreventiveLockThreshold` - Default value for **Invoke-ComputerMaintenance**'s `-PreventiveLockThreshold` parameter.
* `[bool]$ModuleWideSkipPreventivelyLocked` - Default value for **Invoke-ComputerMaintenance**'s `-SkipPreventivelyLocked` parameter.
* `[bool]$ModuleWideSkipNotLockable` - Default value for **Invoke-ComputerMaintenance**'s `-SkipNotLockable` parameter.

* `[int]$ModuleWideInstallUpdateTimeout` - Specifies, in seconds, how often the module will request the state of an install update scheduled task. Effectively, this parameter defines the minimum time which the installation will take.
* `[System.TimeSpan]$ModuleWideInstallUpdateThreshold` - Specifies how long the module will wait for the update installation to finish.
* `[string]$ModuleWideInstallUpdateTaskName` - The name of a Task Scheduler task which executes code to find and install updates.
* `[string]$ModuleWideInstallUpdateTaskDescription` - The description of a Task Scheduler task which executes code to find and install updates.
* `[string]$ModuleWideCheckUpdateDefaultFilterString` - A filter which is used to detect new updates. Used if an `UpdateCheckFilter` attribute is not defined in host's configuration.
* `[string]$ModuleWideInstallUpdateDefaultFilterString` - A filter which is used during updates installation. Used if an `UpdateInstallFilter` attribute is not defined in host's configuration.
* `[string]$ModuleWideUpdateSearchCriteria` - Criteria for the IUpdateSearcher::Search method (https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/nf-wuapi-iupdatesearcher-search)

## Loading variables from an external source
All module-wide variables can be redefined with a `Config.ps1` file, located in the module's root folder. Just put variable definitions in there as you would do with any other PowerShell script. You may find an example of a config file `Config-Example.ps1` in the module's root folder.

## Limitations
* Currently, all hosts should be available by all of the following protocols: RPC, WinRM, SMB.
* %SystemRoot%\system32\dllhost.exe should be able to accept network connections to RPC Dynamic ports not only as a service, but as an ordinary process as well.
* User, which runs Invoke-ComputerMaintenance or Invoke-InfrastructureMaintenance, should be a local administrator at the hosts.
* The module has a tight dependency on the ResourceLocker module - currently it's improssible to use it w/o that module.
* The module is single-treaded, no parallelization support yet.

## What's with all the Write-Debug calls?
https://exchange12rocks.org/2018/11/20/how-do-you-debug-your-powershell-code/

## Related links
https://github.com/Sorrowfulgod/UpdateService