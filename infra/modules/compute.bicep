// compute.bicep
param storageAccountName string
param location string
param prefix string

// "existing" tells Azure: "Don't create this, just look it up so I can use its properties"
// All I need is the name to look it up!
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// 1. Hosting Plan (Consumption/Serverless)
resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: '${prefix}-plan'
  location: location
  sku: {
    name: 'Y1' // Consumption: Pay only when the code runs
    tier: 'Dynamic'
  }
}

// 2. Application Insights (Telemetry/Skill #8 - Auditing)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${prefix}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// 3. The Function App (Python 3.11)
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${prefix}-fn-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
    }
  }
}

// Output the principalId of the Function App's managed identity so we can use
// it in the RBAC module to grant it access to the storage account.
output functionAppIdentityId string = functionApp.identity.principalId

// Output the Function App URL so we can reference it in our ADF pipelines or for testing.
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
