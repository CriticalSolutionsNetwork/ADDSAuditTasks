function Write-TSLog {
    <#
    .SYNOPSIS
    This is a sample Private function only visible within the module.
    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
    $null = Write-Logs -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([string])]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [String[]]$LogString,
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'Begin',
            Position = 0
        )]
        [switch]$Begin,
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'End',
            Position = 0
        )]
        [switch]$End,
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'LogError',
            Position = 0
        )]
        [switch]$LogError,
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'LogErrorEnd',
            Position = 0
        )]
        [switch]$LogErrorEnd,
        [Parameter(ParameterSetName = 'LogError', Position = 1)]
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'LogErrorEnd',
            Position = 1
        )]
        [System.Management.Automation.ErrorRecord[]]$LogErrorVar,
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = 'LogToFile',
            Position = 0
        )]
        [string]$LogOutputPath
    )
    process {
        # Change the ErrorActionPreference to 'Stop'
        $ErrorActionPreference = "SilentlyContinue"
        $ModuleName = $script:MyInvocation.MyCommand.Name.ToString() -replace '\..*'
        $ModuleVer = $MyInvocation.MyCommand.Version.ToString()
        $ErrorActionPreference = "Continue"
        if ($Begin) {
            Clear-Variable Logs -Scope Script -ErrorAction SilentlyContinue
            $TSLogString = "$(Get-TimeStamp) Begin Log for Module version $ModuleVer of Module: $ModuleName `n"
            $script:Logs += $TSLogString
        }
        elseif ($End) {
            $TSLogString = "$(Get-TimeStamp) End Log for Module version $ModuleVer of Module: $ModuleName `n"
            $script:Logs += $TSLogString
            Write-Output $script:Logs
        }
        elseif ($LogError) {
            if ($LogErrorVar) {
                #$TSLogString += "$(($LogErrorVar.Exception).ToString()) `n"
                $TSLogString += "$($global:Error[0].Exception.ErrorRecord) `n"
            }
            else {
                $TSLogString = "$($global:Error[0].Exception.ErrorRecord) `n"
            }
            $script:Logs += $TSLogString
        }
        elseif ($LogErrorEnd) {
            if ($LogErrorVar) {
                $TSLogString = "$(Get-TimeStamp) An Error Occured. The Error Variable was: `n"
                $script:Logs += $TSLogString
                $TSLogString += "$($LogErrorVar.Exception.ErrorRecord)" + "Error`n"
                $script:Logs += $TSLogString
                $TSLogString = "$(Get-TimeStamp) End Log for Module version $ModuleVer of Module: $ModuleName `n"
                $script:Logs += $TSLogString
                $TSLogString = "$(Get-TimeStamp) ErrorLog output to 'C:\temp\ADDSAuditTasksErrors.log' `n"
                $script:Logs += $TSLogString
            }
            else {
                $TSLogString = "$(Get-TimeStamp) An Error Occured. The exception was: `n"
                $script:Logs += $TSLogString
                $TSLogString = "$($global:Error[0].Exception.ErrorRecord) `n"
                $script:Logs += $TSLogString
                $TSLogString = "$(Get-TimeStamp) ErrorLog output to 'C:\temp\ADDSAuditTasksErrors.log' `n"
                $script:Logs += $TSLogString
            }
            Write-Output $script:Logs
            $script:Logs | Out-File "C:\temp\ADDSAuditTasksErrors.log" -Encoding utf8 -Append -Force
        }
        elseif ($LogOutputPath) {
            $script:Logs | Out-File $LogOutputPath -Encoding utf8 -Append -Force
            Write-Output "Logs saved to $LogOutputPath"
        }
        else {
            $TSLogString = "$(Get-TimeStamp) $logstring `n"
            $script:Logs += $TSLogString
        }
    }
}