# Changelog for ADDSAuditTasks

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
