# ADDSAuditTasks Module
## Format-HRRoster
### Synopsis
Takes CSV input as "LastName\<space\>FirstName" and flips it to "Firstname\<space\>Lastname"
### Syntax
```powershell

Format-HRRoster [[-HRRosterCSV] <String>] [[-AttachmentFolder] <String>] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>HRRosterCSV</nobr> |  |  | false | true \\(ByValue, ByPropertyName\) |  |
| <nobr>AttachmentFolder</nobr> |  |  | false | true \\(ByPropertyName\) | C:\\temp\\ActiveUsersHR |
### Note
This function depends on the name column in the employee roster name column, to have been formatted in excel using a find and replace to replace ", " with " ". In other words: The file needs to have "comma space" replaces with "space" in the name column to be easily compared to ADUser output.

### Examples
**EXAMPLE 1**
```powershell
Format-HRRoster -HRRosterCSV "C:\temp\HRRosterNameColumnFormattedLastNameSpaceFirstname.csv" -Verbose
Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
```


### Links

 - [Specify a URI to a help page, this will show when Get-Help -Online is used.](#Specify a URI to a help page, this will show when Get-Help -Online is used.)
## Get-ADDSActiveAccountAudit
### Synopsis
Active Directory Audit with Keyvault retrieval option.
### Syntax
```powershell

Get-ADDSActiveAccountAudit [-LocalDisk] [-AttachmentFolderPath <String>] [-ADDSAccountIsNotEnabled] [-DaysInactive <Int32>] [<CommonParameters>]

Get-ADDSActiveAccountAudit [-SendMailMessage] [-SMTPServer <String>] [-AttachmentFolderPath <String>] [-ADDSAccountIsNotEnabled] [-DaysInactive <Int32>] -UserName <String> [-Password <SecureString>] [-Port <Int32>] -To <String> [-From <String>] [<CommonParameters>]

Get-ADDSActiveAccountAudit [-WinSCP] [-AttachmentFolderPath <String>] [-ADDSAccountIsNotEnabled] [-DaysInactive <Int32>] -UserName <String> -Password <SecureString> -FTPHost <String> -SshHostKeyFingerprint <String> [-RemotePath <String>] [<CommonParameters>]

Get-ADDSActiveAccountAudit [-FunctionApp] <String> [-Function] <String> [-SMTPServer <String>] [-AttachmentFolderPath <String>] [-ADDSAccountIsNotEnabled] [-DaysInactive <Int32>] -UserName <String> [-Port <Int32>] -To <String> [-From <String>] -ApiToken <String> [<CommonParameters>]

Get-ADDSActiveAccountAudit [-Clean] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>LocalDisk</nobr> |  | Only output data to local disk. | true | false | False |
| <nobr>SendMailMessage</nobr> |  | Adds parameters for sending Audit Report as an Email. | true | false | False |
| <nobr>WinSCP</nobr> |  | Adds parameters for sending Audit Report via SFTP. | true | true \\(ByPropertyName\) | False |
| <nobr>FunctionApp</nobr> |  | Azure Function App Name. | true | false |  |
| <nobr>Function</nobr> |  | Azure Function App's Function Name. Ex. "HttpTrigger1" | true | true \\(ByPropertyName\) |  |
| <nobr>SMTPServer</nobr> |  | Defaults to Office 365 SMTP relay. Enter optional relay here. | false | true \\(ByPropertyName\) | smtp.office365.com |
| <nobr>AttachmentFolderPath</nobr> |  | Default path is C:\\temp\\ADDSActiveAccountAuditLogs. This is the folder where attachments are going to be saved. | false | true \\(ByValue\) | C:\\temp\\ADDSActiveAccountAuditLogs |
| <nobr>ADDSAccountIsNotEnabled</nobr> |  | Defaults to not being set. Choose to search for disabled Active Directory Users. | false | true \\(ByPropertyName\) | False |
| <nobr>DaysInactive</nobr> |  | Defaults to 90 days in the past. Specifies how far back to look for accounts last logon. If logon is within 90 days, it won't be included. | false | true \\(ByPropertyName\) | 90 |
| <nobr>UserName</nobr> |  | Specify the account with an active mailbox and MFA disabled. Ensure the account has delegated access for Send On Behalf for any UPN set in the "$From" Parameter | true | true \\(ByPropertyName\) |  |
| <nobr>Password</nobr> |  | Use: \\(Read-Host -AsSecureString\) as in Examples. May be omitted. | false | true \\(ByPropertyName\) |  |
| <nobr>Port</nobr> |  | SMTP Port to Relay. Ports can be: "993", "995", "587", or "25" | false | true \\(ByPropertyName\) | 587 |
| <nobr>To</nobr> |  | Recipient of the attachment outputs. | true | true \\(ByPropertyName\) |  |
| <nobr>From</nobr> |  | Defaults to the same account as $UserName unless the parameter is set. Ensure the Account has delegated access to send on behalf for the $From account. | false | true \\(ByPropertyName\) | $UserName |
| <nobr>ApiToken</nobr> |  | Private Function Key. | true | true \\(ByPropertyName\) |  |
| <nobr>FTPHost</nobr> |  | SFTP Hostname. | true | true \\(ByPropertyName\) |  |
| <nobr>SshHostKeyFingerprint</nobr> |  | Adds parameters for sending Audit Report via SFTP. | true | true \\(ByPropertyName\) |  |
| <nobr>RemotePath</nobr> |  | Remove FTP path. Will be created in the user path under functionname folder if not specified. | false | true \\(ByPropertyName\) | \\("./" \+ $\\($MyInvocation.MyCommand.Name -replace '\\..\*'\)\) |
| <nobr>Clean</nobr> |  | Remove installed modules during run. Remove local files if not a LocalDisk run. | true | false | False |
### Note
Can take password as input into secure string using \\(Read-Host -AsSecureString\).

### Examples
**EXAMPLE 1**
```powershell
Get-ADDSActiveAccountAudit -LocalDisk -Verbose
```


**EXAMPLE 2**
```powershell
Get-ADDSActiveAccountAudit -SendMailMessage -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -Password (Read-Host -AsSecureString) -To "support@domain.com" -Verbose
```


**EXAMPLE 3**
```powershell
Get-ADDSActiveAccountAudit -FunctionApp $FunctionApp -Function $Function -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -To "support@domain.com" -Verbose
```


**EXAMPLE 4**
```powershell
Get-ADDSActiveAccountAudit -WinSCP -UserName "ftphostname.UserName" -Password (Read-Host -AsSecureString) -FTPHost "ftphost.domain.com" -SshHostKeyFingerprint "<SShHostKeyFingerprint>" -Verbose
```


**EXAMPLE 5**
```powershell
Get-ADDSActiveAccountAudit -Clean -Verbose
```


## Get-ADDSDepartedUsersAccountAudit
### Synopsis
Active Directory Audit with Keyvault retrieval option.
### Syntax
```powershell

Get-ADDSDepartedUsersAccountAudit [-LocalDisk] [-AttachmentFolderPath <String>] -WildCardIdentifier <String> [<CommonParameters>]

Get-ADDSDepartedUsersAccountAudit [-SendMailMessage] [-SMTPServer <String>] [-AttachmentFolderPath <String>] -UserName <String> [-Password <SecureString>] [-Port <Int32>] -To <String> [-From <String>] -WildCardIdentifier <String> [<CommonParameters>]

Get-ADDSDepartedUsersAccountAudit [-WinSCP] [-AttachmentFolderPath <String>] -UserName <String> -Password <SecureString> -FTPHost <String> -SshHostKeyFingerprint <String> [-RemotePath <String>] -WildCardIdentifier <String> [<CommonParameters>]

Get-ADDSDepartedUsersAccountAudit [-FunctionApp] <String> [-Function] <String> [-SMTPServer <String>] [-AttachmentFolderPath <String>] -UserName <String> [-Port <Int32>] -To <String> [-From <String>] -ApiToken <String> -WildCardIdentifier <String> [<CommonParameters>]

Get-ADDSDepartedUsersAccountAudit [-Clean] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>LocalDisk</nobr> |  | Only output data to local disk. | true | false | False |
| <nobr>SendMailMessage</nobr> |  | Adds parameters for sending Audit Report as an Email. | true | false | False |
| <nobr>WinSCP</nobr> |  | Adds parameters for sending Audit Report via SFTP. | true | true \\(ByPropertyName\) | False |
| <nobr>FunctionApp</nobr> |  | Azure Function App Name. | true | false |  |
| <nobr>Function</nobr> |  | Azure Function App's Function Name. Ex. "HttpTrigger1" | true | true \\(ByPropertyName\) |  |
| <nobr>SMTPServer</nobr> |  | Defaults to Office 365 SMTP relay. Enter optional relay here. | false | true \\(ByPropertyName\) | smtp.office365.com |
| <nobr>AttachmentFolderPath</nobr> |  | Default path is C:\\temp\\ADDSDepartedUsersAuditLogs. This is the folder where attachments are going to be saved. | false | true \\(ByValue\) | C:\\temp\\ADDSDepartedUsersAuditLogs |
| <nobr>UserName</nobr> |  | Specify the account with an active mailbox and MFA disabled. Ensure the account has delegated access for Send On Behalf for any UPN set in the "$From" Parameter | true | true \\(ByPropertyName\) |  |
| <nobr>Password</nobr> |  | Use: \\(Read-Host -AsSecureString\) as in Examples. May be omitted. | false | true \\(ByPropertyName\) |  |
| <nobr>Port</nobr> |  | SMTP Port to Relay. Ports can be: "993", "995", "587", or "25" | false | true \\(ByPropertyName\) | 587 |
| <nobr>To</nobr> |  | Recipient of the attachment outputs. | true | true \\(ByPropertyName\) |  |
| <nobr>From</nobr> |  | Defaults to the same account as $UserName unless the parameter is set. Ensure the Account has delegated access to send on behalf for the $From account. | false | true \\(ByPropertyName\) | $UserName |
| <nobr>ApiToken</nobr> |  | Private Function Key. | true | true \\(ByPropertyName\) |  |
| <nobr>FTPHost</nobr> |  |  | true | true \\(ByPropertyName\) |  |
| <nobr>SshHostKeyFingerprint</nobr> |  |  | true | true \\(ByPropertyName\) |  |
| <nobr>RemotePath</nobr> |  |  | false | true \\(ByPropertyName\) | \\("./" \+ $\\($MyInvocation.MyCommand.Name -replace '\\..\*'\)\) |
| <nobr>Clean</nobr> |  | Remove installed modules during run. Remove local files if not a LocalDisk run. | true | false | False |
| <nobr>WildCardIdentifier</nobr> |  | Name wildcard appended to user account. | true | true \\(ByPropertyName\) |  |
### Note
Can take password as input into secure string using \\(Read-Host -AsSecureString\).

### Examples
**EXAMPLE 1**
```powershell
Get-ADDSDepartedUsersAccountAudit -LocalDisk -WildCardIdentifier "<StringToSearchFor>" -Verbose
```


**EXAMPLE 2**
```powershell
Get-ADDSDepartedUsersAccountAudit -SendMailMessage -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -Password (Read-Host -AsSecureString) -To "support@domain.com" -WildCardIdentifier "<StringToSearchFor>" -Verbose
```


**EXAMPLE 3**
```powershell
Get-ADDSDepartedUsersAccountAudit -FunctionApp $FunctionApp -Function $Function -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -To "support@domain.com" -WildCardIdentifier "<StringToSearchFor>" -Verbose
```


**EXAMPLE 4**
```powershell
Get-ADDSDepartedUsersAccountAudit -WinSCP -UserName "ftphostname.UserName" -Password (Read-Host -AsSecureString) -FTPHost "ftphost.domain.com" -SshHostKeyFingerprint "<SShHostKeyFingerprint>" -WildCardIdentifier "<StringToSearchFor>" -Verbose
```


**EXAMPLE 5**
```powershell
Get-ADDSDepartedUsersAccountAudit -Clean -Verbose
```


## Get-ADDSPrivilegedAccountAudit
### Synopsis
Active Directory Audit with Keyvault retrieval option.
### Syntax
```powershell

Get-ADDSPrivilegedAccountAudit [-LocalDisk] [-AttachmentFolderPath <String>] [<CommonParameters>]

Get-ADDSPrivilegedAccountAudit [-SendMailMessage] [-SMTPServer <String>] [-AttachmentFolderPath <String>] -UserName <String> [-Password <SecureString>] [-Port <Int32>] -To <String> [-From <String>] [<CommonParameters>]

Get-ADDSPrivilegedAccountAudit [-WinSCP] [-AttachmentFolderPath <String>] -UserName <String> -Password <SecureString> -FTPHost <String> -SshHostKeyFingerprint <String> [-RemotePath <String>] [<CommonParameters>]

Get-ADDSPrivilegedAccountAudit [-FunctionApp] <String> [-Function] <String> [-SMTPServer <String>] [-AttachmentFolderPath <String>] -UserName <String> [-Port <Int32>] -To <String> [-From <String>] -ApiToken <String> [<CommonParameters>]

Get-ADDSPrivilegedAccountAudit [-Clean] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>LocalDisk</nobr> |  | Only output data to local disk. | true | false | False |
| <nobr>SendMailMessage</nobr> |  | Adds parameters for sending Audit Report as an Email. | true | false | False |
| <nobr>WinSCP</nobr> |  | Adds parameters for sending Audit Report via SFTP. | true | true \\(ByPropertyName\) | False |
| <nobr>FunctionApp</nobr> |  | Azure Function App Name. | true | false |  |
| <nobr>Function</nobr> |  | Azure Function App's Function Name. Ex. "HttpTrigger1" | true | true \\(ByPropertyName\) |  |
| <nobr>SMTPServer</nobr> |  | Defaults to Office 365 SMTP relay. Enter optional relay here. | false | true \\(ByPropertyName\) | smtp.office365.com |
| <nobr>AttachmentFolderPath</nobr> |  | Default path is C:\\temp\\ADDSPrivilegedAccountAuditLogs. This is the folder where attachments are going to be saved. | false | true \\(ByValue\) | C:\\temp\\ADDSPrivilegedAccountAuditLogs |
| <nobr>UserName</nobr> |  | Specify the account with an active mailbox and MFA disabled. Ensure the account has delegated access for Send On Behalf for any UPN set in the "$From" Parameter | true | true \\(ByPropertyName\) |  |
| <nobr>Password</nobr> |  | Use: \\(Read-Host -AsSecureString\) as in Examples. May be omitted. | false | true \\(ByPropertyName\) |  |
| <nobr>Port</nobr> |  | SMTP Port to Relay. Ports can be: "993", "995", "587", or "25" | false | true \\(ByPropertyName\) | 587 |
| <nobr>To</nobr> |  | Recipient of the attachment outputs. | true | true \\(ByPropertyName\) |  |
| <nobr>From</nobr> |  | Defaults to the same account as $UserName unless the parameter is set. Ensure the Account has delegated access to send on behalf for the $From account. | false | true \\(ByPropertyName\) | $UserName |
| <nobr>ApiToken</nobr> |  | Private Function Key. | true | true \\(ByPropertyName\) |  |
| <nobr>FTPHost</nobr> |  | SFTP Hostname. | true | true \\(ByPropertyName\) |  |
| <nobr>SshHostKeyFingerprint</nobr> |  | Adds parameters for sending Audit Report via SFTP. | true | true \\(ByPropertyName\) |  |
| <nobr>RemotePath</nobr> |  | Remove FTP path. Will be created in the user path under functionname folder if not specified. | false | true \\(ByPropertyName\) | \\("./" \+ $\\($MyInvocation.MyCommand.Name -replace '\\..\*'\)\) |
| <nobr>Clean</nobr> |  | Remove installed modules during run. Remove local files if not a LocalDisk run. | true | false | False |
### Note
Can take password as input into secure string using \\(Read-Host -AsSecureString\).

### Examples
**EXAMPLE 1**
```powershell
Get-ADDSPrivilegedAccountAudit -LocalDisk -Verbose
```


**EXAMPLE 2**
```powershell
Get-ADDSPrivilegedAccountAudit -SendMailMessage -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -Password (Read-Host -AsSecureString) -To "support@domain.com" -Verbose
```


**EXAMPLE 3**
```powershell
Get-ADDSPrivilegedAccountAudit -FunctionApp $FunctionApp -Function $Function -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -To "support@domain.com" -Verbose
```


**EXAMPLE 4**
```powershell
Get-ADDSPrivilegedAccountAudit -WinSCP -UserName "ftphostname.UserName" -Password (Read-Host -AsSecureString) -FTPHost "ftphost.domain.com" -SshHostKeyFingerprint "<SShHostKeyFingerprint>" -Verbose
```


**EXAMPLE 5**
```powershell
Get-ADDSPrivilegedAccountAudit -Clean -Verbose
```


## Get-ADUsersLastLogon
### Synopsis
Takes SamAccountName as input to retrieve most recent LastLogon from all DC's.
### Syntax
```powershell

Get-ADUsersLastLogon [-SamAccountName] <Object> [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>SamAccountName</nobr> | Identity, UserName, Account | The SamAccountName of the user being checked for LastLogon. | true | true \\(ByValue\) |  |
### Outputs
 - System.DateTime

### Examples
**EXAMPLE 1**
```powershell
Get-ADUsersLastLogon -SamAccountName "UserName"
```


