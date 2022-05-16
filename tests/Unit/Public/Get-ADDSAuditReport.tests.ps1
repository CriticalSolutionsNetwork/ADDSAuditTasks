$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Get-Something {

        Context 'Return values' {
            BeforeEach {
                $return = Get-Something -Data 'value'
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            }

        }

        Context 'Pipeline' {
            It 'Accepts values from the pipeline by value' {
                $return = 'value1', 'value2' | Get-Something

                $return[0] | Should -Be 'value1'
                $return[1] | Should -Be 'value2'
            }

            It 'Accepts value from the pipeline by property name' {
                $return = 'value1', 'value2' | ForEach-Object {
                    [PSCustomObject]@{
                        Data = $_
                        OtherProperty = 'other'
                    }
                } | Get-Something


                $return[0] | Should -Be 'value1'
                $return[1] | Should -Be 'value2'
            }
        }

        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Get-Something).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Get-Something -Data 'value' -WhatIf } | Should -Not -Throw
            }


        }
    }
}

