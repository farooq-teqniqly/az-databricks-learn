function NewAzCommand {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Resource,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(4, 50)]
    [string]$Verb,

    [Parameter(Mandatory = $true)]
    [hashtable]$Options,

    [Parameter()]
    [string]$AdditionalOptions,

    [Parameter()]
    [string]$Query
  )

  $sb = [System.Text.StringBuilder]::new()

  if ($Options.Keys.Length -gt 0) {
    $optionsStringFormat = '--{0} {1} '
  }
  else {
    $optionsStringFormat = '--{0} {1}'
  }

  foreach ($key in $Options.Keys) {
    $sb.AppendFormat($optionsStringFormat, $key, $Options[$key]) | Out-Null
  }

  if ([System.String]::IsNullOrEmpty($Query) -eq $false) {
    $sb.AppendFormat('--query "{0}"', $Query) | Out-Null
  }

  if ([System.String]::IsNullOrEmpty($AdditionalOptions) -eq $false) {
    $sb.Append($AdditionalOptions) | Out-Null
  }

  $commandString = 'az {0} {1} {2} -o tsv' -f $Resource, $Verb, $sb.ToString()

  Write-Verbose $commandString

  return $commandString

}

function InvokeAzCommand {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Command
  )

  $result = Invoke-Expression -Command $Command

  return $result
}