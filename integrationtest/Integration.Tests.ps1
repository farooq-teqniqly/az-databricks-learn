. "$PSScriptRoot\..\private\AzCommand.ps1"
. "$PSScriptRoot\..\private\Cache.ps1"
. "$PSScriptRoot\..\public\ResourceGroup.ps1"
. "$PSScriptRoot\..\public\Databricks.ps1"

Describe 'Create databricks workspace' {
    It 'Creates the workspace' {
        try {
            ClearCache

            New-ResourceGroup `
                -Name 'fm-ps-test-rg' `
                -Location 'westus2'

            New-DatabricksWorkspace `
                -WorkspaceName 'fmpstestdbrixws' `
                -PricingTier 'premium' `
                -ResourceGroupName 'fm-ps-test-rg'
        } finally {
            Remove-ResourceGroup `
                -Name 'fm-ps-test-rg' `
                -Confirm:$false
        }
    }
}