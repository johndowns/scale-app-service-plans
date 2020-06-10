# Scale Azure app service plans on a schedule

This sample demonstrates how to use an Azure Function (written in PowerShell) to automatically perform scale-up and scale-down operations for a set of app service plans.

To run this yourself:
 * Update the `src/plans.json` file to include the details for your plans and the scale up/scale down rules.
 * Configure the `function.json` files to specify the times you want to run the functions. Currently the 'scale down' operation happens at 8am UTC (generally around 6pm AEST, depending on daylight saving time) and the 'scale up' operation happens at 9pm UTC (generally around 7am AEST).
 * Deploy the app by running the `deploy/deploy.ps1` script. You will need to have the [v3 Azure Functions CLI installed](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#v2) to successfully deploy the function.
 * Configure the function app's managed identity to be able to modify the app service plans. You can do this by using [Azure IAM](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal) to grant access at the scope of the individual resources, resource groups, or subscription. The deployment script outputs the name of the function app and its Azure AD object ID so that you can configure this. You can use the `Contributor` rule to allow the function app to make the necessary changes to the plan.
