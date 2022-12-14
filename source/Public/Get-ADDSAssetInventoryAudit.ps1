function Get-ADDSAssetInventoryAudit {
    <#
    .SYNOPSIS
        Active Directory Server and Workstation Audit with Report export option (Can also be piped to CSV if Report isn't specified).
    .DESCRIPTION
        Audit's Active Directory taking "days" as the input for how far back to check for a device's last sign in.
        Output can be piped to a csv manually, or automatically to C:\temp or a specified path in "DirPath" using
        the -Report Switch.
        Use the Tab key for the -HostType Parameter.
    .EXAMPLE
        PS C:\> Get-ADDSInventoryAudit -HostType WindowsServers
    .EXAMPLE
        PS C:\> Get-ADDSInventoryAudit -HostType WindowsWorkstations -DirPath "C:\Temp\" -Report
    .EXAMPLE
        PS C:\> Get-ADDSInventoryAudit -HostType WindowsServers -DirPath "C:\Temp\" -Report
    .EXAMPLE
        PS C:\> Get-ADDSInventoryAudit -OSType "2008" -DirPath "C:\Temp\" -Report
    .PARAMETER HostType
        Select from Windows Server or Windows 10 plus.
    .PARAMETER OSType
        Search an OS String. Wildcards can be omitted as the function will automatically add the
        wildcard characters before searching.
    .PARAMETER DirPath
        The path to the -Report output directory.
    .PARAMETER Report
        Add report output as csv to DirPath directory.
    .PARAMETER AttachmentFolderPath
        Default path is C:\temp\ADDSDepartedUsersAuditLogs.
        This is the folder where attachments are going to be saved.
    .NOTES
        Outputs to C:\temp by default. For help type: help Get-ADDSAssetInventoryAudit -ShowWindow
    #>
    [CmdletBinding(DefaultParameterSetName = 'HostType' , HelpURI = "https://criticalsolutionsnetwork.github.io/ADDSAuditTasks/#Get-ADDSInventoryAudit")]
    param (
        [ValidateSet("WindowsServers","WindowsWorkstations","Non-Windows")]
        [Parameter(
            ParameterSetName = 'HostType',
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Name filter attached to users.',
            ValueFromPipeline = $true
        )]
        [string]$HostType,
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'OSType',
            Position = 0,
            HelpMessage = 'Enter a Specific OS Name or first few letters of the OS to Search for in ActiveDirectory',
            ValueFromPipeline = $true
        )]
        [string]$OSType,
        [Parameter(
            Position = 1,
            HelpMessage = 'How many days back to consider an AD Computer last sign in as active',
            ValueFromPipelineByPropertyName = $true
        )]
        [int]$DaystoConsiderAHostInactive = 90,
        [Parameter(
            Position = 2,
            HelpMessage = 'Switch to output to directory specified in DirPath parameter',
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]$Report,
        [Parameter(
            Position = 3,
            HelpMessage = 'Enter the working directory you wish the report to save to. Default creates C:\temp'
        )]
        [string]$DirPath = 'C:\temp\ADDSAssetInventoryAudit',
        [Parameter(
            HelpMessage = 'Search for Enabled or Disabled hosts',
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]$Enabled = $true
    )
    begin {
        $ScriptFunctionName = $MyInvocation.MyCommand.Name -replace '\..*'
        $time = (Get-Date).Adddays( - ($DaystoConsiderAHostInactive))
        $module = Get-Module -Name ActiveDirectory -ListAvailable
        if (-not $module) {
            [ValidateSet("Y", "N")]$choice = Read-Host "Install Active Directory Module? Y or N ?"
            if (($Choice -eq "Y")) {
                Add-WindowsFeature RSAT-AD-PowerShell -IncludeAllSubFeature -Verbose -ErrorAction Stop
            }
            else {
                throw "You must install the Active Directory module to continue"
            }
        }
        try {
            Import-Module "activedirectory" -Global -ErrorAction Stop | Out-Null
        }
        catch {
            throw $Error[0].Error.Exception
        }
        $AttachmentFolderPathCheck = Test-Path -Path $DirPath
        If (!($AttachmentFolderPathCheck)) {
            Try {
                # If not present then create the dir
                New-Item -ItemType Directory $DirPath -Force -ErrorAction Stop | Out-Null
            }
            Catch {
                throw "Unable to create output directory $($DirPath)"
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'HostType' {
                if ($HostType -eq "WindowsWorkstations") {
                    $FileSuffix = "Workstations"
                    Write-Verbose "###############################################"
                    Write-Verbose "Searching Windows Workstations......"
                    Start-Sleep 2
                }
                elseif ($HostType -eq "Non-Windows") {
                    $POSIX = $true
                    $FileSuffix = "Non-Windows"
                    Write-Verbose "###############################################"
                    Write-Verbose "Searching Non-Windows Computer Objects......"
                    Start-Sleep 2
                }
                elseif ($HostType -eq "WindowsServers") {
                    $OSPicked = "*Server*"
                    $FileSuffix = "Servers"
                    Write-Verbose "###############################################"
                    Write-Verbose "Searching Windows Servers......"
                    Start-Sleep 2
                }
            }
            'OSType' {
                $OSPicked = '*' + $OSType + '*'
                $FileSuffix = $OSType
                Write-Verbose "###############################################"
                Write-Verbose "Searching OSType $OsType......"
                Start-Sleep 2
            }
        }
        $propsArray = `
            "Created", `
            "Description", `
            "DNSHostName", `
            "Enabled", `
            "IPv4Address", `
            "IPv6Address", `
            "KerberosEncryptionType", `
            "lastLogonTimestamp", `
            "Name", `
            "OperatingSystem", `
            "DistinguishedName", `
            "servicePrincipalName", `
            "whenChanged"
    } # End Begin
    process {
        Write-Verbose "Searching computers that have logged in within the last $DaystoConsiderAHostInactive days."
        Write-Verbose "Where property Enabled = $Enabled"

        Start-Sleep 2
        if ($OSPicked) {
            Write-Verbose "And Operating System is like: $OSPicked."
            $ActiveComputers = (Get-ADComputer -Filter { (LastLogonTimeStamp -gt $time) -and (Enabled -eq $Enabled) -and (OperatingSystem -like $OSPicked) }).Name
        }
        elseif ($POSIX) {
            Write-Verbose "And Operating System is: Non-Windows(POSIX)."
            $ActiveComputers = (Get-ADComputer -Filter {OperatingSystem -notlike "*windows*" -and OperatingSystem -notlike "*server*" -and Enabled -eq $Enabled -and lastlogontimestamp -gt $time} ).Name
        }
        else{
            Write-Verbose "And Operating System is -like `"*windows*`" -and Operating System -notlike `"*server*`" (Workstations)."
            $ActiveComputers = (Get-ADComputer -Filter {OperatingSystem -like "*windows*" -and OperatingSystem -notlike "*server*" -and Enabled -eq $Enabled -and lastlogontimestamp -gt $time} ).Name
        }

        $ADComps = @()
        foreach ($comp in $ActiveComputers) {
            Get-ADComputer -Identity $comp -Properties $propsArray | Select-Object $propsArray -OutVariable ADComp | Out-Null
            $ADComps += $ADComp
        } # End Foreach
        $ADCompExport = @()
        foreach ($item in $ADComps) {
            $ADCompExport += [ADComputerAccount]::new(
                $item.Name,
                $item.DNSHostName,
                $item.Enabled,
                $item.IPv4Address,
                $item.IPv6Address,
                $item.OperatingSystem,
                $item.lastLogonTimestamp,
                $item.Created,
                $item.whenChanged,
                $item.Description,
                $item.DistinguishedName,
                $item.KerberosEncryptionType,
                $item.servicePrincipalName,
                $item.Name,
                $item.lastLogonTimestamp
            ) # End New [ADComputerAccount] object
        }# End foreach Item in ADComps
        $Export = @()
        foreach ($Comp in $ADCompExport) {
            $hash = [ordered]@{
                DNSHostName            = $Comp.DNSHostName
                ComputerName           = $Comp.ComputerName
                Enabled                = $Comp.Enabled
                IPv4Address            = $Comp.IPv4Address
                IPv6Address            = $Comp.IPv6Address
                OperatingSystem        = $Comp.OperatingSystem
                LastLogon              = $Comp.LastLogon
                LastSeen               = $Comp.LastSeen
                Created                = $Comp.Created
                Modified               = $Comp.Modified
                Description            = $Comp.Description
                GroupMemberships       = $Comp.GroupMemberships
                OrgUnit                = $Comp.OrgUnit
                KerberosEncryptionType = $Comp.KerberosEncryptionType
                SPNs                   = $Comp.SPNs
            }
            New-Object -TypeName PSCustomObject -Property $hash -OutVariable PSObject | Out-Null
            $Export += $PSObject
        } # End foreach Comp in ADCompExport
    } # End Process
    end {
        if ($Report) {
            # Add Datetime to filename
            $csvFileName = "$DirPath\$((Get-Date).ToString('yyyy-MM-dd_hh.mm.ss'))_$($env:USERDNSDOMAIN)_$($ScriptFunctionName)_$($FileSuffix)"
            # Create FileNames
            $csv = "$csvFileName.csv"
            $zip = "$csvFileName.zip"
            $Export | Export-Csv $csv -NoTypeInformation
            Compress-Archive -Path $csv -DestinationPath $zip
            Remove-Item $csv -Force
            Write-Verbose "Archive saved to: "
            Write-Verbose "Directory: $DirPath"
            Write-Verbose "FilePath: $zip"
        }
        else {
            Write-Verbose "Returning output object."
            Start-Sleep 2
            return $Export
        }
    } # End End
}