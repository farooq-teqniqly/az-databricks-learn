$publicFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1")
$privateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1")

foreach ($file in @($publicFunctions +$privateFunctions)) {
    . $file.FullName
}