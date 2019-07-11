---
external help file: AutomaticMaintenance-help.xml
Module Name: AutomaticMaintenance
online version:
schema: 2.0.0
---

# Invoke-ComputerMaintenance

## SYNOPSIS
The function executes all maintenance steps on a single host.

## SYNTAX

```
Invoke-ComputerMaintenance [-ComputerName] <String> [[-PreventiveLockTimeout] <Int32>]
 [[-PreventiveLockThreshold] <TimeSpan>] [<CommonParameters>]
```

## DESCRIPTION
Use this function to perform maintenance on a single host, defined in the hosts configuration file.
If you use an orchestration/configuration management system, you might prefer it over **Invoke-InfrastructureMaintenance** to run **Invoke-ComputerMaintenance**.

## EXAMPLES

### Example 1
```powershell
PS C:\> Start-ComputerMaintenance -ComputerName 'SRV01'
```

Performs maintenance tasks on SRV01.

### Example 2
```powershell
PS C:\> Start-ComputerMaintenance -ComputerName 'SRV01' -PreventiveLockThreshold (New-Object -TypeName 'System.TimeSpan' -ArgumentList @(2, 0, 0))
```

Performs maintenance tasks on SRV01. If the host will be locked, the function will wait for 2 hours for it to unlock.

## PARAMETERS

### -ComputerName
The name of a computer to process.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreventiveLockThreshold
Specifies how long the function will wait if a target host is locked by some other function.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreventiveLockTimeout
Specifies how often the function will request the lock status of a target host while waiting for it to unlock.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipNotLockable
Defines if the maintenance process should silently skip a host if the function cannot put a host lock on it. Otherwise the function will raise an exception.

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

### -SkipPreventivelyLocked
Defines if the maintenance process should silently skip a host if it is locked by some other function. Otherwise the function will raise an exception.

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
