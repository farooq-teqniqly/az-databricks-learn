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

Describe 'New-StorageContainer' {
    It 'Creates the container' {
        Mock EnsureStorageAccountExists -Verifiable
        Mock Invoke-Expression -Verifiable

        New-StorageContainer `
            -Name 'foo' `
            -StorageAccountName 'bar'
    }
}

Describe 'Get-StorageAccount' {
    It 'Gets the storage account' {
        Mock Invoke-Expression `
            -MockWith {@(
                'id'
                'name',
                'rg',
                'v2',
                $true,
                'blob'
            )} `
            -Verifiable

        $result = Get-StorageAccount -Name 'foo'

        $result['id'] | Should -Be 'id'
        $result['name'] | Should -Be 'name'
        $result['resourceGroup'] | Should -Be 'rg'
        $result['kind'] | Should -Be 'v2'
        $result['blobEndpoint'] | Should -Be 'blob'
        $result['hierarchicalNamespaceEnabled'] | Should -BeTrue
    }
}

Describe 'EnsureStorageAccountExists' {
    It 'Throws if storage account does not exist' {
        Mock Get-StorageAccount -MockWith { $null }

        {EnsureStorageAccountExists -Name 'foobar'} `
            |  Should -Throw 'The storage account "foobar" does not exist. Specify an existing storage account.'
    }
}
