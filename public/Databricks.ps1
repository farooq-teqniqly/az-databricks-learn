
function New-DatabricksWorkspace {
    <#
        .SYNOPSIS
        Creates a new Azure Databricks workspace.

        .DESCRIPTION
        Creates a new Azure Databricks workspace in the resource group specified in the -ResourceGroupName parameter.
        This function fails if the resource group does not exist.

        .PARAMETER WorkspaceName
        The Databricks workspace name.

        .PARAMETER PricingTier
        The Databricks pricing tier. Acceptable values are 'standard' and 'premium'. Defaults to 'standard'.

        .PARAMETER ResourceGroupName
        The resource group to create the workspace in.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter()]
        [ValidateSet("standard", "premium", IgnoreCase = $false)]
        [string] $PricingTier = "standard",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName
    )

    EnsureResourceGroupExists -Name $ResourceGroupName

    $resourceGroup = Get-ResourceGroup -Name $ResourceGroupName

    $deploymentParametersJson = @{
        pricingTier   = @{ value = $PricingTier }
        location      = @{ value = $resourceGroup['location'] }
        workspaceName = @{ value = $WorkspaceName }
    } | ConvertTo-Json

    $deploymentParametersFileName = GetRandomFileName

    WriteFile `
        -Path $deploymentParametersFileName `
        -Content $deploymentParametersJson

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
    <#
        .SYNOPSIS
        Queries for an Azure Databricks workspace.

        .DESCRIPTION
        Queries for an Azure Databricks workspace with the name specified in the -WorkspaceName parameter.

        .PARAMETER WorkspaceName
        The Databricks workspace name.

        .PARAMETER ResourceGroupName
        The resource group containing the workspace.

        .OUTPUTS
        A [hashtable] containing the following:

        1. Resource id for the workspace (id).
        2. Workspace name (name).
        3. Databricks URL (url).
        4. The managed resource group's id (managedResourceGroupId).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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
        -Query '[id, name, location, properties.managedResourceGroupId]'

    $result = InvokeAzCommand -Command $command

    return @{
        id = $result[0];
        name = $result[1];
        url = ("https://{0}.azuredatabricks.net" -f $result[2]);
        managedResourceGroupId = $result[3];
    }
}

function WriteFile {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content)
}

function GetRandomFileName {
    param(
        [string]$Extension = ".json"
    )

    return Join-Path `
        -Path $PSScriptRoot `
        -ChildPath ((New-Guid).ToString() + $Extension)
}