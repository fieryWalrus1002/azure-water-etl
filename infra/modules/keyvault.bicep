// https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-bicep?toc=%2Fazure%2Fazure-resource-manager%2Fbicep%2Ftoc.json&tabs=CLI
// infra/modules/keyvault.bicep

// This one is actually reusable!
param keyVaultName string
param location string
param tenantId string


resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
  }
}
// Output the Key Vault URI so we can reference it in our Function App or other resources that need to access secrets.
output keyVaultId string = keyVault.id
output keyVaultUrl string = keyVault.properties.vaultUri
