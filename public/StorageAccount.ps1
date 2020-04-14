function New-StorageAccount {
    <#
        .SYNOPSIS
        Creates a new Azure storage account.

        .DESCRIPTION
        Creates a new storage account in the resource group specified in the -ResourceGroupName parameter.
        This function fails if the resource group does not exist.

        .PARAMETER Name
        The storage account name.

        .PARAMETER ResourceGroupName
        The resource group to create the workspace in.

        .OUTPUTS
        A [hashtable] containing the following:

        1. Storage account resource id (id).
        2. Storage account name (name).
        3. Storage account blob endpoint (blobEndpoint).
        4. Primary connection string (connectionString).
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
        -AdditionalOptions '--https-only' `
        -Query '[id, name, primaryEndpoints.blob]'

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
        blobEndpoint = $createResult[2];
        connectionString = $showResult[0]
    }
}

function New-StorageContainer {
    <#
        .SYNOPSIS
        Creates a new container in an Azure storage account.

        .DESCRIPTION
        Creates a new container in an Azure storage account specified in the -StorageAccountName parameter.
        This function fails if the storage account does not exist.

        .PARAMETER Name
        The container name.

        .PARAMETER StorageAccountName
        The storage account name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$StorageAccountName
    )

    EnsureStorageAccountExists -Name $StorageAccountName

    $createContainerString = NewAzCommand `
        -Resource 'storage container' `
        -Verb 'create' `
        -Options @{
            name = $Name;
            'account-name' = $StorageAccountName
        }

    InvokeAzCommand -Command $createContainerString
}

function Get-StorageAccount {
    <#
        .SYNOPSIS
        Creates a new container in an Azure storage account.

        .DESCRIPTION
        Creates a new container in an Azure storage account specified in the -StorageAccountName parameter.
        This function fails if the storage account does not exist.

        .PARAMETER Name
        The container name.

        .PARAMETER StorageAccountName
        The storage account name.

        .OUTPUTS
        A [hashtable] containing the following:

        1. Storage account resource id (id).
        2. Storage account name (name).
        3. Resource grouo (resourceGroup).
        4. Storage account type (kind).
        5. If hierarchical namespace is enabled for the storageaccount (hierarchicalNamespaceEnabled).
        6. Storage account blob endpoint (blobEndpoint).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $getStorageAccountString = NewAzCommand `
        -Resource 'storage account' `
        -Verb 'show' `
        -Options @{
            'name' = $Name;
        } `
        -Query '[id, name, resourceGroup,  kind, isHnsEnabled, primaryEndpoints.blob]'

    $result = InvokeAzCommand -Command $getStorageAccountString

    return @{
        id = $result[0];
        name = $result[1];
        resourceGroup = $result[2];
        kind = $result[3];
        hierarchicalNamespaceEnabled = $result[4];
        blobEndpoint = $result[5];
    }
}

function EnsureStorageAccountExists {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    if ($null -eq (Get-StorageAccount -Name $Name)) {
        throw "The storage account ""$Name"" does not exist. Specify an existing storage account."
    }
}