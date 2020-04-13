. "$PSScriptRoot\..\private\AzCommand.ps1"

Describe 'CreateCommand' {
    It 'Returns expected resource, verb, and options' {
        $options = @{
            name = 'rg';
            location = 'westus2';
        }

        $commandString = NewAzCommand `
            -Resource 'group' `
            -Verb 'show' `
            -Options $options

        $commandString | Should -Be 'az group show --name rg --location westus2  -o tsv'
    }

    It 'Returns expected resource, verb, options and query' {
        $options = @{
            name = 'rg';
            location = 'westus2';
        }

        $query = '[name, id]'

        $commandString = NewAzCommand `
            -Resource 'group' `
            -Verb 'create' `
            -Options $options `
            -Query $query

        $commandString | Should -Be 'az group create --name rg --location westus2 --query "[name, id]" -o tsv'
    }
}

Describe 'Invoke-AzCommand' {
    It 'Invokes command and returns result' {
        Mock Invoke-Expression -MockWith { @('rg', '/subscriptions/id')}

        $command = 'az group create --name rg --location westus2 --query "[name, id]" -o tsv'

        $result = InvokeAzCommand -Command $command

        $result[0] | Should -Be 'rg'
        $result[1] | Should -BeLike '/subscriptions*'
    }
}

