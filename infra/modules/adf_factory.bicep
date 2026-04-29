// adf_pipeline.bicep
param adfName string
param functionAppName string
param storageAccountName string

// // 1. Linked Service to Storage (Bronze/Silver/Gold)
resource adlsLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${adfName}/ls_adls_hydroflow'
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${storageAccountName}.dfs.core.windows.net'
    }
    // No keys. Uses the ADF Managed Identity. How cool is that?
  }
}

// // 2. Linked Service to Azure Function
// resource functionLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
//   name: '${adfName}/ls_func_transform'
//   properties: {
//     type: 'AzureFunction'
//     typeProperties: {
//       functionAppUrl: 'https://${functionAppName}.azurewebsites.net'
//       // Requires a Function Key, usually stored in Key Vault
//       functionKey: {
//         type: 'SecureString'
//         value: '{{REDACTED}}' 
//       }
//     }
//   }
// }

// // 3. The Data Pipeline (Skill #1)
// resource ingestPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
//   name: '${adfName}/pl_ingest_usgs'
//   properties: {
//     activities: [
//       {
//         name: 'Ingest_USGS_Raw'
//         type: 'Copy'
//         typeProperties: {
//           source: { type: 'RestSource' } // USGS API
//           sink: { type: 'BlobFSSink' }    // Bronze Layer
//         }
//       }
//       {
//         name: 'Transform_to_Silver'
//         type: 'AzureFunctionActivity'
//         dependsOn: [ { activity: 'Ingest_USGS_Raw', dependencyConditions: ['Succeeded'] } ]
//         typeProperties: {
//           functionName: 'silver_transform'
//           method: 'POST'
//           body: {
//             blobPath: 'bronze/streamflow_data.json'
//           }
//         }
//       }
//     ]
//   }
// }
