function Export-AuditCSVtoZip {
    [CmdletBinding()]
    param (
        [PSCustomObject[]]$Exported,
        [ADAuditAccount[]]$ExportObject,
        [string]$CSVName,
        [string]$ZipName
    )
    process {
        if ($Exported) {
            [PSCustomObject[]]$ExportObject = $Exported
            $membertype = "NoteProperty"
        }
        else {
            $membertype = "Property"
        }

        Write-TSLog "The $($script:MyInvocation.MyCommand.Name -replace '\..*') Export was successful. There are $($ExportObject.Count) objects listed with the following properties: "
            ($ExportObject | Get-Member -MemberType $membertype ).Name | Write-TSLog
        Write-TSLog "Exporting CSV to path: $CSVName"
        try {
            $ExportObject | Export-Csv -Path $CSVName -NoTypeInformation -ErrorVariable ExportErr -ErrorAction Stop
        }
        catch {
            Write-TSLog "The CSV export failed with error: "
            write-tslog "Error" + $ExportErr.Exception.ErrorRecord
        }
        Write-TSLog "Compressing file: $CSVName"
        Write-TSLog "to destination zip file: $ZipName"
        try {
            Compress-Archive -Path $CSVName -DestinationPath $ZipName -ErrorVariable ZipErr -ErrorAction Stop
        }
        catch {
            Write-TSLog "Failed compressing file: "
            Write-TSLog $CSVName
            Write-TSLog "to destination zip file: "
            Write-TSLog $ZipName
            Write-TSLog "with error: "
            Write-TSLog -End
            write-tslog $ZipErr.Exception.ErrorRecord
        }
        Write-TSLog "Removing CSV file: "
        Write-TSLog $CSVName
        Write-TSLog "from the file system."
        try {
            Remove-Item $CSVName -Force -ErrorVariable CSVDeleteErr -ErrorAction Stop
        }
        catch {
            Write-TSLog "Failed to remove CSV file: $CSVName"
            Write-TSLog -LogError -LogErrorVar $CSVDeleteErr.Exception.ErrorRecord
        }
        Write-TSLog "Removed CSV file: "
        Write-TSLog $CSVName
        Write-TSLog "from the file system."

    }
}