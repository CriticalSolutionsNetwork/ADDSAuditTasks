function Send-AuditEmail {
    <#
    .SYNOPSIS
    This is a sample Private function only visible within the module. It uses Send-MailkitMessage
    To send email messages.
    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
    Send-AuditEmail -smtpServer $SMTPServer -port $Port -username $Username -Function $Function -FunctionApp $FunctionApp -token $ApiToken -from $from -to $to -attachmentfilePath "$FilePath" -ssl
    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.
    #>
    param (
        [string]$smtpServer,
        [int]$port,
        [string]$username,
        [switch]$ssl,
        [string]$from,
        [string]$to,
        [string]$subject = "$($script:MyInvocation.MyCommand.Name -replace '\..*') report ran for $($env:USERDNSDOMAIN).",
        [string[]]$attachmentfiles,
        [string]$body,
        [securestring]$pass,
        [string]$Function,
        [string]$FunctionApp,
        [string]$token
    )
    Import-Module Send-MailKitMessage
    # Recipient
    $RecipientList = [MimeKit.InternetAddressList]::new()
    $RecipientList.Add([MimeKit.InternetAddress]$to)
    # Attachment
    $AttachmentList = [System.Collections.Generic.List[string]]::new()
    foreach ($currentItem in $attachmentfiles) {
        $AttachmentList.Add("$currentItem")
    }
    # From
    $from = [MimeKit.MailboxAddress]$from
    # Mail Account variable
    $User = $username
    if ($pass) {
        # Set Credential to $Password parameter input.
        $Credential = `
            [System.Management.Automation.PSCredential]::new($User, $pass)
    }
    elseif ($FunctionApp) {
        $url = "https://$($FunctionApp).azurewebsites.net/api/$($Function)"
        # Retrieve credentials from function app url into a SecureString.
        $a, $b = (Invoke-RestMethod $url -Headers @{ 'x-functions-key' = "$token" }).split(',')
        $Credential = `
            [System.Management.Automation.PSCredential]::new($User, (ConvertTo-SecureString -String $a -Key $b.split(' ')) )
    }
    # Create Parameter hashtable
    $Parameters = @{
        "UseSecureConnectionIfAvailable" = $ssl
        "Credential"                     = $Credential
        "SMTPServer"                     = $SMTPServer
        "Port"                           = $Port
        "From"                           = $From
        "RecipientList"                  = $RecipientList
        "Subject"                        = $subject
        "TextBody"                       = $body
        "AttachmentList"                 = $AttachmentList
    }
    Send-MailKitMessage @Parameters
    Clear-Variable -Name "a", "b", "Credential", "token" -Scope Local -ErrorAction SilentlyContinue
}