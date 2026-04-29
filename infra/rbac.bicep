// // rbac.bicep

// // Grant access to YOU for local EDA (Skill #6: Security Guidelines)
// resource userStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(storageAccountName, principalId, roleDefinitionId)
//   scope: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
//     principalId: principalId
//     principalType: 'User'
//   }
// }

// // Grant access to the FUNCTION for the automated pipeline
// resource functionStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(storageAccountName, functionAppIdentityId, roleDefinitionId)
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
//     principalId: functionAppIdentityId
//     principalType: 'ServicePrincipal'
//   }
// }
