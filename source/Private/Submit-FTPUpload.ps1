function Submit-FTPUpload {
    [CmdletBinding()]
    param (
        [string]$FTPUserName,
        [securestring]$Password,
        # New-WinSCPSessionOption
        [string]$FTPHostName,
        [ValidateSet("Sftp", "SCP", "FTP", "Webdav", "s3")]
        # New-WinSCPSessionOption
        [string]$Protocol = "Sftp",
        [ValidateSet("None", "Implicit ", "Explicit")]
        # New-WinSCPSessionOption
        [string]$FTPSecure = "None",
        # New-WinSCPSessionOption
        #[int]$FTPPort = 0,
        # New-WinSCPSessionOption
        # Mandatory with SFTP/SCP
        [string[]]$SshHostKeyFingerprint,
        # New-WinSCPSessionOption
        #[string]$SshPrivateKeyPath,
        [string[]]$LocalFilePath,
        # Send-WinSCPItem
        # './remoteDirectory'
        [string]$RemoteFTPPath
    )
    process {
        # This script will run in the context of the user. Please be sure it's a local admin with cached credentials.
        # Required Modules
        Import-Module WinSCP
        # Capture credentials.
        $Credential = [System.Management.Automation.PSCredential]::new($FTPUserName, $Password)
        # Open the session using the SessionOptions object.
        $sessionOption = New-WinSCPSessionOption -Credential $Credential -HostName $FTPHostName -SshHostKeyFingerprint $SshHostKeyFingerprint -Protocol $Protocol -FtpSecure $FTPSecure
        # New-WinSCPSession sets the PSDefaultParameterValue of the WinSCPSession parameter for all other cmdlets to this WinSCP.Session object.
        # You can set it to a variable if you would like, but it is only necessary if you will have more then one session open at a time.
        $WinSCPSession = New-WinSCPSession -SessionOption $sessionOption
        if (!(Test-WinSCPPath -Path $RemoteFTPPath -WinSCPSession $WinSCPSession)) {
            New-WinSCPItem -Path $RemoteFTPPath -ItemType Directory -WinSCPSession $WinSCPSession
        }
        $sendvararray
        # Upload a file to the directory.
        $errorindex = 0
        foreach ($File in $LocalFilePath) {
            $sendvar = Send-WinSCPItem -Path $File -Destination $RemoteFTPPath -WinSCPSession $WinSCPSession -ErrorAction Stop -ErrorVariable SendWinSCPErr
            if ($sendvar.IsSuccess -eq $false) {
                write-tslog -LogErrorEnd -LogErrorVar $SendWinSCPErr
                $errorindex += 1
            }
        }
        if ($ErrorIndex -ne 0) {
            Write-Output "Error"
            throw 1
        }
        # Close and remove the session object.
        Remove-WinSCPSession -WinSCPSession $WinSCPSession
    }
}