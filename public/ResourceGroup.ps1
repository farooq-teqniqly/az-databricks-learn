function New-ResourceGroup {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Location
    )

    $commandString = NewAzCommand `
        -Resource 'group' `
        -Verb 'create' `
        -Options @{
            name     = $Name;
            location = $Location
        } `
        -Query '[id, name, location]'

    $result = InvokeAzCommand -Command $commandString

    $resourceGroup = @{
        id = $result[0];
        name = $result[1];
        location = $result[2];
    }

    SetCacheItem `
        -Key $resourceGroup['name'] `
        -Item $resourceGroup `
        | Out-Null

    return $resourceGroup
}

function Remove-ResourceGroup {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $commandString = NewAzCommand `
        -Resource 'group' `
        -Verb 'delete' `
        -Options @{
            name = $Name
        } `
        -AdditionalOptions '--yes' `
        -Query '[id, name]'

    if ($PSCmdlet.ShouldProcess(
        "resource group: $Name",
        'Delete resource group')) {
            $result = InvokeAzCommand -Command $commandString
        }

    return $result
}

function Get-ResourceGroup {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $cachedResourceGroup = GetCacheItem `
        -Key $Name

    if ($null -ne $cachedResourceGroup) {
        return $cachedResourceGroup
    }

    $commandString = NewAzCommand `
        -Resource 'group' `
        -Verb 'show' `
        -Options @{
            name = $Name;
        } `
        -Query '[id, name, location]'

    $result = InvokeAzCommand -Command $commandString

    if ($null -eq $result) {
        return $null
    }

    return @{
        id = $result[0];
        name = $result[1];
        location = $result[2];
    }
}

function EnsureResourceGroupExists {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    if ($null -eq (Get-ResourceGroup -Name $Name)) {
        throw "The resource group ""$Name"" does not exist. Specify an existing resource group."
    }
}