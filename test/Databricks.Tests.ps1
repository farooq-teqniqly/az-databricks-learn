. "$PSScriptRoot\..\private\AzCommand.ps1"
. "$PSScriptRoot\..\private\Cache.ps1"
. "$PSScriptRoot\..\public\ResourceGroup.ps1"
. "$PSScriptRoot\..\public\Databricks.ps1"

Describe 'New-DatabricksWorkspace' {
    It 'Creates the workspace' {
        Mock EnsureResourceGroupExists

        Mock Get-ResourceGroup `
            -MockWith {@{'location' = 'westus2'}} `
            -Verifiable

        Mock WriteDeploymentParametersToFile -Verifiable
        Mock Invoke-Expression -Verifiable
        Mock Remove-Item -Verifiable

        New-DatabricksWorkspace `
            -WorkspaceName 'ws' `
            -ResourceGroupName 'rg'
    }
}

Describe 'Get-DatabricksWorkspace' {
    It 'Gets the workspace' {
        Mock Invoke-Expression `
            -MockWith { @(
                'id', 'name', 'loc', 'mid'
            )} `
            -Verifiable

        $result = Get-DatabricksWorkspace `
                -WorkspaceName 'foo' `
                -ResourceGroupName 'rg'

        $result['id'] | Should -Be 'id'
        $result['name'] | Should -Be 'name'
        $result['url'] | Should -Be 'https://loc.azuredatabricks.net'
        $result['managedResourceGroupId'] | Should -Be 'mid'
    }
}