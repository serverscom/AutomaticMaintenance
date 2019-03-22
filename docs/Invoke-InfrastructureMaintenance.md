---
external help file: AutomaticMaintenance-help.xml
Module Name: AutomaticMaintenance
online version:
schema: 2.0.0
---

# Invoke-InfrastructureMaintenance

## SYNOPSIS
Use this function to invoke maintenance on all hosts defined in the hosts configuration file.

## SYNTAX

```
Invoke-InfrastructureMaintenance [[-LogErrorFilePath] <String>] [[-LogFilePathTemplate] <String>]
 [[-LogMutexName] <String>] [-DebugLog] [<CommonParameters>]
```

## DESCRIPTION
The function performs maintenance on all hosts defined in the hosts configuration files, one by one.
Its main purpose is to be executed from Task Scheduler. We do not recommend to execute this function from an orchestration/configuration management system (Ansible, Chef, System Center Orchestrator etc.) - use **Invoke-ComputerMaintenance** for that.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-InfrastructureMaintenance
```

Performs maintenance tasks on all hosts defined in the main configuration file.

### Example 2
```powershell
PS C:\> Invoke-InfrastructureMaintenance -DebugLog
```

Performs maintenance tasks on all hosts defined in the main configuration file, while logging every command/variable into debug log files.

## PARAMETERS

### -DebugLog
Specifies if the function should log maintenance process in details through the debug log.

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

### -LogErrorFilePath
A path to the error log file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFilePathTemplate
A template used for debug log file paths.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogMutexName
The name of a mutex used to access a debug log file object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
