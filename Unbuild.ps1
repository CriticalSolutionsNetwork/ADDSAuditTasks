Remove-Module ADDSAuditTasks
Remove-Item .\output\ADDSAuditTasks -Recurse
Remove-Item ".\output\ADDSAuditTasks.*.nupkg"
Remove-Item .\output\ReleaseNotes.md
Remove-Item .\output\CHANGELOG.md
.\build.ps1 -tasks build -CodeCoverageThreshold 0
Remove-Item C:\temp\ADDS* -Recurse

.\build.ps1 -ResolveDependency -tasks noop

.\build.ps1 -tasks build -CodeCoverageThreshold 0





.\build.ps1 -tasks build,pack,publish -CodeCoverageThreshold 0

