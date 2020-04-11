<#
    .Synopsis
    Creates an Azure SQL Data Warehouse.

    .Description
    Creates an Azure SQL Data Warehouse.

    .Parameter Cleanup
    Removes the resource group.

    .Parameter SqlServerName
    The SQL Server name.

    .Parameter SqlAdminUserName
    The SQL Server admin user name.

    .Parameter SqlAdminPassword
    The SQL Server admin password.

    .Parameter SqlFirewallClientIpAddress
    The client ip address to allow in the SQL Server firewall rule.

    .Parameter ResourceGroupName
    The resource group name.

    .Parameter ResourceGroupLocation
    The resource group location.

    .Example
    Create an Azure SQL Data Warehouse.:

    .\CreateSqlDw.ps1 -ResourceGroupName my-rg `
        -ResourceGroupLocation westus2 `
        -SqlServerName sql001 `
        -SqlAdminUserName admin1001 `
        -SqlAdminPassword "admin1001_password" `
        -SqlFirewallClientIpAddress 10.10.10.10

    .Example
    Remove the resource group created in the first example:

    .\CreateSqlDw.ps1 -ResourceGroupName my-rg -Cleanup
#>
param(
      [Parameter(Mandatory=$false, ParameterSetName="cleanup")]
      [switch] $Cleanup,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $SqlServerName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $SqlAdminUserName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $SqlAdminPassword,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $SqlFirewallClientIpAddress,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [Parameter(Mandatory=$true, ParameterSetName="cleanup")]
      [string] $ResourceGroupName,

      [Parameter(Mandatory=$true, ParameterSetName="create")]
      [string] $ResourceGroupLocation
)

Write-Host "Creating Resource Group..."

az group create --name $ResourceGroupName --location $ResourceGroupLocation

Write-Host "Creating SQL Server..."

az sql server create `
    --name $SqlServerName `
    --resource-group $ResourceGroupName `
    --location $ResourceGroupLocation `
    --admin-user $SqlAdminUserName `
    --admin-password $SqlAdminPassword


Write-Host "Creating SQL Server firewall rule..."

az sql server firewall-rule create `
    --name $SqlServerName `
    --resource-group  $ResourceGroupName `
    --server $SqlServerName `
    --start-ip-address $SqlFirewallClientIpAddress `
    --end-ip-address $SqlFirewallClientIpAddress

Write-Host "Creating SQL Data Warehouse. This is a good time for a cup of coffee or two..."

$sqlDataWarehouseName = $SqlServerName + "dw"

az sql dw create `
    --name $sqlDataWarehouseName `
    --resource-group $ResourceGroupName `
    --server $SqlServerName

$sqlDataWarehouseEndpoint = az sql server show --name $SqlServerName `
    --resource-group $ResourceGroupName `
    --query fullyQualifiedDomainName `
    -o tsv

Write-Warning "Copy the information below. You may need it to connect to your SQL Data Warehouse instance."
Write-Warning "BEGIN COPY"

Write-Host ("SQL Data Warehouse endpoint: {0}" -f $sqlDataWarehouseEndpoint)

Write-Host "SQL Data Warehouse connection string:"

az sql db show-connection-string `
    --client sqlcmd `
    --auth-type SqlPassword `
    --server $SqlServerName

Write-Warning "END COPY"