function Initialize-AuditEndBlock {
    <#
    .SYNOPSIS
    This is a sample Private function only visible within the module.
    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
    $null = Initialize-AuditEndBlock -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.
    #>
    [cmdletBinding()]
    param
    (
        [string]$SmtpServerEnd,
        [int]$PortEnd,
        [string]$UserNameEnd,
        #[switch]$ssl,
        [string]$FromEnd,
        [string]$ToEnd,
        #[string]$subject = "$($script:MyInvocation.MyCommand.Name -replace '\..*') report ran for $($env:USERDNSDOMAIN).",
        [string]$AttachmentFolderPathEnd,
        #[string]$body,
        [securestring]$Password,
        [string]$FunctionEnd,
        [string]$FunctionAppEnd,
        [string]$ApiTokenEnd,
        [string[]]$ZipEnd,
        [bool]$CleanEnd,
        [bool]$LocalDiskEnd,
        [bool]$SendEmailMessageEnd,
        [bool]$WinSCPEnd,
        [string]$FTPHostEnd,
        [string]$SshHostKeyFingerprintEnd,
        [string]$RemotePathEnd
    )
    process {
        Write-TSLog "The Value of Clean is $CleanEnd."
        if ($CleanEnd) {
            Write-TSLog "Removing Send-MailKitMessage Module"
            try {
                # Remove Modules
                Remove-Module -Name "Send-MailKitMessage" -Force -Confirm:$false -ErrorAction Stop
            }
            catch {
                Write-TSLog "Error removing Send-MailKitMessage Module"
                Write-TSLog -LogError
            }
            Write-TSLog "Uninstalling Send-MailKitMessage Module"
            try {
                # Uninstall Modules
                Uninstall-Module -Name "Send-MailKitMessage" -AllowPrerelease -Force -Confirm:$false
            }
            catch {
                Write-TSLog -LogError
                if (Get-Module -Name Send-MailKitMessage -ListAvailable) {
                    Write-TSLog "Error uninstalling Send-MailKitMessage Module"
                }
            }
            Write-TSLog "Removing directories and files in: "
            Write-TSLog "$AttachmentFolderPathEnd"
            try {
                Remove-Item -Path $AttachmentFolderPathEnd -Recurse -Force -ErrorAction Stop
            }
            catch {
                Write-TSLog "Directory Cleanup error!"
                Write-TSLog -LogError
                throw
            }
            Write-TSLog -End
            Write-TSLog -LogOutputPath C:\temp\ADDSAuditTaskCleanupLogs.log
        }
        else {
            if ($SendEmailMessageEnd) {
                if ($Password) {
                    <#
                    Send Attachment using O365 email account and password.
                    Must exclude from conditional access legacy authentication policies.
                    #>
                    Write-TSLog "Account: $UserNameEnd,"
                    Write-TSLog "SENDING email to: $ToEnd,"
                    Write-TSLog "From USER: $FromEnd,"
                    Write-TSLog "Using PORT: $PortEnd,"
                    Write-TSLog "Using RELAY $SMTPServerEnd, with SSL"
                    Write-TSLog "With: PASSWORD"
                    Write-TSLog "Logs included in body"
                    Write-TSLog -End
                    Send-AuditEmail -smtpServer $SMTPServerEnd -port $PortEnd -username $UserNameEnd `
                        -body $script:Logs -pass $Password -from $FromEnd -to $ToEnd -attachmentfiles ($ZipEnd).Split(" ") -ssl
                    $Password.Dispose()
                    Remove-Item -Path $AttachmentFolderPath -Recurse -Force -ErrorAction Stop
                } # End if
                else {
                    Write-TSLog "Account: $UserNameEnd,"
                    Write-TSLog "SENDING email to: $ToEnd,"
                    Write-TSLog "From USER: $FromEnd,"
                    Write-TSLog "Using PORT: $PortEnd,"
                    Write-TSLog "Using RELAY: $SMTPServerEnd, with SSL"
                    Write-TSLog "Without: PASSWORD"
                    Write-TSLog "Logs included in body"
                    Write-TSLog -End
                    Send-AuditEmail -smtpServer $SMTPServerEnd -port $PortEnd -username $UsernameEnd `
                        -body $script:Logs -from $FromEnd -to $ToEnd -attachmentfiles ($ZipEnd).Split(" ") -ssl
                    Remove-Item -Path $AttachmentFolderPathEnd -Recurse -Force -ErrorAction Stop
                }
            }
            elseif ($FunctionAppEnd) {
                <#
                Send Attachment using O365 email account and Keyvault retrived password.
                Must exclude email account from conditional access legacy authentication policies.
                #>
                Write-TSLog "Account: $UserNameEnd,"
                Write-TSLog "SENDING email to: $ToEnd,"
                Write-TSLog "From USER: $FromEnd,"
                Write-TSLog "Using PORT: $PortEnd,"
                Write-TSLog "Using RELAY: $SMTPServerEnd, with SSL"
                Write-TSLog "Using FUNCTION APP: $FunctionAppEnd,"
                Write-TSLog "With FUNCTION: $FunctionEnd"
                Write-TSLog "Logs included in body"
                Write-TSLog -End
                Send-AuditEmail -smtpServer $SMTPServerEnd -port $PortEnd -username $UserNameEnd `
                    -body $script:Logs -Function $FunctionEnd -FunctionApp $FunctionAppEnd -token $ApiTokenEnd -from $FromEnd -to $ToEnd -attachmentfiles ($ZipEnd).Split(" ") -ssl
                Remove-Item -Path $AttachmentFolderPathEnd -Recurse -Force -ErrorAction Stop
            }
            elseif ($WinSCPEnd) {
                Write-TSLog "Account: $UserNameEnd,"
                Write-TSLog "SENDING SFTP to: $FTPHostEnd,"
                Write-TSLog "For SshHostKeyFingerprint: "
                Write-TSLog "Files: $ZipEnd"
                Write-TSLog $SshHostKeyFingerprintEnd
                Submit-FTPUpload -FTPUserName $UserNameEnd -Password $Password `
                    -FTPHostName $FTPHostEnd -LocalFilePath ($ZipEnd).Split(" ") -SshHostKeyFingerprint $SshHostKeyFingerprintEnd -RemoteFTPPath $RemotePathEnd -ErrorVariable SubmitFTPErr
                if ($?) {
                    Write-TSLog  "The ADDSAuditTask archive has been uploaded to ftp."
                    Write-TSLog -End
                    Write-TSLog -LogOutputPath $LogOutputPath
                }
                else {
                    Write-TSLog -LogError $SubmitFTPErr
                }
            }
            elseif ($LocalDiskEnd) {
                #Confirm output path to console.
                Write-TSLog  "The ADDSAuditTask archive has been saved to: "
                Write-TSLog  "$ZipEnd"
                Write-TSLog -End
                Write-TSLog -LogOutputPath $LogOutputPath
            }
        }
    }
}

