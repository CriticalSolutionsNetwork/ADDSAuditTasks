Import-Module .\output\ADDSAuditTasks\*\*.psd1
.\ModdedModules\psDoc-master\src\psDoc.ps1 -moduleName ADDSAuditTasks -outputDir docs -template ".\ModdedModules\psDoc-master\src\out-html-template.ps1"
.\ModdedModules\psDoc-master\src\psDoc.ps1 -moduleName ADDSAuditTasks -outputDir ".\" -template ".\ModdedModules\psDoc-master\src\out-markdown-template.ps1" -fileName .\README.md