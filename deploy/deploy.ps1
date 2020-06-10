param(
    [Parameter(Mandatory=$true)]
    $ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    $ResourceGroupLocation
)

# Disable colour output on the CLI
$env:AZURE_CORE_NO_COLOR = 'true'

Write-Host "Creating resource group $ResourceGroupName in location $ResourceGroupLocation."
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force

Write-Host 'Starting deployment of ARM template.'
$templateFilePath = Join-Path $PSScriptRoot 'template.json'
$deploymentOutputs = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFilePath
$functionAppName = $deploymentOutputs.Outputs.functionAppName.value
$functionAppName = 'mnvia3cffnmna'
$functionAppIdentityObjectId = $deploymentOutputs.Outputs.functionAppIdentityObjectId.value

Write-Host "Deploying to Azure Functions app $functionAppName."
$functionAppFolder = Join-Path $PSScriptRoot '..' 'src'
Push-Location $functionAppFolder
func azure functionapp publish $functionAppName
Pop-Location

Write-Host 'Deployment is complete.'
Write-Host "Please ensure that you grant Azure RBAC permissions to the function app's identity so that it can scale the app service plans up and down. The function app's name is $functionAppName and the managed identity object ID is $functionAppIdentityObjectId."
