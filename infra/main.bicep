// main.bicep 
// Later we break this into modules, but mvp is one file for simplicity
// Docs: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
// Bicep syntax ref: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file

targetScope = 'resourceGroup'



//********************************************
// Parameters
//********************************************
param location string = resourceGroup().location
param prefix string = 'hydroflow'
param tenantId string = subscription().tenantId

// Provided from the main.local.bicepparam
param userPrincipalId string


@minLength(3)
@maxLength(24)
@description('Provide a unique name for the storage account. Must be between 3 and 24 characters, and can only contain lowercase letters and numbers.')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@minLength(3)
@maxLength(24)
@description('Provide the SKU name for the storage account. Must be between 3 and 24 characters. For cost-effectiveness, use Standard_LRS (Locally Redundant Storage). For higher durability and availability, consider using ZRS (Zone-Redundant Storage) or GRS (Geo-Redundant Storage).')
param storageSkuName string = 'Standard_LRS'


//********************************************
// Variables
//********************************************

var keyVaultName = '${prefix}-keyVault'

//********************************************
// Azure resources required by your function app.
//********************************************

// 1. Data Lake Storage (ADLS Gen2)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: { name: storageSkuName }
  properties: {
    isHnsEnabled: true // Required for ADLS Gen2 (Hierarchical Namespace)
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// 2. Containers (Medallion Layers)
// In prod, these would likely be in a different part of the lifecycle.
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource bronzeContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'bronze'
}

resource silverContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'silver'
}

resource goldContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'gold'
}

// 3. Azure Data Factory
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${prefix}-adf-${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned' // This is the "Service Principal" identity. Created for use by ADF to access other resources securely.
  }
}

//********************************************
// Modules
// 
// Usage:
// module <alias> '<path-to-file>' = {                      
//   name: '<deployment-name>'  // shows up in Azure portal 
// deployment history                                       
//   params: {                                              
//     paramName: someValue                                 
//   }             
// }
//*******************************************

// Create a key vault using our fancy reusable module. 
// We can then reference the outputs (keyVaultId and keyVaultUrl) in other modules 
// that need to access secrets, like the Function App or ADF Linked Service.
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  params: { 
    keyVaultName: keyVaultName
    location: location
    tenantId: tenantId
  }
}

// The compute module does the hard work of processing
// our data. In a real implementation, this would likely be an Azure Function App or Azure Databricks cluster, but for simplicity we just create a placeholder resource here. 
module compute 'modules/compute.bicep' = {
  name: 'compute_deploy'
  params: {
    location: location
    prefix: prefix
    storageAccountName: storageAccountName
  }
}

// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac
module rbac 'modules/rbac.bicep' = {
  name: 'rbac'
  params: {
    keyVaultName: keyVaultName
    adfIdentityPrincipalId: dataFactory.identity.principalId
    storageAccountName: storageAccountName
    functionAppIdentityId: compute.outputs.functionAppIdentityId
    userPrincipalId: userPrincipalId
  }
}

module adfFactory 'modules/adf_factory.bicep' = {
  name: 'adfFactory'
  params: {
    adfName: dataFactory.name
    functionAppUrl: compute.outputs.functionAppUrl
    storageAccountName: storageAccountName
  }
}

