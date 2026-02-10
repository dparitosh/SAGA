param(
    [Parameter(Mandatory=$true)][string]$resourceGroup,
    [Parameter(Mandatory=$true)][string]$vmName
)

$response = @{ status = "unknown"; message = ""; timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ"); action = "start_vm" }

try {
    Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName -ErrorAction Stop
    $response.status = "success"
    $response.message = "VM '$vmName' started successfully."
}
catch {
    $response.status = "error"
    $response.message = $_.Exception.Message
}

Write-Output ($response | ConvertTo-Json -Depth 2)
