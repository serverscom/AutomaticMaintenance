# Plug-ins

Plug-ins allow you to extend the module's functionality by running additional commands at steps, as defined below. Usually you would like to create a PowerShell script, put it into the `$ModuleWideScriptBlocksFolderPath` folder, then insert the name of the script into an appropriate attribute in the main configuration file or in the templates file (or in both, if your config requires so - it's completely up to you).

Plug-ins are good in letting other systems know that a host is about to reboot or it has returned back into service.

There are several plug-in steps defined (in the order of execution):

* Pre-Clear (PreClearCommands) - this step executes before workload is removed from the host. It's a good step to execute a command which will prevent further workload placing on the host.
* Post-Clear (PostClearCommands) - this step executes right after workload is removed from the host. At this step you can disable monitoring, for example.
* Test (TestCommands) - this step executes after the host is back after reboot. Its purpose is to run commands which ensure that it is safe to move workload back to the host.
* Pre-Restore (PreRestoreCommands) - executes before moving workload back to the host. We recommend to enable monitoring here,if you disabled it at "Post-Clear".
* Post-Restore (PostRestoreCommands) - executes when workload moving back has completed. If you prevented workload placement earlier, you can enable it now.
* Finally (FinallyCommands) - this step always executes at the end of the process. If an error happens, it will execute after error processing (The whole function is in a `try` block and `FinallyCommands` run at its `finally` section).

## Requirements

Executable files (usually, PowerShell scripts) specified in those attributes must be in the `$ModuleWideScriptBlocksFolderPath` folder and must accept two following parameters:

* ComputerName - A string, containing a name of a computer which is in progress right now. Mandatory.
* Variables - A collection of `System.Management.Automation.PSVariable` objects. Might be empty, but unlikely.

The commands should not return anything but variable objects (see below) through the standard output stream.

## Passing variables between plug-ins

The `Variables` parameter contains all variables from the scope of the **Invoke-ComputerMaintenance** function. You might want to use some of them in your plug-ins or even add new ones.
To add a variable into **Invoke-ComputerMaintenance**'s scope, execute `Get-Variable -Name $VariableName` command (or a similar one) in your plug-in. Plug-ins executed at later steps will receive that variable along the others through their respective `Variables` parameters.
