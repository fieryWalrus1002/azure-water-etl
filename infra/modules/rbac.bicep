// rbac.bicep

// Grant access to myself for local EDA using Azure Storage Explorer or similar tools. 
// In production, this would be more restrictive and likely use Azure AD groups instead 
// of individual users. Use principal of least privilege in production, but for local development,
// I'm not going to make it more complicated than it needs to be.
resource userStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountName, principalId, roleDefinitionId)
  scope: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'User'
  }
}

// Grant access to the FUNCTION for the automated pipeline
resource functionStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountName, functionAppIdentityId, roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: functionAppIdentityId
    principalType: 'ServicePrincipal'
  }
}
