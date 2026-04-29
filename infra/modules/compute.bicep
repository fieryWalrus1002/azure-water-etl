// // compute.bicep
// param location string = resourceGroup().location
// param prefix string = 'hydroflow'
// param storageAccountName string

// // 1. Hosting Plan (Consumption/Serverless)
// resource hostingPlan 'Microsoft.Web/serverlessInstances@2022-03-01' = {
//   name: '${prefix}-plan'
//   location: location
//   sku: {
//     name: 'Y1' // Consumption: Pay only when the code runs
//     tier: 'Dynamic'
//   }
// }

// // 2. Application Insights (Telemetry/Skill #8 - Auditing)
// resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
//   name: '${prefix}-insights'
//   location: location
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//     publicNetworkAccessForIngestion: 'Enabled'
//     publicNetworkAccessForQuery: 'Enabled'
//   }
// }

// // 3. The Function App (Python 3.11)
// resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
//   name: '${prefix}-fn-${uniqueString(resourceGroup().id)}'
//   location: location
//   kind: 'functionapp,linux'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     serverFarmId: hostingPlan.id
//     siteConfig: {
//       linuxFxVersion: 'PYTHON|3.11'
//       appSettings: [
//         { name: 'AzureWebJobsStorage', value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts\', storageAccountName), \'2023-01-01\').keys[0].value};EndpointSuffix=core.windows.net' },
//         { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: appInsights.properties.InstrumentationKey }
//         { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
//         { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }
//       ]
//     }
//   }
// }
