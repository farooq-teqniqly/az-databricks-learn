param(
      [Parameter(Mandatory=$false, ParameterSetName="cleanup")]
      [switch] $Cleanup,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [Parameter(Mandatory=$true, ParameterSetName="cleanup")]
      [string] $SubscriptionName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [Parameter(Mandatory=$true, ParameterSetName="cleanup")]
      [string] $ResourceGroupName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $ResourceGroupLocation,

      [Parameter(Mandatory=$false, ParameterSetName="create")]
      [ValidateSet("Standard", "Premium")]
      [string] $PricingTier = "Standard"
)

Write-Host "Please login to Azure..."
az login

az account set --subscription $SubscriptionName
Write-Host "Using subscription '$SubscriptionName'."

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
    workspaceName = @{ value = $ResourceGroupName + "-dbrixws"}
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

