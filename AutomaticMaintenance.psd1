@{
    RootModule        = 'AutomaticMaintenance.psm1'
    ModuleVersion     = '2.5.1'
    GUID              = '8e34abf8-40ba-4c68-8bf8-f235cd001d82'
    Author            = 'Kirill Nikolaev'
    CompanyName       = 'Fozzy Inc.'
    Copyright         = '(c) 2018 Fozzy Inc. All rights reserved.'
    PowerShellVersion = '3.0'
    RequiredModules   = @(
        'PendingReboot'
        'ResourceLocker'
        'SimpleTextLogger'
        'SplitOutput'
    )
    FunctionsToExport = @(
        'Get-ComputerMaintenanceConfiguration'
        'Invoke-ComputerMaintenance'
        'Invoke-InfrastructureMaintenance'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()
}