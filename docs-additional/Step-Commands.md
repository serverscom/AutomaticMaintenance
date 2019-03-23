# Step Commands (Plug-ins))
Step commands are scripts which can be run at steps executed throughout the maintenance process, as defined below. Usually you would like to create a PowerShell script, put it into the `ScriptBlocks` folder, then insert the name of the script into an appropriate attribute in the main configuration file or in the templates file (or in both, if your config requires so - it's completely up to you).

Step commands are good to tell other systems that a host is about to reboot, but you of course can find them useful in other ways as well.

There are several steps defined (in the order of execute):
* Pre-Clear (PreClearCommands) - this step executes before workload is removed from the host. It's a good step to execute a command which will prevent further workload placing on the host.
* Post-Clear (PostClearCommands) - this step executes right after workload is removed from the host. At this step you can disable monitoring, for example.
* Test (TestCommands) - this step executes after the host is back after reboot. Its purpose is to run commands which ensure that it is safe to move workload back to the host.
* Pre-Restore (PreRestoreCommands) - executes before moving workload back to the host. We recommend to enable monitoring here,if you disabled it at "Post-Clear".
* Post-Restore (PostRestoreCommands) - executes when workload moving back has completed. If you prevented workload placement earlier, you can enable it now.
* Finally (FinallyCommands) - this step always executes at the end of the process. If an error happens, it will execute after error processing.

## Requirements
Executable files (usually PowerShell scripts), specified in those attributes must accept two following parameters:
* ComputerName - A string, containing a name of a computer which is in progress right now. Mandatory.
* Variables - A collection of `System.Management.Automation.PSVariable` objects. Might be empty, but unlikely.

The commands should not return anything but variable objects (see below) through the standard output stream.

## Passing variables between step commands
The `Variables` parameter contains all variables from the scope of the **Invoke-ComputerMaintenance** function. You might want to use some of them in your step scripts or even add new ones.
To add a variable into **Invoke-ComputerMaintenance**'s scope, execute `Get-Variable -Name $VariableName` command (or a similar one) in your step script. Step scripts executed at later steps will receive that variable along the others through their respective `Variables` parameters.