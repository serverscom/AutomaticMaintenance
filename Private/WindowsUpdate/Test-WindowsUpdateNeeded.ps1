function Test-WindowsUpdateNeeded {
    #Requires -Version 3.0

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [scriptblock]$Filter,
        [string]$DefaultFilterString = $ModuleWideCheckUpdateDefaultFilterString,
        [string]$Criteria = $ModuleWideUpdateSearchCriteria
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)
        Write-Debug -Message ('$DefaultFilterString = ''{0}''' -f $DefaultFilterString)
        Write-Debug -Message ('$Criteria = ''{0}''' -f $Criteria)

        if (-not $Filter) {
            Write-Debug -Message ('$ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName {0}' -f $ComputerName)
            $ComputerMaintenanceConfiguration = Get-ComputerMaintenanceConfiguration -ComputerName $ComputerName
            Write-Debug -Message ('$ComputerMaintenanceConfiguration: {0}' -f $ComputerMaintenanceConfiguration)
            Write-Debug -Message '$FilterString = $ComputerMaintenanceConfiguration.UpdateCheckFilter'
            $FilterString = $ComputerMaintenanceConfiguration.UpdateCheckFilter
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
        
        Write-Debug -Message ('$UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID(''Microsoft.Update.Session'', ''{0}''))' -f $ComputerName)
        $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID('Microsoft.Update.Session', $ComputerName))
        Write-Debug -Message ('$UpdateSession: ''{0}''' -f $UpdateSession)
        Write-Debug -Message '$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()'
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        Write-Debug -Message ('$UpdateSearcher: ''{0}''' -f $UpdateSearcher)
        Write-Debug -Message ('$SearchResult = $UpdateSearcher.Search(''{0}'')' -f $Criteria)
        $SearchResult = $UpdateSearcher.Search($Criteria)
        Write-Debug -Message ('$SearchResult: ''{0}''' -f $SearchResult)

        Write-Debug -Message '$Updates2Install = $false'
        $Updates2Install = $false

        Write-Debug -Message ('$SearchResult.Updates.Count: {0}' -f $SearchResult.Updates.Count)
        Write-Debug -Message 'if ($SearchResult.Updates.Count -gt 0)'
        if ($SearchResult.Updates.Count -gt 0) {
            Write-Debug -Message '$Updates = $SearchResult.Updates'
            $Updates = $SearchResult.Updates
            Write-Debug -Message ('$Updates: ''{0}''' -f [string]$Updates)
            foreach ($Item in $Updates) {
                Write-Debug -Message ('$Item: ''{0}''' -f $Item.Title)
                Write-Debug -Message ('$Item = $Item | Where-Object -FilterScript {0}' -f $Filter)
                $Item = $Item | Where-Object -FilterScript $Filter
                Write-Debug -Message ('$Item: ''{0}''' -f $Item)
                Write-Debug -Message 'if ($Item)'
                if ($Item) {
                    Write-Debug -Message '$Updates2Install = $true'
                    $Updates2Install = $true
                }
            }
        }

        Write-Debug -Message '$Updates2Install'
        $Updates2Install

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