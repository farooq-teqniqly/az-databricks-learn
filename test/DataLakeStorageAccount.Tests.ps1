. "$PSScriptRoot\..\private\AzCommand.ps1"
. "$PSScriptRoot\..\public\ResourceGroup.ps1"
. "$PSScriptRoot\..\public\DataLakeStorageAccount.ps1"

Describe 'New-DataLakeStorageAccount' {
    It 'Returns the expected result' {
        Mock Invoke-Expression `
            -MockWith {@('id', 'sto', 'kind', 'isHnsEnabled', 'endpoint')} `
            -ParameterFilter { $Command -notlike '*show-connection-string*'}

        Mock Invoke-Expression `
            -MockWith {@('cs', '')} `
            -ParameterFilter { $Command -like '*show-connection-string*'}

        Mock EnsureResourceGroupExists

        $result = New-DataLakeStorageAccount `
            -Name 'sto' `
            -ResourceGroupName 'rg'

        $result['id'] | Should -Be 'id'
        $result['name'] | Should -Be 'sto'
        $result['kind'] | Should -Be 'kind'
        $result['hierarchicalNamespaceEnabled'] | Should -Be 'isHnsEnabled'
        $result['blobEndpoint'] | Should -Be 'endpoint'
        $result['connectionString'] | Should -Be 'cs'
    }
}
