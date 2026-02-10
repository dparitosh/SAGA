param(
    [string]$resourceGroup,
    [string]$correlationId,
    [int]$maxRecords = 10
)

$response = @{ status = "unknown"; message = ""; timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ"); action = "get_logs" }

try {
    $params = @{
        MaxRecord = $maxRecords
    }
    if ($resourceGroup) { $params.ResourceGroupName = $resourceGroup }
    if ($correlationId) { $params.CorrelationId = $correlationId }

    $logs = Get-AzActivityLog @params -ErrorAction Stop | Select-Object EventTimestamp, OperationName, Status, Caller, ResourceGroupName, ResourceId

    $response.status = "success"
    $response.message = "Retrieved $($logs.Count) log entries."
    $response.logs = $logs
    
    Write-Output ($response | ConvertTo-Json -Depth 3)
}
catch {
    $response.status = "error"
    $response.message = $_.Exception.Message
    Write-Output ($response | ConvertTo-Json -Depth 2)
}
