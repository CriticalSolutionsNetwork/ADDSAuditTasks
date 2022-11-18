class ADAuditAccount {
    [string]$UserName
    [string]$FirstName
    [string]$LastName
    [string]$UPN
    [string]$LastSignIn
    [string]$Enabled
    [string]$LastSeen
    [string]$OrgUnit
    [string]$Title
    [string]$Manager
    [string]$Department
    # Constructor 1
    ADAuditAccount(
        [string]$UserName,
        [string]$FirstName,
        [string]$LastName,
        [string]$UPN,
        [string]$LastSignIn,
        [string]$Enabled,
        [string]$LastSeen,
        [string]$OrgUnit,
        [string]$Title,
        [string]$Manager,
        [string]$Department,
        [string]$AccessRequired,
        [string]$NeedMailbox
    ) {
        $this.UserName = $UserName
        $this.FirstName = $FirstName
        $this.LastName = $LastName
        $this.UPN = $UPN
        $this.LastSignIn = ([DateTime]::FromFileTime($LastSignIn))
        $this.Enabled = $Enabled
        $this.LastSeen = $(
            switch (([DateTime]::FromFileTime($LastSeen))) {
                # Over 90 Days
                { ($_ -lt (Get-Date).Adddays( - (90))) } { '3+ months'; break }
                # Over 60 Days
                { ($_ -lt (Get-Date).Adddays( - (60))) } { '2+ months'; break }
                # Over 90 Days
                { ($_ -lt (Get-Date).Adddays( - (30))) } { '1+ month'; break }
                default { 'Recently' }
            } # End Switch
        ) # End LastSeen
        $this.OrgUnit = $OrgUnit -replace '^.*?,(?=[A-Z]{2}=)'
        $this.Title = $Title
        $this.Manager = $(
            switch ($Manager) {
                # Over 90 Days
                { if ($_) { return $true } } { "$((Get-ADUser -Identity $Manager).Name)"; break }
                # Over 60 Days
                default { 'NotFound' }
            }
        ) # End Manager
    }
}

# End Class ADExport

<#
enum DeviceType {
    Undefined = 0
    Compute = 1
    Storage = 2
    Networking = 4
    Communications = 8
    Power = 16
    Rack = 32
}
[int]$DaysInactive = '90'
$time = (Get-Date).Adddays( - ($DaysInactive))
Get-aduser -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $true } -Properties `
    GivenName, Surname, Mail, UserPrincipalName, Title, `
    Description, Manager, lastlogontimestamp, samaccountname, DistinguishedName, Department -OutVariable Export
[ADAuditAccount]$ADDSAuditAccount = [ADAuditAccount]::new(
    $($Export[0].SamAccountName),
    $($Export[0].GivenName),
    $($Export[0].Surname),
    $($Export[0].UserPrincipalName),
    $($Export[0].LastLogonTimeStamp),
    $($Export[0].Enabled),
    $($Export[0].LastLogonTimeStamp),
    $($Export[0].DistinguishedName),
    $($Export[0].Title),
    $($Export[0].Manager),
    $($Export[0].Department),
    'False',
    'False'
)
$AuditArray = @()

foreach ($item in $Export) {
    $AuditArray += [ADAuditAccount]::new(
        $($item.SamAccountName),
        $($item.GivenName),
        $($item.Surname),
        $($item.UserPrincipalName),
        $($item.LastLogonTimeStamp),
        $($item.Enabled),
        $($item.LastLogonTimeStamp),
        $($item.DistinguishedName),
        $($item.Title),
        $($item.Manager),
        $($item.Department),
        'False',
        'False'
    )
}

$ADDSAuditAccount

Write-Output $ADDSExport
#>

# End Class ADExport

<#
enum DeviceType {
    Undefined = 0
    Compute = 1
    Storage = 2
    Networking = 4
    Communications = 8
    Power = 16
    Rack = 32
}
$Enabled = $true
[int]$DaysInactive = '90'
$time = (Get-Date).Adddays( - ($DaysInactive))
Get-aduser -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $true } -Properties `
    GivenName, Surname, Mail, UserPrincipalName, Title, `
    Description, Manager, lastlogontimestamp, samaccountname, DistinguishedName, Department -OutVariable Export
[ADAuditAccount]$ADDSAuditAccount = [ADAuditAccount]::new(
    $($Export[0].SamAccountName),
    $($Export[0].GivenName),
    $($Export[0].Surname),
    $($Export[0].UserPrincipalName),
    $($Export[0].LastLogonTimeStamp),
    $($Export[0].Enabled),
    $($Export[0].LastLogonTimeStamp),
    $($Export[0].DistinguishedName),
    $($Export[0].Title),
    $($Export[0].Manager),
    $($Export[0].Department),
    'False',
    'False'
)
$AuditArray = @()

foreach ($item in $Export) {
    $AuditArray += [ADAuditAccount]::new(
        $($item.SamAccountName),
        $($item.GivenName),
        $($item.Surname),
        $($item.UserPrincipalName),
        $($item.LastLogonTimeStamp),
        $($item.Enabled),
        $($item.LastLogonTimeStamp),
        $($item.DistinguishedName),
        $($item.Title),
        $($item.Manager),
        $($item.Department),
        'False',
        'False'
    )
}

$ADDSAuditAccount

Write-Output $ADDSExport
#>

            <#
            | Select-Object `
            @{N = 'UserName'; E = { $_.samaccountname } }, `
            @{N = 'FirstName'; E = { $_.GivenName } }, `
            @{N = 'LastName'; E = { $_.Surname } }, `
            @{N = 'UPN'; E = { $_.UserPrincipalName } }, `
            @{N = "Last Sign-in"; E = { ([DateTime]::FromFileTime($_.lastLogonTimestamp)) } }, `
                Enabled, `
            @{N = 'Last Seen?'; `
                    E = {
                    switch (([DateTime]::FromFileTime($_.lastLogonTimestamp))) {
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
                Title, `
                @{N = 'Manager'; E = { (Get-ADUser -Identity $_.manager).Name } }, `
                Department, "Access Required?", "Need Mailbox?" -OutVariable Export -ErrorVariable ExportErr | Out-Null
                #>