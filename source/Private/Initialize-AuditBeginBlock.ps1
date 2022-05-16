function Initialize-AuditBeginBlock {
<#
    .SYNOPSIS
    This is a sample Private function only visible within the module.

    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.

    .EXAMPLE
    $null = Initialize-AuditBeginBlock -PrivateData 'NOTHING TO SEE HERE'

    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.

    #>
    [cmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(
            ValueFromPipeline = $true
        )]
        [string]$AttachmentFolderPathBegin = "C:\temp\ADDSAuditTasks",
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$ScriptFunctionName,
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]$SendEmailMessageBegin,
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]$CleanBegin,
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]$WinSCPBegin

    )


    process {
        # Create Directory Path
        $AttachmentFolderPathCheck = Test-Path -Path $AttachmentFolderPathBegin
        If (!($AttachmentFolderPathCheck)) {
            Try {
                # If not present then create the dir
                New-Item -ItemType Directory $AttachmentFolderPathBegin -Force -ErrorAction Stop
            }
            Catch {
                Write-TSLog -Begin
                Write-TSLog "Directory: $AttachmentFolderPathBegin was not created."
                Write-TSLog -LogErrorEnd
                throw
            }
        }
        # Begin Logging to $script:Logs
        Write-TSLog -Begin
        $script:LogOutputPath = "$AttachmentFolderPathBegin\$((Get-Date).ToString('yyyy-MM-dd_hh.mm.ss'))_$($ScriptFunctionName)_$($env:USERDNSDOMAIN)_ADDSAuditlog.log"
        Write-TSLog "Log output path: $LogOutputPath"
        # If not Clean
        if (!($CleanBegin)) {
            # Import Active Directory Module
            $module = Get-Module -Name ActiveDirectory -ListAvailable
            if (-not $module) {
                Add-WindowsFeature RSAT-AD-PowerShell -IncludeAllSubFeature -Verbose -ErrorAction Stop
            }
            try {
                Import-Module "activedirectory" -Global -ErrorAction Stop
            }
            catch {
                Write-TSLog "The Module Was not installed. Use `"Add-WindowsFeature RSAT-AD-PowerShell`" or install using server manager under `"Role Administration Tools>AD DS and AD LDS Tools>Active Directory module for Windows Powershell`"."
                Write-TSLog -LogErrorEnd
                throw
            }
            if ($SendEmailMessageBegin) {
                # Install / Import required modules.
                $module = Get-Module -Name Send-MailKitMessage -ListAvailable
                if (-not $module) {
                    Install-Module -Name Send-MailKitMessage -AllowPrerelease -Scope AllUsers -Force
                }
                try {
                    Import-Module "Send-MailKitMessage" -Global -ErrorAction Stop
                }
                catch {
                    # End run and log to file.
                    Write-TSLog "The Module Was not installed. Use `"Save-Module -Name Send-MailKitMessage -AllowPrerelease -Path C:\temp`" on another Windows Machine."
                    Write-TSLog -End
                    throw
                }
            }
            elseif ($WinSCPBegin) {
                $module = Get-Module -Name WinSCP -ListAvailable
                if (-not $module) {
                    Install-Module WinSCP -Scope CurrentUser
                }
                try {
                    Import-Module WinSCP -Global -ErrorAction Stop
                }
                catch {
                    Write-TSLog "The Module Was not installed. Export WinSCP using: `"Save-Module WinSCP -Path <Path>`" and import to this machine."
                    Write-TSLog -LogErrorEnd
                    throw
                }
            }
        }
        # If SendMailMessage

        return $LogOutputPath
    }
}

