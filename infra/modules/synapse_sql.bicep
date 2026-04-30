// infra/modules/synapse_sql.bicep
//
// This module deploys a Synapse SQL pool and configures it with the necessary 
// permissions to access the storage account. This will mean adding a role 
//assignment for the Synapse workspace's managed identity to the storage 
// account, granting it the necessary permissions to read and write data.
//
// Oops, did a pool first. Now doing the serverless database instead, which is more cost effective for this use case.

// Definition in main.bicep:
param location string
param prefix string
param storageAccountName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorPassword string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Define the logical SQL Server
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: '${prefix}-synapse'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorPassword
    defaultDataLakeStorage: {
      resourceId: storageAccount.id
      accountUrl: 'https://${storageAccountName}.dfs.${environment().suffixes.storage}'
      filesystem: 'gold'
    }
  }
}

  // Required to allow Azure services to reach the Synapse workspace                                         
  resource synapseFirewall 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {                  
    parent: synapseWorkspace
    name: 'AllowAllAzureServices'                    
    properties: { 
      startIpAddress: '0.0.0.0'                      
      endIpAddress: '0.0.0.0'
    }                                                
  }               

  output synapsePrincipalId string = synapseWorkspace.identity.principalId
  output synapseServerlessEndpoint string = synapseWorkspace.properties.connectivityEndpoints.sqlOnDemand
