<#
    .Synopsis
    Creates an Azure storage account.

    .Description
    Creates an Azure storage account.

    .Parameter StorageAccountName
    The storage account name.

    .Parameter ResourceGroupName
    The name of an existing resource group.

    .Example
    Create an Azure storage account:

    .\CreateStorage.ps1 `
        -StorageAccountName mystorageaccount `
        -ResourceGroupName my-rg
#>
param(
        [Parameter(Mandatory=$true)]
        [string] $StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory=$false)]
        [switch] $CreateGen2StorageAccount
)

$resourceGroupLocation = az group show --name $ResourceGroupName --query location

if ($null -eq $resourceGroupLocation)
{
    return
}

Write-Host "Creating storage account..."

if ($CreateGen2StorageAccount)
{
    az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --https-only `
    --location $resourceGroupLocation `
    --kind StorageV2 `
    --enable-hierarchical-namespace true
}
else 
{
    az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --https-only `
    --location $resourceGroupLocation
}


Write-Warning "Copy the information below. You may need it to integrate with the storage account."
Write-Warning "BEGIN COPY"

az storage account show-connection-string `
    --name $StorageAccountName `
    --key primary

Write-Warning "END COPY"