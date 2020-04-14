function New-DataLakeStorageAccount {
    <#
        .SYNOPSIS
        Creates a new Azure Data Lake storage account.

        .DESCRIPTION
        Creates a new Azure Data Lake storage account in the resource group specified in the -ResourceGroupName parameter.
        This function fails if the resource group does not exist.

        .PARAMETER Name
        The storage account name.

        .PARAMETER ResourceGroupName
        The resource group to create the workspace in.

        .OUTPUTS
        A [hashtable] containing the following:

        1. Storage account resource id (id).
        2. Storage account name (name).
        3. Storage account type (kind).
        4. If hierarchical namespace is enabled for the storageaccount (hierarchicalNamespaceEnabled).
        5. Storage account blob endpoint (blobEndpoint).
        6. Primary connection string (connectionString).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName
    )

    EnsureResourceGroupExists -Name $ResourceGroupName

    $createCommandString = NewAzCommand `
        -Resource 'storage account' `
        -Verb 'create' `
        -Options @{
            name = $Name;
            'resource-group' = $ResourceGroupName
        } `
        -AdditionalOptions '--https-only --kind StorageV2 --enable-hierarchical-namespace' `
        -Query '[id, name, kind, isHnsEnabled, primaryEndpoints.blob]'

    $createResult = InvokeAzCommand -Command $createCommandString

    $showConnectionStringCommandString = NewAzCommand `
        -Resource 'storage account' `
        -Verb 'show-connection-string' `
        -Options @{
            name = $Name;
        } `
        -Query '[connectionString]'

    $showResult = InvokeAzCommand -Command $showConnectionStringCommandString

    return @{
        id = $createResult[0];
        name = $createResult[1];
        kind = $createResult[2];
        hierarchicalNamespaceEnabled = $createResult[3];
        blobEndpoint = $createResult[4];
        connectionString = $showResult[0]
    }
}