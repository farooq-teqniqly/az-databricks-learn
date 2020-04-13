function New-DatabricksWorkspace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorkspaceName,

        [Parameter()]
        [ValidateSet("standard", "premium", IgnoreCase = $false)]
        [string] $PricingTier = "standard",

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )

    EnsureResourceGroupExists -Name $ResourceGroupName

    $resourceGroup = Get-ResourceGroup -Name $ResourceGroupName

    $deploymentParametersJson = @{
        pricingTier   = @{ value = $PricingTier }
        location      = @{ value = $resourceGroup['location'] }
        workspaceName = @{ value = $WorkspaceName }
    } | ConvertTo-Json

    $deploymentParametersFileName = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath ((New-Guid).ToString() + ".json")

    WriteDeploymentParametersToFile `
        -Path $deploymentParametersFileName `
        -DeploymentParameters $deploymentParametersJson

    try {
        $command = NewAzCommand `
            -Resource 'group deployment' `
            -Verb 'create' `
            -Options @{
            'resource-group' = $ResourceGroupName;
            'template-uri'   = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-databricks-workspace/azuredeploy.json';
            'parameters'     = """$deploymentParametersFileName""";
        }

        InvokeAzCommand -Command $command
    }
    finally {
        Remove-Item -Path $deploymentParametersFileName -Force
    }
}

function Get-DatabricksWorkspace {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )

    $command = NewAzCommand `
        -Resource 'resource' `
        -Verb 'show' `
        -Options @{
            'resource-group' = $ResourceGroupName;
            'name'           = $WorkspaceName;
            'resource-type'  = 'Microsoft.Databricks/workspaces';
        } `
        -Query = '[id, name, location, properties.managedResourceGroupId]'

    $result = InvokeAzCommand -Command $command

    return @{
        id = $result[0];
        name = $result[1];
        url = ("https://{0}.azuredatabricks.net" -f $result[2]);
        managedResourceGroupId = $result[3];
    }
}

function WriteDeploymentParametersToFile {
    param(
        [string]$Path,
        [string]$DeploymentParameters
    )

    [System.IO.File]::WriteAllText($Path, $DeploymentParameters)
}