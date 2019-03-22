---
external help file: AutomaticMaintenance-help.xml
Module Name: AutomaticMaintenance
online version:
schema: 2.0.0
---

# Get-ComputerMaintenanceConfiguration

## SYNOPSIS
Returns full maintenance configuration for a given host or a group of hosts.

## SYNTAX

### ByComputerName
```
Get-ComputerMaintenanceConfiguration -ComputerName <String> [-FilePath <String>] [-NoRecurse]
 [<CommonParameters>]
```

### ByFilter
```
Get-ComputerMaintenanceConfiguration [-FilePath <String>] [-FilterScript <ScriptBlock>] [-NoRecurse]
 [<CommonParameters>]
```

## DESCRIPTION
The function supports two modes: you can either pass a computer name (`-ComputerName` parameter) or a scriptblock (`-FilterScript` parameter) to select for which computers to build a maintenance configuration.
The function is used by other functions in the module and exposed mainly for troubleshooting purposes.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ComputerMaintenanceConfiguration -ComputerName SRV01
```

Returns a full configuration for a host, which name is SRV01.

### Example 2
```powershell
PS C:\> Get-ComputerMaintenanceConfiguration -ComputerName SRV01 -NoRecurse
```

Returns a full configuration for a host, which name is SRV01. Does not resolve templates if the host has any.

### Example 3
```powershell
PS C:\> Get-ComputerMaintenanceConfiguration -FilterScript {$_.Template -eq 'Example-Template'}
```

Returns a full configuration for hosts, which have "Example-Template" as their template.

### Example 4
```powershell
PS C:\> Get-ComputerMaintenanceConfiguration
```

Returns a full configuration for all hosts.

## PARAMETERS

### -ComputerName
Specifies the name of a host to lookup.

```yaml
Type: String
Parameter Sets: ByComputerName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
A path to the main configuration file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterScript
Specifies a scriptblock to use to filter hosts from the main configuration file.

```yaml
Type: ScriptBlock
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRecurse
Turns off templates resolving - only data from the main configuration file will be returned.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
