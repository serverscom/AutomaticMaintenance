function Resolve-ComputerMaintenanceConfiguration {
    #Requires -Version 3.0

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Configuration
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$Configuration: {0}' -f [string]$Configuration)
        Write-Debug -Message ('$Configuration.GetType(): {0}' -f $Configuration.GetType())

        foreach ($ConfigurationSet in $Configuration) {
            Write-Debug -Message ('$ConfigurationSet: ''{0}''' -f [string]$ConfigurationSet)
            Write-Debug -Message ('$ConfigurationSet.GetType(): {0}' -f $ConfigurationSet.GetType())

            Write-Debug -Message ('$ConfigurationSet.Template: ''{0}''' -f [string]$ConfigurationSet.Template)
            Write-Debug -Message 'if ($ConfigurationSet.Template)'
            if ($ConfigurationSet.Template) {
                Write-Debug -Message ('$TemplateSet = Resolve-ComputerMaintenanceConfigurationTemplate -Name ''{0}''' -f $ConfigurationSet.Template)
                $TemplateSet = Resolve-ComputerMaintenanceConfigurationTemplate -Name $ConfigurationSet.Template
                Write-Debug -Message ('$TemplateSet: {0}' -f [string]$TemplateSet)
                Write-Debug -Message '$TemplateProperties = $TemplateSet.Properties'
                $TemplateProperties = $TemplateSet.Properties
                Write-Debug -Message ('$TemplateProperties: ''{0}''' -f [string]$TemplateProperties)
                Write-Debug -Message 'if ($TemplateProperties)'
                if ($TemplateProperties) {
                    Write-Debug -Message ('$TemplateProperties: {0}' -f [string]$TemplateProperties)
                    Write-Debug -Message ('$TemplateProperties.GetType(): {0}' -f $TemplateProperties.GetType())
                    Write-Debug -Message '$Result = @{}'
                    $Result = @{}
                    foreach ($PropertySet in (@($TemplateProperties) + $ConfigurationSet)) {
                        Write-Debug -Message ('$PropertySet: ''{0}''' -f $PropertySet)
                        Write-Debug -Message 'if ($PropertySet)'
                        if ($PropertySet) {
                            Write-Debug -Message ('$PropertySet: {0}' -f [string]$PropertySet)
                            Write-Debug -Message ('$PropertySet.GetType(): {0}' -f $PropertySet.GetType())

                            Write-Debug -Message '$PropertySetMembers = Get-Member -InputObject $PropertySet'
                            $PropertySetMembers = Get-Member -InputObject $PropertySet
                            Write-Debug -Message ('$PropertySetMembers: {0}' -f [string]$PropertySetMembers)
                            Write-Debug -Message '$PropertySetNoteProperties = $PropertySetMembers | Where-Object -FilterScript {$_.MemberType -eq ''NoteProperty''}'
                            $PropertySetNoteProperties = $PropertySetMembers | Where-Object -FilterScript {$_.MemberType -eq 'NoteProperty'}
                            Write-Debug -Message ('$PropertySetNoteProperties: {0}' -f [string]$PropertySetNoteProperties)
                            Write-Debug -Message '$PropertySetNoteProperties).Name'
                            $PropertyNames = ($PropertySetNoteProperties).Name
                            Write-Debug -Message ('$PropertyNames: {0}' -f [string]$PropertyNames)
                            foreach ($PropertyName in $PropertyNames) {
                                Write-Debug -Message ('$PropertyName = ''{0}''' -f $PropertyName)
                                Write-Debug -Message ('$Result.''{0}'' = $PropertySet.''{0}''' -f $PropertyName)
                                $Result.$PropertyName = $PropertySet.$PropertyName
                                Write-Debug -Message ('$Result.''{0}'': {1}' -f $PropertyName, $Result.$PropertyName)
                            }
                        }
                    }
                }
                Write-Debug -Message ('$Result: {0}' -f [string]$Result)

                Write-Debug -Message '[PSCustomObject]$Result'
                [PSCustomObject]$Result
            }
            else {
                Write-Debug -Message '$Configuration'
                $ConfigurationSet
            }
        }

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