param(
    [Parameter(Mandatory=$true)][string]$resourceGroup, 
    [Parameter(Mandatory=$true)][string]$appName, 
    [string]$newTier = "Standard", 
    [string]$newSize = "S1",
    [int]$instanceCount = 1
)

$response = @{ status = "unknown"; message = ""; timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ"); action = "scale_app" }

try {
    # Get the App Service Plan associated with the App Service
    $webApp = Get-AzWebApp -ResourceGroupName $resourceGroup -Name $appName -ErrorAction Stop
    if (-not $webApp) { throw "WebApp '$appName' not found." }

    $appServicePlanName = $webApp.AppServicePlanId.Split('/')[-1]

    # Update the App Service Plan
    Set-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $appServicePlanName -Tier $newTier -WorkerSize $newSize -NumberofWorkers $instanceCount -ErrorAction Stop
    
    $response.status = "success"
    $response.message = "App '$appName' scaled to $newTier $newSize ($instanceCount instances)."
}
catch {
    $response.status = "error"
    $response.message = $_.Exception.Message
}

Write-Output ($response | ConvertTo-Json -Depth 2)
