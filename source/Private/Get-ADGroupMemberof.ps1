function Get-ADGroupMemberof {
    [CmdletBinding()]
    param (
        [string]$SamAccountName
    )
    process {
        $GroupStringArray = ((Get-ADuser -Identity $SamAccountName -Properties memberof).memberof | Get-ADGroup | Select-Object name | Sort-Object name).name
        $GroupString = $GroupStringArray -join " | "
        return $GroupString
    }
}