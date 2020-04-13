$ModuleManifestName = 'LearnDatabricks.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should -Be $true
    }

    It 'Exports the expected functions' {
        $exports = (Test-ModuleManifest -Path $ModuleManifestPath).ExportedFunctions

        $exports.Keys.Count | Should -Be 8

        $exports['New-DatabricksWorkspace'] | Should -Not -Be $null
        $exports['Get-DatabricksWorkspace'] | Should -Not -Be $null
        $exports['New-DatabricksCluster'] | Should -Not -Be $null
        $exports['New-DataLakeStorageAccount'] | Should -Not -Be $null
        $exports['New-ResourceGroup'] | Should -Not -Be $null
        $exports['Remove-ResourceGroup'] | Should -Not -Be $null
        $exports['Get-ResourceGroup'] | Should -Not -Be $null
        $exports['New-StorageAccount'] | Should -Not -Be $null
    }
}

