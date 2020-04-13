function New-DatabricksWorkspace {
    param(
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName,

        [Parameter()]
        [ValidateSet("standard", "premium", IgnoreCase=$false)]
        [string] $PricingTier = "standard",

        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName
    )

    EnsureResourceGroupExists -Name $ResourceGroupName

    $resourceGroup = Get-ResourceGroup -Name $ResourceGroupName

    $deploymentParametersJson = @{
        pricingTier = @{ value = $PricingTier}
        location = @{ value = $resourceGroup['location']}
        workspaceName = @{ value = $WorkspaceName}
    } | ConvertTo-Json

    $deploymentParametersFileName = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath ((New-Guid).ToString() + ".json")

    WriteDeploymentParametersToFile `
        -Path $deploymentParametersFileName `
        -DeploymentParameters $deploymentParametersJson

    try {
        $command = CreateAzCommand `
            -Resource 'group deployment' `
            -Verb 'create' `
            -Options @{
                'resource-group' = $ResourceGroupName;
                'template-uri' = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-databricks-workspace/azuredeploy.json';
                'parameters' = """$deploymentParametersFileName""";
            }

        InvokeAzCommand -Command $command
    } finally {
        Remove-Item -Path $deploymentParametersFileName -Force
    }
}

function WriteDeploymentParametersToFile {
    param(
        [string]$Path,
        [string]$DeploymentParameters
    )

    [System.IO.File]::WriteAllText($Path, $DeploymentParameters)
}