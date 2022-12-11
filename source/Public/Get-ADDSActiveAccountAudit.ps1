function Get-ADDSActiveAccountAudit {
    <#
    .SYNOPSIS
        Active Directory Audit with Keyvault retrieval option.
    .DESCRIPTION
        Audit's Active Directory taking "days" as the input for how far back to check for a last sign in.
        Output can be kept locally, or sent remotely via email or sftp.
        Function App is the same as SendEmail except that it uses a password retrieved using the related Function App.
        The related function app would need to be created.
        Expects SecureString and Key as inputs to function app parameter set.
    .EXAMPLE
        PS C:\> Get-ADDSActiveAccountAudit -LocalDisk -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSActiveAccountAudit -SendMailMessage -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -Password (Read-Host -AsSecureString) -To "support@domain.com" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSActiveAccountAudit -FunctionApp $FunctionApp -Function $Function -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -To "support@domain.com" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSActiveAccountAudit -WinSCP -UserName "ftphostname.UserName" -Password (Read-Host -AsSecureString) -FTPHost "ftphost.domain.com" -SshHostKeyFingerprint "<SShHostKeyFingerprint>" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSActiveAccountAudit -Clean -Verbose
    .PARAMETER LocalDisk
        Only output data to local disk.
    .PARAMETER SendMailMessage
        Adds parameters for sending Audit Report as an Email.
    .PARAMETER WinSCP
        Adds parameters for sending Audit Report via SFTP.
    .PARAMETER AttachmentFolderPath
        Default path is C:\temp\ADDSActiveAccountAuditLogs.
        This is the folder where attachments are going to be saved.
    .PARAMETER FunctionApp
        Azure Function App Name.
    .PARAMETER Function
        Azure Function App's Function Name. Ex. "HttpTrigger1"
    .PARAMETER ApiToken
        Private Function Key.
    .PARAMETER SMTPServer
        Defaults to Office 365 SMTP relay. Enter optional relay here.
    .PARAMETER Port
        SMTP Port to Relay. Ports can be: "993", "995", "587", or "25"
    .PARAMETER UserName
        Specify the account with an active mailbox and MFA disabled.
        Ensure the account has delegated access for Send On Behalf for any
        UPN set in the "$From" Parameter
    .PARAMETER Password
        Use: (Read-Host -AsSecureString) as in Examples.
        May be omitted.
    .PARAMETER To
        Recipient of the attachment outputs.
    .PARAMETER From
        Defaults to the same account as $UserName unless the parameter is set.
        Ensure the Account has delegated access to send on behalf for the $From account.
    .PARAMETER FTPHost
        SFTP Hostname.
    .PARAMETER RemotePath
        Remove FTP path. Will be created in the user path under functionname folder if not specified.
    .PARAMETER SshHostKeyFingerprint
        Adds parameters for sending Audit Report via SFTP.
    .PARAMETER DaysInactive
        Defaults to 90 days in the past.
        Specifies how far back to look for accounts last logon.
        If logon is within 90 days, it won't be included.
    .PARAMETER ADDSAccountIsNotEnabled
        Defaults to not being set.
        Choose to search for disabled Active Directory Users.
    .PARAMETER Clean
        Remove installed modules during run. Remove local files if not a LocalDisk run.
    .NOTES
        Can take password as input into secure string using (Read-Host -AsSecureString).
    #>
    [CmdletBinding(DefaultParameterSetName = 'LocalDisk', HelpURI = "https://criticalsolutionsnetwork.github.io/ADDSAuditTasks/#Get-ADDSActiveAccountAudit")]
    param (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'LocalDisk',
            HelpMessage = 'Output to disk only',
            Position = 0
        )]
        [switch]$LocalDisk,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'SendMailMessage',
            HelpMessage = 'Send Mail to a relay',
            Position = 0
        )]
        [switch]$SendMailMessage,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'WinSCP',
            HelpMessage = 'Send using SFTP via WinSCP Module',
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]$WinSCP,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'FunctionApp',
            HelpMessage = 'Enter the FunctionApp name',
            Position = 0
        )]
        [string]$FunctionApp,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'FunctionApp',
            HelpMessage = 'Enter the FunctionApp Function name',
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]$Function,
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            HelpMessage = 'Enter the SMTP hostname' ,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$SMTPServer = "smtp.office365.com",
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(ParameterSetName = 'SendMailMessage')]
        [Parameter(ParameterSetName = 'WinSCP')]
        [Parameter(
            ParameterSetName = 'LocalDisk',
            HelpMessage = 'Enter output folder path',
            ValueFromPipeline = $true
        )]
        [string]$AttachmentFolderPath = "C:\temp\ADDSActiveAccountAuditLogs",
        [Parameter(ParameterSetName = 'WinSCP')]
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(ParameterSetName = 'SendMailMessage')]
        [Parameter(
            ParameterSetName = 'LocalDisk',
            HelpMessage = 'Active Directory User Enabled or not',
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]$ADDSAccountIsNotEnabled,
        [Parameter(ParameterSetName = 'WinSCP')]
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(ParameterSetName = 'SendMailMessage')]
        [Parameter(
            ParameterSetName = 'LocalDisk',
            HelpMessage = 'Days back to check for recent sign in',
            ValueFromPipelineByPropertyName = $true
        )]
        [int]$DaysInactive = '90',
        [Parameter(Mandatory = $true, ParameterSetName = 'WinSCP')]
        [Parameter(Mandatory = $true, ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            Mandatory = $true,
            HelpMessage = 'Enter the Sending Account UPN Ex:"user@contoso.com"',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$UserName,
        [Parameter(ParameterSetName = 'WinSCP', Mandatory = $true)]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            HelpMessage = 'Copy Paste the following: $Password = (Read-Host -AsSecureString)',
            ValueFromPipelineByPropertyName = $true
        )]
        [securestring]$Password,
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            HelpMessage = 'Enter the port n
                umber for the mail relay',
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet("993", "995", "587", "25")]
        [int]$Port = 587,
        [Parameter(Mandatory = $true, ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            Mandatory = $true,
            HelpMessage = 'Enter the recipient email address',
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [string]$To,
        [Parameter(ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            HelpMessage = 'Enter the name of the sender',
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [string]$From = $UserName,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'FunctionApp',
            HelpMessage = 'Enter output folder path',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$ApiToken,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'WinSCP',
            HelpMessage = 'Enter FTP HostName',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$FTPHost,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'WinSCP',
            HelpMessage = 'Enter SshHostKeyFingerprint like: "ecdsa-sha2-nistp256 256 <Key>" ',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$SshHostKeyFingerprint,
        [Parameter(
            ParameterSetName = 'WinSCP',
            HelpMessage = 'Enter ftp remote path "/path/" ',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$RemotePath = ("./" + $($MyInvocation.MyCommand.Name -replace '\..*')) ,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Clean',
            HelpMessage = 'Clean Modules and output path',
            Position = 0
        )]
        [switch]$Clean
    )
    Begin {
        $ScriptFunctionName = $MyInvocation.MyCommand.Name -replace '\..*'
        try {
            Initialize-AuditBeginBlock -AttachmentFolderPathBegin $AttachmentFolderPath -ScriptFunctionName $ScriptFunctionName -SendEmailMessageBegin $SendMailMessage -WinSCPBegin $WinSCP -CleanBegin $Clean -ErrorVariable InitBeginErr -ErrorAction Stop
        }
        catch {
            Write-TSLog "End Block last error for log: "
            Write-TSLog -LogError -LogErrorVar InitBeginErr
        }
        if ($ADDSAccountIsNotEnabled) {
            $Enabled = $false
        }
        else {
            $Enabled = $true
        }
    }
    Process {
        if (!($Clean)) {
            # Establish timeframe to review.
            $time = (Get-Date).Adddays( - ($DaysInactive))
            # Add Datetime to filename
            $csvFileName = "$AttachmentFolderPath\$((Get-Date).ToString('yyyy-MM-dd_hh.mm.ss'))_$($ScriptFunctionName)_$($env:USERDNSDOMAIN)"
            # Create FileNames
            $csv = "$csvFileName.csv"
            $zip = "$csvFileName.zip"
            Write-TSLog "Searching for users who have not signed in within the last $DaysInactive days, where parameter Enabled = $Enabled"
            # Audit Script with export to csv and zip. Paramters for Manager, lastLogonTimestamp and DistinguishedName normalized.
            # GetActiveUsers
            Get-ADUser -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $Enabled } -Properties `
                samaccountname, GivenName, Surname, Name, UserPrincipalName, lastlogontimestamp, DistinguishedName, `
                Title, Enabled, Description, Manager, Department -OutVariable ADExport | Out-Null
            $Export = @()
            foreach ($item in $ADExport) {
                $Export += [ADAuditAccount]::new(
                    $($item.SamAccountName),
                    $($item.GivenName),
                    $($item.Surname),
                    $($item.Name),
                    $($item.UserPrincipalName),
                    $($item.LastLogonTimeStamp),
                    $($item.Enabled),
                    $($item.LastLogonTimeStamp),
                    $($item.DistinguishedName),
                    $($item.Title),
                    $($item.Manager),
                    $($item.Department),
                    $false,
                    $false
                )
            }
            try {
                Export-AuditCSVtoZip -Exportobject $Export -csv $csv -zip $zip -ErrorAction Stop -ErrorVariable ExportAuditCSVZipErr
            }
            catch {
                Write-TSLog -LogErrorEnd -LogErrorVar $ExportAuditCSVZipErr.Exception.ErrorRecord
            }
        } # End If Clean Region
    } ## End Process Region
    End {
        try {
            Initialize-AuditEndBlock -SendEmailMessageEnd $SendMailMessage -WinSCPEnd $WinSCP -FTPHostend $FTPHost -SshHostKeyFingerprintEnd $SshHostKeyFingerprint -SmtpServerEnd $SMTPServer -PortEnd $Port -UserNameEnd $UserName -FromEnd $From -ToEnd $To `
                -AttachmentFolderPathEnd $AttachmentFolderPath -Password $Password -FunctionEnd $function -FunctionAppEnd $FunctionApp `
                -ApiTokenEnd $ApiToken -ZipEnd $zip -RemotePathEnd $RemotePath -LocalDiskEnd $LocalDisk -CleanEnd $Clean -ErrorVariable InitEndErr
        }
        catch {
            Write-TSLog "End Block last error for log: "
            Write-TSLog -LogError
        }
        # Clear Variables
        Clear-Variable -Name "Function", "FunctionApp", "ApiToken"
    }
}