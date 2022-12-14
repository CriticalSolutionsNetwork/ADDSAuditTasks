# Changelog for ADDSAuditTasks

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.9.9] - 2022-12-13

### Added

- More generic call for workstations in asset inventory.
- Additional call for Non-Windows Machines using POSIX.

## [1.9.8] - 2022-12-11

### Added

- Reporting QoL improvements to Asset inventory
- Added zip and directory to Report Output
- Option to only provide output to console.
- Check for Active Directory Module
- Option to search enabled or disabled hosts in `Get-ADDSAssetInventoryAudit`
- Verbose Output to assist with identifying output location.

### Fixed

- Fixed `Get-ADDSActiveAccountAudit` so that output is piped to `$null`

## [1.9.7] - 2022-12-09

### Fixed

- Comment-Based help

## [1.9.6] - 2022-12-08

### Added

- Feature Added: Function `ADDSAssetInventoryAudit` with reporting.

## [1.9.5] - 2022-11-29

### Added

- Added telnet to default ports to scan.
- Added OUI lookup.
- Added MACID lookup

### Fixed

- Fixed `[ADAuditUser]` Class Department property.

## [1.9.4] - 2022-11-17

### Fixed

- Formatting in various modules. No function changes.

### Added

- Added options to scan specific hosts, subnets, IPs or FQDNs.

## [1.9.2] - 2022-11-08

### Fixed

- Fixed ordered hashtable in departed users audit.
- Fixed service principal name output.

## [1.9.0] - 2022-11-08

### Fixed

- Fixed line 36 of `Switch-SurnameWithGivenName` to `$HRCSV = Import-Csv $RosterCSV`

## [1.8.0] - 2022-11-08

### Removed

- Removed function `Format-HRRoster` to public functions to format roster for compare.

### Added

- Renamed function `Format-HRRoster` for clarity to `Switch-SurnameWithGivenName`.
- Added `Get-NetworkScan` public function to scan subnets for hosts and open ports.

## [1.6.1] - 2022-07-21

### Added

- Added Name parameter to `Get-ADDSActiveUsersAudit` and `Get-ADDSDepartedUsersAudit`

## [1.5.4] - 2022-07-21

### Fixed

- Fixed Log output of ADDSActiveUserAudit function.
- Fixed Release

## [1.5.0] - 2022-05-16

### Fixed

- Fixed Timestamp unassigned variable.
- Fixed unassigned time variables in public functions.

## [1.4.0] - 2022-05-15

### Fixed

- Fixed output for export in Privileged Account Audit.

## [1.3.0] - 2022-05-15

### Added

- Added FTP submission error handling.
- Added Class `[ADAuditAccount]`

## [1.2.0] - 2022-05-14

### Added

- Added Upload via WinSCP using private function `Submit-FTPUpload`

## [1.1.0] - 2022-05-11

### Added

- Added proper attachment handling with multiple files.

## [1.1.0-preview0001] - 2022-05-11

### Added

- Added proper attachment handling with multiple files.

## [0.7.0] - 2022-05-11

### Added

- Added fixes to zip handling.

## [0.6.5] - 2022-05-11

### Added

- Added extended rights to privileged account audit.
- Added private function `Get-ADExtendedRight`

### Changed

- Changed how extended user rights are obtained.
- Changed CSV and ZIP files names to sort by date.

### Removed

- Removed old method of retrieving AD privileged audit output.

### Fixed

- Fixed `Get-ADDSDepartedUsersAccountAudit` Not requiring wildcard.
- Log output for csv export.
- Log output filename for log file.

### Security

- In case of vulnerabilities.

## [0.6.4] - 2022-05-09

### Fixed

- Fixed unused parameters in public functions.
