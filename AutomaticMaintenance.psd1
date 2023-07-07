@{
    RootModule        = 'AutomaticMaintenance.psm1'
    ModuleVersion     = '2.10.0'
    GUID              = '8e34abf8-40ba-4c68-8bf8-f235cd001d82'
    Author            = 'Kirill Nikolaev'
    CompanyName       = 'Fozzy Inc.'
    Copyright         = '(c) 2018 Fozzy Inc. All rights reserved.'
    PowerShellVersion = '3.0'
    Description       = 'Helps IT engineers to establish a continuous update process in large intertangled infrastructures.'
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
    PrivateData       = @{
        PSData = @{
            Tags         = @()
            LicenseUri   = 'https://github.com/FozzyHosting/AutomaticMaintenance/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/FozzyHosting/AutomaticMaintenance/'
            ReleaseNotes = ''
        }
    }
}
