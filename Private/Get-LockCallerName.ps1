function Get-LockCallerName {
    #Requires -Version 3.0

    [CmdletBinding()]
    [OutputType([string])]

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message '$IPGlobalProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()'
        $IPGlobalProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
        Write-Debug -Message ('$IPGlobalProperties: {0}' -f [string]$IPGlobalProperties)
        Write-Debug -Message ('$ScriptHostDnsName = ''{{0}}.{{1}}'' -f {0}, {1}' -f $IPGlobalProperties.HostName, $IPGlobalProperties.DomainName)
        $ScriptHostDnsName = '{0}.{1}' -f $IPGlobalProperties.HostName, $IPGlobalProperties.DomainName
        Write-Debug -Message ('$ScriptHostDnsName = {0}' -f $ScriptHostDnsName)

        Write-Debug -Message '$CallerName = (Get-PSCallStack)[1].Command'
        $CallerName = (Get-PSCallStack)[1].Command
        Write-Debug -Message ('$CallerName = {0}' -f $CallerName)
        Write-Debug -Message ('''{{0}}@{{1}}'' -f ''{0}'', ''{1}''' -f $CallerName, $ScriptHostDnsName)
        '{0}@{1}' -f $CallerName, $ScriptHostDnsName
    
        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: throw $_)' -f $MyInvocation.MyCommand.Name)
        throw $_

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}