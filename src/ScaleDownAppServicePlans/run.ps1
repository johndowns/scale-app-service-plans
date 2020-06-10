# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

# Connect to Azure using the application's managed identity.
Add-AzAccount -Identity -Subscription $env:AzureSubscriptionId

# Load the plans.json file, which contains the instructions for the scale up and down operations.
$allPlanSettings = Get-Content 'plans.json' -Raw | ConvertFrom-Json
foreach ($planSettings in $allPlanSettings)
{
    Write-Host "Reconfiguring plan $($planSettings.Name)"
    Set-AzAppServicePlan -Name $planSettings.Name -ResourceGroupName $planSettings.ResourceGroupName -Tier $planSettings.ScaleDown.Tier -WorkerSize $planSettings.ScaleDown.WorkerSize -NumberofWorkers $planSettings.ScaleDown.NumberOfWorkers
}
