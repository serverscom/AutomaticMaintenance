# Configuration

The module's configuration consists of two files located in the module's folder: `AutomaticMaintenance-Hosts.json` and `AutomaticMaintenance-Templates.json`

## AutomaticMaintenance-Hosts.json

The main file where you should put all hosts which you want to maintain.

Please take a look at [AutomaticMaintenance-Hosts-Example.json](../AutomaticMaintenance-Hosts-Example.json) for examples on how to build this file.

## AutomaticMaintenance-Templates.json

This file allows you to build your configuration more efficiently by introducing a concept of templates
You don't HAVE to use templates: if you don't like them, just describe each host separately in a hosts configuration file.

Please take a look at [AutomaticMaintenance-Templates-Example.json](../AutomaticMaintenance-Templates-Example.json) for examples on how to build this file.

Each template must have at least two attributes:

* Name - The name of a template. Should be unique.
* Properties - An array of properties to apply to hosts, which use this template.

### Template including

You can include templates into each other. Use an attribute `Include` for that.
The `Include` attribute defines a collection of objects. Each of those objects must have two following attributes:

* Name - The name of a template from which the current template should inherit host properties.
* Priority - Used to resolve conflicts if you include several templates into one.

## Attributes

* Name - The name of a host where you want to install updates automatically. Should be unique.
* Type - A type of a host. Currently, the acceptable values are `HV-SCVMM`, `HV-Vanilla`, `Generic`.
* UpdateInstallFilter - A filter which is used to filter out unneeded updates, like preview versions etc.
* Disabled - Settings this attribute to `True` allows you to temporary disable processing of this particular host. Useful when you need to perform some manual maintenance.

The following set of attributes describes plug-ins:

* PreClearCommands
* PostClearCommands
* PreRestoreCommands
* PostRestoreCommands
* TestCommands
* FinallyCommands

Each attribute is usually a name of a PowerShell script, located in the `$ModuleWideScriptBlocksFolderPath` folder in the module's folder. See more about these commands [here](Plug-ins.md)

### Workload-specific attributes

#### HV-SCVMM

* VMMServerName - A name of a VMM server which manages the current host.
* Workload - Defines a container with workload objects which describe how to migrate virtual machines before host maintenance.

Workload objects have the following attributes:

* Path - Path where VM's configuration is located.
* DestinationName - Destination host's name where to move virtual machines.
* DestinationPath - Local path on the destination host.
* Filter - Defines a filter which will be used to pick VMs from the source host. For example, if you wish for some VMs not to mirate, but stay at the source host during maintenance, you can filter them out here.

#### HV-Vanilla

Generally, the same as `HV-SCVMM`, just without the `VMMServerName` attribute.

* PutInASubfolder - When set to `true`, places vanilla Hyper-V virtual machines in subfolders, named as VMs themselves, therefore mimicking SCVMM behavior. Can be set on both the host and workload levels. When defined on the workload level, rewrites the value defined on the host level. If the attribute is not defined in host configuration, the default value (`$ModuleWideHVVanillaPutInASubfolder`) is used.

## Configuration testing

The module exposes the **Get-ComputerMaintenanceConfiguration** function to retrieve a resulting configuration for a host. This function is used by the module itself to build host's configuration. Use it to test your configuration files before deploying them to production.

To review the resulting configuration from the `AutomaticMaintenance-Hosts-Example.json` and `AutomaticMaintenance-Templates-Example.json` files, remove example suffixes from their names and load the module into a current PowerShell session. Then run **Get-ComputerMaintenanceConfiguration**, specifying different computer names. Here's what you should get (the output here is sorted to improve readability):

### SRV01

    Name                : SRV01
    Template            : Example-Template
    PreClearCommands    : Example-PreClear.ps1
    PostClearCommands   : Example-PostClear.ps1
    TestCommands        : Example-Test.ps1
    PreRestoreCommands  : Example-PreRestore.ps1
    PostRestoreCommands : Example-PostRestore.ps1
    FinallyCommands     : Example-Finally.ps1
    UpdateInstallFilter : $_.Title -notlike '*Preview*' -and $_.Title -notlike '*Silverlight*' -and $_.Title -notlike
                          '*Security Only*'

This is a basic example: a host has only one template (`Example-Template`).

### SRV02

    Name                : SRV02
    Template            : Example-Template
    PreClearCommands    : Example-PreClear.ps1
    PostClearCommands   : Example-PostClear.ps1
    TestCommands        : Example-Test.ps1
    PreRestoreCommands  : Example-PreRestore.ps1
    PostRestoreCommands : Example-PostRestore.ps1
    FinallyCommands     : Example-Finally.ps1
    UpdateInstallFilter : $_.Title -notlike '*Preview*' -and $_.Title -notlike '*Silverlight*' -and $_.Title -notlike
                          '*Security Only*'
    MyCustomAttribute   : CustomValue2

SRV02 also uses Example-Template, but on the host level, there's a new attribute defined: `MyCustomAttribute`. The attribute neatly merged with the resulting configuration.

### SRV03

    Name                : SRV03
    Template            : Example-Template2
    Type                : HV-SCVMM
    PreClearCommands    : Example-PreClear.ps1
    PostClearCommands   : Example-PostClear.ps1
    TestCommands        : Example-Test.ps1
    PreRestoreCommands  : Example-PreRestore.ps1
    PostRestoreCommands : Example-PostRestore.ps1
    FinallyCommands     : Example-Finally.ps1
    UpdateInstallFilter : $_.Title -notlike '*Preview*' -and $_.Title -notlike '*Silverlight*' -and $_.Title -notlike
                          '*Security Only*'
    VMMServerName       : SRVVMM01
    Workload            : {@{Path=C:\VMs; DestinationName=SRV05; DestinationPath=D:\VMs; Filter=$_.Name -notlike
                          '*-DontMove'}, @{Path=E:\VMs; DestinationName=SRV05; DestinationPath=E:\VMs; Filter=$_.Name
                          -notlike '*-DontMove'}}

SRV03 is a stand-alone Hyper-V host, that's why it uses `Example-Template2`, which describes how to maintain Hyper-V hosts in this example infrastructure.
Note, that `Example-Template2` does not have plug-ins defined, but the template itself inherits properties from `Example-Template`, that's why we see all those attributes in the configuration. This also gives us `UpdateInstallFilter`.

### SRV04

    Name                : SRV04
    Template            : Example-Template2
    Type                : HV-SCVMM
    PreClearCommands    : Example-PreClear.ps1
    PostClearCommands   : Example-PostClear.ps1
    TestCommands        : Example-Test.ps1
    PreRestoreCommands  : Example-PreRestore.ps1
    PostRestoreCommands :
    FinallyCommands     : Example-Finally.ps1
    UpdateInstallFilter : $_.Title -notlike '*Preview*' -and $_.Title -notlike '*Silverlight*' -and $_.Title -notlike
                          '*Security Only*'
    VMMServerName       : SRVVMM01
    MyCustomAttribute   : CustomValue1
    Workload            : {@{Path=D:\VMs; DestinationName=SRV05; DestinationPath=E:\VMs; Filter=$_.Name -notlike
                          '*-DontMove'}}

Similar to SRV03, but has `MyCustomAttribute` defined at the host level. Also note that the `PostRestoreCommands` property is empty because at the host level it is also empty — you can redefine attributes at any level. The `Workload` property is redefined as well.

### SRV05

    Name              : SRV05
    Type              : HV-SCVMM
    VMMServerName     : SRVVMM01
    MyCustomAttribute : CustomValue1
    Workload          : {@{Path=D:\VMs; DestinationName=SRV03; DestinationPath=C:\VMs; Filter=$_.Name -notlike
                        '*-DontMove'}, @{Path=E:\VMs; DestinationName=SRV03; DestinationPath=E:\VMs; Filter=$_.Name
                        -notlike '*-DontMove'}}

This host does not use any templates: all its attributes are defined at the host level — that's why it's configuration lacks plug-ins etc.
