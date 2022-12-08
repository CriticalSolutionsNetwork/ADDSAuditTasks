class ADAuditAccount {
    [string]$UserName
    [string]$FirstName
    [string]$LastName
    [string]$Name
    [string]$UPN
    [string]$LastSignIn
    [string]$Enabled
    [string]$LastSeen
    [string]$OrgUnit
    [string]$Title
    [string]$Manager
    [string]$Department
    [bool]$AccessRequired
    [bool]$NeedMailbox
    # Constructor 1
    ADAuditAccount([string]$UserName) {
        $this.UserName = $UserName
        $this.AccessRequired = $false
        $this.NeedMailBox = $false
    }
    ADAuditAccount(
        [string]$UserName,
        [string]$FirstName,
        [string]$LastName,
        [string]$Name,
        [string]$UPN,
        [string]$LastSignIn,
        [string]$Enabled,
        [string]$LastSeen,
        [string]$OrgUnit,
        [string]$Title,
        [string]$Manager,
        [string]$Department,
        [bool]$AccessRequired,
        [bool]$NeedMailbox
    ) {
        $this.UserName = $UserName
        $this.FirstName = $FirstName
        $this.LastName = $LastName
        $this.Name = $Name
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
        $this.AccessRequired = $AccessRequired
        $this.NeedMailbox = $NeedMailbox
        $this.Department = $Department
    }
}
class ADComputerAccount {
    [string]$ComputerName
    [string]$DNSHostName
    [string]$IPv4Address
    [string]$IPv6Address
    [string]$OperatingSystem
    [string]$LastLogon
    [string]$Created
    [string]$Modified
    [string]$Description
    [string]$OrgUnit
    [string]$KerberosEncryptionType
    [string]$SPNs
    [string]$GroupMemberships #Computername for Group Membership Search
    [string]$LastSeen
    # Constructor 1
    ADComputerAccount(
        [string]$ComputerName,
        [string]$DNSHostName,
        [string]$IPv4Address,
        [string]$IPv6Address,
        [string]$OperatingSystem,
        [long]$LastLogon,
        [datetime]$Created,
        [string]$Modified,
        [string]$Description,
        [string]$OrgUnit,
        [Microsoft.ActiveDirectory.Management.ADPropertyValueCollection]$KerberosEncryptionType,
        [Microsoft.ActiveDirectory.Management.ADPropertyValueCollection]$SPNs,
        [string]$GroupMemberships,
        [long]$LastSeen
    ) {
        #Begin Contructor 1
        $this.ComputerName = $ComputerName
        $this.DNSHostName = $DNSHostName
        $this.IPv4Address = $IPv4Address
        $this.IPv6Address = $IPv6Address
        $this.OperatingSystem = $OperatingSystem
        $this.LastLogon = ([DateTime]::FromFileTime($LastLogon))
        $this.Created = $Created
        $this.Modified = $Modified
        $this.Description = $Description
        $this.OrgUnit = $(($OrgUnit -replace '^.*?,(?=[A-Z]{2}=)') -replace ",", ">")
        $this.KerberosEncryptionType = $(($KerberosEncryptionType | Select-Object -ExpandProperty $_) -replace ", ", " | ")
        $this.SPNs = $($SPNs -join " | " )
        $this.GroupMemberships = $(Get-ADComputerGroupMemberof -SamAccountName $GroupMemberships)
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
    }# End Constuctor 1
}