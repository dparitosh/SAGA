param(
    [Parameter(Mandatory=$true)][string]$resourceGroup,
    [Parameter(Mandatory=$true)][string]$vmName
)

$response = @{ status = "unknown"; message = ""; timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ"); action = "stop_vm" }

try {
    Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force -ErrorAction Stop
    $response.status = "success"
    $response.message = "VM '$vmName' stopped successfully."
}
catch {
    $response.status = "error"
    $response.message = $_.Exception.Message
}

Write-Output ($response | ConvertTo-Json -Depth 2)
