<#
    .Synopsis
    Creates or deletes an Azure Databricks Workspace.

    .Description
    Creates or deletes an Azure Databricks Workspace.

    Specify the -Cleanup switch to remove the Azure Databricks workspace.

    .Parameter Cleanup
    When specified, removes the Azure Databricks workspace.

    .Parameter ResourceGroupName
    The Azure resource group name.

    .Parameter ResourceGroupLocation
    The Azure resource group location.

    .Parameter WorkspaceName
    The Azure Databricks workspace name.

    .Parameter PricingTier
    The Azure Databricks tier. Defaults to "Standard".

    .Example
    Create an  Azure Databricks workspace:

    .\Databricks.ps1 -ResourceGroupName dbrix-test-rg `
        -ResourceGroupLocation westus2 `
        -WorkspaceName dbrixtestws

    .Example
    Remove the resource group created in the first example:

    .\Databricks.ps1 -Cleanup `
        -ResourceGroupName dbrix-test-rg `
#>
param(
      [Parameter(Mandatory=$false, ParameterSetName="cleanup")]
      [switch] $Cleanup,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [Parameter(Mandatory=$true, ParameterSetName="cleanup")]
      [string] $ResourceGroupName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $ResourceGroupLocation,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $WorkspaceName,
      
      [Parameter(Mandatory=$false, ParameterSetName="create")]
      [ValidateSet("standard", "premium")]
      [string] $PricingTier = "standard"
)

if ($Cleanup)
{
    Write-Host "Removing resource group..."
    az group delete --name $ResourceGroupName --yes

    return
}

Write-Host "Creating resource group..."

az group create `
    --name $ResourceGroupName `
    --location $ResourceGroupLocation

Write-Host "Creating Azure Databricks workspace..."

$deploymentParametersFileName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name) + "_Temp.ps1"

@{
    pricingTier = @{ value = $PricingTier}
    location = @{ value = $ResourceGroupLocation}
    workspaceName = @{ value = $WorkspaceName}
} | ConvertTo-Json >> $deploymentParametersFileName

try 
{
    az group deployment create `
    --resource-group $ResourceGroupName `
    --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-databricks-workspace/azuredeploy.json `
    --parameters "@$($deploymentParametersFileName)"
}
finally 
{  
    Remove-Item -Path $deploymentParametersFileName -Force
}

