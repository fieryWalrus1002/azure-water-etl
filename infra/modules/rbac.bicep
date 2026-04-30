// infra/modules/rbac.bicep

param storageAccountName string
param adfIdentityPrincipalId string
param functionAppIdentityId string
param userPrincipalId string // My personal Object ID for local EDA
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

//********************************************
// GUID Generation for Role Assignments
//********************************************
//
// Industry standard: Define the GUID as a variable for readability
// Its okay to hard-code in Azure role definition IDs, because these are
// globally consistent and won't change across subscriptions or tenants.

// Role: Key Vault Secrets User (for ADF to read secrets from Key Vault)
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

// Role: Storage Blob Data Contributor
var storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// 1. Grant access to ADF for the storage account (for data movement)
resource adfStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, adfIdentityPrincipalId, storageBlobDataContributor)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: adfIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// 2. Grant ADF access to Key Vault secrets (for Function App key)
resource adfKeyVaultRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, adfIdentityPrincipalId, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',keyVaultSecretsUserRoleId)
    principalId: adfIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// 2. Grant storage access to the Function App
resource functionStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionAppIdentityId, storageBlobDataContributor)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: functionAppIdentityId
    principalType: 'ServicePrincipal'
  }
}

// 3. Grant storage access to YOU (the User) for local EDA
resource userStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, userPrincipalId, storageBlobDataContributor)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: userPrincipalId
    principalType: 'User'
  }
}
