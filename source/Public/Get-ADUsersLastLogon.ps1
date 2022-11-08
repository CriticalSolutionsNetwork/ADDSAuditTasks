function Get-ADUsersLastLogon {
    <#
    .SYNOPSIS
    Takes SamAccountName as input to retrieve most recent LastLogon from all DC's.
    .DESCRIPTION
    Takes SamAccountName as input to retrieve most recent LastLogon from all DC's and output as DateTime.
    .EXAMPLE
    Get-ADUsersLastLogon -SamAccountName "UserName"
    .PARAMETER SamAccountName
    The SamAccountName of the user being checked for LastLogon.
    #>
    [CmdletBinding(HelpURI = "https://criticalsolutionsnetwork.github.io/ADDSAuditTasks/#Get-ADUsersLastLogon")]
    [OutputType([datetime])]
    param (
        [Alias("Identity", "UserName", "Account")]
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Enter the SamAccountName',
            ValueFromPipeline = $true
        )]
        $SamAccountName
    )
    process {
        $dcs = Get-ADDomainController -Filter { Name -like "*" }
        $user = Get-ADUser -Identity $SamAccountName
        $time = 0
        $dt = @()
        foreach ($dc in $dcs) {
            $hostname = $dc.HostName
            $usertime = $user | Get-ADObject -Server $hostname -Properties lastLogon
            if ($usertime.LastLogon -gt $time) {
                $time = $usertime.LastLogon
            }
            $dt += [DateTime]::FromFileTime($time)
        }
        return ($dt | Sort-Object -Descending)[0]
    }
}