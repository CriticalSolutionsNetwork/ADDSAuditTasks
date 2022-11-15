function Get-ADGroupMemberof {
    [CmdletBinding()]
    param (
        [string]$SamAccountName
    )
    process {
        $GroupStringArray = ((Get-ADUser -Identity $SamAccountName -Properties memberof).memberof | Get-ADGroup | Select-Object name | Sort-Object name).name
        $GroupString = $GroupStringArray -join " | "
        return $GroupString
    }
}