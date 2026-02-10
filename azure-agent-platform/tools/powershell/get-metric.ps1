param(
    [Parameter(Mandatory=$true)]
    [string]$resourceId,
    
    [Parameter(Mandatory=$true)]
    [string]$metricName,

    [string]$aggregation = "Average",
    
    [int]$timeRangeHours = 1
)

try {
    $endTime = Get-Date
    $startTime = $endTime.AddHours(-$timeRangeHours)

    $metric = Get-AzMetric -ResourceId $resourceId -MetricName $metricName -StartTime $startTime -EndTime $endTime -TimeGrain "00:01:00" -AggregationType $aggregation

    # Get the last non-null data point
    $latestData = $metric.Data | Where-Object { $_.$aggregation -ne $null } | Select-Object -Last 1

    if ($latestData) {
        $result = [PSCustomObject]@{
            status = "success"
            metric = $metricName
            value = $latestData.$aggregation
            unit = $metric.Unit
            timestamp = $latestData.TimeStamp
        }
        Write-Output ($result | ConvertTo-Json -Depth 2)
    } else {
        $result = [PSCustomObject]@{
            status = "warning"
            message = "No data found for metric $metricName in the last $timeRangeHours hours."
        }
        Write-Output ($result | ConvertTo-Json -Depth 2)
    }
}
catch {
    $result = [PSCustomObject]@{
        status = "error"
        message = $_.Exception.Message
    }
    Write-Output ($result | ConvertTo-Json -Depth 2)
}
