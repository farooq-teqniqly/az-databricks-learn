. "$PSScriptRoot\..\private\AzCommand.ps1"
. "$PSScriptRoot\..\private\Cache.ps1"
. "$PSScriptRoot\..\public\ResourceGroup.ps1"

Describe 'New-ResourceGroup' {
    It 'Returns the expected result' {

        Mock Invoke-Expression -MockWith {
            @('/subscriptions/id', 'rg', 'westus2') }

        $result = New-ResourceGroup `
        -Name 'ps-test-rg' `
        -Location 'westus2' `

        $result['id'] | Should -Be '/subscriptions/id'
        $result['name'] | Should -Be 'rg'
        $result['location'] | Should -Be 'westus2'
    }
}

Describe 'Get-ResourceGroup' {
    It 'Returns the expected result' {

        Mock Invoke-Expression -MockWith {
            @('/subscriptions/id', 'rg', 'westus2') }

        $result = Get-ResourceGroup -Name 'ps-test-rg'

        $result['id'] | Should -Be '/subscriptions/id'
        $result['name'] | Should -Be 'rg'
        $result['location'] | Should -Be 'westus2'
    }

    It 'When the group does not exist returns $null' {
        Mock Invoke-Expression -MockWith { $null }

        $result = Get-ResourceGroup -Name 'ps-test-rg'

        $result | Should -Be $null
    }
}

Describe 'Remove-ResourceGroup' {
    It 'Deletes the resource group' {
        Mock Invoke-Expression -Verifiable

        Remove-ResourceGroup `
            -Name 'rg' `
            -Confirm:$false
    }
}

Describe 'EnsureResourceGroupExists' {
    It 'Throws if resource group does not exist' {
        Mock Get-ResourceGroup -MockWith { $null }

        {EnsureResourceGroupExists -Name 'foobar'} `
            |  Should -Throw 'The resource group "foobar" does not exist. Specify an existing resource group.'
    }
}
