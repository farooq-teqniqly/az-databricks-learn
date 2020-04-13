[hashtable]$script:cache = @{}

function ClearCache {
    param()

    [hashtable]$script:cache = @{}
}

function GetKeys {
    param()

    return $script:cache.Keys
}

function SetCacheItem {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$Item
    )

    $cachedItem = $script:cache[$Key]

    if ($null -eq $cachedItem) {
        $script:cache.Add($Key, $Item)
    } else {
        $script:cache[$Key] = $Item
    }

    return $script:cache[$Key]
}

function GetCacheItem {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Key
    )

    return $script:cache[$Key]
}