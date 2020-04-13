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