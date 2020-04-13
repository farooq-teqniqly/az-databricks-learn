function New-DataLakeStorageAccount {
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