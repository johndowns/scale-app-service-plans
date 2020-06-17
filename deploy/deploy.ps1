param(
    [Parameter(Mandatory=$true)]
    $ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    $ResourceGroupLocation
)

# Cause all errors to halt the script.
$ErrorActionPreference = 'Stop'

Write-Host "Creating resource group $ResourceGroupName in location $ResourceGroupLocation."
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force

Write-Host 'Starting deployment of ARM template.'
Write-Host 'Often this step fails the first time it executes because the managed identity does not provision successfully. If this happens, the script will retry the deployment.'
$templateFilePath = Join-Path $PSScriptRoot 'template.json'
$ErrorActionPreference = 'Continue' # Due to the issue provisioning new managed identities, we will temporarily allow errors to continue for this section of the script
$hasDeployedFunctionApp = $false
while ($hasDeployedFunctionApp -ne $true)
{
    $deploymentOutputs = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFilePath
    if ($null -ne $deploymentOutputs.Outputs)
    {
        break
    }
    
    Write-Host 'Retrying Azure Functions app resources deployment in 5 seconds.'
    Start-Sleep -Seconds 5
}
$ErrorActionPreference = 'Stop'

$functionAppName = $deploymentOutputs.Outputs.functionAppName.value
$functionAppIdentityObjectId = $deploymentOutputs.Outputs.functionAppIdentityObjectId.value

Write-Host "Deploying to Azure Functions app $functionAppName."
$functionAppFolder = Join-Path $PSScriptRoot '..' 'src'
Push-Location $functionAppFolder
func azure functionapp publish $functionAppName
Pop-Location

Write-Host 'Deployment is complete.'
Write-Host "Please ensure that you grant Azure RBAC permissions to the function app's identity so that it can scale the app service plans up and down. The function app's name is $functionAppName and the managed identity object ID is $functionAppIdentityObjectId."
