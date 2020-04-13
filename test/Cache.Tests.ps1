. "$PSScriptRoot\..\private\Cache.ps1"

Describe 'UpdateCache tests' {
    It 'Adds and updates item' {
        $item = UpdateCache `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        $item['value'] | Should -Be 'bar'

        $updatedItem =  UpdateCache `
        -Key 'foo' `
        -Item @{'value' = 'boo'}

        $updatedItem['value'] | Should -Be 'boo'
    }
}

Describe 'GetCachedItem tests' {
    It 'Gets the item' {
        UpdateCache `
            -Key 'foo' `
            -Item @{'value' = 'bar'}

        $cachedItem = GetCachedItem -Key 'foo'

        $cachedItem['value'] | Should -Be 'bar'
    }
}