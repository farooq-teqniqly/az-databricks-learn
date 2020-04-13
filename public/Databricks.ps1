function New-DatabricksWorkspace {
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

function New-DatabricksCluster {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$ClusterName
    )

    $clusterParametersFileName = GetRandomFileName

    $createClusterJson = @{
        num_workers = $null
        autoscale = @{
            min_workers = 2
            max_workers = 4
        }
        cluster_name = $ClusterName
        spark_version = "6.4.x-scala2.11"
        spark_conf = @{}
        node_type_id = "Standard_DS3_v2"
        ssh_public_keys = @()
        custom_tags = @{}
        spark_env_vars = @{
            PYSPARK_PYTHON = "/databricks/python3/bin/python3"
        }
        autotermination_minutes = 60
        init_scripts = @()
    } | ConvertTo-Json

    WriteFile `
        -Path $clusterParametersFileName `
        -Content $createClusterJson

    try {
        InvokeAzCommand -Command "databricks clusters create --json-file $clusterParametersFileName"
    } finally {
        Remove-Item -Path $clusterParametersFileName -Force
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