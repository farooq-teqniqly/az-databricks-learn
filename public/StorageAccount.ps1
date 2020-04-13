function New-StorageAccount {
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