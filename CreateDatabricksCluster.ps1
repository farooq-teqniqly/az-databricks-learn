<#
    .Synopsis
    Creates an Azure Databricks cluster.

    .Description
    Creates an Azure Databricks cluster.

    .Parameter ClusterName
    The Azure Databricks cluster name.

    .Parameter AutoTerminationMinutes
    Specifies the maximum idle time before the cluster is terminated. Defaults to 30 minutes.

    .Example
    Create an  Azure Databricks cluster:

    .\CreateDatabricksCluster.ps1 -ClusterName dbrixcl
#>
param(
      [Parameter(Mandatory=$true)]
      [string] $ClusterName,

      [Parameter(Mandatory=$false)]
      [int] $AutoTerminationMinutes = 30
)

Write-Host "Creating Azure Databricks cluster..."

$clusterJsonFileName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name) + "_Temp.json"

$createClusterJson = @{
    num_workers = $null
    autoscale = @{
        min_workers = 1
        max_workers = 3
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
    autotermination_minutes = $AutoTerminationMinutes
    init_scripts = @()
} | ConvertTo-Json

[System.IO.File]::WriteAllText($clusterJsonFileName, $createClusterJson)

try 
{
    databricks clusters create --json-file $clusterJsonFileName
}
finally 
{  
    Remove-Item -Path $clusterJsonFileName -Force
}

