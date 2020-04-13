. "$PSScriptRoot\..\private\Cache.ps1"

Describe 'SetCacheItem tests' {
    It 'Adds and updates item' {
        $item = SetCacheItem `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        $item['value'] | Should -Be 'bar'

        $updatedItem =  SetCacheItem `
        -Key 'foo' `
        -Item @{'value' = 'boo'}

        $updatedItem['value'] | Should -Be 'boo'
    }
}

Describe 'GetCacheItem tests' {
    It 'Gets the item' {
        SetCacheItem `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        $cachedItem = GetCacheItem -Key 'foo'

        $cachedItem['value'] | Should -Be 'bar'
    }
}

Describe 'ClearCache tests' {
    It 'Clears the cache' {
        SetCacheItem `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        ClearCache

        GetKeys | Should -Be $null
    }
}

Describe 'GetKeys tests' {
    It 'Gets the keys' {
        ClearCache

        SetCacheItem `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        SetCacheItem `
            -Key 'baz' `
            -Item @{'value' = 'qux'}

        (GetKeys).Count | Should -Be 2
    }
}