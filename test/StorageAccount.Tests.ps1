. "$PSScriptRoot\..\private\AzCommand.ps1"
. "$PSScriptRoot\..\public\ResourceGroup.ps1"
. "$PSScriptRoot\..\public\StorageAccount.ps1"

Describe 'New-StorageAccount' {
    It 'Returns the expected result' {
        Mock Invoke-Expression `
            -MockWith {@('id', 'sto', 'endpoint')} `
            -ParameterFilter { $Command -notlike '*show-connection-string*'}

        Mock Invoke-Expression `
            -MockWith {@('cs', '')} `
            -ParameterFilter { $Command -like '*show-connection-string*'}

        Mock EnsureResourceGroupExists

        $result = New-StorageAccount `
            -Name 'sto' `
            -ResourceGroupName 'rg'

        $result['id'] | Should -Be 'id'
        $result['name'] | Should -Be 'sto'
        $result['blobEndpoint'] | Should -Be 'endpoint'
        $result['connectionString'] | Should -Be 'cs'
    }
}
