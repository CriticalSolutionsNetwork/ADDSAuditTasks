function Get-ADComputerGroupMemberof {
    [CmdletBinding()]
    param (
        [string]$SamAccountName
    )
    process {
        $GroupStringArray = ((Get-ADComputer -Identity $SamAccountName -Properties memberof).memberof | Get-ADGroup | Select-Object name | Sort-Object name).name
        $GroupString = $GroupStringArray -join " | "
        return $GroupString
    }
}