function Format-HRRoster {
    <#
    .SYNOPSIS
        Takes CSV input as "LastName<space>FirstName" and flips it to "Firstname<space>Lastname"
    .DESCRIPTION
        Takes a CSV that was formatted as 'LastName, FirstName' with the comma and space removed, to 'FirstName Lastname'.
    .NOTES
        This function depends on the name column in the employee roster name column, to have been formatted in excel using a find and replace to replace ", " with " ".
        In other words: The file needs to have "comma space" replaces with "space" in the name column to be easily compared to ADUser output.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Format-HRRoster -HRRosterCSV "C:\temp\HRRosterNameColumnFormattedLastNameSpaceFirstname.csv" -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'Enter the full path to the csv file',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]$HRRosterCSV,
        [Parameter(
            HelpMessage = 'Enter the folder path to the new csv file',
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )][string]$AttachmentFolder = "C:\temp\ActiveUsersHR"
    )
    $AttachmentFolderPathCheck = Test-Path -Path $AttachmentFolder
    If (!($AttachmentFolderPathCheck)) {
        # If not present then create the dir
        New-Item -ItemType Directory $AttachmentFolder -Force -ErrorAction Stop
    }
    $HRCSV = Import-Csv $HRRosterCSV
    $Export = @()
    foreach ($user in $HRCSV) {
        $a, $b = ($user.Name).split(' ')
        New-Object -TypeName PSCustomObject -Property @{
            NewName = "$b $a"
        } -OutVariable PSObject | Out-Null
        $Export += $PSObject
    }
    $Export | Export-Csv "$($home)\Documents\$((Get-Date).ToString("yyyy.MM.dd hh.mm tt")).HRRosterFirstNameSpaceLastName.csv" -NoTypeInformation
}