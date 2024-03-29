function Get-ADDSPrivilegedAccountAudit {
    <#
    .SYNOPSIS
        Active Directory Audit with Keyvault retrieval option.
    .DESCRIPTION
        Audit's Active Directory for priviledged users and groups, and extended rights.
        Output can be kept locally, or sent remotely via email or sftp.
        Function App is the same as SendEmail except that it uses a password retrieved using the related Function App.
        The related function app would need to be created.
        Expects SecureString and Key as inputs to function app parameter set.
    .EXAMPLE
        PS C:\> Get-ADDSPrivilegedAccountAudit -LocalDisk -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSPrivilegedAccountAudit -SendMailMessage -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -Password (Read-Host -AsSecureString) -To "support@domain.com" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSPrivilegedAccountAudit -FunctionApp $FunctionApp -Function $Function -SMTPServer $SMTPServer -UserName "helpdesk@domain.com" -To "support@domain.com" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSPrivilegedAccountAudit -WinSCP -UserName "ftphostname.UserName" -Password (Read-Host -AsSecureString) -FTPHost "ftphost.domain.com" -SshHostKeyFingerprint "<SShHostKeyFingerprint>" -Verbose
    .EXAMPLE
        PS C:\> Get-ADDSPrivilegedAccountAudit -Clean -Verbose
    .PARAMETER LocalDisk
        Only output data to local disk.
    .PARAMETER SendMailMessage
        Adds parameters for sending Audit Report as an Email.
    .PARAMETER WinSCP
        Adds parameters for sending Audit Report via SFTP.
    .PARAMETER AttachmentFolderPath
        Default path is C:\temp\ADDSPrivilegedAccountAuditLogs.
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
    .PARAMETER Clean
        Remove installed modules during run. Remove local files if not a LocalDisk run.
    .NOTES
        Can take password as input into secure string using (Read-Host -AsSecureString).
    #>
    [CmdletBinding(DefaultParameterSetName = 'LocalDisk' , HelpURI = "https://criticalsolutionsnetwork.github.io/ADDSAuditTasks/#Get-ADDSPrivilegedAccountAudit")]
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
        [string]$AttachmentFolderPath = "C:\temp\ADDSPrivilegedAccountAuditLogs",
        [Parameter(Mandatory = $true, ParameterSetName = 'WinSCP')]
        [Parameter(Mandatory = $true, ParameterSetName = 'FunctionApp')]
        [Parameter(
            ParameterSetName = 'SendMailMessage',
            Mandatory = $true,
            HelpMessage = 'Enter the Sending Account UPN or FTP Username if using WinSCP. Ex:"user@contoso.com" or "ftphost.helpdesk"',
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
            HelpMessage = 'Enter the port number for the mail relay',
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
    begin {
        $ScriptFunctionName = $MyInvocation.MyCommand.Name -replace '\..*'
        try {
            Initialize-AuditBeginBlock -AttachmentFolderPathBegin $AttachmentFolderPath -ScriptFunctionName $ScriptFunctionName -SendEmailMessageBegin $SendMailMessage -CleanBegin $Clean -ErrorVariable InitBeginErr -ErrorAction Stop
        }
        catch {
            Write-TSLog "End Block last error for log: "
            Write-TSLog -LogError -LogErrorVar InitBeginErr
        }
    } # End begin
    process {
        if (!($Clean)) {
            $csvFileName = "$AttachmentFolderPath\$((Get-Date).ToString('yyyy-MM-dd_hh.mm.ss'))_$($ScriptFunctionName)_$($env:USERDNSDOMAIN)"
            # Create FileNames
            $csv = "$csvFileName.csv"
            $zip = "$csvFileName.zip"
            # AD Privileged Groups Array
            $AD_PrivilegedGroups = @(
                'Enterprise Admins',
                'Schema Admins',
                'Domain Admins',
                'Administrators',
                'Cert Publishers',
                'Account Operators',
                'Server Operators',
                'Backup Operators',
                'Print Operators',
                'DnsAdmins',
                'DnsUpdateProxy',
                'DHCP Administrators'
            )
            # Time Variables
            $time90 = (Get-Date).Adddays( - (90))
            $time60 = (Get-Date).Adddays( - (60))
            $time30 = (Get-Date).Adddays( - (30))
            # Create Arrays
            $members = @()
            $ADUsers = @()
            foreach ($group in $AD_PrivilegedGroups) {
                Clear-Variable GroupMember -ErrorAction SilentlyContinue
                Get-ADGroupMember -Identity $group -Recursive -OutVariable GroupMember | Out-Null
                $GroupMember | Select-Object SamAccountName, Name, ObjectClass, `
                @{N = 'PriviledgedGroup'; E = { $group } }, `
                @{N = 'Enabled'; E = { (Get-ADUser -Identity $_.samaccountname).Enabled } }, `
                @{N = 'PasswordNeverExpires'; E = { (Get-ADUser -Identity $_.samaccountname -Properties PasswordNeverExpires).PasswordNeverExpires } }, `
                @{N = 'LastLogin'; E = { [DateTime]::FromFileTime((Get-ADUser -Identity $_.samaccountname -Properties lastLogonTimestamp).lastLogonTimestamp) } }, `
                @{N = 'LastSeen'; E = {
                        switch ([DateTime]::FromFileTime((Get-ADUser -Identity $_.samaccountname -Properties lastLogonTimestamp).lastLogonTimestamp)) {
                            # Over 90 Days
                            { ($_ -lt $time90) } { '3+ months'; break }
                            # Over 60 Days
                            { ($_ -lt $time60) } { '2+ months'; break }
                            # Over 90 Days
                            { ($_ -lt $time30) } { '1+ month'; break }
                            default { 'Recently' }
                        }
                    }
                }, `
                @{N = 'OrgUnit'; E = { $_.DistinguishedName -replace '^.*?,(?=[A-Z]{2}=)' } }, `
                @{N = 'GroupMemberships'; E = { Get-ADGroupMemberof -SamAccountName $_.samaccountname } }, `
                    Title, `
                @{N = 'Manager'; E = { (Get-ADUser -Identity $_.manager).Name } }, `
                @{N = 'SuspectedSvcAccount'; E = {
                        # Null gave unexpected behavior on the left side. Works on the right side.
                        if (((Get-ADUser -Identity $_.samaccountname -Properties PasswordNeverExpires).PasswordNeverExpires) -or (((Get-ADUser -Identity $_.samaccountname -Properties servicePrincipalName).servicePrincipalName) -ne $null) ) {
                            return $true
                        } # end if
                        else {
                            return $false
                        } # end else
                    } # End Expression
                }, # End Named Expression SuspectedSvcAccount
                Department, AccessRequired, NeedMailbox -OutVariable members | Out-Null
                $ADUsers += $members
            }
            $Export = @()
            # Create $Export Object
            foreach ($User in $ADUsers) {
                $hash = [ordered]@{
                    PriviledgedGroup     = $User.PriviledgedGroup
                    SamAccountName       = $User.SamAccountName
                    Name                 = $User.Name
                    ObjectClass          = $User.ObjectClass
                    LastLogin            = $User.LastLogin
                    LastSeen             = $User.LastSeen
                    GroupMemberships     = $User.GroupMemberships
                    Title                = $User.Title
                    Manager              = $User.Manager
                    Department           = $User.Department
                    OrgUnit              = $User.OrgUnit
                    Enabled              = $User.Enabled
                    PasswordNeverExpires = $User.PasswordNeverExpires
                    SuspectedSvcAccount  = $User.SuspectedSvcAccount
                    AccessRequired       = $false
                    NeedMailbox          = $true
                }
                New-Object -TypeName PSCustomObject -Property $hash -OutVariable PSObject | Out-Null
                $Export += $PSObject
            }
            # Create filenames
            $csv2 = $csv -replace ".csv", ".ExtendedPermissions.csv"
            $zip2 = $zip -replace ".zip", ".ExtendedPermissions.zip"
            $csv3 = $csv -replace ".csv", ".PossibleServiceAccounts.csv"
            $zip3 = $zip -replace ".zip", ".PossibleServiceAccounts.zip"
            # Get PDC
            $dc = (Get-ADDomainController -Discover -DomainName $env:USERDNSDOMAIN -Service PrimaryDC).Name
            # Get DN of AD Root.
            $rootou = (Get-ADRootDSE).defaultNamingContext
            # Get ad objects from the PDC for the root ou. #TODO Check
            $Allobjects = Get-ADObject -Server $dc -SearchBase $rootou -SearchScope subtree -LDAPFilter `
                "(&(objectclass=user)(objectcategory=person))" -Properties ntSecurityDescriptor -ResultSetSize $null
            # "(|(objectClass=domain)(objectClass=organizationalUnit)(objectClass=group)(sAMAccountType=805306368)(objectCategory=Computer)(&(objectclass=user)(objectcategory=person)))"
            # Create $Export2 Object
            $Export2 = Foreach ($ADObject in $Allobjects) {
                Get-AdExtendedRight $ADObject
            }
            # Export Delegated access, allowed protocols and Destination Serivces.
            $Export3 = Get-ADObject -Filter { (msDS-AllowedToDelegateTo -like '*') -or (UserAccountControl -band 0x0080000) -or (UserAccountControl -band 0x1000000) } `
                -prop samAccountName, msDS-AllowedToDelegateTo, servicePrincipalName, userAccountControl | `
                Select-Object DistinguishedName, ObjectClass, samAccountName, `
            @{N = 'servicePrincipalName'; E = { $_.servicePrincipalName -join " | " } }, `
            @{N = 'DelegationStatus'; E = { if ($_.UserAccountControl -band 0x80000) { 'AllServices' }else { 'SpecificServices' } } }, `
            @{N = 'AllowedProtocols'; E = { if ($_.UserAccountControl -band 0x1000000) { 'Any' }else { 'Kerberos' } } }, `
            @{N = 'DestinationServices'; E = { $_.'msDS-AllowedToDelegateTo' } }
            # Try first export.
            Export-AuditCSVtoZip -Exported $Export -CSVName $csv -ZipName $zip -ErrorVariable ExportAuditCSVZipErr
            # Try second export.
            Export-AuditCSVtoZip -Exported $Export2 -CSVName $csv2 -ZipName $zip2 -ErrorVariable ExportAuditCSVZipErr2
            # try third export
            Export-AuditCSVtoZip -Exported $Export3 -CSVName $csv3 -ZipName $zip3 -ErrorVariable ExportAuditCSVZipErr3
        } # End If Not Clean
    } # End process
    End {
        try {
            Initialize-AuditEndBlock -SendEmailMessageEnd $SendMailMessage -WinSCPEnd $WinSCP -FTPHostend $FTPHost -SshHostKeyFingerprintEnd $SshHostKeyFingerprint -SmtpServerEnd $SMTPServer -PortEnd $Port -UserNameEnd $UserName -FromEnd $From -ToEnd $To `
                -AttachmentFolderPathEnd $AttachmentFolderPath -Password $Password -FunctionEnd $function -FunctionAppEnd $FunctionApp `
                -ApiTokenEnd $ApiToken -ZipEnd $zip, $zip2, $zip3 -RemotePathEnd $RemotePath -LocalDiskEnd $LocalDisk -CleanEnd $Clean -ErrorVariable InitEndErr
        }
        catch {
            Write-TSLog "End Block last error for log: "
            Write-TSLog -LogError
        }
        # Clear Variables
        Clear-Variable -Name "Function", "FunctionApp", "ApiToken"
    } # End end
}